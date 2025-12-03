import 'package:cpv_app/features/partida/partida_time_model.dart';

class PartidaCadastrar {
  final int codigoRacha;
  final List<PartidaTime> listaTime;

  PartidaCadastrar({
    required this.codigoRacha,
    required this.listaTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "codigoRacha": codigoRacha.toString(),
      "listaTime": listaTime.map((t) => t.toJson()).toList(),
    };
  }
}
