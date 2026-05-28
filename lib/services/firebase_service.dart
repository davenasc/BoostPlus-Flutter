import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile.dart';
import '../models/vehicle.dart';
import '../models/maintenance.dart';
import '../models/category.dart';

class BackendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Autenticação (E-mail ou CPF)
  Future<UserCredential?> login(String emailOrCpf, String password) async {
    String emailToUse = emailOrCpf;
    
    // Se conter apenas números, vamos assumir que é CPF e buscar o e-mail associado
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

  // Obter Perfil Atual
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

  // 2. Streams de Veículos e Manutenções
  Stream<List<Vehicle>> getVehicles() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _db.collection('perfis').doc(user.uid).collection('veiculos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Vehicle.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<Maintenance>> getMaintenances(String veiculoId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _db
        .collection('perfis')
        .doc(user.uid)
        .collection('veiculos')
        .doc(veiculoId)
        .collection('manutencoes')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Maintenance.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  // 3. Obter Categoria pelo ID
  Future<Category?> getCategory(String categoriaId) async {
    final doc = await _db.collection('categorias').doc(categoriaId).get();
    if (doc.exists) {
      return Category.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  // 4. Atualizar Quilometragem do Veículo
  Future<void> atualizarOdometro(String veiculoId, int novoKm) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db
        .collection('perfis')
        .doc(user.uid)
        .collection('veiculos')
        .doc(veiculoId)
        .update({'km_atual': novoKm});
  }

  // 5. SEED (Popular o banco para testes)
  Future<void> seedDatabase() async {
    // Criar Usuário (Auth + Firestore)
    String uid = '';
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: 'davenasc@gmail.com',
        password: 'david123',
      );
      uid = userCredential.user!.uid;

      // Criar Profile
      await _db.collection('perfis').doc(uid).set({
        'nome': 'David Nascimento',
        'cpf': '12345678900',
        'email': 'davenasc@gmail.com',
        'tipo_usuario': 'Cliente',
      });

      // Criar Veículos e histórico apenas para a nova conta
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

      await veiculoCivicRef.collection('manutencoes').add({
        'id_categoria': 'cat_oleo',
        'id_mecanico': 'mecanico_x',
        'data_servico': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
        'km_no_servico': 35000,
        'especificacao_peca': 'Óleo 5W30',
        'validade_km': 10000,
        'validade_meses': 6,
        'observacoes': 'Trocado óleo e filtro.',
      });

      await veiculoCivicRef.collection('manutencoes').add({
        'id_categoria': 'cat_freio',
        'id_mecanico': 'mecanico_x',
        'data_servico': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 120))),
        'km_no_servico': 25000,
        'especificacao_peca': 'Pastilhas de cerâmica',
        'validade_km': 40000,
        'validade_meses': 24,
        'observacoes': 'Discos em bom estado.',
      });
    } catch (e) {
      // Ignora erro se o usuário já existe
      print('Usuário de teste já existe ou erro: $e');
    }

    // Apenas popule categorias se estiverem vazias
    final categoriasSnapshot = await _db.collection('categorias').limit(1).get();
    if (categoriasSnapshot.docs.isNotEmpty) return;

    // Criar categorias globais
    await _db.collection('categorias').doc('cat_oleo').set({
      'nome': 'Troca de Óleo',
      'descricao': 'Serviço de troca de óleo e filtro',
    });

    await _db.collection('categorias').doc('cat_freio').set({
      'nome': 'Freios',
      'descricao': 'Manutenção de pastilhas e discos',
    });

    await _db.collection('categorias').doc('cat_pneu').set({
      'nome': 'Pneus',
      'descricao': 'Troca ou rodízio de pneus',
    });
  }
}
