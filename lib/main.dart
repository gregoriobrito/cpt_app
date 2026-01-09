import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Ice White
        primaryColor: const Color(0xFF2962FF), // Electric Blue
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1E2230)),
        ),
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
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  final Color _primaryBlue = const Color(0xFF2962FF);
  final Color _darkText = const Color(0xFF1E2230);

  late AnimationController _headerAnimController;
  late AnimationController _entranceController;
  late Animation<Alignment> _topAlign;
  late Animation<Alignment> _bottomAlign;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));

    _headerAnimController = AnimationController(vsync: this, duration: const Duration(seconds: 15));
    _topAlign = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
    ]).animate(_headerAnimController);
    _bottomAlign = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
    ]).animate(_headerAnimController);
    _headerAnimController.repeat();

    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _entranceController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      await ApiClient().login(username: _emailController.text.trim().toUpperCase(), password: _senhaController.text.trim());
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (_, __, ___) => const HomePage(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header Animado (Identidade Visual)
          AnimatedBuilder(
            animation: _headerAnimController,
            builder: (context, child) => Container(
              height: 350,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: const [Color(0xFF2962FF), Color(0xFF00B0FF), Color(0xFF1565C0)], begin: _topAlign.value, end: _bottomAlign.value),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(60), bottomRight: Radius.circular(60)),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo / Título
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10))]),
                    child: Icon(Icons.sports_volleyball_rounded, size: 50, color: _primaryBlue),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: AnimatedTextKit(
                      animatedTexts: [TypewriterAnimatedText('CONTROLAR PONTOS', speed: const Duration(milliseconds: 100), cursor: '|', textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2.0))],
                      isRepeatingAnimation: false,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Card de Login
                  FadeTransition(
                    opacity: _entranceController,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic)),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text("Bem-vindo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _darkText)),
                              const SizedBox(height: 30),
                              _buildInput(_emailController, "Usuário", Icons.person_outline),
                              const SizedBox(height: 20),
                              _buildInput(_senhaController, "Senha", Icons.lock_outline, isPassword: true),
                              const SizedBox(height: 30),
                              _buildButton("ENTRAR", _fazerLogin),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsuarioCadastroPage())),
                    child: Text("Criar nova conta", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller, obscureText: isPassword && _obscurePassword,
      style: TextStyle(color: _darkText, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, color: _primaryBlue),
        suffixIcon: isPassword ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true, fillColor: const Color(0xFFF5F7FA),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10, shadowColor: _primaryBlue.withOpacity(0.4),
        ),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }
}