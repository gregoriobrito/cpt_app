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
      backgroundColor: Colors.grey[200],

      appBar: AppBar(title: const Text('Partidas')),

      body: FutureBuilder<List<Partida>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final partidas = snapshot.data ?? [];

          if (partidas.isEmpty) {
            return const Center(child: Text('Nenhuma partida encontrada'));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ...partidas.map((partida) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partida.identificador,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(partida.data),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PartidaPlacaPage(
                              idPartida: partida.codigo, pageBack: 3,
                            ),
                          ),
                        );
                      },
                      child: const Text("Alterar"),
                    ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
