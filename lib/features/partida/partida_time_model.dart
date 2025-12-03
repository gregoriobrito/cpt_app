import 'package:cpv_app/features/partida/partida_usuario_time_model.dart';

class PartidaTime {
  final List<PartidaUsuarioTime> listaUsuario;

  PartidaTime({
    required this.listaUsuario,
  });

  Map<String, dynamic> toJson() {
    return {
      "listaUsuario": listaUsuario.map((u) => u.toJson()).toList(),
    };
  }
}