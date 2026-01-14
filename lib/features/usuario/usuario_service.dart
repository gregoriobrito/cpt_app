import 'dart:convert';
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
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Erro desconhecido');
    }
  }

  Future<Usuario> cadastrar(UsuarioCadastro request) async {
    final response = await _client.post("/usuario/cadastrar", body: request.toJson());
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return Usuario.fromJson(jsonBody);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Erro desconhecido');
    }
  }

  Future<Usuario> buscarLogin(int codigoRacha, String login) async {
    final response = await _client.get('/usuario/buscarLogin/$codigoRacha/$login');
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return Usuario.fromJson(jsonBody);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Erro desconhecido');
    }
  }

  Future<RachaUsuario> vincular(UsuarioVincular request) async {
    final response = await _client.post("/usuario/vincularRacha", body: request.toJson());
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return RachaUsuario.fromJson(jsonBody);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Erro desconhecido');
    }
  }

  Future<UsuarioVincular> desvincular(UsuarioVincular request) async {
    final response = await _client.post("/usuario/desvincularRacha", body: request.toJson());
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return UsuarioVincular.fromJson(jsonBody);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Erro desconhecido');
    }
  }

  Future<void> recuperarSenha(String email) async {
    final response = await _client.post("/usuario/recuperarSenha", body: {"email": email});
    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Erro ao enviar e-mail de recuperação');
    }
  }

  Future<void> alterarSenha(String senhaAtual, String novaSenha) async {
    final response = await _client.post(
      "/usuario/alterar_senha",
      body: {
        "senhaAtual": senhaAtual,
        "novaSenha": novaSenha,
      },
    );

    if (response.statusCode == 200) {
      return; // Sucesso
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['message'] ?? 'Erro ao alterar senha';
        throw Exception(message);
      } catch (e) {
        // Se vier HTML (erro 404/500 padrão do servidor) ou texto puro
        if (response.statusCode == 404) {
           throw Exception("Erro de conexão: Endpoint não encontrado (404). Reinicie o servidor Java.");
        }
        throw Exception(response.body.isNotEmpty ? response.body : 'Erro desconhecido ao alterar senha');
      }
    }
  }
}