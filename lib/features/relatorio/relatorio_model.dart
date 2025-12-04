class Relatorio {
  final String nomeRelatorio;
  final List<GrupoResultado> lista;

  Relatorio({
    required this.nomeRelatorio,
    required this.lista,
  });

  factory Relatorio.fromJson(Map<String, dynamic> json) {
    return Relatorio(
      nomeRelatorio: json['nomeRelatorio'] as String,
      lista: (json['lista'] as List<dynamic>)
          .map((e) => GrupoResultado.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GrupoResultado {
  final String agrupador;
  final List<ItemResultado> listaResultado;

  GrupoResultado({
    required this.agrupador,
    required this.listaResultado,
  });

  factory GrupoResultado.fromJson(Map<String, dynamic> json) {
    return GrupoResultado(
      agrupador: json['agrupador'] as String,
      listaResultado: (json['listaResultado'] as List<dynamic>)
          .map((e) => ItemResultado.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ItemResultado {
  final String agrupador;
  final String apelido;
  final String nome;
  final int pontuacao;

  ItemResultado({
    required this.agrupador,
    required this.apelido,
    required this.nome,
    required this.pontuacao,
  });

  factory ItemResultado.fromJson(Map<String, dynamic> json) {
    return ItemResultado(
      agrupador: json['agrupador'] as String,
      apelido: json['apelido'] as String,
      nome: json['nome'] as String,
      pontuacao: (json['pontuacao'] as num).toInt(),
    );
  }
}
