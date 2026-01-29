class UsuarioAdministrador {
  final int codigoUsuario;
  final int codigoRacha;
  final String flagAdministrador;

  UsuarioAdministrador({
    required this.codigoUsuario,
    required this.codigoRacha,
    required this.flagAdministrador
  });

  factory UsuarioAdministrador.fromJson(Map<String, dynamic> json) {
    return UsuarioAdministrador(
      codigoUsuario: json['codigoUsuario'] as int, 
      codigoRacha: json['codigoRacha'] as int, 
      flagAdministrador: json['flagAdministrador'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      "codigoUsuario": codigoUsuario.toString(),
      "codigoRacha": codigoRacha.toString(),
      "flagAdministrador": flagAdministrador.toString()
    };
  }
}