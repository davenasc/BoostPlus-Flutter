import 'package:flutter/material.dart';
import 'package:boost_plus/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_settings/app_settings.dart';
import '../services/firebase_service.dart';
import '../models/profile.dart';
import '../main.dart'; // precisa importar o main

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Em breve...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.langSelect,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Text('🇧🇷', style: TextStyle(fontSize: 24)),
                  title: Text(l10n.langPt),
                  onTap: () {
                    BoostPlusApp.setLocale(context, const Locale('pt', ''));
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  title: Text(l10n.langEn),
                  onTap: () {
                    BoostPlusApp.setLocale(context, const Locale('en', ''));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backendService = BackendService();

    final currentUser = FirebaseAuth.instance.currentUser;
    final defaultName = currentUser?.displayName ?? 'User Name';
    final defaultEmail = currentUser?.email ?? 'user@example.com';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Boost+', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(l10n.profileTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // cabecalho do perfil
          StreamBuilder<Profile?>(
            stream: backendService.currentProfileStream,
            builder: (context, snapshot) {
              final profile = snapshot.data;
              final name = profile?.name ?? defaultName;
              final email = profile?.email ?? defaultEmail;

              final initials = name.isNotEmpty
                  ? name.split(' ').map((e) => e.substring(0, 1)).take(2).join('').toUpperCase()
                  : 'B+';

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email,
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (profile != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                        onPressed: () {
                          _showEditProfileBottomSheet(context, profile);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // cards de metricas
          StreamBuilder<ProfileStats>(
            stream: backendService.getProfileStats(),
            builder: (context, snapshot) {
              final stats = snapshot.data;
              final vehicleCount = stats?.vehicleCount ?? 0;
              final serviceCount = stats?.serviceCount ?? 0;

              return Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$vehicleCount', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                          Text(l10n.profileVehicles, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$serviceCount', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                          Text(l10n.profileServices, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          Text(l10n.profileAccount, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          
          // menu de botoes
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildListTile(context, Icons.notifications, l10n.profileNotifications, onTap: () {
                  AppSettings.openAppSettings(type: AppSettingsType.notification);
                }),
                const Divider(height: 1),
                _buildListTile(context, Icons.security, l10n.profilePrivacy, onTap: () {
                  _showSoonSnackBar(context);
                }),
                const Divider(height: 1),
                _buildListTile(context, Icons.help, l10n.profileHelpSupport, onTap: () {
                  _showSoonSnackBar(context);
                }),
                const Divider(height: 1),
                _buildListTile(context, Icons.language, l10n.profileLanguage, onTap: () {
                  _showLanguageSelector(context);
                }),
                const Divider(height: 1),
                _buildListTile(context, Icons.logout, l10n.profileSignOut, onTap: () async {
                  await backendService.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }

  void _showEditProfileBottomSheet(BuildContext context, Profile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _EditProfileBottomSheet(profile: profile),
      ),
    );
  }
}

class _EditProfileBottomSheet extends StatefulWidget {
  final Profile profile;

  const _EditProfileBottomSheet({required this.profile});

  @override
  State<_EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cpfController;

  final _backendService = BackendService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _cpfController = TextEditingController(text: widget.profile.cpf);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cleanCpf = _cpfController.text.replaceAll(RegExp(r'\D'), '');
      await _backendService.atualizarPerfil(_nameController.text.trim(), cleanCpf);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll(RegExp(r'^Exception: '), '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                height: 6,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.person, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileEditTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Boost+',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nome Completo
            Text(l10n.profileEditName, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              validator: (value) => value == null || value.trim().isEmpty ? '' : null,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                errorStyle: const TextStyle(height: 0),
              ),
            ),
            const SizedBox(height: 16),

            // CPF
            Text(l10n.profileEditCpf, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cpfController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return '';
                final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                if (digitsOnly.length < 11) return '';
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.badge_outlined, color: colorScheme.primary),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                errorStyle: const TextStyle(height: 0),
              ),
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null) ...[
              Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      l10n.profileEditCancel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            l10n.profileEditSave,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

