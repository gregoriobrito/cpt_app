import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importante para salvar
import 'package:cpv_app/features/racha/racha_model.dart';
import 'package:cpv_app/features/racha/racha_service.dart';
import 'package:cpv_app/features/usuario/usuario_model.dart';
import 'package:cpv_app/features/partida/partida_historico_page.dart';

class UsuarioPerfilPage extends StatefulWidget {
  final Usuario usuario;

  const UsuarioPerfilPage({super.key, required this.usuario});

  @override
  State<UsuarioPerfilPage> createState() => _UsuarioPerfilPageState();
}

class _UsuarioPerfilPageState extends State<UsuarioPerfilPage> {
  // Cores Design System
  final Color _primaryBlue = const Color(0xFF2979FF);
  final Color _darkText = const Color(0xFF1E2230);

  bool _isEditing = false;
  late TextEditingController _nomeController;
  late TextEditingController _apelidoController;
  late TextEditingController _loginController;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  late Future<List<Racha>> _rachasFuture;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _apelidoController = TextEditingController(text: widget.usuario.apelido ?? "");
    _loginController = TextEditingController(text: widget.usuario.login);
    
    _rachasFuture = RachaService().listarRacha();
    _carregarFotoSalva(); // Carrega a foto ao abrir
  }

  // --- LÓGICA DE PERSISTÊNCIA DA FOTO ---
  Future<void> _carregarFotoSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null) {
      setState(() {
        _imageFile = File(path);
      });
    }
  }

  Future<void> _salvarFoto(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        await _salvarFoto(pickedFile.path); // Salva no disco
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  void _voltar() {
    // Retorna true para indicar que pode ter havido mudança
    Navigator.pop(context, true);
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Simulação de salvamento
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado com sucesso!"), backgroundColor: Colors.green),
      );
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
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            ),
            onPressed: _voltar,
          ),
          title: const Text("Meu Perfil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _toggleEdit,
              child: Text(
                _isEditing ? "SALVAR" : "EDITAR",
                style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            // Fundo Decorativo
            Positioned(
              top: -100, left: -50,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _primaryBlue.withOpacity(0.4)),
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
                  // --- 1. FOTO DE PERFIL ---
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: _primaryBlue.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: _primaryBlue.withOpacity(0.1),
                            backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                            child: _imageFile == null
                                ? Text(
                                    widget.usuario.nome.isNotEmpty ? widget.usuario.nome[0].toUpperCase() : "U",
                                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _primaryBlue),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _primaryBlue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // --- 2. ESTATÍSTICAS RÁPIDAS (NOVO) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem("Partidas", "42"),
                      Container(width: 1, height: 40, color: Colors.grey.shade300),
                      _buildStatItem("Vitórias", "28"),
                      Container(width: 1, height: 40, color: Colors.grey.shade300),
                      _buildStatItem("MVP", "5"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- 3. DADOS PESSOAIS ---
                  Align(alignment: Alignment.centerLeft, child: Text("Informações Pessoais", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _darkText))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        _buildEditableField("Nome Completo", _nomeController, Icons.person),
                        const SizedBox(height: 20),
                        _buildEditableField("Apelido", _apelidoController, Icons.face),
                        const SizedBox(height: 20),
                        _buildEditableField("Login", _loginController, Icons.email),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 4. RACHAS VINCULADOS ---
                  Align(alignment: Alignment.centerLeft, child: Text("Meus Rachas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _darkText))),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Racha>>(
                    future: _rachasFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: const Center(child: Text("Sem rachas vinculados.")),
                        );
                      }
                      return Column(
                        children: snapshot.data!.map((racha) => _buildRachaItem(racha)).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // --- 5. CONFIGURAÇÕES (NOVO) ---
                  Align(alignment: Alignment.centerLeft, child: Text("Conta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _darkText))),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock_outline, color: Colors.grey),
                          title: const Text("Alterar Senha", style: TextStyle(fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.notifications_none, color: Colors.grey),
                          title: const Text("Notificações", style: TextStyle(fontWeight: FontWeight.w600)),
                          trailing: Switch(value: true, onChanged: (v){}, activeColor: _primaryBlue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _primaryBlue)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: _isEditing,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _isEditing ? Colors.black : _darkText),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _primaryBlue),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: _isEditing ? Colors.blue.shade50 : const Color(0xFFF5F7FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.groups, color: _primaryBlue),
        ),
        title: Text(racha.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartidaHistoricoPage(codigoRacha: racha.codigo))),
      ),
    );
  }
}