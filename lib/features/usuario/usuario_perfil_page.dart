import 'dart:io';
import 'dart:ui';

import 'package:cpv_app/core/api_client.dart';
import 'package:cpv_app/features/partida/partida_historico_page.dart';
import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/racha/racha_service.dart';
import 'package:cpv_app/features/usuario/usuario_alterar_model.dart';
import 'package:cpv_app/features/usuario/usuario_alterar_senha_page.dart';
import 'package:cpv_app/features/usuario/usuario_informacoes_model.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UsuarioPerfilPage extends StatefulWidget {
  final Usuario usuario;
  final Racha racha;

  const UsuarioPerfilPage({
    super.key,
    required this.usuario,
    required this.racha,
  });

  @override
  State<UsuarioPerfilPage> createState() => _UsuarioPerfilPageState();
}

class _UsuarioPerfilPageState extends State<UsuarioPerfilPage> {
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);

  bool _loading = false;
  bool _isEditing = false;

  late TextEditingController _nomeController;
  late TextEditingController _apelidoController;
  late TextEditingController _loginController;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  late Future<InformacoesUsuario> _informacoesUsuario;
  late Future<Usuario> _usuarioFuture;

  @override
  void initState() {
    super.initState();

    _nomeController = TextEditingController(text: widget.usuario.nome);
    _apelidoController = TextEditingController(
      text: widget.usuario.apelido ?? "",
    );
    _loginController = TextEditingController(text: widget.usuario.login);

    _carregarInformacoesUsuario();
    _carregarUsuario();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _apelidoController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  void _carregarInformacoesUsuario() {
    _informacoesUsuario = RachaService().informacoesUsuario(
      widget.racha.codigo,
    );
  }

  void _carregarUsuario() {
    _usuarioFuture = UsuarioService().buscar();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,      // qualidade JPEG (0-100)
        maxWidth: 400,
        maxHeight: 400,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      setState(() {
        _imageFile = file;
      });

      await _uploadImagem(file);

      if (!mounted) return;

      setState(() {
        _carregarUsuario();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Imagem atualizada com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _uploadImagem(File imagem) async {
    final uri = Uri.parse('${ApiClient().baseUrl}/usuario/imagemPerfil');

    final request = http.MultipartRequest('POST', uri);
    String? token = ApiClient().token;

    request.headers.addAll({
    'Authorization': 'Bearer $token'
  });

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto',
        imagem.path,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao enviar imagem: ${response.statusCode} - $body');
    }
  }

  Future<void> _sairDoRacha(Racha r) async {
    try {
      await RachaService().deletar(r.codigo);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Você saiu do grupo."),
          backgroundColor: Colors.grey,
        ),
      );

      setState(() {
        _carregarInformacoesUsuario();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao sair: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmarSaida(Racha r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Sair do Racha?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text("Deseja realmente sair do grupo '${r.nome}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "CANCELAR",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _sairDoRacha(r);
            },
            child: const Text(
              "SAIR",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcoesRacha(Racha r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(bottom: 30),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.groups, color: _primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        r.nome,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _darkText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history_edu_rounded,
                    color: Colors.orange,
                  ),
                ),
                title: const Text(
                  "Ver Histórico",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PartidaHistoricoPage(racha: r),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: Colors.red,
                  ),
                ),
                title: const Text(
                  "Sair do Racha",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarSaida(r);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _voltar() {
    Navigator.pop(context, true);
  }

  Future<void> _toggleEdit() async {
    if (_isEditing) {
      try {
        setState(() => _loading = true);

        final login = _loginController.text.trim().toUpperCase();
        final nome = _nomeController.text.trim().toUpperCase();
        final apelido = _apelidoController.text.trim().toUpperCase();

        final request = UsuarioAlterar(
          nome: nome,
          apelido: apelido,
          login: login,
        );

        await UsuarioService().alterar(request);

        if (!mounted) return;

        _loginController.text = login;
        _nomeController.text = nome;
        _apelidoController.text = apelido;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perfil atualizado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }

    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _voltar();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black,
              ),
            ),
            onPressed: _voltar,
          ),
          title: const Text(
            "Meu Perfil",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _loading ? null : _toggleEdit,
              child: Text(
                _loading
                    ? "..."
                    : _isEditing
                        ? "SALVAR"
                        : "EDITAR",
                style: TextStyle(
                  color: _primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder<Usuario>(
          future: _usuarioFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erro ao carregar usuário: ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text("Usuário não encontrado."),
              );
            }

            final usuario = snapshot.data!;

            return Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primaryBlue.withOpacity(0.4),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 110, 24, 24),
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryBlue.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: _imageFile != null
                                      ? Image.file(
                                          _imageFile!,
                                          fit: BoxFit.cover,
                                        )
                                      : usuario.flagImagem == "S"
                                          ? Image.network(
                                              '${ApiClient().baseUrl}/usuario/imagemPerfil/${usuario.codigo}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return _buildAvatarInicial(
                                                  usuario.nome,
                                                );
                                              },
                                            )
                                          : _buildAvatarInicial(usuario.nome),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _primaryBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      FutureBuilder<InformacoesUsuario>(
                        future: _informacoesUsuario,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text(
                              "Erro ao carregar informações: ${snapshot.error}",
                              textAlign: TextAlign.center,
                            );
                          }

                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final info = snapshot.data!;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(
                                "Partidas",
                                info.totalPartida.toString(),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.shade300,
                              ),
                              _buildStatItem(
                                "Vitórias",
                                info.vitorias.toString(),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey.shade300,
                              ),
                              _buildStatItem(
                                "Pontos",
                                info.pontos.toString(),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Informações Pessoais",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _darkText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildEditableField(
                              "Nome Completo",
                              _nomeController,
                              Icons.person,
                            ),
                            const SizedBox(height: 20),
                            _buildEditableField(
                              "Apelido",
                              _apelidoController,
                              Icons.face,
                            ),
                            const SizedBox(height: 20),
                            _buildEditableField(
                              "Login",
                              _loginController,
                              Icons.email,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Conta",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _darkText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                              ),
                              title: const Text(
                                "Alterar Senha",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey,
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const UsuarioAlterarSenhaPage(),
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.notifications_none,
                                color: Colors.grey,
                              ),
                              title: const Text(
                                "Notificações",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: Switch(
                                value: true,
                                onChanged: (v) {},
                                activeColor: _primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarInicial(String nome) {
    return Container(
      color: _primaryBlue.withOpacity(0.1),
      alignment: Alignment.center,
      child: Text(
        nome.isNotEmpty ? nome[0].toUpperCase() : "U",
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: _primaryBlue,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _primaryBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: _isEditing,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _isEditing ? Colors.black : _darkText,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _primaryBlue),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor:
                _isEditing ? Colors.blue.shade50 : const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRachaItem(Racha racha) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.groups, color: _primaryBlue),
        ),
        title: Text(
          racha.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Icon(
          Icons.more_horiz_rounded,
          size: 24,
          color: Colors.grey.shade400,
        ),
        onTap: () => _mostrarOpcoesRacha(racha),
      ),
    );
  }
}