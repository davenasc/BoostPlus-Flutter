class Profile {
  final String id; // uid do Firebase Auth
  final String name;
  final String cpf;
  final String email;
  final String userType;

  Profile({
    required this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.userType,
  });

  factory Profile.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Profile(
      id: documentId,
      name: data['nome'] ?? '',
      cpf: data['cpf'] ?? '',
      email: data['email'] ?? '',
      userType: data['tipo_usuario'] ?? 'Cliente',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': name,
      'cpf': cpf,
      'email': email,
      'tipo_usuario': userType,
    };
  }
}
