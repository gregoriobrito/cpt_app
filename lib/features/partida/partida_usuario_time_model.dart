class PartidaUsuarioTime {
  final int codigo;

  PartidaUsuarioTime({required this.codigo});

  Map<String, dynamic> toJson() {
    return {
      "codigo": codigo.toString(),
    };
  }
}