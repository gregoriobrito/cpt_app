import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/partida/partida_usuario_page.dart';
import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/relatorio/relatorio_estatistica_page.dart';
import 'package:cpv_app/features/usuario/usuario_lista_page.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/usuario/usuario_perfil_page.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:cpv_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Racha racha;
  const HomePage({super.key, required this.racha});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Future<Usuario> _usuarioFuture;
  
  // Caminho da foto de perfil
  String? _profileImagePath;

  // --- DESIGN SYSTEM ---
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _darkText = const Color(0xFF1E2230);
  final Color _primaryBlue = const Color(0xFF2979FF);
  
  late AnimationController _lightsController;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _usuarioFuture = UsuarioService().buscar();
    _carregarDadosLocais();

    _lightsController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }

  Future<void> _carregarDadosLocais() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
    });
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

  // --- MENU INFERIOR DE FILTRO (Mantido) ---
  Widget _buildFilterBtn(BuildContext context, String label, int id, int tipo, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => RelatorioEstatisticaPage(idRacha: id, tipoRacha: tipo)));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5F7FA),
          foregroundColor: const Color(0xFF1E2230),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20)
        ),
        child: Row(
          children: [
            Icon(icon, color: _primaryBlue),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  void _abrirBottomSheetEstatisticas(BuildContext context, int codigoRacha) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text('Filtrar Relatório', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E2230))),
                const SizedBox(height: 24),
                _buildFilterBtn(context, "Geral", codigoRacha, 1, Icons.dashboard_outlined),
                const SizedBox(height: 12),
                _buildFilterBtn(context, "Por Data", codigoRacha, 2, Icons.calendar_today_outlined),
                const SizedBox(height: 12),
                _buildFilterBtn(context, "Mensal", codigoRacha, 3, Icons.calendar_view_month_outlined),
                const SizedBox(height: 12),
                _buildFilterBtn(context, "Anual", codigoRacha, 4, Icons.calendar_today_rounded),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // 1. FUNDO ANIMADO
          AnimatedBuilder(
            animation: _lightsController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(top: -50, right: -50, child: _buildLightBlob(const Color(0xFFE3F2FD), 300)), 
                  Positioned(top: size.height * 0.4, left: -60, child: _buildLightBlob(const Color(0xFFE1F5FE), 350)), 
                  Positioned(bottom: -50, right: -20, child: _buildLightBlob(const Color(0xFFEDE7F6), 400)), 
                ],
              );
            },
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER (Perfil do Usuário) ---
                  FutureBuilder<Usuario>(
                    future: _usuarioFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox(height: 80);
                      final usuario = snapshot.data!;
                      final nomeDisplay = usuario.apelido ?? usuario.nome.split(' ')[0];

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => UsuarioPerfilPage(usuario: usuario)));
                          _carregarDadosLocais();
                          setState(() { _usuarioFuture = UsuarioService().buscar(); });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                height: 55, width: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.2), blurRadius: 10)],
                                  image: _profileImagePath != null ? DecorationImage(image: FileImage(File(_profileImagePath!)), fit: BoxFit.cover) : null,
                                ),
                                child: _profileImagePath == null 
                                    ? Center(child: Text(nomeDisplay[0].toUpperCase(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryBlue)))
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // AJUSTE 1: Texto "Meu Perfil"
                                    Text("Meu Perfil", style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
                                    // AJUSTE 1: Nome do Usuário
                                    Text(
                                      nomeDisplay.toUpperCase(), 
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _darkText, fontFamily: 'Roboto')
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.settings, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // --- BARRA DO RACHA ATUAL E BOTÃO VOLTAR (AJUSTE 2 e 3) ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [_primaryBlue.withOpacity(0.05), Colors.white.withOpacity(0.5)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _primaryBlue.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Racha Selecionado:", style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              // Hero Animation para o Título do Racha
                              Hero(
                                tag: 'racha_title_${widget.racha.codigo}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    widget.racha.nome,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _primaryBlue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Botão de Trocar (Voltar)
                        InkWell(
                          onTap: () => Navigator.pop(context), // Volta para a RachaPage
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.1), blurRadius: 5)]
                            ),
                            child: Row(
                              children: [
                                Text("Trocar", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryBlue)),
                                const SizedBox(width: 4),
                                Icon(Icons.swap_horiz, size: 16, color: _primaryBlue),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  Text("Painel de Controle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText)),
                  const SizedBox(height: 16),

                  // --- GRID DE OPÇÕES ---
                  GridView.count(
                    crossAxisCount: 2, // 2 colunas
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85, // Proporção para não cortar o card
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Card 1: Nova Partida
                      _buildAnimatedGridCard(
                        index: 0,
                        title: "Nova Partida",
                        subtitle: "Iniciar jogo",
                        icon: Icons.sports_volleyball_rounded,
                        color: const Color(0xFF2979FF),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaUsuarioPage(codigoRacha: widget.racha.codigo))),
                      ),

                      // Card 2: Histórico
                      _buildAnimatedGridCard(
                        index: 1,
                        title: "Histórico",
                        subtitle: "Ver placares",
                        icon: Icons.history_edu_rounded,
                        color: const Color(0xFFFF9100),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaHistoricoPage(racha: widget.racha))),
                      ),

                      // Card 3: Integrantes
                      _buildAnimatedGridCard(
                        index: 2,
                        title: "Integrantes",
                        subtitle: "Gerenciar time",
                        icon: Icons.groups_rounded,
                        color: const Color(0xFF00C853),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UsuarioListaPage(racha: widget.racha))),
                      ),

                      // Card 4: Estatísticas
                      _buildAnimatedGridCard(
                        index: 3,
                        title: "Estatísticas",
                        subtitle: "Performance",
                        icon: Icons.bar_chart_rounded,
                        color: const Color(0xFF6200EA),
                        onTap: () => _abrirBottomSheetEstatisticas(context, widget.racha.codigo),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Sair da conta", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.05),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES E ANIMAÇÕES ---

  Widget _buildAnimatedGridCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Animação de entrada cascata
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval((index * 0.1), 1.0, curve: Curves.easeOutBack),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          // Correção do clamp para opacidade
          child: Opacity(opacity: animation.value.clamp(0.0, 1.0), child: child),
        );
      },
      child: _BouncingGridCard(
        title: title,
        subtitle: subtitle,
        icon: icon,
        color: color,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLightBlob(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.8), boxShadow: [BoxShadow(color: color, blurRadius: 60, spreadRadius: 10)]),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40), child: Container(color: Colors.transparent)),
    );
  }
}

// Widget Stateful separado para lidar com a animação de clique (Bouncing) e Design do Card
class _BouncingGridCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BouncingGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_BouncingGridCard> createState() => _BouncingGridCardState();
}

class _BouncingGridCardState extends State<_BouncingGridCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Ícone Gigante de Fundo (Marca D'água)
              Positioned(
                bottom: -20,
                right: -20,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(widget.icon, size: 100, color: widget.color.withOpacity(0.08)),
                ),
              ),
              
              // Conteúdo
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ícone com fundo colorido
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 34),
                    ),
                    
                    const Spacer(),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E2230), height: 1.1),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}