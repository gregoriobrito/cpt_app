import 'dart:ui'; // Para o efeito de vidro (Blur)
import 'dart:math' as math; // Para as animações circulares
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

  // Cores do Tema "Vôlei Night"
  final Color _cyanLight = const Color(0xFF00E5FF);
  final Color _purpleLight = const Color(0xFFD500F9);
  final Color _blueLight = const Color(0xFF2979FF);

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
    
    // Configura a barra de status transparente
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // 1. Animação das Luzes de Fundo (Loop Infinito)
    _lightsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // 2. Animação de Entrada do Card (Fade + Slide)
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
      final login = _loginController.text.trim();
      final nome = _nomeController.text.trim();
      final apelido = _apelidoController.text.trim();
      final senha = _senhaController.text;

      UsuarioCadastro request = UsuarioCadastro(nome: nome, apelido: apelido, login: login, senha: senha);
      await UsuarioService().cadastrar(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conta criada com sucesso! Bem-vindo ao time.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context); // Volta para o login
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
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
      backgroundColor: const Color(0xFF020510), // Fundo Preto Azulado
      body: Stack(
        children: [
          // --- CAMADA 1: LUZES ANIMADAS (Fundo) ---
          AnimatedBuilder(
            animation: _lightsController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: size.height * 0.1,
                    left: size.width * 0.1 + (math.cos(_lightsController.value * 2 * math.pi) * 30),
                    child: _buildLightBlob(_purpleLight, 300),
                  ),
                  Positioned(
                    top: size.height * 0.4,
                    right: size.width * -0.2,
                    child: _buildLightBlob(_cyanLight, 350),
                  ),
                  Positioned(
                    bottom: -50,
                    left: size.width * 0.2,
                    child: _buildLightBlob(_blueLight, 400),
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
                    
                    // 1. Header: Botão Voltar e Ícone de Destaque
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const [
                                Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                                SizedBox(width: 8),
                                Text("Voltar", style: TextStyle(color: Colors.white70, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        
                        // Ícone Grande no Círculo Neon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(color: _cyanLight.withOpacity(0.5), width: 2),
                            boxShadow: [
                              BoxShadow(color: _cyanLight.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)
                            ]
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded, size: 32, color: Colors.white),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),

                    // 2. Título Animado (Typewriter)
                    SizedBox(
                      height: 35,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'NOVA CONTA',
                            speed: const Duration(milliseconds: 100),
                            cursor: '_',
                            textStyle: const TextStyle(
                              fontSize: 26, // Fonte Grande mantida
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              letterSpacing: 2.0,
                              shadows: [Shadow(color: Color(0xFF00E5FF), blurRadius: 15)]
                            ),
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Cartão de Vidro (Formulário)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildPremiumGlassCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                // Seção: Dados Pessoais
                                _buildSectionLabel("PESSOAL"),
                                const SizedBox(height: 10),
                                
                                _buildNeonInput(
                                  controller: _nomeController,
                                  label: "Nome Completo",
                                  icon: Icons.badge_outlined,
                                ),
                                const SizedBox(height: 12), // Espaço equilibrado
                                
                                _buildNeonInput(
                                  controller: _apelidoController,
                                  label: "Apelido (Nome na quadra)",
                                  icon: Icons.sports_handball_outlined,
                                ),

                                const SizedBox(height: 20),
                                
                                // Seção: Dados de Acesso
                                _buildSectionLabel("ACESSO"),
                                const SizedBox(height: 10),

                                _buildNeonInput(
                                  controller: _loginController,
                                  label: "Usuário / Login",
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 12),

                                _buildNeonInput(
                                  controller: _senhaController,
                                  label: "Senha",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: _obscureSenha,
                                  onToggleVisibility: () => setState(() => _obscureSenha = !_obscureSenha),
                                ),

                                const SizedBox(height: 24),

                                // Botão de Cadastro
                                _buildGlowButton(),
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

  // --- WIDGETS VISUAIS ---

  // 1. Bolhas de Luz (Fundo)
  Widget _buildLightBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.5), color.withOpacity(0.0)],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }

  // 2. Cartão de Vidro (Premium)
  Widget _buildPremiumGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Blur forte e bonito
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.10), // Reflexo superior
                Colors.white.withOpacity(0.02), // Mais transparente embaixo
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2), // Borda fina de vidro
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: -10,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: _cyanLight.withOpacity(0.1), // Glow sutil na borda
                blurRadius: 20,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // 3. Título de Seção (Pequeno e Neon)
  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _cyanLight.withOpacity(0.8),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // 4. Input Neon Moderno
  Widget _buildNeonInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        cursorColor: _cyanLight,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Padding confortável
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _cyanLight, width: 1.5),
          ),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
          if (isPassword && v.length < 4) return 'Mínimo 4 caracteres';
          return null;
        },
      ),
    );
  }

  // 5. Botão Grande com Brilho
  Widget _buildGlowButton() {
    return GestureDetector(
      onTap: _loading ? null : _cadastrar,
      child: Container(
        width: double.infinity,
        height: 54, // Altura padrão boa para o dedo
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [const Color(0xFF00E5FF), const Color(0xFF2979FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: _cyanLight.withOpacity(0.4),
              blurRadius: 20,
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
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1.5
                  ),
                ),
        ),
      ),
    );
  }
}