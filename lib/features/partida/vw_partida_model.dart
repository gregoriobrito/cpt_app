import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/time/time_model.dart';

class VwPartida {
  final int codigo;
  final int codigoRacha;
  final String identificadorTimeA;
  final int pontosTimeA;
  final String identificadorTimeB;
  final int pontosTimeB;
  final DateTime data;

  VwPartida({
    required this.codigo,
    required this.codigoRacha,
    required this.identificadorTimeA,
    required this.pontosTimeA,
    required this.identificadorTimeB,
    required this.pontosTimeB,
    required this.data,
  });

  factory VwPartida.fromJson(Map<String, dynamic> json) {
    return VwPartida(
      codigo: json['codigo'] as int,
      codigoRacha: json['codigoRacha'] as int,
      identificadorTimeA: json['identificadorTimeA'] as String,
      pontosTimeA: json['pontosTimeA'] as int,
      identificadorTimeB: json['identificadorTimeB'] as String,
      pontosTimeB: json['pontosTimeB'] as int,
      data: DateTime.parse(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "codigo": codigo.toString(),
      "codigoRacha": codigoRacha.toString(),
      "identificadorTimeA": identificadorTimeA.toString(),
      "pontosTimeA": pontosTimeA.toString(),
      "identificadorTimeB": identificadorTimeB.toString(),
      "pontosTimeB": pontosTimeB.toString(),
    };
  }
}
