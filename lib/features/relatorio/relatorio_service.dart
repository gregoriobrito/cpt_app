import 'dart:convert';

import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/relatorio/relatorio_model.dart';

class RelatorioService {
  final ApiClient _client = ApiClient();

  Future<Relatorio> buscarRelatorioGeral(int idRacha) async {
    // Exemplo de endpoint: /relatorio/geral/{idRacha}
    final response = await _client.get('/relatorio/geral/$idRacha');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return Relatorio.fromJson(jsonBody);
    } else {
      throw Exception(
        'Erro ao buscar relatório: ${response.statusCode} | ${response.body}',
      );
    }
  }

  Future<Relatorio> buscarRelatorioData(int idRacha) async {
    final response = await _client.get('/relatorio/data/$idRacha');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return Relatorio.fromJson(jsonBody);
    } else {
      throw Exception(
        'Erro ao buscar relatório: ${response.statusCode} | ${response.body}',
      );
    }
  }

  Future<Relatorio> buscarRelatorioMes(int idRacha) async {
    final response = await _client.get('/relatorio/mes/$idRacha');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return Relatorio.fromJson(jsonBody);
    } else {
      throw Exception(
        'Erro ao buscar relatório: ${response.statusCode} | ${response.body}',
      );
    }
  }

  Future<Relatorio> buscarRelatorioAno(int idRacha) async {
    final response = await _client.get('/relatorio/ano/$idRacha');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return Relatorio.fromJson(jsonBody);
    } else {
      throw Exception(
        'Erro ao buscar relatório: ${response.statusCode} | ${response.body}',
      );
    }
  }
}
