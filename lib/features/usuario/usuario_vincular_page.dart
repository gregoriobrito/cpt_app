import 'package:cpv_app/features/usuario/usuario_lista_page.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:cpv_app/features/usuario/usuario_vincular_model.dart';
import 'package:flutter/material.dart';

class UsuarioVincularPage extends StatefulWidget {
  final int codigoRacha;
  const UsuarioVincularPage({super.key, required this.codigoRacha});

  @override
  State<UsuarioVincularPage> createState() => _UsuarioVincularPageState();
}

class _UsuarioVincularPageState extends State<UsuarioVincularPage> {
  final _formKey = GlobalKey<FormState>();

  final _loginController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  void _confirmarVinculo(Usuario elemento) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Confirma vincular o usuário?'),
          content: Text(
            'Login: ${_loginController.text.toUpperCase()} \n'
            'Apelido: ${elemento.apelido} \n'
            'Nome: ${elemento.nome} \n',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // fecha o dialog
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.pop(context); // fecha o dialog

                try {
                  UsuarioVincular vincular = UsuarioVincular(
                    codigoUsuario: elemento.codigo,
                    codigoRacha: widget.codigoRacha,
                  );
                  await UsuarioService().vincular(vincular);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          UsuarioListaPage(codigoRacha: widget.codigoRacha),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuário vinculado com sucesso!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao vincular o usuário: $e')),
                  );
                }
              },
              child: const Text('Vincular'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final login = _loginController.text.trim();

      Usuario usuario = await UsuarioService().buscarLogin(
        widget.codigoRacha,
        login,
      );

      if (!mounted) return;

      _confirmarVinculo(usuario);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao cadastrar usuário: $e')));
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
        appBar: AppBar(title: const Text('Vincular Usuário')),
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

                // ---------- BOTÃO ----------
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _cadastrar,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Procurar'),
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