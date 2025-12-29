import 'package:cpv_app/features/partida/partida_placar_page.dart';
import 'package:cpv_app/features/partida/partida_service.dart';
import 'package:cpv_app/features/partida/vw_partida_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PartidaHistoricoPage extends StatefulWidget {
  final int codigoRacha;

  const PartidaHistoricoPage({
    super.key,
    required this.codigoRacha,
  });

  @override
  State<PartidaHistoricoPage> createState() => _PartidaHistoricoPageState();
}

class _PartidaHistoricoPageState extends State<PartidaHistoricoPage> {
  final _service = PartidaService();
  late Future<List<VwPartida>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listarPartidasV2(widget.codigoRacha);
  }

  String _formatarData(DateTime data) {
    final local = data.toLocal();
    return DateFormat('dd/MM/yyyy').format(local);
  }

  void _mostrarOpcoesPartida(VwPartida partida) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Alterar'),
                onTap: () {
                  Navigator.pop(context); // fecha o bottom sheet
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PartidaPlacaPage(idPartida: partida.codigo, pageBack: 1,),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarExclusao(partida.codigo);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _recarregar() {
  setState(() {
    _future = _service.listarPartidasV2(widget.codigoRacha);
  });
}

  void _confirmarExclusao(int codigoPartida) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Excluir partida'),
        content: const Text(
          'Tem certeza que deseja excluir esta partida?\n'
          'Essa ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha o dialog
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context); // fecha o dialog

              try {
                await _service.excluirPartida(codigoPartida);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Partida excluída com sucesso'),
                  ),
                );

                _recarregar();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir partida: $e'),
                  ),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Partidas'),
      ),
      body: FutureBuilder<List<VwPartida>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar histórico:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final partidas = snapshot.data ?? [];
          if (partidas.isEmpty) {
            return const Center(
              child: Text('Nenhuma partida encontrada.'),
            );
          }

          // ---------- AGRUPAR POR DATA ----------
          final Map<String, List<VwPartida>> porData = {};

          for (final p in partidas) {
            final chaveData = _formatarData(p.data);
            porData.putIfAbsent(chaveData, () => []);
            porData[chaveData]!.add(p);
          }

          // ordenar datas (mais recente primeiro)
          final datasOrdenadas = porData.keys.toList()
            ..sort((a, b) {
              final da = DateFormat('dd/MM/yyyy').parse(a);
              final db = DateFormat('dd/MM/yyyy').parse(b);
              return db.compareTo(da); // desc
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: datasOrdenadas.length,
            itemBuilder: (context, index) {
              final dataStr = datasOrdenadas[index];
              final listaDoDia = porData[dataStr]!;

              return _buildGrupoPorData(dataStr, listaDoDia);
            },
          );
        },
      ),
    );
  }

  Widget _buildGrupoPorData(
      String dataStr, List<VwPartida> partidasDoDia) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho da data
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            dataStr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Lista de partidas dessa data
        ...partidasDoDia.map((p) => _buildLinhaPartida(p)).toList(),

        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  Widget _buildLinhaPartida(VwPartida p) {
    return InkWell(
      onTap: () => _mostrarOpcoesPartida(p),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            // ------ LADO ESQUERDO (TIME A) ------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.identificadorTimeA,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${p.pontosTimeA}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ------ MEIO (X) ------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'X',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),

            // ------ LADO DIREITO (TIME B) ------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    p.identificadorTimeB,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${p.pontosTimeB}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
