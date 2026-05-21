import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @loginWelcome.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para acessar sua garagem'**
  String get loginSubtitle;

  /// No description provided for @loginUsername.
  ///
  /// In pt, this message translates to:
  /// **'USUÁRIO'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In pt, this message translates to:
  /// **'SENHA'**
  String get loginPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginSignIn;

  /// No description provided for @garageVehicleMaintenance.
  ///
  /// In pt, this message translates to:
  /// **'Manutenção de Veículos'**
  String get garageVehicleMaintenance;

  /// No description provided for @garageMyGarage.
  ///
  /// In pt, this message translates to:
  /// **'Minha Garagem'**
  String get garageMyGarage;

  /// No description provided for @garageOdometer.
  ///
  /// In pt, this message translates to:
  /// **'ODÔMETRO'**
  String get garageOdometer;

  /// No description provided for @garagePartStatus.
  ///
  /// In pt, this message translates to:
  /// **'Status das peças'**
  String get garagePartStatus;

  /// No description provided for @garageSeeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver tudo'**
  String get garageSeeAll;

  /// No description provided for @garageUpdateKm.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar KM'**
  String get garageUpdateKm;

  /// No description provided for @garageMaintenanceTips.
  ///
  /// In pt, this message translates to:
  /// **'DICAS DE MANUTENÇÃO'**
  String get garageMaintenanceTips;

  /// No description provided for @garageTips1.
  ///
  /// In pt, this message translates to:
  /// **'Verifique a pressão dos pneus a cada 15 dias.'**
  String get garageTips1;

  /// No description provided for @garageTips2.
  ///
  /// In pt, this message translates to:
  /// **'Troque o óleo do motor a cada 10.000 km.'**
  String get garageTips2;

  /// No description provided for @garageTips3.
  ///
  /// In pt, this message translates to:
  /// **'Verifique o nível do fluido de freio mensalmente.'**
  String get garageTips3;

  /// No description provided for @garageTips4.
  ///
  /// In pt, this message translates to:
  /// **'Faça o rodízio dos pneus para garantir um desgaste uniforme.'**
  String get garageTips4;

  /// No description provided for @partsAllParts.
  ///
  /// In pt, this message translates to:
  /// **'Todas as Peças'**
  String get partsAllParts;

  /// No description provided for @partRemaining.
  ///
  /// In pt, this message translates to:
  /// **'{km} km restantes'**
  String partRemaining(String km);

  /// No description provided for @partStatusOk.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get partStatusOk;

  /// No description provided for @partStatusWarning.
  ///
  /// In pt, this message translates to:
  /// **'ATENÇÃO'**
  String get partStatusWarning;

  /// No description provided for @historyMaintenanceHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de Manutenção'**
  String get historyMaintenanceHistory;

  /// No description provided for @historyTimeline.
  ///
  /// In pt, this message translates to:
  /// **'Linha do tempo de cada serviço'**
  String get historyTimeline;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileVehicles.
  ///
  /// In pt, this message translates to:
  /// **'Veículos'**
  String get profileVehicles;

  /// No description provided for @profileServices.
  ///
  /// In pt, this message translates to:
  /// **'Serviços'**
  String get profileServices;

  /// No description provided for @profileAccount.
  ///
  /// In pt, this message translates to:
  /// **'CONTA'**
  String get profileAccount;

  /// No description provided for @profileNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get profileNotifications;

  /// No description provided for @profilePrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get profilePrivacy;

  /// No description provided for @profileHelpSupport.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda e Suporte'**
  String get profileHelpSupport;

  /// No description provided for @profileLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get profileLanguage;

  /// No description provided for @profileSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get profileSignOut;

  /// No description provided for @langPt.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get langPt;

  /// No description provided for @langEn.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @langSelect.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o idioma'**
  String get langSelect;

  /// No description provided for @partOilChange.
  ///
  /// In pt, this message translates to:
  /// **'Óleo do motor'**
  String get partOilChange;

  /// No description provided for @partBrakePads.
  ///
  /// In pt, this message translates to:
  /// **'Freios'**
  String get partBrakePads;

  /// No description provided for @partTires.
  ///
  /// In pt, this message translates to:
  /// **'Pneus'**
  String get partTires;

  /// No description provided for @partBattery.
  ///
  /// In pt, this message translates to:
  /// **'Bateria'**
  String get partBattery;

  /// No description provided for @partFilters.
  ///
  /// In pt, this message translates to:
  /// **'Filtros'**
  String get partFilters;

  /// No description provided for @partCooling.
  ///
  /// In pt, this message translates to:
  /// **'Arrefecimento'**
  String get partCooling;

  /// No description provided for @navGarage.
  ///
  /// In pt, this message translates to:
  /// **'Garagem'**
  String get navGarage;

  /// No description provided for @navHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @dialogUpdateKmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar Quilometragem'**
  String get dialogUpdateKmTitle;

  /// No description provided for @dialogUpdateKmLastRecorded.
  ///
  /// In pt, this message translates to:
  /// **'Último registro: {km} km'**
  String dialogUpdateKmLastRecorded(String km);

  /// No description provided for @dialogUpdateKmDescription.
  ///
  /// In pt, this message translates to:
  /// **'Mantenha seu hodômetro atualizado para receber alertas precisos de manutenção.'**
  String get dialogUpdateKmDescription;

  /// No description provided for @dialogUpdateKmCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get dialogUpdateKmCancel;

  /// No description provided for @dialogUpdateKmSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get dialogUpdateKmSave;

  /// No description provided for @dialogUpdateKmError.
  ///
  /// In pt, this message translates to:
  /// **'Valor inválido ou menor que o atual.'**
  String get dialogUpdateKmError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
