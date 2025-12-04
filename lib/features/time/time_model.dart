class Time {
  final int codigo;
  final String identificador;
  final int pontuacao;
  
  Time({
    required this.codigo,
    required this.identificador,
    required this.pontuacao
  });

  factory Time.fromJson(Map<String, dynamic> json) {
    return Time(
      codigo: json['codigo'] as int,
      identificador: json['identificador'] as String,
      pontuacao: json['pontuacao'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "codigo": codigo.toString(),
      "identificador": identificador.toString(),
      "pontuacao": pontuacao.toString(),
    };
  }
}
