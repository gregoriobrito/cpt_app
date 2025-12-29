import 'dart:convert';
import 'dart:math';

import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/racha/racha_usuario_model.dart';
import 'package:cpv_app/features/usuario/usuario_cadastro_model.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/usuario/usuario_vincular_model.dart';

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

  Future<Usuario> cadastrar(UsuarioCadastro request) async {
    final response = await _client.post(
      "/usuario/cadastrar",
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return Usuario.fromJson(jsonBody);
    } else {
      throw Exception(
        "Erro ao atualizar pontos da partida: ${response.statusCode} | ${response.body}",
      );
    }
  }

  Future<Usuario> buscarLogin(int codigoRacha, String login) async {
    final response = await _client.get('/usuario/buscarLogin/$codigoRacha/$login');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return Usuario.fromJson(jsonBody);
    } else {
      throw Exception(
        'Erro ao buscar relatório: ${response.statusCode} | ${response.body}',
      );
    }
  }

  Future<RachaUsuario> vincular(UsuarioVincular request) async {
    final response = await _client.post(
      "/usuario/vincularRacha",
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return RachaUsuario.fromJson(jsonBody);
    } else {
      throw Exception(
        "Erro ao vincular usuario: ${response.statusCode} | ${response.body}",
      );
    }
  }

  Future<UsuarioVincular> desvincular(UsuarioVincular request) async {
    final response = await _client.post(
      "/usuario/desvincularRacha",
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return UsuarioVincular.fromJson(jsonBody);
    } else {
      throw Exception(
        "Erro ao vincular usuario: ${response.statusCode} | ${response.body}",
      );
    }
  }
}
