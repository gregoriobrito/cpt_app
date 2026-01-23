import 'package:cpv_app/features/partida/partida_model.dart';
import 'package:cpv_app/features/partida/partida_placar_page.dart';
import 'package:cpv_app/features/partida/partida_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PartidasPage extends StatefulWidget {
  final int codigoRacha;
  const PartidasPage({super.key, required this.codigoRacha});

  @override
  State<PartidasPage> createState() => _PartidasPageState();
}

class _PartidasPageState extends State<PartidasPage> {
  final _service = PartidaService();
  late Future<List<Partida>> _future;

  // Design System
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _blue = const Color(0xFF2979FF);

  @override
  void initState() {
    super.initState();
    _future = _service.listarPartidas(widget.codigoRacha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text("Histórico de Jogos", style: TextStyle(color: Color(0xFF1E2230), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E2230)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Partida>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final partidas = snapshot.data ?? [];
          if (partidas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_volleyball_outlined, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text("Nenhuma partida registrada", style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            itemCount: partidas.length,
            separatorBuilder: (_,__) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final p = partidas[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: _blue.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaPlacaPage(idPartida: p.codigo, pageBack: 3))),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Box da Data
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: _blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('dd').format(p.data!),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _blue),
                              ),
                              Text(
                                DateFormat('MMM').format(p.data!).toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _blue),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        
                        // Infos
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.identificador!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E2230))),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: Colors.green.shade400),
                                  const SizedBox(width: 4),
                                  Text("Finalizada", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}