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

  // --- DESIGN SYSTEM (Padrão Clean) ---
  final Color _backgroundColor = const Color(0xFFF5F7FA); // Branco Gelo
  final Color _primaryBlue = const Color(0xFF2979FF); // Azul Elétrico
  final Color _darkText = const Color(0xFF1E2230); // Texto Escuro

  @override
  void initState() {
    super.initState();
    // Status Bar Escura (para fundo claro)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    _future = _service.listarRacha();
    
    // Animação de entrada da lista
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
      // AppBar Simples e Limpa
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Nova Partida",
          style: TextStyle(
            color: _darkText, 
            fontWeight: FontWeight.w900, 
            fontSize: 16, 
            letterSpacing: 1.2
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // Título Principal
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
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ),
            
            Text(
              "Selecione o grupo para iniciar o jogo",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            
            const SizedBox(height: 30),

            // --- LISTA DE RACHAS (Cards Brancos) ---
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
                          const SizedBox(height: 16),
                          Text("Nenhum racha encontrado", style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: rachas.length,
                    separatorBuilder: (_,__) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final r = rachas[index];
                      
                      // Animação de entrada item por item
                      final animation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                        CurvedAnimation(parent: _controller, curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutCubic)),
                      );

                      return SlideTransition(
                        position: animation,
                        child: FadeTransition(
                          opacity: _controller,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaUsuarioPage(codigoRacha: r.codigo))),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      // Ícone em Destaque
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: _primaryBlue.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.stadium_rounded, color: _primaryBlue, size: 28),
                                      ),
                                      const SizedBox(width: 20),
                                      
                                      // Textos
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(r.nome, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText)),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.play_circle_fill, size: 14, color: Colors.green.shade400),
                                                const SizedBox(width: 4),
                                                Text("Toque para jogar", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Seta
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
    );
  }
}