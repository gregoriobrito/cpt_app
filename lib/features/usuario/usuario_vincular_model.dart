class UsuarioVincular {
  final int codigoUsuario;
  final int codigoRacha;

  UsuarioVincular({
    required this.codigoUsuario,
    required this.codigoRacha
  });

  factory UsuarioVincular.fromJson(Map<String, dynamic> json) {
    return UsuarioVincular(
      codigoUsuario: json['codigoUsuario'] as int,
      codigoRacha: json['codigoRacha'] as int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "codigoUsuario": codigoUsuario.toString(),
      "codigoRacha": codigoRacha.toString()
    };
  }
}
