import 'dart:async';
import 'package:flutter/foundation.dart' hide Category;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../models/profile.dart';
import '../models/vehicle.dart';
import '../models/maintenance.dart';
import '../models/category.dart';
import '../models/part.dart';
import 'part_calculator.dart';
import 'notification_service.dart';
import 'package:boost_plus/l10n/app_localizations.dart';

class BackendService {
  static final ValueNotifier<String?> selectedVehicleIdNotifier = ValueNotifier<String?>(null);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // login por email ou cpf
  Future<UserCredential?> login(String emailOrCpf, String password) async {
    String emailToUse = emailOrCpf;
    
    // se for so numero, assume que e cpf e pega o email
    final isCpf = RegExp(r'^\d+$').hasMatch(emailOrCpf);
    if (isCpf) {
      final querySnapshot = await _db.collection('perfis').where('cpf', isEqualTo: emailOrCpf).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        emailToUse = querySnapshot.docs.first.data()['email'];
      } else {
        throw Exception('CPF não encontrado.');
      }
    }

    return await _auth.signInWithEmailAndPassword(email: emailToUse, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // pega o perfil
  Stream<Profile?> get currentProfileStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _db.collection('perfis').doc(user.uid).get();
      if (doc.exists) {
        return Profile.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // busca os dados de veiculos e manutencoes
  Stream<List<Vehicle>> getVehicles() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    final controller = StreamController<List<Vehicle>>();

    // pega do cache antes
    final box = Hive.box<Vehicle>('vehicles');
    final cachedVehicles = box.values.where((v) => v.customerId == user.uid).toList();
    if (cachedVehicles.isNotEmpty) {
      controller.add(cachedVehicles);
    }

    // depois pega do firestore
    final subscription = _db
        .collection('perfis')
        .doc(user.uid)
        .collection('veiculos')
        .snapshots()
        .listen((snapshot) async {
      final vehicles = snapshot.docs.map((doc) {
        return Vehicle.fromFirestore(doc.data(), doc.id, customerId: user.uid);
      }).toList();

      // apaga do cache antigo
      final keysToDelete = box.keys.where((k) {
        final v = box.get(k);
        return v != null && v.customerId == user.uid;
      }).toList();
      for (final key in keysToDelete) {
        await box.delete(key);
      }

      // salva novos no cache
      for (final vehicle in vehicles) {
        await box.put(vehicle.id, vehicle);
      }

      if (!controller.isClosed) {
        controller.add(vehicles);
      }
    }, onError: (err) {
      if (!controller.isClosed) {
        controller.addError(err);
      }
    });

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  Stream<List<Maintenance>> getMaintenances(String veiculoId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    final controller = StreamController<List<Maintenance>>();

    // carrega do cache primeiro
    final box = Hive.box<Maintenance>('maintenances');
    final cached = box.values.where((m) => m.vehicleId == veiculoId).toList();
    if (cached.isNotEmpty) {
      cached.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
      controller.add(cached);
    }

    // depois pega do firestore
    final subscription = _db
        .collection('perfis')
        .doc(user.uid)
        .collection('veiculos')
        .doc(veiculoId)
        .collection('manutencoes')
        .orderBy('data_servico', descending: true)
        .snapshots()
        .listen((snapshot) async {
      final list = snapshot.docs.map((doc) {
        return Maintenance.fromFirestore(doc.data(), doc.id, vehicleId: veiculoId);
      }).toList();

      // apaga cache antigo
      final keysToDelete = box.keys.where((k) {
        final m = box.get(k);
        return m != null && m.vehicleId == veiculoId;
      }).toList();
      for (final key in keysToDelete) {
        await box.delete(key);
      }

      // salva novos no cache
      for (final maintenance in list) {
        await box.put(maintenance.id, maintenance);
      }

      if (!controller.isClosed) {
        controller.add(list);
      }
    }, onError: (err) {
      if (!controller.isClosed) {
        controller.addError(err);
      }
    });

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  // pega categoria
  Future<Category?> getCategory(String categoriaId) async {
    final doc = await _db.collection('categorias').doc(categoriaId).get();
    if (doc.exists) {
      return Category.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // atualiza a km do carro
  Future<void> atualizarOdometro(String veiculoId, int novoKm, {required AppLocalizations l10n}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // atualiza o cache na hora
    final box = Hive.box<Vehicle>('vehicles');
    final localVehicle = box.get(veiculoId);
    if (localVehicle != null) {
      final updatedVehicle = Vehicle(
        id: localVehicle.id,
        plate: localVehicle.plate,
        brand: localVehicle.brand,
        model: localVehicle.model,
        year: localVehicle.year,
        currentKm: novoKm,
        customerId: localVehicle.customerId,
      );
      await box.put(veiculoId, updatedVehicle);
    }

    await _db
        .collection('perfis')
        .doc(user.uid)
        .collection('veiculos')
        .doc(veiculoId)
        .update({'km_atual': novoKm});

    // busca as manutencoes para recalcular a saude das pecas
    List<Maintenance> history;
    try {
      final query = await _db
          .collection('perfis')
          .doc(user.uid)
          .collection('veiculos')
          .doc(veiculoId)
          .collection('manutencoes')
          .get();

      history = query.docs
          .map((doc) => Maintenance.fromFirestore(doc.data(), doc.id, vehicleId: veiculoId))
          .toList();
    } catch (e) {
      // se der erro ou tiver offline, pega do hive
      final box = Hive.box<Maintenance>('maintenances');
      history = box.values.where((m) => m.vehicleId == veiculoId).toList();
      history.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
    }

    try {
      final List<Part> parts = PartCalculator.calculatePartsStatus(history, novoKm);

      final notifiedBox = Hive.box<bool>('notified_parts');

      for (final part in parts) {
        final key = '${veiculoId}_${part.nameKey}';
        final hasBeenNotified = notifiedBox.get(key) ?? false;

        if (part.health <= 0.20) {
          if (!hasBeenNotified) {
            final percent = (part.health * 100).toInt();

            String readablePartName;
            switch (part.nameKey) {
              case 'partOilChange':
                readablePartName = l10n.partOilChange;
                break;
              case 'partBrakePads':
                readablePartName = l10n.partBrakePads;
                break;
              case 'partTires':
                readablePartName = l10n.partTires;
                break;
              case 'partBattery':
                readablePartName = l10n.partBattery;
                break;
              case 'partFilters':
                readablePartName = l10n.partFilters;
                break;
              case 'partCooling':
                readablePartName = l10n.partCooling;
                break;
              default:
                readablePartName = part.nameKey;
            }

            final vehicleName = localVehicle != null 
                ? '${localVehicle.brand} ${localVehicle.model}' 
                : 'Veículo';

            await NotificationService().showNotification(
              id: part.nameKey.hashCode,
              title: l10n.notificationTitle,
              body: l10n.notificationBody(readablePartName, vehicleName, percent.toString()),
            );

            await notifiedBox.put(key, true);
          }
        } else {
          // se a peca ta boa de novo, limpa a flag de avisado
          if (hasBeenNotified) {
            await notifiedBox.delete(key);
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar saúde das peças para notificações: $e');
    }
  }

  Stream<ProfileStats> getProfileStats() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(ProfileStats(vehicleCount: 0, serviceCount: 0));

    return getVehicles().asyncMap((vehicles) async {
      int totalServices = 0;
      for (final vehicle in vehicles) {
        final query = await _db
            .collection('perfis')
            .doc(user.uid)
            .collection('veiculos')
            .doc(vehicle.id)
            .collection('manutencoes')
            .get();
        totalServices += query.docs.length;
      }
      return ProfileStats(
        vehicleCount: vehicles.length,
        serviceCount: totalServices,
      );
    });
  }

  // cria um cliente
  Future<UserCredential?> cadastrarCliente(
      String nome, String cpf, String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = userCredential.user?.uid;
    if (uid != null) {
      await _db.collection('perfis').doc(uid).set({
        'nome': nome,
        'cpf': cpf,
        'email': email,
        'tipo_usuario': 'Cliente',
      });
    }
    return userCredential;
  }

  // cadastra um carro
  Future<Vehicle?> cadastrarVeiculo(
      String placa, String marca, String modelo, int ano, int kmAtual) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final docRef = _db
        .collection('perfis')
        .doc(user.uid)
        .collection('veiculos')
        .doc();

    final newVehicle = Vehicle(
      id: docRef.id,
      plate: placa,
      brand: marca,
      model: modelo,
      year: ano,
      currentKm: kmAtual,
      customerId: user.uid,
    );

    // envia pro firestore
    await docRef.set(newVehicle.toFirestore());

    // salva no hive
    final box = Hive.box<Vehicle>('vehicles');
    await box.put(newVehicle.id, newVehicle);

    // seleciona esse se nao tiver outro
    if (selectedVehicleIdNotifier.value == null) {
      selectedVehicleIdNotifier.value = newVehicle.id;
    }

    return newVehicle;
  }

  // atualiza perfil
  Future<void> atualizarPerfil(String nome, String cpf) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('perfis').doc(user.uid).update({
      'nome': nome,
      'cpf': cpf,
    });
  }

  // popula banco para teste
  Future<void> seedDatabase() async {
    // cria usuario de teste
    String uid = '';
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: 'davenasc@gmail.com',
        password: 'david123',
      );
      uid = userCredential.user!.uid;

      // salva dados do perfil
      await _db.collection('perfis').doc(uid).set({
        'nome': 'David Nascimento',
        'cpf': '12345678900',
        'email': 'davenasc@gmail.com',
        'tipo_usuario': 'Cliente',
      });
    } catch (e) {
      debugPrint('Usuário de teste já existe no Auth: $e');
      final querySnapshot = await _db.collection('perfis').where('email', isEqualTo: 'davenasc@gmail.com').limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        uid = querySnapshot.docs.first.id;
      }
    }

    if (uid.isNotEmpty) {
      // ve se ja tem veiculo
      final vehiclesQuery = await _db.collection('perfis').doc(uid).collection('veiculos').limit(1).get();
      if (vehiclesQuery.docs.isNotEmpty) {
        debugPrint('Usuário já possui veículos cadastrados. Pulando o seed do banco de dados.');
        return;
      }

      // cria veiculos de teste
      final veiculoCivicRef = _db.collection('perfis').doc(uid).collection('veiculos').doc('civic_id');
      await veiculoCivicRef.set({
        'placa': 'ABC-1234',
        'marca': 'Honda',
        'modelo': 'Civic',
        'ano': 2022,
        'km_atual': 45000,
      });

      final veiculoCorollaRef = _db.collection('perfis').doc(uid).collection('veiculos').doc('corolla_id');
      await veiculoCorollaRef.set({
        'placa': 'XYZ-9876',
        'marca': 'Toyota',
        'modelo': 'Corolla',
        'ano': 2020,
        'km_atual': 85000,
      });

      // deleta as velhas e insere as novas do Civic
      final civicManutencoes = await veiculoCivicRef.collection('manutencoes').get();
      for (final doc in civicManutencoes.docs) {
        await doc.reference.delete();
      }

      await veiculoCivicRef.collection('manutencoes').doc('os_civic_1').set({
        'id_mecanico': 'mecanico_x',
        'data_servico': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
        'km_no_servico': 35000,
        'observacoes': 'Troca periódica de fluidos e filtros recomendados na revisão de 35.000 KM.',
        'numero_os': 'OS-2026-001',
        'itens': [
          {
            'id_categoria': 'cat_oleo',
            'especificacao_peca': 'Óleo 5W30 Sintético',
            'validade_km': 10000,
            'validade_meses': 6,
          },
          {
            'id_categoria': 'cat_filtros',
            'especificacao_peca': 'Filtro de Óleo e Filtro de Ar do Motor',
            'validade_km': 10000,
            'validade_meses': 12,
          }
        ]
      });

      await veiculoCivicRef.collection('manutencoes').doc('os_civic_2').set({
        'id_mecanico': 'mecanico_x',
        'data_servico': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 120))),
        'km_no_servico': 25000,
        'observacoes': 'Revisão do sistema elétrico e substituição de pastilhas gastas.',
        'numero_os': 'OS-2026-002',
        'itens': [
          {
            'id_categoria': 'cat_freio',
            'especificacao_peca': 'Pastilhas de cerâmica Bosch',
            'validade_km': 40000,
            'validade_meses': 24,
          },
          {
            'id_categoria': 'cat_bateria',
            'especificacao_peca': 'Bateria Moura 60Ah',
            'validade_km': 50000,
            'validade_meses': 36,
          }
        ]
      });

      await veiculoCivicRef.collection('manutencoes').doc('os_civic_3').set({
        'id_mecanico': 'mecanico_y',
        'data_servico': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10))),
        'km_no_servico': 40000,
        'observacoes': 'Substituição preventiva de pneus e adição de aditivo de radiador.',
        'numero_os': 'OS-2026-003',
        'itens': [
          {
            'id_categoria': 'cat_pneu',
            'especificacao_peca': 'Pneus Michelin Primacy 4',
            'validade_km': 15000,
            'validade_meses': 12,
          },
          {
            'id_categoria': 'cat_arrefecimento',
            'especificacao_peca': 'Aditivo de Radiador Orgânico',
            'validade_km': 30000,
            'validade_meses': 24,
          }
        ]
      });

      // deleta as velhas e insere as novas do Corolla
      final corollaManutencoes = await veiculoCorollaRef.collection('manutencoes').get();
      for (final doc in corollaManutencoes.docs) {
        await doc.reference.delete();
      }

      await veiculoCorollaRef.collection('manutencoes').doc('os_corolla_1').set({
        'id_mecanico': 'mecanico_x',
        'data_servico': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15))),
        'km_no_servico': 80000,
        'observacoes': 'Troca de óleo, filtros gerais e pneus novos no alinhamento de 80.000 KM.',
        'numero_os': 'OS-2026-004',
        'itens': [
          {
            'id_categoria': 'cat_oleo',
            'especificacao_peca': 'Óleo 0W20 Toyota Sintético',
            'validade_km': 10000,
            'validade_meses': 6,
          },
          {
            'id_categoria': 'cat_filtros',
            'especificacao_peca': 'Filtro de Óleo, Combustível e Cabine',
            'validade_km': 10000,
            'validade_meses': 12,
          },
          {
            'id_categoria': 'cat_pneu',
            'especificacao_peca': 'Pneus Pirelli Cinturato P7',
            'validade_km': 20000,
            'validade_meses': 12,
          }
        ]
      });

      await veiculoCorollaRef.collection('manutencoes').doc('os_corolla_2').set({
        'id_mecanico': 'mecanico_z',
        'data_servico': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 150))),
        'km_no_servico': 75000,
        'observacoes': 'Troca preventiva dos componentes de freio dianteiros e traseiros.',
        'numero_os': 'OS-2026-005',
        'itens': [
          {
            'id_categoria': 'cat_freio',
            'especificacao_peca': 'Pastilhas e Discos de freio Fremax',
            'validade_km': 25000,
            'validade_meses': 24,
          }
        ]
      });

      await veiculoCorollaRef.collection('manutencoes').doc('os_corolla_3').set({
        'id_mecanico': 'mecanico_z',
        'data_servico': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 500))),
        'km_no_servico': 50000,
        'observacoes': 'Troca de bateria devido ao fim da vida útil e limpeza do arrefecimento.',
        'numero_os': 'OS-2026-006',
        'itens': [
          {
            'id_categoria': 'cat_bateria',
            'especificacao_peca': 'Bateria Heliar 60Ah',
            'validade_km': 40000,
            'validade_meses': 36,
          },
          {
            'id_categoria': 'cat_arrefecimento',
            'especificacao_peca': 'Limpeza completa e aditivo de arrefecimento',
            'validade_km': 30000,
            'validade_meses': 24,
          }
        ]
      });
    }

    // insere as categorias
    final Map<String, Map<String, String>> categoriasMap = {
      'cat_oleo': {
        'nome': 'Troca de Óleo',
        'descricao': 'Serviço de troca de óleo do motor',
      },
      'cat_freio': {
        'nome': 'Freios',
        'descricao': 'Manutenção de pastilhas e discos',
      },
      'cat_pneu': {
        'nome': 'Pneus',
        'descricao': 'Troca ou rodízio de pneus',
      },
      'cat_bateria': {
        'nome': 'Bateria',
        'descricao': 'Troca e teste de bateria',
      },
      'cat_filtros': {
        'nome': 'Filtros',
        'descricao': 'Substituição de filtros do veículo',
      },
      'cat_arrefecimento': {
        'nome': 'Arrefecimento',
        'descricao': 'Manutenção do sistema de arrefecimento e radiador',
      },
    };

    for (final entry in categoriasMap.entries) {
      await _db.collection('categorias').doc(entry.key).set({
        'nome': entry.value['nome'],
        'descricao': entry.value['descricao'],
      });
    }
  }
}

class ProfileStats {
  final int vehicleCount;
  final int serviceCount;
  ProfileStats({required this.vehicleCount, required this.serviceCount});
}
