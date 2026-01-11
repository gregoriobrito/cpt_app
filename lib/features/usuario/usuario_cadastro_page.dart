import 'dart:ui'; 
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cpv_app/features/usuario/usuario_cadastro_model.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';

class UsuarioCadastroPage extends StatefulWidget {
  const UsuarioCadastroPage({super.key});

  @override
  State<UsuarioCadastroPage> createState() => _UsuarioCadastroPageState();
}

class _UsuarioCadastroPageState extends State<UsuarioCadastroPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _loginController = TextEditingController();
  final _nomeController = TextEditingController();
  final _apelidoController = TextEditingController();
  final _senhaController = TextEditingController();

  // --- DESIGN SYSTEM (Igual Main.dart) ---
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);
  final Color _pastelBlue = const Color(0xFFE3F2FD);
  final Color _pastelCyan = const Color(0xFFE1F5FE);

  // Controladores de Animação
  late AnimationController _lightsController;
  late AnimationController _entranceAnimController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _obscureSenha = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    
    // Status Bar Dark Icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // 1. Animação das Luzes de Fundo
    _lightsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // 2. Animação de Entrada
    _entranceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = CurvedAnimation(
        parent: _entranceAnimController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut));
        
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceAnimController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));
            
    _entranceAnimController.forward();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _nomeController.dispose();
    _apelidoController.dispose();
    _senhaController.dispose();
    _entranceAnimController.dispose();
    _lightsController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final login = _loginController.text.trim().toUpperCase();
      final nome = _nomeController.text.trim();
      final apelido = _apelidoController.text.trim();
      final senha = _senhaController.text;

      UsuarioCadastro request = UsuarioCadastro(nome: nome, apelido: apelido, login: login, senha: senha);
      await UsuarioService().cadastrar(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conta criada! Faça login para continuar.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context); // Volta para o login
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor, // Fundo Claro
      body: Stack(
        children: [
          // --- CAMADA 1: FUNDO ANIMADO (Suave) ---
          AnimatedBuilder(
            animation: _lightsController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: size.height * 0.1,
                    left: size.width * 0.1 + (math.cos(_lightsController.value * 2 * math.pi) * 30),
                    child: _buildLightBlob(_pastelBlue, 300),
                  ),
                  Positioned(
                    top: size.height * 0.4,
                    right: size.width * -0.2,
                    child: _buildLightBlob(_pastelCyan, 350),
                  ),
                ],
              );
            },
          ),

          // --- CAMADA 2: CONTEÚDO ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    // 1. Header: Botão Voltar e Ícone
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back_ios_new, color: _darkText, size: 20),
                                const SizedBox(width: 8),
                                Text("Voltar", style: TextStyle(color: _darkText, fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                        
                        // Ícone com fundo azul suave
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: _primaryBlue.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)
                            ]
                          ),
                          child: Icon(Icons.person_add_alt_1_rounded, size: 30, color: _primaryBlue),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),

                    // 2. Título Animado
                    SizedBox(
                      height: 35,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'NOVA CONTA',
                            speed: const Duration(milliseconds: 100),
                            cursor: '_',
                            textStyle: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: _darkText, // Texto Escuro
                              fontFamily: 'Roboto',
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Card Branco Clean (Substituindo o Vidro Escuro)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: _primaryBlue.withOpacity(0.1), // Sombra Suave
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                _buildSectionLabel("PESSOAL"),
                                const SizedBox(height: 10),
                                
                                _buildModernInput(
                                  controller: _nomeController,
                                  label: "Nome Completo",
                                  icon: Icons.badge_outlined,
                                ),
                                const SizedBox(height: 16),
                                
                                _buildModernInput(
                                  controller: _apelidoController,
                                  label: "Apelido (Nome na quadra)",
                                  icon: Icons.sports_handball_outlined,
                                ),

                                const SizedBox(height: 24),
                                
                                _buildSectionLabel("ACESSO"),
                                const SizedBox(height: 10),

                                _buildModernInput(
                                  controller: _loginController,
                                  label: "Usuário / Login",
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 16),

                                _buildModernInput(
                                  controller: _senhaController,
                                  label: "Senha",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: _obscureSenha,
                                  onToggleVisibility: () => setState(() => _obscureSenha = !_obscureSenha),
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

  // --- WIDGETS ATUALIZADOS ---

  Widget _buildLightBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.6), // Mais opaco para o tema claro
        boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 10)],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade400, // Cinza suave
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // Input Moderno (Igual ao Login e Main)
  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor, // Fundo cinza clarinho
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: _darkText, fontWeight: FontWeight.w600),
        cursorColor: _primaryBlue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: _primaryBlue),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
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
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Obrigatório';
          if (isPassword && v.length < 3) return 'Muito curta';
          return null;
        },
      ),
    );
  }

  Widget _buildGradientButton() {
    return GestureDetector(
      onTap: _loading ? null : _cadastrar,
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
            BoxShadow(
              color: _primaryBlue.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: _loading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text(
                  'CADASTRAR',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.2
                  ),
                ),
        ),
      ),
    );
  }
}