import 'dart:ui';
import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cpv_app/features/partida/partida_placar_page.dart';
import 'package:cpv_app/features/partida/partida_service.dart';
import 'package:cpv_app/features/partida/vw_partida_model.dart';

class PartidaHistoricoPage extends StatefulWidget {
  final Racha racha;
  const PartidaHistoricoPage({super.key, required this.racha});

  @override
  State<PartidaHistoricoPage> createState() => _PartidaHistoricoPageState();
}

class _PartidaHistoricoPageState extends State<PartidaHistoricoPage> {
  late Future<List<VwPartida>> _future;
  final _service = PartidaService();
  
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
    _future = _service.listarPartidasV2(widget.racha.codigo);
  }

  void _recarregar() {
    setState(() {
      _future = _service.listarPartidasV2(widget.racha.codigo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text("HISTÓRICO", style: TextStyle(color: _darkText, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _darkText), 
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: FutureBuilder<List<VwPartida>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final partidas = snapshot.data!;
          if (partidas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text("Sem partidas registradas", style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          // Agrupamento por Data
          final Map<String, List<VwPartida>> porData = {};
          for (var p in partidas) {
            porData.putIfAbsent(DateFormat('dd/MM/yyyy').format(p.data.toLocal()), () => []).add(p);
          }
          final datas = porData.keys.toList()..sort((a, b) => DateFormat('dd/MM/yyyy').parse(b).compareTo(DateFormat('dd/MM/yyyy').parse(a)));

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            itemCount: datas.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12, top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: _primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(datas[index], style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.racha.flagUsuarioAdmin == "S" ? () => _mostrarOpcoes(p) : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(p.identificadorTimeA, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, color: _darkText, fontSize: 16))),
                
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
                  child: Text("${p.pontosTimeA} x ${p.pontosTimeB}", style: TextStyle(fontWeight: FontWeight.w900, color: _primaryBlue, fontSize: 18)),
                ),
                
                Expanded(child: Text(p.identificadorTimeB, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600, color: _darkText, fontSize: 16))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CONFIRMAÇÃO DE EXCLUSÃO ---
  void _confirmarExclusaoPartida(VwPartida p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Excluir Partida?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Tem certeza que deseja remover o registro desta partida?\n\n${p.identificadorTimeA} ${p.pontosTimeA} x ${p.pontosTimeB} ${p.identificadorTimeB}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx); // Fecha Dialog
              await _service.excluirPartida(p.codigo);
              if(mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Partida removida."), backgroundColor: Colors.grey));
                 _recarregar();
              }
            },
            child: const Text("EXCLUIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcoes(VwPartida p) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent, 
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))
        ),
        padding: const EdgeInsets.only(bottom: 30),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              
              // --- CABEÇALHO DO MODAL (DETALHES DA PARTIDA) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text("Gerenciar Partida", style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: Text(p.identificadorTimeA, textAlign: TextAlign.right, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText))),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text("${p.pontosTimeA} x ${p.pontosTimeB}", style: TextStyle(fontWeight: FontWeight.w900, color: _primaryBlue, fontSize: 16)),
                        ),
                        Flexible(child: Text(p.identificadorTimeB, textAlign: TextAlign.left, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkText))),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Divider(height: 1),
              
              // --- OPÇÕES ---
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.edit_rounded, color: Colors.blue)), 
                title: const Text("Corrigir Placar", style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () { 
                  Navigator.pop(context); 
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PartidaPlacaPage(idPartida: p.codigo, pageBack: 1))); 
                }
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_outline_rounded, color: Colors.red)), 
                title: const Text("Excluir Partida", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context); 
                  _confirmarExclusaoPartida(p); 
                }
              ),
            ],
          ),
        )
      )
    );
  }
}