import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/usuario/usuario_lista_page.dart';
import 'racha_model.dart';
import 'racha_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class RachaPage extends StatefulWidget {
  const RachaPage({super.key});

  @override
  State<RachaPage> createState() => _RachaPageState();
}

class _RachaPageState extends State<RachaPage> with TickerProviderStateMixin {
  final _service = RachaService();
  late Future<List<Racha>> _future;

  // --- DESIGN SYSTEM (Padrão Clean) ---
  final Color _backgroundColor = const Color(0xFFF5F7FA); // Branco Gelo
  final Color _primaryBlue = const Color(0xFF2979FF); // Azul Elétrico
  final Color _darkText = const Color(0xFF1E2230); // Texto Escuro

  // Controlador de Animação da Lista
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    // Status Bar com ícones escuros (para fundo claro)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _future = _service.listarRacha();

    // Animação de Entrada em Cascata
    _listController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1000)
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  void _mostrarOpcoesRacha(Racha r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              
              // Cabeçalho do Modal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: _primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.shield_rounded, color: _primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Gerenciar Grupo", style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                          Text(r.nome, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              
              _buildModalItem(Icons.history_rounded, Colors.orange, "Histórico de Partidas", () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaHistoricoPage(racha: r)));
              }),
              if (r.flagUsuarioAdmin == "S")
              _buildModalItem(Icons.group_add_rounded, Colors.green, "Gerenciar Integrantes", () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => UsuarioListaPage(codigoRacha: r.codigo)));
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalItem(IconData icon, Color color, String text, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _darkText)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      
      // AppBar Clean
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Gerenciar", 
          style: TextStyle(color: _darkText, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)
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
            
            // Título Grande Animado
            SizedBox(
              height: 40,
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'MEUS RACHAS',
                    speed: const Duration(milliseconds: 100),
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _darkText,
                      fontFamily: 'Roboto',
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ),
            
            Text(
              "Toque em um grupo para ver opções",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            
            const SizedBox(height: 30),

            // Lista de Cards
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
                          Icon(Icons.sports_volleyball_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text("Nenhum grupo encontrado", style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
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
                      
                      // Cálculo da animação staggered (um por um)
                      final start = (index * 0.1).clamp(0.0, 0.8);
                      final end = (start + 0.4).clamp(0.0, 1.0);
                      final slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                        CurvedAnimation(parent: _listController, curve: Interval(start, end, curve: Curves.easeOutCubic))
                      );
                      final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(parent: _listController, curve: Interval(start, end, curve: Curves.easeOut))
                      );

                      return FadeTransition(
                        opacity: fadeAnim,
                        child: SlideTransition(
                          position: slideAnim,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryBlue.withOpacity(0.08), 
                                  blurRadius: 20, 
                                  offset: const Offset(0, 10)
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _mostrarOpcoesRacha(r),
                                borderRadius: BorderRadius.circular(24),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      // Ícone
                                      Container(
                                        height: 56, width: 56,
                                        decoration: BoxDecoration(
                                          color: _primaryBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Icon(Icons.shield_rounded, color: _primaryBlue, size: 30),
                                      ),
                                      const SizedBox(width: 20),
                                      
                                      // Textos
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(r.nome, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText)),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.circle, size: 8, color: Colors.green.shade400),
                                                const SizedBox(width: 6),
                                                Text("Ativo", style: TextStyle(fontSize: 12, color: Colors.grey.shade500))
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Ícone de Opções
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: const Color(0xFFF5F7FA), shape: BoxShape.circle),
                                        child: Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 20),
                                      ),
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