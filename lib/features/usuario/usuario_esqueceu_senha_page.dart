import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart'; // Certifique-se que o import está correto

class UsuarioEsqueceuSenhaPage extends StatefulWidget {
  const UsuarioEsqueceuSenhaPage({Key? key}) : super(key: key);

  @override
  State<UsuarioEsqueceuSenhaPage> createState() => _UsuarioEsqueceuSenhaPageState();
}

class _UsuarioEsqueceuSenhaPageState extends State<UsuarioEsqueceuSenhaPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Cores do tema (iguais ao main.dart)
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);
  
  // Variáveis de estado
  bool _isLoading = false;

  // Controladores de Animação
  late AnimationController _lightsController;
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Configuração das animações de fundo
    _lightsController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    
    // Configuração da entrada do card
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _lightsController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _enviarRecuperacao() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Esconde o teclado
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // Chamada real ao serviço
      await UsuarioService().recuperarSenha(_emailController.text.trim());

      if (!mounted) return;

      // Sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail enviado! Verifique sua caixa de entrada.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Aguarda um pouco e volta para o login
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      // Erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: $e"), 
          backgroundColor: Colors.redAccent, 
          behavior: SnackBarBehavior.floating
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA), // Fundo Gelo
      body: Stack(
        children: [
          // --- Fundo Animado (Blobs) ---
          AnimatedBuilder(
            animation: _lightsController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: _buildLightBlob(const Color(0xFFE3F2FD), 300),
                  ),
                  Positioned(
                    top: size.height * 0.4,
                    left: -50,
                    child: _buildLightBlob(const Color(0xFFE1F5FE), 350),
                  ),
                ],
              );
            },
          ),

          // --- Conteúdo Principal ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone de Cadeado no topo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: _primaryBlue.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                        ]
                      ),
                      child: Icon(Icons.lock_reset_rounded, size: 50, color: _primaryBlue),
                    ),
                    
                    const SizedBox(height: 30),

                    // Animação de Entrada do Card
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: _buildCleanCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Text(
                                  "Recuperar Senha",
                                  style: TextStyle(
                                    color: _darkText,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Informe seu e-mail cadastrado para receber as instruções.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                
                                // Input de E-mail estilizado
                                _buildLightInput(
                                  controller: _emailController,
                                  label: 'E-mail',
                                  icon: Icons.email_outlined,
                                  inputType: TextInputType.emailAddress,
                                ),
                                
                                const SizedBox(height: 30),
                                
                                // Botão Gradiente
                                _buildGradientButton(),
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
        ],
      ),
    );
  }

  // --- Widgets Auxiliares (Mesmo Design System do Main) ---

  Widget _buildLightBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.8),
        boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 10)],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildCleanCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLightInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        style: TextStyle(color: _darkText, fontWeight: FontWeight.w600),
        cursorColor: _primaryBlue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: _primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primaryBlue, width: 1.5),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
          if (!value.contains('@')) return 'E-mail inválido';
          return null;
        },
      ),
    );
  }

  Widget _buildGradientButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _enviarRecuperacao,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [_primaryBlue, const Color(0xFF00B0FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: _primaryBlue.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text(
                  'ENVIAR LINK',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
        ),
      ),
    );
  }
}