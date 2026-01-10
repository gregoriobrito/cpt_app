import 'package:cpv_app/features/partida/partida_usuario_page.dart';
import 'package:cpv_app/features/relatorio/relatorio_estatistica_page.dart';
import 'package:flutter/material.dart';
import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/racha/racha_service.dart';

class RelatorioRachaPage extends StatefulWidget {
  const RelatorioRachaPage({super.key});

  @override
  State<RelatorioRachaPage> createState() => _RelatorioRachaPageState();
}

class _RelatorioRachaPageState extends State<RelatorioRachaPage> {
  final _service = RachaService();
  late Future<List<Racha>> _future;

  // Design
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _blue = const Color(0xFF2979FF);

  @override
  void initState() {
    super.initState();
    _future = _service.listarRacha();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('ESTATÍSTICAS', style: TextStyle(color: Color(0xFF1E2230), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E2230)), onPressed: () => Navigator.pop(context)),
      ),
      body: FutureBuilder<List<Racha>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final rachas = snapshot.data ?? [];

          if (rachas.isEmpty) return const Center(child: Text('Nenhum racha encontrado'));

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: rachas.length,
            separatorBuilder: (_,__) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final r = rachas[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: _blue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: _blue.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.bar_chart_rounded, color: _blue),
                        ),
                        const SizedBox(width: 16),
                        Text(r.nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2230))),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
                      onPressed: () => _abrirBottomSheet(context, r.codigo),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _abrirBottomSheet(BuildContext context, int codigoRacha) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text('Filtrar Relatório', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2230))),
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
          backgroundColor: const Color(0xFFF5F7FA), // Botão cinza claro
          foregroundColor: const Color(0xFF1E2230), // Texto escuro
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20)
        ),
        child: Row(
          children: [
            Icon(icon, color: _blue),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}