class Usuario {
  final int codigo;
  final String nome;
  final String? apelido;
  final String login;    
  final String? flagUsuarioAdmin;

  Usuario({
    required this.codigo,
    required this.nome,
    this.apelido,
    required this.login,
    this.flagUsuarioAdmin
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      codigo: json['codigo'] as int,
      nome: json['nome'] as String,
      apelido: json['apelido'] as String?, 
      login: (json['login'] as String?) ?? '', 
      flagUsuarioAdmin: (json['flagUsuarioAdmin'] as String?) ?? ''
    );
  }
}