import 'package:flutter/material.dart';
import 'package:cpv_app/features/partida/partida_cadastrar_model.dart';
import 'package:cpv_app/features/partida/partida_placar_page.dart';
import 'package:cpv_app/features/partida/partida_service.dart';
import 'package:cpv_app/features/partida/partida_time_model.dart';
import 'package:cpv_app/features/partida/partida_usuario_time_model.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/racha/racha_service.dart';

class PartidaUsuarioPage extends StatefulWidget {
  final int codigoRacha;
  const PartidaUsuarioPage({super.key, required this.codigoRacha});

  @override
  State<PartidaUsuarioPage> createState() => _PartidaUsuarioPageState();
}

class _PartidaUsuarioPageState extends State<PartidaUsuarioPage> {
  final _service = RachaService();
  late Future<List<Usuario>> _future;

  int _timeAtual = 1; 
  final Map<int, int> _timePorJogador = {}; 

  // --- DESIGN SYSTEM ---
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _blue = const Color(0xFF2979FF);
  final Color _green = const Color(0xFF00C853); // Verde Vibrante

  @override
  void initState() {
    super.initState();
    _future = _service.listarUsuario(widget.codigoRacha);
  }

  void _toggleSelecionado(int idJogador) {
    setState(() {
      final timeDoJogador = _timePorJogador[idJogador];
      if (timeDoJogador == _timeAtual) {
        _timePorJogador.remove(idJogador);
      } else {
        _timePorJogador[idJogador] = _timeAtual;
      }
    });
  }

  void _trocarTime() => setState(() => _timeAtual = (_timeAtual == 1) ? 2 : 1);

  int _contarJogadores(int time) => _timePorJogador.values.where((t) => t == time).length;

  void _cadastrarPartida() async {
    final t1 = _timePorJogador.entries.where((e) => e.value == 1).map((e) => e.key).toList();
    final t2 = _timePorJogador.entries.where((e) => e.value == 2).map((e) => e.key).toList();

    if (t1.isEmpty || t2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione jogadores para os dois times!'), backgroundColor: Colors.red));
      return;
    }

    final request = PartidaCadastrar(
      codigoRacha: widget.codigoRacha,
      listaTime: [
        PartidaTime(listaUsuario: t1.map((id) => PartidaUsuarioTime(codigo: id)).toList()),
        PartidaTime(listaUsuario: t2.map((id) => PartidaUsuarioTime(codigo: id)).toList()),
      ],
    );

    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      final partida = await PartidaService().cadastrar(request);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PartidaPlacaPage(idPartida: partida.codigo, pageBack: 2)));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final corAtiva = _timeAtual == 1 ? _blue : _green;
    final nomeTime = _timeAtual == 1 ? "Time Azul" : "Time Verde";

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER FLUTUANTE ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                          child: const Icon(Icons.arrow_back_ios_new, size: 18),
                        ),
                      ),
                      const Spacer(),
                      const Text("Montar Equipes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // CARD DO TIME ATUAL
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [corAtiva, corAtiva.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: corAtiva.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.shield, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("SELECIONANDO", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, letterSpacing: 1.5)),
                            Text(nomeTime.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Text("${_contarJogadores(_timeAtual)}", style: TextStyle(color: corAtiva, fontWeight: FontWeight.bold, fontSize: 16)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- LISTA DE JOGADORES ---
            Expanded(
              child: FutureBuilder<List<Usuario>>(
                future: _future,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final jogadores = snapshot.data ?? [];

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: jogadores.length,
                    itemBuilder: (context, index) {
                      final u = jogadores[index];
                      final timeSel = _timePorJogador[u.codigo];
                      final isSelected = timeSel == _timeAtual;
                      final isOther = timeSel != null && timeSel != _timeAtual;

                      return GestureDetector(
                        onTap: isOther ? null : () => _toggleSelecionado(u.codigo),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? corAtiva.withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? corAtiva : Colors.transparent, width: 1.5),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isOther ? Colors.grey[200] : (isSelected ? corAtiva : Colors.grey[100]),
                                child: Icon(Icons.person, color: isSelected ? Colors.white : Colors.grey),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u.nome, style: TextStyle(fontWeight: FontWeight.bold, color: isOther ? Colors.grey : Colors.black87)),
                                    if(isOther) Text("Time Adversário", style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                  ],
                                ),
                              ),
                              if (isSelected) Icon(Icons.check_circle, color: corAtiva),
                            ],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _timeAtual == 1 ? _trocarTime : _cadastrarPartida,
            style: ElevatedButton.styleFrom(
              backgroundColor: corAtiva,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              shadowColor: corAtiva.withOpacity(0.5),
            ),
            child: Text(
              _timeAtual == 1 ? "PRÓXIMO: TIME VERDE" : "INICIAR PARTIDA",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }
}