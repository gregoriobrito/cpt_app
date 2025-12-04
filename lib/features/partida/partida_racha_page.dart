import 'package:cpv_app/features/partida/partida_usuario_page.dart';
import 'package:flutter/material.dart';
import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/racha/racha_service.dart';

class PartidaRachaPage extends StatefulWidget {
  const PartidaRachaPage({super.key});

  @override
  State<PartidaRachaPage> createState() => _PartidaRachaPageState();
}

class _PartidaRachaPageState extends State<PartidaRachaPage> {
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
        title: const Text('Rachas - Cadastrar Partida'),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PartidaUsuarioPage(
                              codigoRacha: r.codigo, // ou r.id, conforme seu model
                            ),
                          ),
                        );
                      },
                      child: const Text("Cadastrar"),
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