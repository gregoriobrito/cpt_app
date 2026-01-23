class Racha {
  final int codigo;
  final String nome;
  final String? flagUsuarioAdmin;

  Racha({
    required this.codigo,
    required this.nome,
    this.flagUsuarioAdmin
  });

  factory Racha.fromJson(Map<String, dynamic> json) {
    return Racha(
      codigo: json['codigo'] as int,
      nome: json['nome'] as String,
      flagUsuarioAdmin: json['flagUsuarioAdmin'] != null ? json['flagUsuarioAdmin'] as String : null,
    );
  }
}
