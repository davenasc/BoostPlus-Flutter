// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginWelcome => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to access your garage';

  @override
  String get loginUsername => 'USERNAME';

  @override
  String get loginPassword => 'PASSWORD';

  @override
  String get loginSignIn => 'Sign In';

  @override
  String get garageVehicleMaintenance => 'Vehicle Maintenance';

  @override
  String get garageMyGarage => 'My Garage';

  @override
  String get garageOdometer => 'ODOMETER';

  @override
  String get garagePartStatus => 'Part Status';

  @override
  String get garageSeeAll => 'See All';

  @override
  String get garageUpdateKm => 'Update KM';

  @override
  String get garageMaintenanceTips => 'MAINTENANCE TIPS';

  @override
  String get garageTips1 => 'Check tire pressure every 15 days.';

  @override
  String get garageTips2 => 'Change engine oil every 10,000 km.';

  @override
  String get garageTips3 => 'Check brake fluid level monthly.';

  @override
  String get garageTips4 => 'Rotate tires to ensure even wear.';

  @override
  String get partsAllParts => 'All Parts';

  @override
  String partRemaining(String km) {
    return '$km km remaining';
  }

  @override
  String get partStatusOk => 'OK';

  @override
  String get partStatusWarning => 'WARNING';

  @override
  String get historyMaintenanceHistory => 'Maintenance History';

  @override
  String get historyTimeline => 'Timeline of every service';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileVehicles => 'Vehicles';

  @override
  String get profileServices => 'Services';

  @override
  String get profileAccount => 'ACCOUNT';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get langPt => 'Português';

  @override
  String get langEn => 'English';

  @override
  String get langSelect => 'Select language';

  @override
  String get partOilChange => 'Engine Oil';

  @override
  String get partBrakePads => 'Brakes';

  @override
  String get partTires => 'Tires';

  @override
  String get partBattery => 'Battery';

  @override
  String get partFilters => 'Filters';

  @override
  String get partCooling => 'Cooling';

  @override
  String get navGarage => 'Garage';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get dialogUpdateKmTitle => 'Update Kilometrage';

  @override
  String dialogUpdateKmLastRecorded(String km) {
    return 'Last recorded: $km km';
  }

  @override
  String get dialogUpdateKmDescription =>
      'Keep your odometer up to date to get accurate maintenance alerts.';

  @override
  String get dialogUpdateKmCancel => 'Cancel';

  @override
  String get dialogUpdateKmSave => 'Save';

  @override
  String get dialogUpdateKmError => 'Invalid value or less than current.';
}
