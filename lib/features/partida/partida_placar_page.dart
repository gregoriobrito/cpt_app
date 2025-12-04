import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'partida_model.dart';
import 'partida_service.dart';

class PartidaPlacaPage extends StatefulWidget {
  final int idPartida;

  const PartidaPlacaPage({
    super.key,
    required this.idPartida,
  });

  @override
  State<PartidaPlacaPage> createState() => _PartidaPlacaPageState();
}

class _PartidaPlacaPageState extends State<PartidaPlacaPage> {
  final _service = PartidaService();
  late Future<Partida> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.burcar(widget.idPartida);
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Partida'),
      ),
      body: FutureBuilder<Partida>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar partida:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final partida = snapshot.data;
          if (partida == null) {
            return const Center(child: Text('Partida não encontrada.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Card com dados principais ----------
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partida.racha!.nome, //partida.racha.nome,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _formatarData(partida.data),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Times',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // ---------- Lista de times ----------
                ListView.builder(
                  itemCount: partida.listaTime?.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final time = partida.listaTime?[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          time!.identificador,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${time.pontuacao}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
