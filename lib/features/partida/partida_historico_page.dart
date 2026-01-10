import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cpv_app/features/partida/partida_placar_page.dart';
import 'package:cpv_app/features/partida/partida_service.dart';
import 'package:cpv_app/features/partida/vw_partida_model.dart';

class PartidaHistoricoPage extends StatefulWidget {
  final int codigoRacha;
  const PartidaHistoricoPage({super.key, required this.codigoRacha});

  @override
  State<PartidaHistoricoPage> createState() => _PartidaHistoricoPageState();
}

class _PartidaHistoricoPageState extends State<PartidaHistoricoPage> {
  late Future<List<VwPartida>> _future;
  final _service = PartidaService();
  
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
    _future = _service.listarPartidasV2(widget.codigoRacha);
  }

  void _recarregar() => setState(() => _future = _service.listarPartidasV2(widget.codigoRacha));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("HISTÓRICO", style: TextStyle(color: _darkText, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: _darkText), onPressed: () => Navigator.pop(context)),
      ),
      body: FutureBuilder<List<VwPartida>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final partidas = snapshot.data!;
          if (partidas.isEmpty) return Center(child: Text("Sem partidas registradas", style: TextStyle(color: Colors.grey.shade500)));

          final Map<String, List<VwPartida>> porData = {};
          for (var p in partidas) {
            porData.putIfAbsent(DateFormat('dd/MM/yyyy').format(p.data.toLocal()), () => []).add(p);
          }
          final datas = porData.keys.toList()..sort((a, b) => DateFormat('dd/MM/yyyy').parse(b).compareTo(DateFormat('dd/MM/yyyy').parse(a)));

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: datas.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
                    child: Text(datas[index], style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  ...porData[datas[index]]!.map((p) => _buildMatchCard(p)).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(VwPartida p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () => _mostrarOpcoes(p),
        title: Row(
          children: [
            Expanded(child: Text(p.identificadorTimeA, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, color: _darkText))),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
              child: Text("${p.pontosTimeA} x ${p.pontosTimeB}", style: TextStyle(fontWeight: FontWeight.w900, color: _primaryBlue, fontSize: 16)),
            ),
            Expanded(child: Text(p.identificadorTimeB, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600, color: _darkText))),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcoes(VwPartida p) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 20),
        ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text("Alterar Placar"), onTap: () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PartidaPlacaPage(idPartida: p.codigo, pageBack: 1))); }),
        ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("Excluir"), onTap: () async { Navigator.pop(context); await _service.excluirPartida(p.codigo); _recarregar(); }),
        const SizedBox(height: 20),
      ]))
    ));
  }
}