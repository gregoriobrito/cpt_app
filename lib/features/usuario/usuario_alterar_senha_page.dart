import 'package:cpv_app/features/usuario/usuario_service.dart';
import 'package:flutter/material.dart';

class UsuarioAlterarSenhaPage extends StatefulWidget {
  const UsuarioAlterarSenhaPage({super.key});

  @override
  State<UsuarioAlterarSenhaPage> createState() => _UsuarioAlterarSenhaPageState();
}

class _UsuarioAlterarSenhaPageState extends State<UsuarioAlterarSenhaPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  bool _senhaAtualVisible = false;
  bool _novaSenhaVisible = false;
  bool _confirmarSenhaVisible = false;
  // -------------------------------------------------

  final UsuarioService _usuarioService = UsuarioService();
  bool _isLoading = false;

  @override
  void dispose() {
    // É boa prática descartar os controllers quando a tela fecha
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracao() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Fecha o teclado se estiver aberto
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      await _usuarioService.alterarSenha(
        _senhaAtualController.text,
        _novaSenhaController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Senha alterada com sucesso!"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceAll("Exception:", "").trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2979FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Alterar Senha", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Segurança",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2230)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Para sua segurança, confirme sua senha atual antes de definir uma nova.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Card Branco do Formulário
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    // --- CHAMADAS ATUALIZADAS DO WIDGET ---
                    _buildPasswordField(
                      label: "Senha Atual",
                      controller: _senhaAtualController,
                      isVisible: _senhaAtualVisible,
                      onToggleVisibility: () => setState(() => _senhaAtualVisible = !_senhaAtualVisible),
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      label: "Nova Senha",
                      controller: _novaSenhaController,
                      isVisible: _novaSenhaVisible,
                      onToggleVisibility: () => setState(() => _novaSenhaVisible = !_novaSenhaVisible),
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      label: "Confirmar Nova Senha",
                      controller: _confirmarSenhaController,
                      isVisible: _confirmarSenhaVisible,
                      onToggleVisibility: () => setState(() => _confirmarSenhaVisible = !_confirmarSenhaVisible),
                      validator: (val) {
                        if (val != _novaSenhaController.text) return "As senhas não conferem";
                        return null;
                      },
                    ),
                    // ---------------------------------------
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _salvarAlteracao,
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("ATUALIZAR SENHA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET AUXILIAR ATUALIZADO ---
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible, // Se não estiver visível, obscurece
          validator: validator ??
              (value) {
                if (value == null || value.isEmpty) return "Campo obrigatório";
                if (value.length < 3) return "Senha muito curta";
                return null;
              },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2979FF)),
            // Ícone do "olhinho" no final
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}