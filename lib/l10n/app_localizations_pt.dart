// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get loginWelcome => 'Bem-vindo de volta';

  @override
  String get loginSubtitle => 'Faça login para acessar sua garagem';

  @override
  String get loginUsername => 'USUÁRIO';

  @override
  String get loginPassword => 'SENHA';

  @override
  String get loginSignIn => 'Entrar';

  @override
  String get garageVehicleMaintenance => 'Manutenção de Veículos';

  @override
  String get garageMyGarage => 'Minha Garagem';

  @override
  String get garageOdometer => 'ODÔMETRO';

  @override
  String get garagePartStatus => 'Status das peças';

  @override
  String get garageSeeAll => 'Ver tudo';

  @override
  String get garageUpdateKm => 'Atualizar KM';

  @override
  String get garageMaintenanceTips => 'DICAS DE MANUTENÇÃO';

  @override
  String get garageTips1 => 'Verifique a pressão dos pneus a cada 15 dias.';

  @override
  String get garageTips2 => 'Troque o óleo do motor a cada 10.000 km.';

  @override
  String get garageTips3 => 'Verifique o nível do fluido de freio mensalmente.';

  @override
  String get garageTips4 =>
      'Faça o rodízio dos pneus para garantir um desgaste uniforme.';

  @override
  String get partsAllParts => 'Todas as Peças';

  @override
  String partRemaining(String km) {
    return '$km km restantes';
  }

  @override
  String get partStatusOk => 'OK';

  @override
  String get partStatusWarning => 'ATENÇÃO';

  @override
  String get historyMaintenanceHistory => 'Histórico de Manutenção';

  @override
  String get historyTimeline => 'Linha do tempo de cada serviço';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileVehicles => 'Veículos';

  @override
  String get profileServices => 'Serviços';

  @override
  String get profileAccount => 'CONTA';

  @override
  String get profileNotifications => 'Notificações';

  @override
  String get profilePrivacy => 'Privacidade';

  @override
  String get profileHelpSupport => 'Ajuda e Suporte';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileSignOut => 'Sair';

  @override
  String get langPt => 'Português';

  @override
  String get langEn => 'English';

  @override
  String get langSelect => 'Selecione o idioma';

  @override
  String get partOilChange => 'Óleo do motor';

  @override
  String get partBrakePads => 'Freios';

  @override
  String get partTires => 'Pneus';

  @override
  String get partBattery => 'Bateria';

  @override
  String get partFilters => 'Filtros';

  @override
  String get partCooling => 'Arrefecimento';

  @override
  String get navGarage => 'Garagem';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navProfile => 'Perfil';

  @override
  String get dialogUpdateKmTitle => 'Atualizar Quilometragem';

  @override
  String dialogUpdateKmLastRecorded(String km) {
    return 'Último registro: $km km';
  }

  @override
  String get dialogUpdateKmDescription =>
      'Mantenha seu hodômetro atualizado para receber alertas precisos de manutenção.';

  @override
  String get dialogUpdateKmCancel => 'Cancelar';

  @override
  String get dialogUpdateKmSave => 'Salvar';

  @override
  String get dialogUpdateKmError => 'Valor inválido ou menor que o atual.';
}
