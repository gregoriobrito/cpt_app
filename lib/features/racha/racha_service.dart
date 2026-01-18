import 'dart:convert';
import 'package:cpv_app/features/usuario/usuario_model.dart';

import '../../core/api_client.dart';
import 'racha_model.dart';

class RachaService {
  final ApiClient _client = ApiClient();

  Future<List<Racha>> listarRacha() async {
    final response = await _client.get('/racha/v2'); // Ajuste a versão se necessário

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((e) => Racha.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao listar rachas: ${response.statusCode}');
  }

  Future<List<Usuario>> listarUsuario(int idRacha) async {
    final response = await _client.get('/racha/usuario/$idRacha');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erro ao listar usuários: ${response.statusCode}');
  }

  Future<Racha> get(int idRacha) async {
    final response = await _client.get('/racha/$idRacha');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return Racha.fromJson(jsonBody);
    } else {
      throw Exception("Erro ao buscar racha: ${response.statusCode}");
    }
  }

  Future<void> cadastrar(String nome) async {
    final response = await _client.post(
      '/racha/cadastrar', 
      body: {
        "nome": nome,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return; 
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['message'] ?? 'Erro ao criar o grupo';
        throw Exception(message);
      } catch (e) {
        throw Exception('Erro ao criar racha: ${response.statusCode}');
      }
    }
  }

  Future<void> deletar(int codigoRacha) async {
    final response = await _client.delete('/racha/$codigoRacha');

    if (response.statusCode == 200) {
      return;
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['message'] ?? 'Erro ao excluir o grupo';
        throw Exception(message);
      } catch (e) {
        throw Exception('Erro ${response.statusCode} ao excluir.');
      }
    }
  }
}
