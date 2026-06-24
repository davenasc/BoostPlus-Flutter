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

  @override
  String get historyOS => 'Service Order';

  @override
  String historyOSWithNumber(String osNumber) {
    return 'Service Order #$osNumber';
  }

  @override
  String get historyOSDetails => 'OS Details';

  @override
  String historyMechanic(String mechanic) {
    return 'Mechanic: $mechanic';
  }

  @override
  String get historyReplacedParts => 'Parts & Services Replaced';

  @override
  String historyValidity(String km, String months) {
    return 'Validity: $km km or $months months';
  }

  @override
  String get historyNoVehicleSelected => 'No vehicle selected.';

  @override
  String get historyNoHistoryFound => 'No maintenance history found.';

  @override
  String get notificationTitle => 'Maintenance Alert ⚠️';

  @override
  String notificationBody(String partName, String vehicleName, String percent) {
    return 'The part \"$partName\" of your $vehicleName has only $percent% of remaining life. Schedule a service!';
  }

  @override
  String get loginNoAccount => 'Don\'t have an account? Sign Up';

  @override
  String get loginSignUp => 'Sign Up';

  @override
  String get signUpTitle => 'Create Account';

  @override
  String get signUpSubtitle => 'Fill in the details to register';

  @override
  String get signUpName => 'FULL NAME';

  @override
  String get signUpCpf => 'CPF (numbers only)';

  @override
  String get signUpEmail => 'EMAIL';

  @override
  String get signUpPassword => 'PASSWORD';

  @override
  String get signUpConfirmPassword => 'CONFIRM PASSWORD';

  @override
  String get signUpButton => 'Register';

  @override
  String get signUpPasswordMismatch => 'Passwords do not match.';

  @override
  String get signUpSuccess => 'Account created successfully!';

  @override
  String signUpError(String error) {
    return 'Error creating account: $error';
  }

  @override
  String get profileEditTitle => 'Edit Profile';

  @override
  String get profileEditName => 'Full Name';

  @override
  String get profileEditCpf => 'CPF';

  @override
  String get profileEditSave => 'Save';

  @override
  String get profileEditCancel => 'Cancel';

  @override
  String get garageAddVehicle => 'Add Vehicle';

  @override
  String get garageAddVehicleTitle => 'Register Vehicle';

  @override
  String get garageAddPlate => 'Plate (e.g. ABC-1234)';

  @override
  String get garageAddBrand => 'Brand';

  @override
  String get garageAddModel => 'Model';

  @override
  String get garageAddYear => 'Year';

  @override
  String get garageAddInitialKm => 'Current Mileage (Odometer)';

  @override
  String get garageAddSuccess => 'Vehicle registered successfully!';
}
