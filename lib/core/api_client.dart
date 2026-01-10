import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient._internal();

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final String baseUrl = 'https://trihydric-freeman-ungesticular.ngrok-free.dev';

  String? _token;

  static const _tokenKey = 'jwt_token';

  Future<void> init() async {
    // Carrega token salvo (se existir)
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  bool get isLogged => _token != null;

  String? get token => _token;

  /// ----------- LOGIN (POST /login) -----------
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Seu backend retorna { "token": "..." }
      final token = json['token'] as String?;
      if (token == null) {
        throw Exception('Resposta sem token');
      }

      await _saveToken(token);
    } else if (response.statusCode == 401) {
      throw Exception('Usuário ou senha inválidos');
    } else {
      throw Exception('Erro ao fazer login: ${response.statusCode}');
    }
  }

  /// ----------- MÉTODOS GENÉRICOS GET/POST/etc -----------
  Map<String, String> _defaultHeaders({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    if (extra != null) {
      headers.addAll(extra);
    }

    return headers;
  }

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    final response = await http.get(
      uri,
      headers: _defaultHeaders(extra: headers),
    );

    _checkAuthError(response);
    return response;
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.post(
      uri,
      headers: _defaultHeaders(extra: headers),
      body: body != null ? jsonEncode(body) : null,
    );

    _checkAuthError(response);
    return response;
  }

  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.put(
      uri,
      headers: _defaultHeaders(extra: headers),
      body: body != null ? jsonEncode(body) : null,
    );

    _checkAuthError(response);
    return response;
  }

  Future<http.Response> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.delete(
      uri,
      headers: _defaultHeaders(extra: headers),
      body: body != null ? jsonEncode(body) : null,
    );

    _checkAuthError(response);
    return response;
  }

  void _checkAuthError(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      // Aqui você pode, por exemplo, fazer logout automático
      // ou sinalizar para o app que precisa logar novamente
    }
  }
}
