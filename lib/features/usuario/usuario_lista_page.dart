import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/racha/racha_service.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:cpv_app/features/usuario/usuario_vincular_model.dart';
import 'package:cpv_app/features/usuario/usuario_vincular_page.dart';
import 'package:flutter/material.dart';

class UsuarioListaPage extends StatefulWidget {
  final int codigoRacha;
  const UsuarioListaPage({super.key, required this.codigoRacha});

  @override
  State<UsuarioListaPage> createState() => _UsuarioListaPageState();
}

class _UsuarioListaPageState extends State<UsuarioListaPage> {
  final _service = RachaService();
  late Future<List<Usuario>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listarUsuario(widget.codigoRacha); // ID do racha
  }

  void _recarregar() {
    setState(() {
      _future = _service.listarUsuario(widget.codigoRacha); // ID do racha
    });
  }

  void _confirmarExclusao(Usuario elemento) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Confirma desvincular o usuário?'),
          content: Text(
            'Apelido: ${elemento.apelido} \n'
            'Nome: ${elemento.nome} \n',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // fecha o dialog
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context); // fecha o dialog

                try {
                  UsuarioVincular vincular = UsuarioVincular(
                    codigoUsuario: elemento.codigo,
                    codigoRacha: widget.codigoRacha,
                  );
                  await UsuarioService().desvincular(vincular);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuário desvinculado com sucesso!'),
                    ),
                  );

                  _recarregar();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao vincular o usuário: $e')),
                  );
                }
              },
              child: const Text('Desvincular'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarOpcoesRacha(Usuario r) {
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
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Administrador'),
                onTap: () {
                  Navigator.pop(context); // fecha o bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PartidaHistoricoPage(codigoRacha: r.codigo),
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
                  _confirmarExclusao(r);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // fundo cinza

      appBar: AppBar(
        title: const Text('Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Encontrar jogador',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      UsuarioVincularPage(codigoRacha: widget.codigoRacha),
                ),
              );
            },
          ),
        ],
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

          final rachas = snapshot.data ?? [];

          if (rachas.isEmpty) {
            return const Center(child: Text('Nenhum racha encontrado'));
          }

          return ListView.builder(
            itemCount: rachas.length,
            itemBuilder: (context, index) {
              final r = rachas[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white, // cada linha branca
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _mostrarOpcoesRacha(r);
                      },
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
