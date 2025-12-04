import 'dart:convert';

import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';

class UsuarioService {
  final ApiClient _client = ApiClient();

  Future<Usuario> buscar() async {
    final response = await _client.get('/usuario');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return Usuario.fromJson(jsonBody);
    } else {
      throw Exception(
        'Erro ao buscar relatório: ${response.statusCode} | ${response.body}',
      );
    }
  }
}
