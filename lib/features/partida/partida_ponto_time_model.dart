import 'package:cpv_app/features/partida/partida_ponto_time_detalhe_model.dart';

class PartidaPontoTime {
  final List<PartidaPontoTimeDetalhe> lista;

  PartidaPontoTime({
    required this.lista
  });

  Map<String, dynamic> toJson() {
    return {
      "lista": lista.map((t) => t.toJson()).toList(),
    };
  }
}
