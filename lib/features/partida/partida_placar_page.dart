import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/partida/partida_usuario_page.dart';
import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/racha/racha_service.dart';
import 'package:flutter/material.dart';
import 'package:cpv_app/features/partida/partida_model.dart';
import 'package:cpv_app/features/partida/partida_ponto_time_detalhe_model.dart';
import 'package:cpv_app/features/partida/partida_ponto_time_model.dart';
import 'package:cpv_app/features/partida/partida_service.dart';

class PartidaPlacaPage extends StatefulWidget {
  final int idPartida;
  final int pageBack;
  const PartidaPlacaPage({super.key, required this.idPartida, required this.pageBack});

  @override
  State<PartidaPlacaPage> createState() => _PartidaPlacaPageState();
}

class _PartidaPlacaPageState extends State<PartidaPlacaPage> {
  final _service = PartidaService();
  late Future<Partida> _future;
  Partida? _partida;
  List<int> _pontuacoes = [];

  // Cores
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _blue = const Color(0xFF2979FF);

  @override
  void initState() {
    super.initState();
    _future = _service.buscar(widget.idPartida);
  }

  void _initPontuacoesIfNeeded(Partida partida) {
    if (_pontuacoes.isNotEmpty) return;
    _pontuacoes = partida.listaTime?.map((t) => t.pontuacao ?? 0).toList() ?? [];
  }

  void _alterarPontos(int index, int delta) {
    setState(() {
      int novo = _pontuacoes[index] + delta;
      if (novo >= 0) _pontuacoes[index] = novo;
    });
  }

  Future<void> _salvarPlacar() async {
    if (_partida?.listaTime == null) return;
    
    final lista = List.generate(_partida!.listaTime!.length, (i) {
      return PartidaPontoTimeDetalhe(idTime: _partida!.listaTime![i].codigo, pontos: _pontuacoes[i]);
    });

    try {
      await _service.atualizarPontos(PartidaPontoTime(lista: lista));
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placar atualizado!'), backgroundColor: Colors.green));
      _voltarTela(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  void _voltarTela(BuildContext context) async {
    if (widget.pageBack == 1) {
      Racha racha = await RachaService().get(_partida!.codigoRacha!);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PartidaHistoricoPage(racha: racha)));
    } else if (widget.pageBack == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PartidaUsuarioPage(codigoRacha: _partida!.codigoRacha!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) { if (!didPop) _voltarTela(context); },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87), onPressed: () => _voltarTela(context)),
          title: const Text("Placar Ao Vivo", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: FutureBuilder<Partida>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            _partida = snapshot.data;
            _initPontuacoesIfNeeded(_partida!);
            final times = _partida!.listaTime ?? [];

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                    child: Text(_partida?.racha?.nome ?? "Partida", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView.separated(
                      itemCount: times.length,
                      separatorBuilder: (_,__) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("VS", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.grey)),
                      ),
                      itemBuilder: (ctx, idx) => _buildCardTime(idx, times[idx].identificador, idx == 0 ? _blue : Colors.green),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _salvarPlacar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 10,
                        shadowColor: _blue.withOpacity(0.4),
                      ),
                      child: const Text("ATUALIZAR PLACAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardTime(int index, String nome, Color cor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: cor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(nome.toUpperCase(), style: TextStyle(color: cor, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _btn(Icons.remove, () => _alterarPontos(index, -1)),
              Container(
                width: 80,
                alignment: Alignment.center,
                child: Text("${_pontuacoes[index]}", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF1E2230))),
              ),
              _btn(Icons.add, () => _alterarPontos(index, 1), isAdd: true, color: cor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, {bool isAdd = false, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAdd ? (color ?? Colors.blue) : Colors.grey.shade100,
          shape: BoxShape.circle,
          boxShadow: isAdd ? [BoxShadow(color: color!.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Icon(icon, color: isAdd ? Colors.white : Colors.grey, size: 28),
      ),
    );
  }
}