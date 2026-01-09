import 'package:flutter/material.dart';
import 'package:cpv_app/features/partida/partida_cadastrar_model.dart';
import 'package:cpv_app/features/partida/partida_placar_page.dart';
import 'package:cpv_app/features/partida/partida_service.dart';
import 'package:cpv_app/features/partida/partida_time_model.dart';
import 'package:cpv_app/features/partida/partida_usuario_time_model.dart';
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

  int _timeAtual = 1; // 1 ou 2
  final Map<int, int> _timePorJogador = {}; // Map<ID_JOGADOR, ID_TIME>

  @override
  void initState() {
    super.initState();
    _future = _service.listarUsuario(widget.codigoRacha);
  }

  void _toggleSelecionado(int idJogador) {
    setState(() {
      final timeDoJogador = _timePorJogador[idJogador];
      if (timeDoJogador == _timeAtual) {
        _timePorJogador.remove(idJogador); // Desmarca
      } else {
        _timePorJogador[idJogador] = _timeAtual; // Marca no time atual
      }
    });
  }

  void _trocarTime() {
    setState(() {
      _timeAtual = (_timeAtual == 1) ? 2 : 1;
    });
  }

  int _contarJogadores(int time) {
    return _timePorJogador.values.where((t) => t == time).length;
  }

  void _cadastrarPartida() async {
    final t1 = _timePorJogador.entries.where((e) => e.value == 1).map((e) => e.key).toList();
    final t2 = _timePorJogador.entries.where((e) => e.value == 2).map((e) => e.key).toList();

    if (t1.isEmpty || t2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione pelo menos 1 jogador para cada time!'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final request = PartidaCadastrar(
      codigoRacha: widget.codigoRacha,
      listaTime: [
        PartidaTime(listaUsuario: t1.map((id) => PartidaUsuarioTime(codigo: id)).toList()),
        PartidaTime(listaUsuario: t2.map((id) => PartidaUsuarioTime(codigo: id)).toList()),
      ],
    );

    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      
      final partida = await PartidaService().cadastrar(request);
      
      if (!mounted) return;
      Navigator.pop(context); // Fecha loading

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PartidaPlacaPage(idPartida: partida.codigo, pageBack: 2)),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Fecha loading se der erro
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cores temáticas para cada time
    final corTime = _timeAtual == 1 ? const Color(0xFF1976D2) : const Color(0xFF2E7D32);
    final nomeTime = _timeAtual == 1 ? "Time Azul" : "Time Verde";

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          // --- HEADER DINÂMICO ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 180,
            decoration: BoxDecoration(
              color: corTime,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [BoxShadow(color: corTime.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            "Montar Equipes",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const Spacer(),
                    
                    // Seletor de Time Visual
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_timeAtual == 1 ? Icons.shield : Icons.shield_outlined, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "SELECIONANDO",
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, letterSpacing: 1),
                              ),
                              Text(
                                nomeTime.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              "${_contarJogadores(_timeAtual)} JOGADORES",
                              style: TextStyle(color: corTime, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          // --- LISTA DE JOGADORES ---
          Expanded(
            child: FutureBuilder<List<Usuario>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return const Center(child: Text("Erro ao carregar jogadores"));
                
                final jogadores = snapshot.data ?? [];
                if (jogadores.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_rounded, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text("Nenhum jogador cadastrado neste racha", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), // Espaço para o botão flutuante
                  physics: const BouncingScrollPhysics(),
                  itemCount: jogadores.length,
                  itemBuilder: (context, index) {
                    final usuario = jogadores[index];
                    final timeSelecionado = _timePorJogador[usuario.codigo];
                    final isNoTimeAtual = timeSelecionado == _timeAtual;
                    final isEmOutroTime = timeSelecionado != null && timeSelecionado != _timeAtual;

                    return GestureDetector(
                      onTap: isEmOutroTime ? null : () => _toggleSelecionado(usuario.codigo),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isNoTimeAtual ? corTime.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isNoTimeAtual ? corTime : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isEmOutroTime 
                                  ? Colors.grey.shade300 
                                  : (isNoTimeAtual ? corTime : Colors.grey.shade200),
                              child: Icon(Icons.person, color: isNoTimeAtual ? Colors.white : Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    usuario.nome,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isEmOutroTime ? Colors.grey : Colors.black87,
                                    ),
                                  ),
                                  if (isEmOutroTime)
                                    Text(
                                      "Já está no outro time",
                                      style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                                    ),
                                  if (usuario.apelido != null && !isEmOutroTime)
                                    Text(
                                      usuario.apelido!,
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                    ),
                                ],
                              ),
                            ),
                            if (isNoTimeAtual)
                              Icon(Icons.check_circle, color: corTime),
                            if (!isNoTimeAtual && !isEmOutroTime)
                              Icon(Icons.circle_outlined, color: Colors.grey.shade300),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // --- BOTÃO DE AÇÃO FLUTUANTE (FAB) ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _timeAtual == 1 ? _trocarTime : _cadastrarPartida,
            style: ElevatedButton.styleFrom(
              backgroundColor: corTime,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _timeAtual == 1 ? "PRÓXIMO: TIME 2" : "FINALIZAR E JOGAR",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                ),
                const SizedBox(width: 8),
                Icon(_timeAtual == 1 ? Icons.arrow_forward : Icons.sports_soccer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}