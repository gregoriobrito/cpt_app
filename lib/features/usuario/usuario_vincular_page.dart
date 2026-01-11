import 'package:cpv_app/features/usuario/usuario_lista_page.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:cpv_app/features/usuario/usuario_vincular_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // --- DESIGN SYSTEM ---
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Encontramos!', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(elemento.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                          // CORREÇÃO: Usamos o controller já que o objeto Usuario não retorna o login na busca
                          Text(
                            "Login: ${_loginController.text.toUpperCase()}", 
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
                          ),
                          if (elemento.apelido.isNotEmpty)
                             Text(
                               "Apelido: ${elemento.apelido}", 
                               style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
                             ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text("Deseja vincular este atleta ao seu racha?"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  UsuarioVincular vincular = UsuarioVincular(
                    codigoUsuario: elemento.codigo,
                    codigoRacha: widget.codigoRacha,
                  );
                  await UsuarioService().vincular(vincular);

                  if(!mounted) return;
                  
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UsuarioListaPage(codigoRacha: widget.codigoRacha)));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atleta vinculado com sucesso!'), backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('VINCULAR AGORA'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _buscarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final login = _loginController.text.trim();
      // A busca retorna um objeto Usuario (sem o campo login explícito no retorno, mas temos o nome/apelido)
      Usuario usuario = await UsuarioService().buscarLogin(widget.codigoRacha, login);
      
      if (!mounted) return;
      _confirmarVinculo(usuario);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não encontrado'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          title: Text('ADICIONAR ATLETA', style: TextStyle(color: _darkText, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: _darkText),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UsuarioListaPage(codigoRacha: widget.codigoRacha))),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Buscar Jogador",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Digite o login do usuário para encontrá-lo.",
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 30),

                // --- INPUT MODERNO ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
                  ),
                  child: TextFormField(
                    controller: _loginController,
                    style: TextStyle(color: _darkText, fontWeight: FontWeight.w600),
                    cursorColor: _primaryBlue,
                    decoration: InputDecoration(
                      labelText: 'Login do usuário',
                      labelStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search_rounded, color: _primaryBlue),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _primaryBlue, width: 1.5)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => _buscarUsuario(),
                    validator: (v) => v == null || v.isEmpty ? 'Informe o login' : null,
                  ),
                ),

                const SizedBox(height: 30),

                // --- BOTÃO GRADIENTE ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _buscarUsuario,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 10,
                      shadowColor: _primaryBlue.withOpacity(0.4),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_primaryBlue, const Color(0xFF00B0FF)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: _loading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('PROCURAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                      ),
                    ),
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