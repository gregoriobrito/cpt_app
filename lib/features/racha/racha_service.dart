import 'dart:convert';
import '../../core/api_client.dart';
import 'racha_model.dart';

class RachaService {
  final ApiClient _client = ApiClient();

  /// GET /racha
  Future<List<Racha>> listarRacha() async {
    final response = await _client.get('/racha');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList
          .map((e) => Racha.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao listar rachas: ${response.statusCode}');
  }
}
