import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/relatorio/relatorio_racha_page.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:cpv_app/main.dart';
import 'package:flutter/material.dart';
import 'package:cpv_app/features/racha/racha_page.dart';
import 'package:cpv_app/features/partida/partida_racha_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<String> _carregarUsuario() async {
    final usuarioService = UsuarioService();
    final usuario = await usuarioService.buscar();
    return usuario.apelido;
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Sair"),
          content: const Text("Deseja realmente sair do aplicativo?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // fecha dialog
                await ApiClient().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text("Sair"),
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
        title: const Text("Controlador de Pontos"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmarLogout(context),
          ),
        ],
      ),

      body: FutureBuilder<String>(
        future: _carregarUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar usuário: ${snapshot.error}"));
          }

          final nomeUsuario = snapshot.data ?? "Capivara";

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Olá, $nomeUsuario!",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _HomeButton(
                      label: "Rachas",
                      icon: Icons.groups,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RachaPage(),
                          ),
                        );
                      },
                    ),
                    _HomeButton(
                      label: "Partidas",
                      icon: Icons.sports_soccer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PartidaRachaPage(),
                          ),
                        );
                      },
                    ),
                    _HomeButton(
                      label: "Estatísticas",
                      icon: Icons.bar_chart,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RelatorioRachaPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


// --------------------- WIDGET DO BOTÃO ---------------------
class _HomeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.blue.shade700),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}