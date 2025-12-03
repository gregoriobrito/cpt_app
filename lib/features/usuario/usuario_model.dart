class Usuario {
  final int codigo;
  final String nome;
  final String apelido;

  Usuario({
    required this.codigo,
    required this.nome,
    required this.apelido
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      codigo: json['codigo'] as int,
      nome: json['nome'] as String,
      apelido: json['apelido'] as String
    );
  }
}
