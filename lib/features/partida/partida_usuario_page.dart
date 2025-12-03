import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:flutter/material.dart';
import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/racha/racha_service.dart';

class PartidaUsuarioPage extends StatefulWidget {
  const PartidaUsuarioPage({super.key});

  @override
  State<PartidaUsuarioPage> createState() => _PartidaUsuarioPageState();
}

class _PartidaUsuarioPageState extends State<PartidaUsuarioPage> {
  final _service = RachaService();
  late Future<List<Usuario>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listarUsuario(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // fundo cinza

      appBar: AppBar(
        title: const Text('Jogadores - Cadastrar Partida'),
      ),

      body: FutureBuilder<List<Usuario>>(
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

          final jogadores = snapshot.data ?? [];

          if (jogadores.isEmpty) {
            return const Center(
              child: Text('Nenhum jogador encontrado'),
            );
          }

          return ListView.builder(
            itemCount: jogadores.length,
            itemBuilder: (context, index) {
              final r = jogadores[index];

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

                    // Botão (direita)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,MaterialPageRoute(builder: (_) => const PartidaUsuarioPage(),),);
                      },
                      child: const Text("Seleecionar"),
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