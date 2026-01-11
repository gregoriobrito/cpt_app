import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'relatorio_model.dart';
import 'relatorio_service.dart';

class RelatorioEstatisticaPage extends StatefulWidget {
  final int idRacha;
  final int tipoRacha;

  const RelatorioEstatisticaPage({super.key, required this.idRacha, required this.tipoRacha});

  @override
  State<RelatorioEstatisticaPage> createState() => _RelatorioEstatisticaPageState();
}

class _RelatorioEstatisticaPageState extends State<RelatorioEstatisticaPage> {
  final _service = RelatorioService();
  late Future<Relatorio> _future;

  final Color _bg = const Color(0xFFF5F7FA);
  final Color _blue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
    if (widget.tipoRacha == 1) {
      _future = _service.buscarRelatorioGeral(widget.idRacha);
    } else if (widget.tipoRacha == 2) {
      _future = _service.buscarRelatorioData(widget.idRacha);
    } else if (widget.tipoRacha == 3) {
      _future = _service.buscarRelatorioMes(widget.idRacha);
    } else if (widget.tipoRacha == 4) {
      _future = _service.buscarRelatorioAno(widget.idRacha);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('RESULTADOS', style: TextStyle(color: Color(0xFF1E2230), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E2230)), onPressed: () => Navigator.pop(context)),
      ),
      body: FutureBuilder<Relatorio>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));

          final relatorio = snapshot.data;
          if (relatorio == null) return const Center(child: Text('Nenhum dado encontrado.'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título Grande
                Text(
                  relatorio.nomeRelatorio.toUpperCase(),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _blue),
                ),
                const SizedBox(height: 4),
                Text("Desempenho dos atletas", style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(height: 24),

                // Lista de Agrupadores
                ...relatorio.lista.map((grupo) => _buildGrupoCard(grupo)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrupoCard(GrupoResultado grupo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: _blue.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do Grupo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Text(
              grupo.agrupador.toUpperCase(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _blue, letterSpacing: 1),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: grupo.listaResultado.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        child: Text(item.nome.substring(0, 1), style: TextStyle(color: _darkText, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.nome, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _darkText)),
                            if (item.apelido.isNotEmpty)
                              Text(item.apelido, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(12)),
                        child: Text('${item.pontuacao}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}