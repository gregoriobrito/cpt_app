class PartidaPontoTimeDetalhe {
  final int idTime;
  final int pontos;

  PartidaPontoTimeDetalhe({
    required this.idTime,
    required this.pontos,
  });

  Map<String, dynamic> toJson() {
    return {
      "idTime": idTime.toString(),
      "pontos": pontos.toString()
    };
  }
}
