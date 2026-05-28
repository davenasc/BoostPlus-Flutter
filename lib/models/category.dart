class Category {
  final String id;
  final String name;
  final String description;

  Category({required this.id, required this.name, required this.description});

  factory Category.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Category(
      id: documentId,
      name: data['nome'] ?? '',
      description: data['descricao'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': name,
      'descricao': description,
    };
  }
}
