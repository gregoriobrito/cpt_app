class Partida {
  final int codigo;
  final String identificador;

  Partida({
    required this.codigo,
    required this.identificador,
  });

  factory Partida.fromJson(Map<String, dynamic> json) {
    return Partida(
      codigo: json['codigo'] as int,
      identificador: json['identificador'] as String,
    );
  }
}
