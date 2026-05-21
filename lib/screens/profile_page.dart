import 'package:flutter/material.dart';
import 'package:boost_plus/l10n/app_localizations.dart';
import '../main.dart'; // Import to use BoostPlusApp.setLocale

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('B+', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('user@example.com', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
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
                      const Text('2', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
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
                      const Text('15', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                      Text(l10n.profileServices, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.profileAccount, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                _buildListTile(context, Icons.notifications, l10n.profileNotifications),
                const Divider(height: 1),
                _buildListTile(context, Icons.security, l10n.profilePrivacy),
                const Divider(height: 1),
                _buildListTile(context, Icons.help, l10n.profileHelpSupport),
                const Divider(height: 1),
                _buildListTile(context, Icons.language, l10n.profileLanguage, onTap: () {
                  _showLanguageSelector(context);
                }),
                const Divider(height: 1),
                _buildListTile(context, Icons.logout, l10n.profileSignOut, onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
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
}

