class Usuario {
  final int codigo;
  final String nome;
  final String? apelido;
  final String login;    
  final String? flagUsuarioAdmin;
  final String? flagImagem;

  Usuario({
    required this.codigo,
    required this.nome,
    this.apelido,
    required this.login,
    this.flagUsuarioAdmin,
    this.flagImagem
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      codigo: json['codigo'] as int,
      nome: json['nome'] as String,
      apelido: json['apelido'] as String?, 
      login: (json['login'] as String?) ?? '', 
      flagUsuarioAdmin: (json['flagUsuarioAdmin'] as String?) ?? '',
      flagImagem: (json['flagImagem'] as String?) ?? ''
    );
  }
}