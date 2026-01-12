import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Certifique-se de ter adicionado 'animated_text_kit' no pubspec.yaml
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/home/home_page.dart';
import 'package:cpv_app/features/usuario/usuario_cadastro_page.dart';
// import 'package:cpv_app/features/usuario/usuario_esqueceu_senha_page.dart'; // Descomente se criou esta página

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ponto a Ponto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light, 
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Fundo Gelo
        primaryColor: const Color(0xFF2979FF), // Azul Principal
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

  // Cores do Tema
  final Color _primaryBlue = const Color(0xFF2979FF); 
  final Color _darkText = const Color(0xFF1E2230); 

  // Controladores de Animação
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

    // Deixa a barra de status transparente (Imersão)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, 
    ));

    // Animação das Luzes de Fundo
    _lightsController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    
    // Animação de Entrada do Card
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _entryController.forward();

    // Animação do Ícone Pulando
    _bouncingIconController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
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

    final loginInput = _loginController.text.trim().toUpperCase();
    final senhaInput = _senhaController.text.trim();

    try {
      await ApiClient().login(username: loginInput, password: senhaInput);
      
      if (!mounted) return;
      
      // Navegação Suave para a Home
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      body: Stack(
        children: [
          // --- FUNDO ANIMADO COM LUZES ---
          AnimatedBuilder(
            animation: _lightsController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -50, right: -50,
                    child: _buildLightBlob(const Color(0xFFE3F2FD), 300), 
                  ),
                  Positioned(
                    top: size.height * 0.4, left: -50,
                    child: _buildLightBlob(const Color(0xFFE1F5FE), 350), 
                  ),
                  Positioned(
                    bottom: -50, right: -20,
                    child: _buildLightBlob(const Color(0xFFEDE7F6), 400), 
                  ),
                ],
              );
            },
          ),

          // --- CONTEÚDO ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO E TÍTULOS
                    _buildHeader(),
                    
                    const SizedBox(height: 40),
                    
                    // CARD DE LOGIN
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
                                  "Bem-vindo de volta",
                                  style: TextStyle(color: _darkText, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Acesse para gerenciar seus jogos",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                ),
                                const SizedBox(height: 30),
                                
                                // INPUT USUÁRIO
                                _buildLightInput(
                                  controller: _loginController,
                                  label: 'Usuário',
                                  icon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 20),
                                
                                // INPUT SENHA
                                _buildLightInput(
                                  controller: _senhaController,
                                  label: 'Senha',
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  obscureText: _obscurePassword,
                                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                
                                // ESQUECEU SENHA
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Se tiver a rota, descomente:
                                      // Navigator.pushNamed(context, '/esqueceu_senha');
                                    },
                                    child: Text(
                                      "Esqueceu a senha?",
                                      style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // BOTÃO ENTRAR
                                _buildGradientButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // RODAPÉ CRIAR CONTA
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

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader() {
    return Column(
      children: [
        // Ícone Animado
        AnimatedBuilder(
          animation: _bouncingIconController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -8 * math.sin(_bouncingIconController.value * math.pi)),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: _primaryBlue.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: Icon(Icons.sports_volleyball, size: 50, color: _primaryBlue),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        
        // TÍTULO: PONTO A PONTO
        SizedBox(
          height: 35,
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'PONTO A PONTO',
                speed: const Duration(milliseconds: 100),
                cursor: '|',
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: _darkText,
                  letterSpacing: 2.0,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
            isRepeatingAnimation: false,
          ),
        ),
        
        // SLOGAN: CADA PONTO CONTA!
        SizedBox(
          height: 30,
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Cada ponto conta!',
                speed: const Duration(milliseconds: 80),
                cursor: '_',
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
            pause: const Duration(milliseconds: 1200), // Espera o título terminar
            isRepeatingAnimation: false,
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
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
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
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
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
        validator: (value) => value == null || value.trim().isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  Widget _buildGradientButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _fazerLogin,
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
                  'ENTRAR',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
     return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Novo no time? ', style: TextStyle(color: Colors.grey.shade600)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsuarioCadastroPage())),
          child: Text(
            'Criar Conta',
            style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
} 