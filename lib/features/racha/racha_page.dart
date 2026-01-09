import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/usuario/usuario_lista_page.dart';
import 'racha_model.dart';
import 'racha_service.dart';
// Certifique-se de ter 'animated_text_kit' no pubspec.yaml
import 'package:animated_text_kit/animated_text_kit.dart';

class RachaPage extends StatefulWidget {
  const RachaPage({super.key});

  @override
  State<RachaPage> createState() => _RachaPageState();
}

class _RachaPageState extends State<RachaPage> with TickerProviderStateMixin {
  final _service = RachaService();
  late Future<List<Racha>> _future;

  // Controladores de Animação
  late AnimationController _listController; // Para entrada em cascata
  late AnimationController _headerBgController; // Para o gradiente vivo
  
  // Animações do Gradiente
  late Animation<Alignment> _headerTopAlign;
  late Animation<Alignment> _headerBottomAlign;

  @override
  void initState() {
    super.initState();
    // Barra de status transparente
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _future = _service.listarRacha();

    // 1. Configuração da Animação da Lista (Cascata)
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _listController.forward();

    // 2. Configuração do Header Vivo (Lento e Suave)
    _headerBgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _headerTopAlign = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
    ]).animate(CurvedAnimation(parent: _headerBgController, curve: Curves.linear));

    _headerBottomAlign = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
    ]).animate(CurvedAnimation(parent: _headerBgController, curve: Curves.linear));

    _headerBgController.repeat();
  }

  @override
  void dispose() {
    _listController.dispose();
    _headerBgController.dispose();
    super.dispose();
  }

  // --- MENU DE OPÇÕES MODERNO ---
  void _mostrarOpcoesRacha(Racha r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Transparente para ver o arredondamento
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Pílula de arrasto
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.groups, color: Colors.blue.shade800),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Opções do Racha",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            r.nome,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                const Divider(height: 1),
                
                _buildModalItem(
                  icon: Icons.history_edu_rounded,
                  color: Colors.orange,
                  text: "Histórico de Partidas",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PartidaHistoricoPage(codigoRacha: r.codigo)),
                    );
                  },
                ),
                _buildModalItem(
                  icon: Icons.person_add_alt_1_rounded,
                  color: Colors.green,
                  text: "Gerenciar Integrantes",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UsuarioListaPage(codigoRacha: r.codigo)),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalItem({required IconData icon, required Color color, required String text, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Ice Blue Clean
      body: Stack(
        children: [
          // --- 1. HEADER VIVO ---
          AnimatedBuilder(
            animation: _headerBgController,
            builder: (context, child) => _buildLiveHeader(),
          ),

          // --- 2. CONTEÚDO ---
          Padding(
            padding: const EdgeInsets.only(top: 140),
            child: FutureBuilder<List<Racha>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text("Erro: ${snapshot.error}", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final rachas = snapshot.data ?? [];

                if (rachas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_soccer_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text("Nenhum racha encontrado", style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Espaço extra embaixo
                  physics: const BouncingScrollPhysics(),
                  itemCount: rachas.length,
                  itemBuilder: (context, index) {
                    final r = rachas[index];
                    return _AnimatedRachaCard(
                      racha: r,
                      index: index,
                      animationController: _listController,
                      onTap: () => _mostrarOpcoesRacha(r),
                    );
                  },
                );
              },
            ),
          ),
          
          // --- 3. BOTÃO VOLTAR FLUTUANTE ---
          Positioned(
            top: 50,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [
            Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF002171),
          ],
          begin: _headerTopAlign.value,
          end: _headerBottomAlign.value,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 70), // Espaço para o botão voltar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Gerenciar",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(
                height: 40,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText('Meus Rachas', speed: const Duration(milliseconds: 100)),
                    ],
                    isRepeatingAnimation: false,
                    totalRepeatCount: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------- CARD ANIMADO DO RACHA ---------------------
class _AnimatedRachaCard extends StatelessWidget {
  final Racha racha;
  final int index;
  final AnimationController animationController;
  final VoidCallback onTap;

  const _AnimatedRachaCard({
    required this.racha,
    required this.index,
    required this.animationController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Animação Staggered (Cascata)
    final start = (index * 0.1).clamp(0.0, 0.8);
    final end = (start + 0.4).clamp(0.0, 1.0);

    final slideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: animationController, curve: Interval(start, end, curve: Curves.easeOutCubic)),
    );

    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Interval(start, end, curve: Curves.easeOut)),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1976D2).withOpacity(0.08), // Sombra azulada bem suave
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Ícone do Grupo
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Icon(Icons.shield_outlined, color: Colors.blue.shade800, size: 28),
                    ),
                    const SizedBox(width: 16),
                    
                    // Informações
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            racha.nome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF263238),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.green.shade400),
                              const SizedBox(width: 6),
                              Text(
                                "Ativo",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Botão de Opções
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade50,
                      ),
                      child: Icon(Icons.more_horiz, color: Colors.grey.shade400),
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