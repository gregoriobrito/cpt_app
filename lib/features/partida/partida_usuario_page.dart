import 'package:cpv_app/features/partida/partida_cadastrar_model.dart';
import 'package:cpv_app/features/partida/partida_placar_page.dart';
import 'package:cpv_app/features/partida/partida_service.dart';
import 'package:cpv_app/features/partida/partida_time_model.dart';
import 'package:cpv_app/features/partida/partida_usuario_time_model.dart';
import 'package:flutter/material.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/racha/racha_service.dart';

class PartidaUsuarioPage extends StatefulWidget {
  final int codigoRacha;
  const PartidaUsuarioPage({super.key, required this.codigoRacha});

  @override
  State<PartidaUsuarioPage> createState() => _PartidaUsuarioPageState();
}

class _PartidaUsuarioPageState extends State<PartidaUsuarioPage> {
  final _service = RachaService();
  late Future<List<Usuario>> _future;

  // time que está sendo editado agora (1 ou 2)
  int _timeAtual = 1;

  // jogadorId -> número do time (1, 2, ...)
  final Map<int, int> _timePorJogador = {};

  @override
  void initState() {
    super.initState();
    _future = _service.listarUsuario(widget.codigoRacha); // ID do racha
  }

  void _toggleSelecionado(int idJogador) {
    setState(() {
      final timeAtualDoJogador = _timePorJogador[idJogador];

      // Se já está neste time, remove (desmarca)
      if (timeAtualDoJogador == _timeAtual) {
        _timePorJogador.remove(idJogador);
      } else {
        // Coloca o jogador no time atual
        _timePorJogador[idJogador] = _timeAtual;
      }
    });
  }

  void _trocarTime() {
    setState(() {
      _timeAtual = _timeAtual == 1 ? 2 : 1;
    });
  }

  void _cadastrarPartida() async {
    final jogadoresTime1 = _timePorJogador.entries
        .where((e) => e.value == 1)
        .map((e) => e.key)
        .toList();

    final jogadoresTime2 = _timePorJogador.entries
        .where((e) => e.value == 2)
        .map((e) => e.key)
        .toList();

    if (jogadoresTime1.isEmpty || jogadoresTime2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione jogadores para os dois times antes de cadastrar.'),
        ),
      );

      return;
    }

    final request = PartidaCadastrar(
      codigoRacha: widget.codigoRacha, // você passou esse valor na navegação
      listaTime: [
        PartidaTime(
          listaUsuario: jogadoresTime1
              .map((codigoUsu) => PartidaUsuarioTime(codigo: codigoUsu))
              .toList(),
        ),
        PartidaTime(
          listaUsuario: jogadoresTime2
              .map((codigoUsu) => PartidaUsuarioTime(codigo: codigoUsu))
              .toList(),
        ),
      ],
    );

    try {
      final service = PartidaService();
      final partida = await service.cadastrar(request);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Partida cadastrada!"),
        ),
      );

     Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PartidaPlacaPage(idPartida: partida.codigo),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao cadastrar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

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
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final jogadores = snapshot.data ?? [];

          if (jogadores.isEmpty) {
            return const Center(child: Text('Nenhum jogador encontrado'));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // ---------- TÍTULO DO TIME ----------
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Time $_timeAtual",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ---------- LISTA DE JOGADORES ----------
              ...jogadores.map((usuario) {
                final timeDoJogador = _timePorJogador[usuario.codigo];
                final isSelecionadoNoTimeAtual = timeDoJogador == _timeAtual;
                final emOutroTime =
                    timeDoJogador != null && timeDoJogador != _timeAtual;

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
                      // Nome + Apelido
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usuario.nome,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (usuario.apelido != null &&
                              usuario.apelido!.isNotEmpty)
                            Text(
                              usuario.apelido!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),

                      // Botão / estado de seleção
                      if (emOutroTime)
                        OutlinedButton(
                          onPressed: null,
                          child: Text('No Time $timeDoJogador'),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => _toggleSelecionado(usuario.codigo),
                          icon: Icon(
                            isSelecionadoNoTimeAtual
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: Colors.white,
                          ),
                          label: Text(
                            isSelecionadoNoTimeAtual
                                ? "Selecionado"
                                : "Selecionar",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelecionadoNoTimeAtual
                                ? Colors.green
                                : Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),

      // ---------- BOTÕES INFERIORES ----------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _timeAtual == 1
              // TIME 1 → só botão de continuar
              ? SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _trocarTime,
                    child: const Text('Continuar (selecionar Time 2)'),
                  ),
                )
              // TIME 2 → cadastrar partida + voltar pro time 1
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cadastrarPartida,
                        child: const Text('Cadastrar partida'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _trocarTime,
                        child: const Text('Voltar para Time 1'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
