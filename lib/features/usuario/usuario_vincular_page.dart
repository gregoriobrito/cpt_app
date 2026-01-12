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

class _UsuarioVincularPageState extends State<UsuarioVincularPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  
  // Controladores de Animação
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    // Configuração da animação de entrada
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _confirmarVinculo(Usuario elemento) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 28),
              ),
              const SizedBox(width: 12),
              const Text('Encontramos!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Este é o jogador que você procura?", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              
              // Card do Jogador Encontrado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _primaryBlue.withOpacity(0.1),
                      child: Text(
                        elemento.nome[0].toUpperCase(),
                        style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            elemento.nome,
                            style: TextStyle(fontWeight: FontWeight.bold, color: _darkText, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          // CORREÇÃO: Uso correto do login que agora existe no model
                          Text(
                            "Login: ${elemento.login.toUpperCase()}", 
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
                          ),
                          // CORREÇÃO: Verificação de nulo no apelido
                          if (elemento.apelido != null && elemento.apelido!.isNotEmpty)
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
            ],
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCELAR', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              child: const Text('CONFIRMAR VÍNCULO'),
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
      Usuario usuario = await UsuarioService().buscarLogin(widget.codigoRacha, login);
      
      if (!mounted) return;
      _confirmarVinculo(usuario);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [Icon(Icons.error_outline, color: Colors.white), SizedBox(width: 10), Text('Usuário não encontrado')]),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
      );
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
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Buscar Jogador",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _darkText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Digite o login do usuário para encontrá-lo e adicioná-lo ao racha.",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                    ),
                    const SizedBox(height: 40),

                    // --- INPUT MODERNO ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10))],
                      ),
                      child: TextFormField(
                        controller: _loginController,
                        style: TextStyle(color: _darkText, fontWeight: FontWeight.w600, fontSize: 16),
                        cursorColor: _primaryBlue,
                        decoration: InputDecoration(
                          labelText: 'Login do usuário',
                          labelStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search_rounded, color: _primaryBlue),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _primaryBlue, width: 2)),
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
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _buscarUsuario,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
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
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('PROCURAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}