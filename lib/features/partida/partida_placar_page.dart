import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/partida/partida_racha_page.dart';
import 'package:cpv_app/features/partida/partida_usuario_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  
  // Guardamos os pontos como inteiros, não controllers de texto (UX Melhor)
  List<int> _pontuacoes = [];

  @override
  void initState() {
    super.initState();
    _future = _service.burcar(widget.idPartida);
  }

  void _initPontuacoesIfNeeded(Partida partida) {
    if (_pontuacoes.isNotEmpty) return;
    final times = partida.listaTime ?? [];
    // Inicializa a lista de inteiros com os valores atuais
    _pontuacoes = times.map((t) => t.pontuacao ?? 0).toList();
  }

  void _alterarPontos(int index, int delta) {
    setState(() {
      int novoValor = _pontuacoes[index] + delta;
      if (novoValor < 0) novoValor = 0; // Não permite negativo
      _pontuacoes[index] = novoValor;
    });
  }

  Future<void> _salvarPlacar() async {
    if (_partida == null || _partida!.listaTime == null) return;
    
    final lista = <PartidaPontoTimeDetalhe>[];
    for (int i = 0; i < _partida!.listaTime!.length; i++) {
      lista.add(PartidaPontoTimeDetalhe(
        idTime: _partida!.listaTime![i].codigo, 
        pontos: _pontuacoes[i],
      ));
    }

    try {
      await _service.atualizarPontos(PartidaPontoTime(lista: lista));
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Placar atualizado com sucesso!'), backgroundColor: Colors.green),
      );
      _voltarTela(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
    }
  }

  void _voltarTela(BuildContext context) {
    if (widget.pageBack == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PartidaHistoricoPage(codigoRacha: _partida!.codigoRacha!),
        ),
      );
    } else if (widget.pageBack == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PartidaUsuarioPage(codigoRacha: _partida!.codigoRacha!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) _voltarTela(context);
      },
      child: Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // Fundo azul escuro (Estádio)
      appBar: AppBar(
        title: const Text("Placar Ao Vivo"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Partida>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
          if (snapshot.hasError) return const Center(child: Text("Erro ao carregar", style: TextStyle(color: Colors.white)));
          
          final partida = snapshot.data;
          if (partida == null) return const SizedBox();

          _partida = partida;
          _initPontuacoesIfNeeded(partida);
          final times = partida.listaTime ?? [];

          return Column(
            children: [
              // Info do Racha
              Text(
                partida.racha?.nome ?? "Partida",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // --- ÁREA DO PLACAR ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F4F8), // Fundo claro curvo
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      // Renderiza os times (Ideal para 2 times)
                      if (times.length >= 2) ...[
                        _buildTimeScoreRow(0, times[0].identificador, Colors.blue),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text("VS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                        _buildTimeScoreRow(1, times[1].identificador, Colors.green),
                      ] else ...[
                        // Fallback se tiver quantidade diferente de times
                        Expanded(
                           child: ListView.separated(
                             itemCount: times.length,
                             separatorBuilder: (_,__) => const Divider(),
                             itemBuilder: (ctx, idx) => _buildTimeScoreRow(idx, times[idx].identificador, Colors.blue),
                           ),
                        )
                      ],
                      
                      const Spacer(),
                      
                      // Botão Salvar Gigante
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _salvarPlacar,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text("ATUALIZAR PLACAR", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _buildTimeScoreRow(int index, String nomeTime, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nome do Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TIME ${index + 1}",
                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
                ),
                Text(
                  nomeTime,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Controlador Numérico
          Row(
            children: [
              _circleBtn(Icons.remove, () => _alterarPontos(index, -1)),
              SizedBox(
                width: 60,
                child: Text(
                  "${_pontuacoes[index]}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                ),
              ),
              _circleBtn(Icons.add, () => _alterarPontos(index, 1), isAdd: true),
            ],
          )
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {bool isAdd = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isAdd ? const Color(0xFF0D47A1) : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isAdd ? Colors.white : Colors.black54, size: 24),
      ),
    );
  }
}