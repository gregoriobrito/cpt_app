import 'package:flutter/material.dart';
import 'racha_model.dart';
import 'racha_service.dart';

class RachaPage extends StatefulWidget {
  const RachaPage({super.key});

  @override
  State<RachaPage> createState() => _RachaPageState();
}

class _RachaPageState extends State<RachaPage> {
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
      appBar: AppBar(
        title: const Text('Rachas'),
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
              return ListTile(
                title: Text(r.nome),
                subtitle: Text('Código: ${r.codigo}'),
              );
            },
          );
        },
      ),
    );
  }
}
