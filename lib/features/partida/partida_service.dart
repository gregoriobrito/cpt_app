import 'dart:convert';

import '../../core/api_client.dart';
import 'partida_cadastrar_model.dart';
import 'partida_model.dart';

class PartidaService {
  final ApiClient _client = ApiClient();

  Future<Partida> cadastrar(PartidaCadastrar request) async {
    final response = await _client.post(
      "/partida",
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return Partida.fromJson(jsonBody);
    } else {
      throw Exception(
        "Erro ao cadastrar partida: ${response.statusCode} | ${response.body}",
      );
    }
  }
}
