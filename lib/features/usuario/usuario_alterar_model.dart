class UsuarioAlterar {
    final String login;
    final String apelido;
    final String nome;

    UsuarioAlterar({
      required this.login,
      required this.apelido,
      required this.nome
    });

    factory UsuarioAlterar.fromJson(Map<String, dynamic> json) {
    return UsuarioAlterar(
      login: json['login'] as String, 
      apelido: json['apelido'] as String, 
      nome: json['nome'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      "login": login,
      "apelido": apelido,
      "nome": nome
    };
  }
}