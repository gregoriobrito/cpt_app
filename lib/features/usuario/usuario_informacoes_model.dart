class InformacoesUsuario {

  final int totalPartida;
  final int vitorias;
  final int pontos;

  InformacoesUsuario({
      required this.totalPartida,
      required this.vitorias,
      required this.pontos
  });

  factory InformacoesUsuario.fromJson(Map<String, dynamic> json) {
    return InformacoesUsuario(
      totalPartida: json['totalPartida'] as int,
      vitorias: json['vitorias'] as int,
      pontos: json['pontos'] as int
    );
  }

}