import 'package:flutter/material.dart';
import 'package:boost_plus/l10n/app_localizations.dart';
import '../services/firebase_service.dart';
import '../widgets/boost_logo.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _backendService = BackendService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = l10n.signUpPasswordMismatch;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cleanCpf = _cpfController.text.replaceAll(RegExp(r'\D'), '');
      await _backendService.cadastrarCliente(
        _nameController.text.trim(),
        cleanCpf,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.signUpSuccess)),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = l10n.signUpError(e.toString().replaceAll(RegExp(r'^Exception: '), ''));
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                const BoostLogo(size: 64),
                  const SizedBox(height: 16),
                  Text(l10n.signUpTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(l10n.signUpSubtitle, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Nome Completo
                        Text(l10n.signUpName, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          validator: (value) => value == null || value.trim().isEmpty ? '' : null,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            errorStyle: const TextStyle(height: 0),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // CPF
                        Text(l10n.signUpCpf, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
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
                            prefixIcon: Icon(Icons.badge, color: colorScheme.primary),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            errorStyle: const TextStyle(height: 0),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // E-mail
                        Text(l10n.signUpEmail, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return '';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return '';
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            errorStyle: const TextStyle(height: 0),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Senha
                        Text(l10n.signUpPassword, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) => value == null || value.length < 6 ? '' : null,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                            errorStyle: const TextStyle(height: 0),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirmar Senha
                        Text(l10n.signUpConfirmPassword, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          validator: (value) => value == null || value.isEmpty ? '' : null,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
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

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(l10n.signUpButton),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
