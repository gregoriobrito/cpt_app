import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math' as math;
import 'core/api_client.dart';
import 'features/home/home_page.dart';
import 'features/usuario/usuario_cadastro_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controlar Pontos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020510),
        primaryColor: const Color(0xFF00E5FF),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  final _loginController = TextEditingController(); 
  final _senhaController = TextEditingController();

  final Color _cyanLight = const Color(0xFF00E5FF);
  final Color _purpleLight = const Color(0xFFD500F9);
  final Color _blueLight = const Color(0xFF2979FF);

  late AnimationController _lightsController;
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late AnimationController _bouncingIconController;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // 1. Luzes de Fundo
    _lightsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(); 

    // 2. Animação de Entrada
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _entryController.forward();

    _bouncingIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _loginController.dispose();
    _senhaController.dispose();
    _lightsController.dispose();
    _entryController.dispose();
    _bouncingIconController.dispose();
    super.dispose();
  }

  void _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));
    
    // Lógica de Login...
    
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF020510),
      body: Stack(
        children: [
          // --- CAMADA 1: LUZES ---
          AnimatedBuilder(
            animation: _lightsController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: size.height * 0.1 + (math.sin(_lightsController.value * 2 * math.pi) * 50),
                    left: size.width * 0.1 + (math.cos(_lightsController.value * 2 * math.pi) * 30),
                    child: _buildLightBlob(_purpleLight, 300),
                  ),
                  Positioned(
                    top: size.height * 0.4,
                    right: size.width * -0.2 + (math.sin(_lightsController.value * 2 * math.pi) * 60),
                    child: _buildLightBlob(_cyanLight, 350),
                  ),
                  Positioned(
                    bottom: -50,
                    left: size.width * 0.2 + (math.cos(_lightsController.value * 2 * math.pi) * 80),
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- CABEÇALHO ATUALIZADO (VÔLEI) ---
                    _buildHeader(),
                    
                    const SizedBox(height: 40),

                    // CARTÃO DE LOGIN
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: _buildPremiumGlassCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                const Text(
                                  "Bem-vindo, Jogador",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Gerencie seus rachas e partidas",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                _buildNeonInput(
                                  controller: _loginController,
                                  label: 'Usuário',
                                  icon: Icons.person_outline_rounded,
                                  keyboardType: TextInputType.text,
                                ),
                                
                                const SizedBox(height: 20),
                                
                                _buildNeonInput(
                                  controller: _senhaController,
                                  label: 'Senha',
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  obscureText: _obscurePassword,
                                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "Esqueceu a senha?",
                                      style: TextStyle(color: _cyanLight.withOpacity(0.8)),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
                                _buildGlowButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS PERSONALIZADOS ---

  // *** CABEÇALHO DE VÔLEI ***
  Widget _buildHeader() {
    return Column(
      children: [
        // Animação leve da bola flutuando (Bounce suave)
        AnimatedBuilder(
          animation: _bouncingIconController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -10 * math.sin(_bouncingIconController.value * math.pi)), // Movimento vertical
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: _cyanLight.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _cyanLight.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 2,
                    )
                  ]
                ),
                // ÍCONE DE VÔLEI
                child: Icon(
                  Icons.sports_volleyball, 
                  size: 54, 
                  color: Colors.white
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Efeito de Digitação "CONTROLAR PONTOS"
        SizedBox(
          height: 40,
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'CONTROLAR PONTOS',
                speed: const Duration(milliseconds: 100),
                cursor: '|',
                textStyle: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  fontFamily: 'Roboto',
                  shadows: [
                    Shadow(color: Color(0xFF00E5FF), blurRadius: 15)
                  ]
                ),
              ),
            ],
            isRepeatingAnimation: false,
            displayFullTextOnTap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildLightBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.6), color.withOpacity(0.0)],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }

  Widget _buildPremiumGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: -5,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: _cyanLight.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildNeonInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _cyanLight, width: 1.5),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Obrigatório';
          return null;
        },
      ),
    );
  }

  Widget _buildGlowButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _fazerLogin,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
               const Color(0xFF00E5FF),
               const Color(0xFF2979FF),
            ],
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
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text(
                  'ENTRAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
     return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Novo no time? ',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UsuarioCadastroPage()));
          },
          child: Text(
            'Cadastrar',
            style: TextStyle(
              color: _cyanLight,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: _cyanLight,
              shadows: [Shadow(color: _cyanLight, blurRadius: 10)]
            ),
          ),
        ),
      ],
    );
  }
}