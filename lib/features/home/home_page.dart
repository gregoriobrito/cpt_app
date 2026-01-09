import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/partida/partida_racha_page.dart';
import 'package:cpv_app/features/racha/racha_page.dart';
import 'package:cpv_app/features/relatorio/relatorio_racha_page.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:cpv_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Future<String> _usuarioFuture;
  
  // Controladores de Animação
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  // Controlador para o "Jogo de Luz" do Header (LENTO e SUAVE)
  late AnimationController _headerBgController;
  late Animation<Alignment> _headerTopAlign;
  late Animation<Alignment> _headerBottomAlign;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _usuarioFuture = _carregarUsuario();

    // 1. Animação de Entrada (Cascata Elástica)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _entranceController.forward();

    // 2. Animação de Pulso 3D (Mais orgânico e vivo)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Ciclo de respiração mais lento
    )..repeat(reverse: true);

    // 3. JOGOS DE LUZ HEADER (Bem Lento - 20 segundos)
    _headerBgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Movimento muito suave
    );

    // Movimento do gradiente
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
    _entranceController.dispose();
    _pulseController.dispose();
    _headerBgController.dispose();
    super.dispose();
  }

  Future<String> _carregarUsuario() async {
    try {
      final usuarioService = UsuarioService();
      final usuario = await usuarioService.buscar();
      return usuario.apelido.isNotEmpty ? usuario.apelido : usuario.nome;
    } catch (e) {
      return "Atleta";
    }
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFC62828)),
              SizedBox(width: 10),
              Text("Desconectar"),
            ],
          ),
          content: const Text("Deseja realmente sair do aplicativo?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ApiClient().logout();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Sair"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Ice Blue Clean
      body: FutureBuilder<String>(
        future: _usuarioFuture,
        builder: (context, snapshot) {
          final nomeUsuario = snapshot.data ?? "...";
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return Stack(
            children: [
              // --- 1. HEADER CURVO COM JOGOS DE LUZ LENTOS ---
              AnimatedBuilder(
                animation: _headerBgController,
                builder: (context, child) {
                  return _buildLiveHeader(context, nomeUsuario, isLoading);
                },
              ),

              // --- 2. LISTA DE CARDS (Sem luz passando, apenas Pulso 3D) ---
              Padding(
                padding: const EdgeInsets.only(top: 240),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Card 1: Rachas
                    _AnimatedPremiumCard(
                      entranceController: _entranceController,
                      pulseController: _pulseController,
                      delay: 0.0,
                      title: "Meus Rachas",
                      subtitle: "Gerencie seus grupos",
                      icon: Icons.groups_rounded,
                      color: const Color(0xFF1976D2),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RachaPage())),
                    ),
                    const SizedBox(height: 18),

                    // Card 2: Partidas
                    _AnimatedPremiumCard(
                      entranceController: _entranceController,
                      pulseController: _pulseController,
                      delay: 0.2,
                      title: "Nova Partida",
                      subtitle: "Iniciar jogo agora",
                      icon: Icons.sports_soccer_rounded,
                      color: const Color(0xFF2E7D32),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartidaRachaPage())),
                    ),
                    const SizedBox(height: 18),

                    // Card 3: Estatísticas
                    _AnimatedPremiumCard(
                      entranceController: _entranceController,
                      pulseController: _pulseController,
                      delay: 0.4,
                      title: "Estatísticas",
                      subtitle: "Analise o desempenho",
                      icon: Icons.bar_chart_rounded,
                      color: const Color(0xFFEF6C00),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RelatorioRachaPage())),
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        "Versão 1.0.0",
                        style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- HEADER VIVO (LENTO) ---
  Widget _buildLiveHeader(BuildContext context, String nome, bool loading) {
    return Container(
      height: 290,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [
            Color(0xFF0D47A1), // Azul Profundo
            Color(0xFF1565C0), // Azul Médio
            Color(0xFF1E88E5), // Azul Claro
            Color(0xFF002171), // Roxo/Escuro
          ],
          begin: _headerTopAlign.value,
          end: _headerBottomAlign.value,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.dashboard_outlined, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => _confirmarLogout(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                "Olá,",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                ),
              ),
              loading
                  ? const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    )
                  : SizedBox(
                      height: 50,
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          fontFamily: 'Roboto',
                          shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              nome,
                              speed: const Duration(milliseconds: 150),
                              cursor: '_',
                            ),
                          ],
                          isRepeatingAnimation: false,
                          totalRepeatCount: 1,
                        ),
                      ),
                    ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Text(
                  "Painel de Controle",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------- CARD PREMIUM (SEM SHIMMER, SÓ PULSO 3D) ---------------------
class _AnimatedPremiumCard extends StatefulWidget {
  final AnimationController entranceController;
  final AnimationController pulseController;
  final double delay;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedPremiumCard({
    required this.entranceController,
    required this.pulseController,
    required this.delay,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedPremiumCard> createState() => _AnimatedPremiumCardState();
}

class _AnimatedPremiumCardState extends State<_AnimatedPremiumCard> with SingleTickerProviderStateMixin {
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();

    // 1. Mola (Elasticidade na Entrada)
    final start = widget.delay * 0.4;
    final end = start + 0.6;

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1.0), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.entranceController,
      curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.elasticOut),
    ));

    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: widget.entranceController,
      curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeOut),
    ));

    // 2. Clique (Feedback Tátil)
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(_pressController);
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnim.value * 50,
          child: Transform.scale(scale: _scaleAnim.value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressController.reverse(),
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) => Transform.scale(scale: _pressScale.value, child: child),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  // Ícone Pulsante 3D (Efeito de Respiração)
                  AnimatedBuilder(
                    animation: widget.pulseController,
                    builder: (context, child) {
                      // Curva senoidal para um pulso suave e orgânico
                      final scale = 1.0 + (widget.pulseController.value * 0.12); // Respira 12%
                      
                      return Transform.scale(
                        scale: scale, 
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                            // Sombra sutil que acompanha o pulso
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withOpacity(0.2),
                                blurRadius: 10 * scale,
                                spreadRadius: -2,
                              )
                            ]
                          ),
                          child: Icon(widget.icon, color: widget.color, size: 30),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),

                  // Textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Seta
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}