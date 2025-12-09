import 'dart:convert';

import 'package:cpv_app/features/partida/partida_ponto_time_model.dart';
import 'package:cpv_app/features/partida/vw_partida_model.dart';

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

  Future<Partida> burcar(int codigo) async {
    final response = await _client.get('/partida/$codigo');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return Partida.fromJson(jsonBody);
    } else {
      throw Exception(
        "Erro ao buscar partida: ${response.statusCode} | ${response.body}",
      );
    }
  }

  Future<List<Partida>> listarPartidas(int idRacha) async {
    final response = await _client.get('/partida/racha/$idRacha');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList
          .map((e) => Partida.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao listar rachas: ${response.statusCode}');
  }

  Future<Partida> atualizarPontos(PartidaPontoTime request) async {
    final response = await _client.post(
      "/partida/atualizarPonto",
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return Partida.fromJson(jsonBody);
    } else {
      throw Exception(
        "Erro ao atualizar pontos da partida: ${response.statusCode} | ${response.body}",
      );
    }
  }

  Future<List<VwPartida>> listarPartidasV2(int idRacha) async {
    final response = await _client.get('/partida/v2/racha/$idRacha');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList
          .map((e) => VwPartida.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao listar rachas: ${response.statusCode}');
  }
}
