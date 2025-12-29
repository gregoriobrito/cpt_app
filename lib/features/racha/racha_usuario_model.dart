class RachaUsuario {
  final int codigo;
  final int codigoUsuario;
  final int codigoRacha;
  final int situacao;
  final String flagAdministrador;

  RachaUsuario({
    required this.codigo,
    required this.codigoUsuario,
    required this.codigoRacha,
    required this.situacao,
    required this.flagAdministrador
  });

  factory RachaUsuario.fromJson(Map<String, dynamic> json) {
    return RachaUsuario(
      codigo: json['codigo'] as int,
      codigoUsuario: json['codigoUsuario'] as int,
      codigoRacha: json['codigoRacha'] as int,
      situacao: json['situacao'] as int,
      flagAdministrador: json['flagAdministrador'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "codigo": codigo.toString(),
      "codigoUsuario": codigoUsuario.toString(),
      "codigoRacha": codigoRacha.toString(),
      "situacao": situacao.toString(),
      "flagAdministrador": flagAdministrador.toString()
    };
  }
}
