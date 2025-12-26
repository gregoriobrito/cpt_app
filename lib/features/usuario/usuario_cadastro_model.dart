class UsuarioCadastro {
  final String nome;
  final String apelido;
  final String login;
  final String senha;

  UsuarioCadastro({
    required this.nome,
    required this.apelido,
    required this.login,
    required this.senha
  });

  factory UsuarioCadastro.fromJson(Map<String, dynamic> json) {
    return UsuarioCadastro(
      nome: json['nome'] as String,
      apelido: json['apelido'] as String,
      login: json['login'] as String,
      senha: json['senha'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nome": nome.toString(),
      "apelido": apelido.toString(),
      "login": login.toString(),
      "senha": senha.toString()
    };
  }
}
