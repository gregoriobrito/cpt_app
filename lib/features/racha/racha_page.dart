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

  // --- DESIGN SYSTEM ---
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);

  late AnimationController _listController;
  final TextEditingController _nomeRachaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _carregarLista();

    _listController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1000)
    );
    _listController.forward();
  }

  void _carregarLista() {
    setState(() {
      _future = _service.listarRacha();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    _nomeRachaController.dispose();
    super.dispose();
  }

  // --- FUNÇÃO DE CRIAR ---
  Future<void> _salvarNovoRacha() async {
    final nome = _nomeRachaController.text.trim();
    if (nome.isEmpty) return;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception:", "")), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNÇÃO DE EXCLUIR (NOVO) ---
  Future<void> _excluirRacha(Racha r) async {
    setState(() => _isLoading = true);
    
    try {
      await _service.deletar(r.codigo); // Chama o service
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Grupo excluído."), backgroundColor: Colors.grey));
        _carregarLista(); // Atualiza a lista na tela
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception:", "")), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- POP-UP DE CONFIRMAÇÃO (NOVO) ---
  void _confirmarExclusao(Racha r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Excluir Grupo?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Tem certeza que deseja apagar o racha '${r.nome}'? Todo o histórico de partidas será perdido."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(ctx); // Fecha o pop-up
              _excluirRacha(r);   // Executa a exclusão
            },
            child: const Text("EXCLUIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primaryBlue.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.add, color: _primaryBlue)),
            const SizedBox(width: 12),
            Text("Novo Racha", style: TextStyle(color: _darkText, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dê um nome para o seu grupo de vôlei.", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            TextField(
              controller: _nomeRachaController,
              autofocus: true,
              style: TextStyle(color: _darkText, fontWeight: FontWeight.w600),
              decoration: InputDecoration(hintText: "Ex: Vôlei de Terça", filled: true, fillColor: _backgroundColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _nomeRachaController.clear(); }, child: const Text("CANCELAR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(onPressed: _salvarNovoRacha, style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), elevation: 0), child: const Text("CRIAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // --- MODAL DE OPÇÕES (ATUALIZADO) ---
  void _mostrarOpcoesRacha(Racha r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Adicionado para evitar overflow
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24), // Ajuste de padding
        child: SafeArea(
          child: SingleChildScrollView(
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
                      ),
                      // Botão Fechar (X)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
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

                // SE FOR ADMIN, MOSTRA OPÇÕES EXTRAS
                if (r.flagUsuarioAdmin == "S") ...[
                  _buildModalItem(Icons.group_add_rounded, Colors.green, "Gerenciar Integrantes", () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => UsuarioListaPage(codigoRacha: r.codigo)));
                  }),
                  
                  const SizedBox(height: 10),
                  
                  // --- BOTÃO DE EXCLUIR (NOVO) ---
                  _buildModalItem(Icons.delete_forever_rounded, Colors.red, "Excluir Grupo", () {
                    Navigator.pop(context); // Fecha o modal de opções
                    _confirmarExclusao(r);  // Abre o popup de confirmação
                  }),
                ]
              ],
            ),
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
      title: Text(text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: (icon == Icons.delete_forever_rounded) ? Colors.red : _darkText)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Gerenciar", style: TextStyle(color: _darkText, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: _darkText), onPressed: () => Navigator.pop(context)),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 40,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText('MEUS RACHAS', speed: const Duration(milliseconds: 100), textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _darkText, fontFamily: 'Roboto', letterSpacing: 1.0)),
                    ],
                    isRepeatingAnimation: false,
                  ),
                ),
                InkWell(
                  onTap: _mostrarModalCriacao,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primaryBlue.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.add, color: _primaryBlue, size: 28)),
                ),
              ],
            ),
            
            Text("Toque em um grupo para ver opções", style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            const SizedBox(height: 30),

            Expanded(
              child: FutureBuilder<List<Racha>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) return const Center(child: CircularProgressIndicator());
                  if (_isLoading) return const Center(child: CircularProgressIndicator()); // Mostra loading se estiver excluindo

                  final rachas = snapshot.data ?? [];
                  if (rachas.isEmpty) {
                    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.sports_volleyball_rounded, size: 64, color: Colors.grey.shade300), const SizedBox(height: 16), Text("Nenhum grupo encontrado", style: TextStyle(fontSize: 16, color: Colors.grey.shade500))]));
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: rachas.length,
                    separatorBuilder: (_,__) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final r = rachas[index];
                      // Animação simples
                      return Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))]),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _mostrarOpcoesRacha(r),
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(height: 56, width: 56, decoration: BoxDecoration(color: _primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(18)), child: Icon(Icons.shield_rounded, color: _primaryBlue, size: 30)),
                                  const SizedBox(width: 20),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.nome, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText)), const SizedBox(height: 6), Row(children: [Icon(Icons.circle, size: 8, color: Colors.green.shade400), const SizedBox(width: 6), Text("Ativo", style: TextStyle(fontSize: 12, color: Colors.grey.shade500))])])),
                                  Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFFF5F7FA), shape: BoxShape.circle), child: Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 20)),
                                ],
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