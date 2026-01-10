import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/racha/racha_service.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:cpv_app/features/usuario/usuario_vincular_model.dart';
import 'package:cpv_app/features/usuario/usuario_vincular_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UsuarioListaPage extends StatefulWidget {
  final int codigoRacha;
  const UsuarioListaPage({super.key, required this.codigoRacha});

  @override
  State<UsuarioListaPage> createState() => _UsuarioListaPageState();
}

class _UsuarioListaPageState extends State<UsuarioListaPage> {
  final _service = RachaService();
  late Future<List<Usuario>> _future;

  // --- DESIGN SYSTEM ---
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _future = _service.listarUsuario(widget.codigoRacha);
  }

  void _recarregar() {
    setState(() {
      _future = _service.listarUsuario(widget.codigoRacha);
    });
  }

  void _confirmarExclusao(Usuario elemento) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Remover Jogador?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tem certeza que deseja desvincular este atleta?"),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Icon(Icons.person_remove, color: Colors.red.shade700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(elemento.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(elemento.apelido ?? "", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  UsuarioVincular vincular = UsuarioVincular(
                    codigoUsuario: elemento.codigo,
                    codigoRacha: widget.codigoRacha,
                  );
                  await UsuarioService().desvincular(vincular);
                  if(!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário desvinculado com sucesso!')));
                  _recarregar();
                } catch (e) {
                  if(!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
                }
              },
              child: const Text('REMOVER'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarOpcoesRacha(Usuario r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                
                // Header do Usuário no Sheet
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _primaryBlue.withOpacity(0.1),
                        child: Text(r.nome.substring(0,1), style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Gerenciar atleta", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.history_edu, color: Colors.orange),
                  ),
                  title: const Text('Histórico do Jogador', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaHistoricoPage(codigoRacha: r.codigo)));
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.person_remove_outlined, color: Colors.red),
                  ),
                  title: const Text('Remover do Time', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmarExclusao(r);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text('ATLETAS', style: TextStyle(color: _darkText, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _darkText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _primaryBlue, shape: BoxShape.circle),
                child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
              ),
              tooltip: 'Vincular jogador',
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UsuarioVincularPage(codigoRacha: widget.codigoRacha)));
              },
            ),
          ),
        ],
      ),

      body: FutureBuilder<List<Usuario>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final usuarios = snapshot.data ?? [];
          if (usuarios.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off_rounded, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text('Nenhum atleta vinculado', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: usuarios.length,
            separatorBuilder: (_,__) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final u = usuarios[index];
              final inicial = u.nome.isNotEmpty ? u.nome.substring(0, 1).toUpperCase() : "?";

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: _primaryBlue.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: _primaryBlue.withOpacity(0.1),
                    child: Text(inicial, style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(u.nome, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _darkText)),
                  subtitle: u.apelido != null && u.apelido!.isNotEmpty 
                      ? Text(u.apelido!, style: TextStyle(color: Colors.grey.shade500)) 
                      : null,
                  trailing: IconButton(
                    icon: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade400),
                    onPressed: () => _mostrarOpcoesRacha(u),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}