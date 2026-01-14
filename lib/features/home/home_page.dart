import 'dart:convert'; // Necessário para salvar a lista de objetos
import 'dart:io';
import 'dart:ui';
import 'package:cpv_app/features/partida/partida_usuario_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/partida/partida_racha_page.dart';
import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/racha/racha_page.dart';
import 'package:cpv_app/features/racha/racha_service.dart';
import 'package:cpv_app/features/relatorio/relatorio_racha_page.dart';
import 'package:cpv_app/features/usuario/usuario_lista_page.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/usuario/usuario_perfil_page.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:cpv_app/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Future<Usuario> _usuarioFuture;
  late Future<List<Racha>> _meusRachasFuture;
  
  // Lista de atalhos (inicia vazia, mas será preenchida pelo SharedPreferences)
  List<Racha> _atalhosFixados = [];

  // Caminho da foto de perfil
  String? _profileImagePath;

  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);
  
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
    _meusRachasFuture = RachaService().listarRacha();
    
    // Carrega dados persistidos (Foto e Atalhos)
    _carregarDadosLocais();

    _lightsController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
  }

  // --- PERSISTÊNCIA DE DADOS ---

  Future<void> _carregarDadosLocais() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Carregar Foto
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
    });

    // 2. Carregar Atalhos
    final atalhosString = prefs.getStringList('atalhos_fixados');
    if (atalhosString != null) {
      setState(() {
        _atalhosFixados = atalhosString
            .map((item) => Racha.fromJson(jsonDecode(item)))
            .toList();
      });
    }
  }

  Future<void> _salvarAtalhos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> atalhosString = _atalhosFixados
        .map((racha) => jsonEncode({
              'codigo': racha.codigo,
              'nome': racha.nome,
              'flagUsuarioAdmin': racha.flagUsuarioAdmin
            }))
        .toList();
    
    await prefs.setStringList('atalhos_fixados', atalhosString);
  }

  // -----------------------------

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

  // --- MODAL: ADICIONAR ATALHO ---
  void _mostrarSelecaoDeAtalho() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text("Adicionar Atalho", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _darkText)),
              const SizedBox(height: 8),
              const Text("Escolha um racha para fixar na tela inicial", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Racha>>(
                  future: RachaService().listarRacha(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nenhum racha disponível."));

                    final lista = snapshot.data!;
                    
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: lista.length,
                      separatorBuilder: (_,__) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final racha = lista[index];
                        final jaAdicionado = _atalhosFixados.any((r) => r.codigo == racha.codigo);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: jaAdicionado ? Colors.green.withOpacity(0.1) : _primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(jaAdicionado ? Icons.check : Icons.sports_soccer, color: jaAdicionado ? Colors.green : _primaryBlue),
                          ),
                          title: Text(racha.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: jaAdicionado 
                              ? const Text("Adicionado", style: TextStyle(color: Colors.green, fontSize: 12))
                              : const Icon(Icons.add_circle_outline, color: Colors.grey),
                          onTap: () {
                            setState(() {
                              if (!jaAdicionado) {
                                _atalhosFixados.add(racha);
                              } else {
                                _atalhosFixados.removeWhere((r) => r.codigo == racha.codigo);
                              }
                            });
                            _salvarAtalhos(); // Salva no disco após modificar
                            if (!jaAdicionado) Navigator.pop(context); // Fecha se adicionou
                          },
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

  // --- MODAL: OPÇÕES DO ATALHO ---
  void _mostrarOpcoesRachaAtalho(Racha r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.star, color: _primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Racha Selecionado", style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(r.nome, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _atalhosFixados.removeWhere((element) => element.codigo == r.codigo);
                      });
                      _salvarAtalhos(); // Atualiza persistência ao remover
                      Navigator.pop(context);
                    },
                    tooltip: "Remover atalho",
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              _buildModalOption(
                icon: Icons.add, 
                color: Colors.blue, 
                title: "Nova Partida", 
                subtitle: "Toque para jogar",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaUsuarioPage(codigoRacha: r.codigo)));
                }
              ),
              _buildModalOption(
                icon: Icons.history, 
                color: Colors.orange, 
                title: "Ver Histórico", 
                subtitle: "Placares e partidas passadas",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaHistoricoPage(racha: r)));
                }
              ),
              if (r.flagUsuarioAdmin == "S")
              _buildModalOption(
                icon: Icons.groups, 
                color: Colors.green, 
                title: "Ver Integrantes", 
                subtitle: "Lista de jogadores deste racha",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => UsuarioListaPage(codigoRacha: r.codigo)));
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalOption({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Fundo Animado
          AnimatedBuilder(
            animation: _lightsController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(top: -50, right: -50, child: _buildLightBlob(const Color(0xFFE3F2FD), 300)), 
                  Positioned(top: size.height * 0.3, left: -60, child: _buildLightBlob(const Color(0xFFE1F5FE), 350)), 
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
                  // --- HEADER ---
                  FutureBuilder<Usuario>(
                    future: _usuarioFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox(height: 80);
                      final usuario = snapshot.data!;
                      final nomeDisplay = (usuario.apelido != null && usuario.apelido!.isNotEmpty) 
                          ? usuario.apelido! 
                          : usuario.nome.split(' ')[0];

                      return GestureDetector(
                        onTap: () async {
                          // Navega para o perfil e espera
                          await Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => UsuarioPerfilPage(usuario: usuario))
                          );
                          // Ao voltar, força recarregar TUDO (foto e dados)
                          _carregarDadosLocais();
                          setState(() { _usuarioFuture = UsuarioService().buscar(); });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                height: 60, width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))],
                                  image: _profileImagePath != null 
                                      ? DecorationImage(image: FileImage(File(_profileImagePath!)), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: _profileImagePath == null 
                                    ? Center(child: Text(nomeDisplay[0].toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryBlue)))
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Olá, atleta", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    SizedBox(
                                      height: 35,
                                      child: AnimatedTextKit(
                                        animatedTexts: [
                                          TypewriterAnimatedText(
                                            nomeDisplay.toUpperCase(),
                                            speed: const Duration(milliseconds: 150),
                                            textStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _darkText, fontFamily: 'Roboto', height: 1.0),
                                            cursor: '|'
                                          )
                                        ],
                                        isRepeatingAnimation: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: _backgroundColor, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.settings, size: 20, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),

                  // --- LISTA DE ATALHOS (Meus Rachas Fixados) ---
                  Text("Acesso Rápido", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _darkText)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      // Soma 1 para o botão de adicionar
                      itemCount: _atalhosFixados.length + 1, 
                      separatorBuilder: (_,__) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        // Se for o último item, mostra o botão de adicionar
                        if (index == _atalhosFixados.length) {
                          return _buildAddShortcutButton();
                        }
                        // Senão, mostra o atalho fixado
                        return _buildRachaShortcut(_atalhosFixados[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- MENU PRINCIPAL (Vertical) ---
                  _buildMenuCard(0, "Meus Rachas", "Gerencie seus grupos", Icons.groups_rounded, const Color(0xFF2979FF), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RachaPage()))),
                  _buildMenuCard(1, "Nova Partida", "Iniciar jogo agora", Icons.sports_volleyball_rounded, const Color(0xFF00B0FF), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartidaRachaPage()))),
                  _buildMenuCard(2, "Estatísticas", "Seu desempenho", Icons.bar_chart_rounded, const Color(0xFFFF6D00), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RelatorioRachaPage()))),
                  
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Sair da conta", style: TextStyle(color: Colors.red)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildAddShortcutButton() {
    return GestureDetector(
      onTap: _mostrarSelecaoDeAtalho,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryBlue.withOpacity(0.3), width: 1, style: BorderStyle.solid),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
              child: Icon(Icons.add, color: _primaryBlue, size: 24),
            ),
            const SizedBox(height: 10),
            Text("Adicionar", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildRachaShortcut(Racha racha) {
    return GestureDetector(
      onTap: () => _mostrarOpcoesRachaAtalho(racha),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryBlue.withOpacity(0.1), _primaryBlue.withOpacity(0.2)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight
                ),
                shape: BoxShape.circle
              ),
              child: Icon(Icons.bolt, color: _primaryBlue, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              racha.nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _darkText, height: 1.1),
              textAlign: TextAlign.center,
            ),
          ],
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

  Widget _buildMenuCard(int index, String title, String subtitle, IconData icon, Color accentColor, VoidCallback onTap) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _entranceController, curve: Interval(index * 0.2, 1.0, curve: Curves.easeOutCubic))),
      child: FadeTransition(
        opacity: _entranceController,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10))]),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: accentColor, size: 30)),
                    const SizedBox(width: 20),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13))])),
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFF5F7FA), shape: BoxShape.circle), child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey)),
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