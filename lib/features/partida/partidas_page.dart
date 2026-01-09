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

  @override
  void initState() {
    super.initState();
    _future = _service.listarPartidas(widget.codigoRacha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Histórico"),
        backgroundColor: const Color(0xFF0D47A1), // Azul Navy
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: FutureBuilder<List<Partida>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Erro ao carregar'));
          final partidas = snapshot.data ?? [];

          if (partidas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text("Nenhuma partida ainda", style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: partidas.length,
            itemBuilder: (context, index) {
              final p = partidas[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    // Data em Destaque
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('dd').format(p.data!),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue.shade800),
                          ),
                          Text(
                            DateFormat('MMM').format(p.data!).toUpperCase(),
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.identificador!, // Ex: "Partida #123"
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text("Finalizada", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Botão Ação
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaPlacaPage(idPartida: p.codigo, pageBack: 3,)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text("Ver Placar"),
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
}