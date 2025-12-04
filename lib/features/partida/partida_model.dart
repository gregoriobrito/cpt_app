import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/time/time_model.dart';

class Partida {
  final int codigo;
  final String identificador;
  final DateTime data;
  final Racha? racha;
  final List<Time>? listaTime;

  Partida({
    required this.codigo,
    required this.identificador,
    required this.data,
    this.racha,
    this.listaTime,
  });

  factory Partida.fromJson(Map<String, dynamic> json) {
    return Partida(
      codigo: json['codigo'] as int,
      identificador: json['identificador'] as String,
      data: DateTime.parse(json['data']),
      racha: json['racha'] != null ? Racha.fromJson(json['racha']) : null,
      listaTime: json['listaTime'] != null ? (json['listaTime'] as List).map((e) => Time.fromJson(e)).toList(): null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "codigo": codigo.toString(),
      "identificador": identificador.toString()
    };
  }
}
