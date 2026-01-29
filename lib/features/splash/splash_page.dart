import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Certifique-se de ter este pacote
import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/racha/racha_page.dart';
import 'package:cpv_app/main.dart'; // Importe onde está sua LoginPage

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  // Controlador para o fundo animado
  late AnimationController _lightsController;

  @override
  void initState() {
    super.initState();
    
    // Configura Imersão (Barra transparente)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // 1. Configura animação da Logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // 2. Configura animação do Fundo (Luzes)
    _lightsController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 10)
    )..repeat(reverse: true);

    _controller.forward();

    // 3. Inicia verificação de login
    _verificarLoginEProsseguir();
  }

  Future<void> _verificarLoginEProsseguir() async {
    // Garante que a animação da logo seja vista por pelo menos 3 segundos
    final minDuration = Future.delayed(const Duration(seconds: 3));
    
    // Inicializa API e verifica token
    final apiClient = ApiClient();
    await apiClient.init();
    
    bool tokenValido = false;
    
    // Lógica de verificação do Token JWT
    if (apiClient.token != null && apiClient.token!.isNotEmpty) {
      if (!JwtDecoder.isExpired(apiClient.token!)) {
        tokenValido = true;
      }
    }

    // Espera o tempo da animação terminar
    await minDuration;

    if (!mounted) return;

    // Navegação com transição suave (Fade)
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => tokenValido ? const RachaPage() : const LoginPage(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _lightsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fundo Gelo
      body: Stack(
        children: [
          // --- 1. FUNDO ANIMADO (Igual ao da Home/RachaPage) ---
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
                    top: size.height * 0.4, left: -60,
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

          // --- 2. CONTEÚDO CENTRAL (LOGO) ---
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Container da Logo com Sombra e Borda
                        Container(
                          width: 180, 
                          height: 180,
                          padding: const EdgeInsets.all(4), // Borda branca fina
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2979FF).withOpacity(0.25),
                                blurRadius: 50,
                                offset: const Offset(0, 20),
                                spreadRadius: 5
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logoapp.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Texto do App
                        const Text(
                          "PONTO A PONTO",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E2230),
                            letterSpacing: 2.5,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Loading Discreto
                        const SizedBox(
                          width: 20, 
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF2979FF),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para as luzes de fundo
  Widget _buildLightBlob(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: color, 
            blurRadius: 60, 
            spreadRadius: 10
          )
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}