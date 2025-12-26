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

  @override
  void initState() {
    super.initState();
    _future = _service.listarRacha();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // fundo cinza

      appBar: AppBar(
        title: const Text('Estatísticas - Rachas'),
      ),

      body: FutureBuilder<List<Racha>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          final rachas = snapshot.data ?? [];

          if (rachas.isEmpty) {
            return const Center(
              child: Text('Nenhum racha encontrado'),
            );
          }

          return ListView.builder(
            itemCount: rachas.length,
            itemBuilder: (context, index) {
              final r = rachas[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,       // cada linha branca
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nome do racha (esquerda)
                    Text(
                      r.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        _abrirBottomSheet(context, r.codigo);
                      },
                      child: const Text("Estatísticas"),
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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título do sheet
            const Text(
              'Selecionar tipo de relatório',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // fecha o bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RelatorioEstatisticaPage(
                        idRacha: codigoRacha, tipoRacha: 1,
                      ),
                    ),
                  );
                },
                child: const Text("Geral"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // fecha o bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RelatorioEstatisticaPage(
                        idRacha: codigoRacha, tipoRacha: 2,
                      ),
                    ),
                  );
                },
                child: const Text("Data"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // fecha o bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RelatorioEstatisticaPage(
                        idRacha: codigoRacha, tipoRacha: 3,
                      ),
                    ),
                  );
                },
                child: const Text("Mes"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // fecha o bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RelatorioEstatisticaPage(
                        idRacha: codigoRacha, tipoRacha: 4,
                      ),
                    ),
                  );
                },
                child: const Text("Ano"),
              ),
            ),
          ],
        ),
      );
    },
  );
}
}