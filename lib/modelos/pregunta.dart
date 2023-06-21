import 'dart:collection';
import 'dart:convert';
import '../sheets_api.dart';

typedef Preguntas = List<Pregunta>;

class Pregunta {
  String id;
  String descripcion;
  List<String> respuestas;
  int respuesta = 0;

  Pregunta({required this.id, required this.descripcion, required this.respuestas});

  Pregunta copyWith({String? id, String? descripcion, List<String>? respuestas, List<int>? cantidades}) => Pregunta(
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

  bool get opcionUnica => respuestas.length == 1;
  bool get esContestada => respuesta != 0;

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
}

class Encuesta extends ListBase<Pregunta> {
  List<Pregunta> preguntas = [];
  int posicion = -1;
  List<int> anteriores = [];

  Encuesta() {
    this.posicion = 0;
  }

  int get length => preguntas.length;
  set length(int newLength) => preguntas.length = newLength;

  Pregunta operator [](int index) => preguntas[index];
  void operator []=(int index, Pregunta value) => preguntas[index] = value;

  void add(Pregunta pregunta) {
    preguntas.add(pregunta);
    posicion = 0;
  }

  bool get esInicial => posicion == 0;
  bool get esFinal => posicion == length - 1;

  Pregunta get actual => preguntas[posicion];

  void siguiente() {
    if (esFinal) return;

    anteriores.add(posicion);

    final id = "${actual.id}.${actual.respuesta}";
    final i = preguntas.indexWhere((p) => p.id == id);
    if (i != -1) {
      posicion = i;
    } else {
      final id = '${int.parse(actual.id.split(".").first) + 1}';
      posicion = preguntas.indexWhere((p) => p.id == id);
    }
  }

  void anterior() {
    if (esInicial) return;
    
    posicion = anteriores.removeLast();
  }

  void responder(int respuesta) {
    preguntas[posicion].respuesta = respuesta;
  }

  static Future<Encuesta> bajar() async {
    final datos = await SheetsApi.traerPreguntas();

    final salida = Encuesta();
    datos.forEach((dato) => salida.add(Pregunta.fromMap(dato)));
    return salida;
  }

  void guardar() async {
    await SheetsApi.registrarRespuestas(this.map((pregunta) => pregunta.respuesta).toList());
  }

  factory Encuesta.bienvenida() {
    final salida = Encuesta();
    salida.add(Pregunta(
        id: "0", descripcion: 'Bienvenido..La siguiente encuesta es totalmente anónima', respuestas: ["Comenzar"]));
    return salida;
  }

  factory Encuesta.ejemplo() {
    final salida = Encuesta();
    Pregunta.ejemplos.forEach((e) => salida.add(e));
    return salida;
  }

  void reiniciar() {
    preguntas.forEach((pregunta) => pregunta.respuesta = 0);
    anteriores.clear();
    posicion = 0;
  }
}
