class Racha {
  final int codigo;
  final String nome;

  Racha({
    required this.codigo,
    required this.nome,
  });

  factory Racha.fromJson(Map<String, dynamic> json) {
    return Racha(
      codigo: json['codigo'] as int,
      nome: json['nome'] as String,
    );
  }
}
