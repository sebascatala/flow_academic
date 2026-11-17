import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.nombre,
    required super.email,
    required super.carrera,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UsuarioModel(
      id: documentId,
      nombre: map['nombre'] as String? ?? '',
      email: map['email'] as String? ?? '',
      carrera: map['carrera'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'carrera': carrera,
    };
  }
}