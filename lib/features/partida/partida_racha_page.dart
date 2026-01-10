import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cpv_app/features/partida/partida_usuario_page.dart';
import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/racha/racha_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class PartidaRachaPage extends StatefulWidget {
  const PartidaRachaPage({super.key});

  @override
  State<PartidaRachaPage> createState() => _PartidaRachaPageState();
}

class _PartidaRachaPageState extends State<PartidaRachaPage> with SingleTickerProviderStateMixin {
  final _service = RachaService();
  late Future<List<Racha>> _future;
  late AnimationController _controller;

  // --- DESIGN SYSTEM ---
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);

  @override
  void initState() {
    super.initState();
    // Status Bar Dark
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    _future = _service.listarRacha();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER CLEAN ---
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 18, color: _darkText),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text("Nova Partida", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                ],
              ),
              const SizedBox(height: 30),
              
              // Título Animado
              SizedBox(
                height: 40,
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'ESCOLHA O RACHA',
                      speed: const Duration(milliseconds: 100),
                      textStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: _darkText,
                        letterSpacing: 1.5,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                  isRepeatingAnimation: false,
                ),
              ),
              const SizedBox(height: 20),

              // --- LISTA ---
              Expanded(
                child: FutureBuilder<List<Racha>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    
                    final rachas = snapshot.data ?? [];
                    if (rachas.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.groups_outlined, size: 60, color: Colors.grey.shade300),
                            const Text("Nenhum racha encontrado", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: rachas.length,
                      itemBuilder: (context, index) {
                        final r = rachas[index];
                        
                        // Animação de entrada
                        final animation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                          CurvedAnimation(parent: _controller, curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic)),
                        );

                        return SlideTransition(
                          position: animation,
                          child: FadeTransition(
                            opacity: _controller,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryBlue.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaUsuarioPage(codigoRacha: r.codigo))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: _primaryBlue.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.stadium_rounded, color: _primaryBlue),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(r.nome, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText)),
                                              const SizedBox(height: 4),
                                              Text("Toque para iniciar", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}