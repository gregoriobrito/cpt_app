import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/partida/partida_ponto_time_detalhe_model.dart';
import 'package:cpv_app/features/partida/partida_ponto_time_model.dart';
import 'package:cpv_app/features/partida/partida_racha_page.dart';
import 'package:cpv_app/features/partida/partida_time_model.dart';
import 'package:cpv_app/features/partida/partida_usuario_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'partida_model.dart';
import 'partida_service.dart';

class PartidaPlacaPage extends StatefulWidget {
  final int idPartida;
  final int pageBack;

  const PartidaPlacaPage({
    super.key,
    required this.idPartida,
    required this.pageBack,
  });

  @override
  State<PartidaPlacaPage> createState() => _PartidaPlacaPageState();
}

class _PartidaPlacaPageState extends State<PartidaPlacaPage> {
  final _service = PartidaService();
  late Future<Partida> _future;

  // Vamos guardar a partida carregada para usar no _atualizarPlaca
  Partida? _partida;

  // Um controller para cada campo de pontuação
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _future = _service.burcar(widget.idPartida); // seu método existente
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _initControllersIfNeeded(Partida partida) {
    final times = partida.listaTime ?? [];

    // Se já tiver controllers com o mesmo tamanho, não recria
    if (_controllers.length == times.length) return;

    // Descarta controllers antigos (se tiver)
    for (final c in _controllers) {
      c.dispose();
    }

    _controllers = times
        .map((t) => TextEditingController(text: (t.pontuacao ?? 0).toString()))
        .toList();
  }

  Future<void> _atualizarPlaca() async {
    if (_partida == null || _partida!.listaTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partida ou times não carregados.')),
      );
      return;
    }

    final times = _partida!.listaTime!;
    List<PartidaPontoTimeDetalhe> lista = [];

    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      final pontosText = _controllers[i].text.trim();
      final pontos = int.tryParse(pontosText) ?? 0;
      lista.add(PartidaPontoTimeDetalhe(idTime: time.codigo, pontos: pontos));
    }

    try {
      await _service.atualizarPontos(PartidaPontoTime(lista: lista));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A pontuação foi atualizada.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar pontuação: $e')),
      );
    }
  }

  void _showExitConfirmationDialog(BuildContext context) {
    if (widget.pageBack == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PartidaHistoricoPage(codigoRacha: _partida!.codigoRacha!),
        ),
      );
    } else if (widget.pageBack == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PartidaUsuarioPage(codigoRacha: _partida!.codigoRacha!),
        ),
      );
    }
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return; // Se o pop já ocorreu por outro motivo, saia.
        }
        // Adicione sua lógica personalizada aqui, por exemplo:
        print("Botão de voltar pressionado! Exibindo diálogo de confirmação.");
        _showExitConfirmationDialog(context);
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // <--- fecha o teclado
        child: Scaffold(
          appBar: AppBar(title: const Text('Detalhes da Partida')),
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

              // Guarda a partida carregada no state
              _partida = partida;

              // Inicializa controllers de pontuação (se ainda não foram criados)
              _initControllersIfNeeded(partida);

              final listaTimes = partida.listaTime ?? [];

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
                              partida.racha?.nome ?? 'Racha',
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
                      itemCount: listaTimes.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final time = listaTimes[index];
                        final controller = _controllers[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(
                              time.identificador,
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
                              child: SizedBox(
                                width: 40,
                                child: TextFormField(
                                  controller: controller,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
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

          // ---------- BOTÃO INFERIOR ----------
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _atualizarPlaca,
                  child: const Text('Atualizar Pontuação'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
