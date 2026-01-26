import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/home/home_page.dart'; // Importe sua HomePage nova aqui
import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/usuario/usuario_lista_page.dart';
import 'package:cpv_app/main.dart';
import 'racha_model.dart';
import 'racha_service.dart';

class RachaPage extends StatefulWidget {
  const RachaPage({super.key});

  @override
  State<RachaPage> createState() => _RachaPageState();
}

class _RachaPageState extends State<RachaPage> with TickerProviderStateMixin {
  final _service = RachaService();
  late Future<List<Racha>> _future;

  // --- DESIGN SYSTEM ---
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);

  // Controladores
  late PageController _pageController;
  late AnimationController _lightsController;
  final TextEditingController _nomeRachaController = TextEditingController();
  
  bool _isLoading = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _carregarLista();

    // Viewport 0.80 permite ver um pedaço do próximo card (efeito carrossel)
    _pageController = PageController(viewportFraction: 0.80);
    
    // Animação lenta das luzes de fundo
    _lightsController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
  }

  void _carregarLista() {
    setState(() {
      _future = _service.listarRacha();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _lightsController.dispose();
    _nomeRachaController.dispose();
    super.dispose();
  }

  // --- NAVEGAÇÃO FLUIDA ---
  void _navegarParaHome(Racha racha) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomePage(racha: racha),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Efeito de Fade + leve Zoom para entrada suave
          var curve = CurvedAnimation(parent: animation, curve: Curves.easeOutQuart);
          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600), // Duração um pouco maior para fluidez
      ),
    );
  }

  // --- LOGOUT ---
  void _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Sair da conta?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Você será desconectado do aplicativo."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(ctx); 
              await ApiClient().logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (r) => false,
                );
              }
            },
            child: const Text("SAIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE CRUD ---
  Future<void> _salvarNovoRacha() async {
    final nome = _nomeRachaController.text.trim();
    if (nome.isEmpty) return;
    
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    Navigator.pop(context); 
    
    try {
      await _service.cadastrar(nome);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Grupo criado com sucesso!"), backgroundColor: Colors.green));
        _nomeRachaController.clear();
        _carregarLista();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _excluirRacha(Racha r) async {
    setState(() => _isLoading = true);
    try {
      await _service.deletar(r.codigo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Grupo excluído."), backgroundColor: Colors.grey));
        _carregarLista();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmarExclusao(Racha r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Excluir Grupo?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Tem certeza que deseja apagar '${r.nome}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { Navigator.pop(ctx); _excluirRacha(r); },
            child: const Text("EXCLUIR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarModalCriacao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [Icon(Icons.add_circle, color: _primaryBlue), const SizedBox(width: 10), const Text("Novo Racha")]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Crie um novo grupo para gerenciar suas partidas.", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: _nomeRachaController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Nome (ex: Vôlei de Quarta)",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: _salvarNovoRacha,
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("CRIAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcoesRacha(Racha r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(r.nome, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _darkText), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 20),
              const Divider(),
              // Opção de entrar também pelo modal
              _buildModalItem(Icons.login_rounded, _primaryBlue, "Acessar Painel", () { Navigator.pop(context); _navegarParaHome(r); }),
              _buildModalItem(Icons.history, Colors.orange, "Histórico de Partidas", () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaHistoricoPage(racha: r))); }),
              if (r.flagUsuarioAdmin == "S") ...[
                _buildModalItem(Icons.group, Colors.green, "Gerenciar Integrantes", () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => UsuarioListaPage(codigoRacha: r.codigo))); }),
                _buildModalItem(Icons.delete_outline, Colors.red, "Excluir Grupo", () { Navigator.pop(context); _confirmarExclusao(r); }),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalItem(IconData icon, Color color, String text, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: false, 
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

          // 2. CONTEÚDO PRINCIPAL
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                        onPressed: _logout,
                        tooltip: "Sair da conta",
                      ),
                      Text("SEUS GRUPOS", style: TextStyle(color: _darkText, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: _primaryBlue, size: 28),
                        onPressed: _mostrarModalCriacao,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                
                // TÍTULO ANIMADO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    height: 50,
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText('Escolha o Racha', speed: const Duration(milliseconds: 100), textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _darkText)),
                      ],
                      isRepeatingAnimation: false,
                    ),
                  ),
                ),

                const Spacer(),

                // 3. CARROSSEL 3D FLUIDO
                Expanded(
                  flex: 10,
                  child: FutureBuilder<List<Racha>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) return const Center(child: CircularProgressIndicator());
                      
                      final rachas = snapshot.data ?? [];
                      if (rachas.isEmpty) {
                        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.sports_volleyball, size: 60, color: Colors.grey.shade300), const SizedBox(height: 10), const Text("Nenhum grupo ainda.")]));
                      }

                      return PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: rachas.length,
                        onPageChanged: (idx) => setState(() => _currentPage = idx),
                        itemBuilder: (context, index) {
                          final racha = rachas[index];
                          
                          // Animação de Escala 3D
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (_pageController.position.haveDimensions) {
                                value = _pageController.page! - index;
                                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                              } else {
                                value = (index == 0) ? 1.0 : 0.7;
                              }
                              final curve = Curves.easeOut.transform(value);

                              return Center(
                                child: Transform.scale(
                                  scale: curve,
                                  child: Opacity(
                                    opacity: (value < 0.5) ? 0.5 : 1.0, 
                                    child: _buildGlassCard(racha), // Chama o Card
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const Spacer(flex: 2),
                
                // Indicador
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text("Deslize para selecionar", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD DE VIDRO COM HERO ANIMATION ---
  Widget _buildGlassCard(Racha racha) {
    return GestureDetector(
      onTap: () => _navegarParaHome(racha), // Usa a navegação suave
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65), 
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: -5
                )
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -20, right: -20,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(color: _primaryBlue.withOpacity(0.08), shape: BoxShape.circle),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // HERO 1: Ícone
                      Hero(
                        tag: 'racha_icon_${racha.codigo}', // Tag única para o racha
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Icon(Icons.shield, size: 60, color: _primaryBlue),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // HERO 2: Título
                      Hero(
                        tag: 'racha_title_${racha.codigo}',
                        child: Material( // Material necessário para evitar erro de texto no Hero
                          color: Colors.transparent,
                          child: Text(
                            racha.nome,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _darkText, height: 1.1),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.withOpacity(0.3))
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.green),
                            const SizedBox(width: 8),
                            Text("Ativo", style: TextStyle(fontSize: 14, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Botão Acessar
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [_primaryBlue, const Color(0xFF00B0FF)]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: const Text(
                          "ACESSAR",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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