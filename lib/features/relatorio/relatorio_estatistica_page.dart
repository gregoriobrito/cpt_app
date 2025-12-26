import 'package:flutter/material.dart';

import 'relatorio_model.dart';
import 'relatorio_service.dart';

class RelatorioEstatisticaPage extends StatefulWidget {
  final int idRacha;
  final int tipoRacha;

  const RelatorioEstatisticaPage({
    super.key,
    required this.idRacha,
    required this.tipoRacha
  });

  @override
  State<RelatorioEstatisticaPage> createState() =>
      _RelatorioEstatisticaPageState();
}

class _RelatorioEstatisticaPageState extends State<RelatorioEstatisticaPage> {
  final _service = RelatorioService();
  late Future<Relatorio> _future;

  @override
  void initState() {
    super.initState();
    if (widget.tipoRacha == 1) {
      _future = _service.buscarRelatorioGeral(widget.idRacha);
    }
    else if (widget.tipoRacha == 2) {
      _future = _service.buscarRelatorioData(widget.idRacha);
    }
    else if (widget.tipoRacha == 3) {
      _future = _service.buscarRelatorioMes(widget.idRacha);
    }
    else if (widget.tipoRacha == 4) {
      _future = _service.buscarRelatorioAno(widget.idRacha);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
      ),
      body: FutureBuilder<Relatorio>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar relatório:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final relatorio = snapshot.data;
          if (relatorio == null) {
            return const Center(child: Text('Nenhum dado encontrado.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Nome do relatório
                Text(
                  relatorio.nomeRelatorio,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Lista de agrupadores
                ...relatorio.lista.map((grupo) {
                  return _buildGrupoCard(grupo);
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrupoCard(GrupoResultado grupo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Nome do agrupador
            Text(
              grupo.agrupador,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 16),

            // 3. Lista de jogadores (nome + apelido + pontuação)
            ...grupo.listaResultado.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Esquerda: nome e apelido
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item.apelido,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    // Direita: pontuação
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item.pontuacao}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
