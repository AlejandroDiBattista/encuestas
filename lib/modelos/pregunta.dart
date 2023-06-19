import 'dart:convert';
import '../sheets_api.dart';

typedef Preguntas = List<Pregunta>;

class Pregunta {
  String id;
  String descripcion;
  List<String> respuestas;

  Pregunta({required this.id, required this.descripcion, required this.respuestas});

  Pregunta copyWith({String? id, String? descripcion, List<String>? respuestas}) => Pregunta(
        id: id ?? this.id,
        descripcion: descripcion ?? this.descripcion,
        respuestas: respuestas ?? this.respuestas,
      );

  Map<String, dynamic> toMap() => {'id': id, 'descripcion': descripcion, 'respuestas': respuestas};

  factory Pregunta.fromMap(Map<String, dynamic> map) => Pregunta(
      id: map['id'] ?? '',
      descripcion: map['descripcion'] ?? '',
      respuestas: List<String>.from(
          [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((i) => map['r$i']).where((x) => x != null && x.length > 2)));

  String toJson() => json.encode(toMap());

  factory Pregunta.fromJson(String source) => Pregunta.fromMap(json.decode(source));

  @override
  String toString() => 'Pregunta(id: $id, descripcion: $descripcion, respuestas: $respuestas)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is Pregunta && other.id == id;

  @override
  int get hashCode => id.hashCode ^ descripcion.hashCode ^ respuestas.hashCode;

  static Preguntas preguntas = [];

  static Preguntas ejemplos = [
    Pregunta(
      id: "P1",
      descripcion: "¿Qué partido votará?",
      respuestas: ["✌🏼 Peronimos | P2 ", "🦾 Junto por el cambio | P2 ", "🦁 Milei | P3"],
    ),
    Pregunta(
      id: "P2",
      descripcion: "¿Son demasiadas opciones?",
      respuestas: ["Uno", "Dos", "Tres", "Cuatro", "Cinco", "Seis"],
    ),
    Pregunta(
      id: "P3",
      descripcion:
          "¿Es acaso la pregunta demasiado larga, es decir que tiene un texto muy largo y dificil de leer pór la cantidad de texto que tiene?",
      respuestas: ["👍🏼 Si", "👎🏼 No"],
    ),
    Pregunta(
      id: "P4",
      descripcion: "¿Cúal es tu color favorito?",
      respuestas: ["Rojo", "Azul", "Amarillo", "Verde", "Rosa", "Celeste"],
    )
  ];

  static Future<void> cargar() async {
    preguntas = await bajar();
  }

  static Future<Preguntas> bajar() async {
    final datos = await SheetsApi.traerPreguntas();
    return datos.map((dato) => Pregunta.fromMap(dato)).toList();
  }

  static void guardarRespuestas(List<int> datos) async {
    await SheetsApi.registrarRespuestas(datos);
  }
}
