import 'package:flutter/material.dart';
import 'package:cpv_app/features/racha/racha_page.dart';
import 'package:cpv_app/features/partida/partida_racha_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const nomeUsuario = "Gregório"; // fixo por enquanto

    return Scaffold(
      appBar: AppBar(
        title: const Text("Início"),
        centerTitle: true,
      ),
      body: Padding(
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

            // ---------- Botões ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _HomeButton(
                  label: "Rachas",
                  icon: Icons.groups,
                  onTap: () {
                    Navigator.push(context,MaterialPageRoute(builder: (_) => const RachaPage(),),);
                  },
                ),
                _HomeButton(
                  label: "Partidas",
                  icon: Icons.sports_soccer,
                  onTap: () {
                    Navigator.push(context,MaterialPageRoute(builder: (_) => const PartidaRachaPage(),),);
                  },
                ),
                _HomeButton(
                  label: "Estatísticas",
                  icon: Icons.bar_chart,
                  onTap: () {
                    // Navigator.push(...);
                  },
                ),
              ],
            ),
          ],
        ),
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
