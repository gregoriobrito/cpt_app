class Usuario {
  final int codigo;
  final String nome;
  final String? apelido;
  final String login;    

  Usuario({
    required this.codigo,
    required this.nome,
    this.apelido,
    required this.login,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      codigo: json['codigo'] as int,
      nome: json['nome'] as String,
      apelido: json['apelido'] as String?, 
      login: (json['login'] as String?) ?? '', 
    );
  }
}