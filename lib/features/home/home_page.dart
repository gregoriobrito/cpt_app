import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/partida/partida_racha_page.dart';
import 'package:cpv_app/features/racha/racha_page.dart';
import 'package:cpv_app/features/relatorio/relatorio_racha_page.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:cpv_app/main.dart'; // Para navegar de volta ao login se precisar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Future<String> _usuarioFuture;
  
  // --- DESIGN SYSTEM (Consistência com main.dart) ---
  final Color _backgroundColor = const Color(0xFFF5F7FA); // Branco Gelo
  final Color _primaryBlue = const Color(0xFF2979FF); // Azul Elétrico
  final Color _darkText = const Color(0xFF1E2230); // Texto Escuro
  
  // Animações
  late AnimationController _lightsController;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    // Status Bar escura para fundo claro
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _usuarioFuture = _buscarNomeUsuario();

    // Animação de Fundo
    _lightsController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    
    // Animação de Entrada em Cascata
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
  }

  Future<String> _buscarNomeUsuario() async {
    try {
      final usuario = await UsuarioService().buscar();
      if (usuario.apelido.isNotEmpty) return usuario.apelido;
      return usuario.nome.split(' ')[0];
    } catch (e) {
      return "Atleta";
    }
  }

  @override
  void dispose() {
    _lightsController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) async {
    await ApiClient().logout();
    if(mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (_) => const LoginPage()), 
        (r) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // --- FUNDO ANIMADO (Cores Pastéis Suaves) ---
          AnimatedBuilder(
            animation: _lightsController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(top: -50, right: -50, child: _buildLightBlob(const Color(0xFFE3F2FD), 300)), // Azul bebê
                  Positioned(top: size.height * 0.3, left: -60, child: _buildLightBlob(const Color(0xFFE1F5FE), 350)), // Ciano bebê
                  Positioned(bottom: -50, right: -20, child: _buildLightBlob(const Color(0xFFEDE7F6), 400)), // Roxo bebê
                ],
              );
            },
          ),

          // --- CONTEÚDO ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(12), 
                          boxShadow: [
                            BoxShadow(color: _primaryBlue.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))
                          ]
                        ),
                        child: Icon(Icons.dashboard_rounded, color: _primaryBlue),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.grey),
                        onPressed: () => _logout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  const Text("Olá, atleta", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  FutureBuilder<String>(
                    future: _usuarioFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox(height: 40);
                      return SizedBox(
                        height: 40,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              snapshot.data!.toUpperCase(),
                              speed: const Duration(milliseconds: 150),
                              textStyle: TextStyle(
                                fontSize: 32, 
                                fontWeight: FontWeight.w900, 
                                color: _darkText, 
                                fontFamily: 'Roboto'
                              ),
                            )
                          ],
                          isRepeatingAnimation: false,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 30),

                  // LISTA DE CARDS (Menu Principal)
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildMenuCard(0, "Meus Rachas", "Gerencie seus grupos", Icons.groups_rounded, const Color(0xFF2979FF), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RachaPage()))),
                        _buildMenuCard(1, "Nova Partida", "Iniciar jogo agora", Icons.sports_volleyball_rounded, const Color(0xFF00B0FF), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartidaRachaPage()))),
                        _buildMenuCard(2, "Estatísticas", "Seu desempenho", Icons.bar_chart_rounded, const Color(0xFFFF6D00), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RelatorioRachaPage()))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightBlob(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, 
        color: color.withOpacity(0.8), 
        boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 10)]
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), 
        child: Container(color: Colors.transparent)
      ),
    );
  }

  Widget _buildMenuCard(int index, String title, String subtitle, IconData icon, Color accentColor, VoidCallback onTap) {
    // Animação staggered (um entra depois do outro)
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _entranceController, curve: Interval(index * 0.2, 1.0, curve: Curves.easeOutCubic))
      ),
      child: FadeTransition(
        opacity: _entranceController,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            // Sombra Padrão Enterprise
            boxShadow: [
              BoxShadow(
                color: _primaryBlue.withOpacity(0.08), 
                blurRadius: 25, 
                offset: const Offset(0, 10)
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1), 
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Icon(icon, color: accentColor, size: 30),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText)),
                          const SizedBox(height: 4),
                          Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), shape: BoxShape.circle),
                      child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
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