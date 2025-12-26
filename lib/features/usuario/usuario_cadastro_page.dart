import 'package:cpv_app/features/usuario/usuario_cadastro_model.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:flutter/material.dart';

class UsuarioCadastroPage extends StatefulWidget {
  const UsuarioCadastroPage({super.key});

  @override
  State<UsuarioCadastroPage> createState() => _UsuarioCadastroPageState();
}

class _UsuarioCadastroPageState extends State<UsuarioCadastroPage> {
  final _formKey = GlobalKey<FormState>();

  final _loginController = TextEditingController();
  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _obscureSenha = true;
  bool _loading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _nomeController.dispose();
    _apelidoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final login = _loginController.text.trim();
      final nome = _nomeController.text.trim();
      final apelido = _apelidoController.text.trim();
      final senha = _senhaController.text;

      UsuarioCadastro request = UsuarioCadastro(nome: nome, apelido: apelido, login: login, senha: senha);
      await UsuarioService().cadastrar(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário cadastrado com sucesso'),
        ),
      );

      Navigator.pop(context); // volta pra tela anterior
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar usuário: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // fecha teclado
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cadastrar Usuário'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ---------- LOGIN ----------
                TextFormField(
                  controller: _loginController,
                  decoration: const InputDecoration(
                    labelText: 'Login',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe o login' : null,
                ),

                const SizedBox(height: 16),

                // ---------- NOME ----------
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe o nome' : null,
                ),

                const SizedBox(height: 16),

                // ---------- APELIDO ----------
                TextFormField(
                  controller: _apelidoController,
                  decoration: const InputDecoration(
                    labelText: 'Apelido',
                    prefixIcon: Icon(Icons.tag),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe o apelido' : null,
                ),

                const SizedBox(height: 16),

                // ---------- SENHA ----------
                TextFormField(
                  controller: _senhaController,
                  obscureText: _obscureSenha,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureSenha
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureSenha = !_obscureSenha;
                        });
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Informe a senha';
                    }
                    if (v.length < 4) {
                      return 'Senha muito curta';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // ---------- BOTÃO ----------
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _cadastrar,
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
