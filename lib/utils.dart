import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'colores.dart';

extension DateTimeUtils on DateTime {
  String get fecha => DateFormat('dd/MM/yyyy').format(this);
  String get hora => DateFormat('HH:mm:ss').format(this);
  String get fechaHora => DateFormat('dd/MM/yyyy HH:mm:ss').format(this);
  int get segundosTranscurridos => this.difference(DateTime.now()).inSeconds.abs();
}

extension UtilesString on String {
  String get sinEspacios => this.trim().replaceAll(RegExp(' +'), ' ');
  String get simplificar => sinAcentos.toLowerCase().replaceAll(RegExp('[^a-zñ0-9_]+'), ' ').sinEspacios;
  String get sinAcentos => this
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U');

  List<String> get palabras => this.sinEspacios.split(' ').map((p) => p.sinAcentos).toList();
  bool contienePalabras(List<String> palabras) => palabras.every((palabra) => this.contains(palabra));
  bool get esNombre => RegExp(r'[A-ZÑÁÉÍÓÏÜ]', caseSensitive: true).hasMatch(this);
  bool get esNumero => RegExp(r'^[+-]?[[0-9]+$').hasMatch(this);
  bool get soloLetras => RegExp(r'^[a-zñáéíóïü]+$', caseSensitive: false).hasMatch(this);
  String pad([int n = 20]) => this.padRight(n).substring(0, n);

  String get invertirNombre {
    if (!this.contains(",")) return this;
    final partes = this.split(",").map((e) => e.trim()).toList();
    return '${partes[1]} ${partes[0]}';
  }
}

extension UtilesInt on int {
  String info([String singular = '', String? plural, String? vacio]) {
    if (plural == null) {
      plural = singular.endsWith('ión') ? singular.replaceAll('ión', 'iones') : singular + 's';
    }
    if (!singular.contains('#')) singular = '# $singular';
    if (!plural.contains('#')) plural = '# $plural';

    final formato = switch (this) { 0 => vacio ?? '', 1 => singular, _ => plural };
    return formato.replaceAll('#', '$this');
  }

  String pad([int n = 3]) {
    return this.toString().padLeft(n);
  }
}

extension UtilesBool on bool {
  String info([String si = 'Si', String no = 'No']) => this ? si : no;
}

extension ListRandomExtension<E> on List<E> {
  E getRandomElement() {
    if (isEmpty) {
      throw Exception('La lista está vacía');
    }

    Random random = Random();
    int randomIndex = random.nextInt(length);
    return this[randomIndex];
  }
}

DateTime? inicio;
DateTime? etapa;
int contarEtapas = 0;

void comenzar(String titulo) {
  inicio = DateTime.now();
  etapa = inicio;
  contarEtapas = 0;
  print("> $titulo");
}

void avanzar(String mensaje) {
  if (inicio == null || etapa == null) return;
  final ahora = DateTime.now();
  final tiempo = '${ahora.difference(etapa!).inMilliseconds}';
  contarEtapas++;
  mensaje = mensaje.replaceAll("#", contarEtapas.toString());
  print("${mensaje.padRight(40)} ${tiempo.padLeft(5)} ms");
  etapa = ahora;
}

void terminar() {
  if (inicio == null || etapa == null) return;
  final ahora = DateTime.now();
  print("| ${(ahora.difference(inicio!).inMilliseconds)} ms");
  print("");
}

void medir(String mensaje, Function ejecutar) {
  final reloj = Stopwatch()..start();
  print('> $mensaje.');
  ejecutar();
  reloj.stop();
  print('| [ ${reloj.elapsedMilliseconds}ms ]');
}

AppBar crearTitulo(Widget titulo, {List<Widget>? actions}) =>
    AppBar(title: titulo, backgroundColor: Colors.transparent, elevation: 0, actions: actions);

BoxDecoration crearFondo() => const BoxDecoration(
        gradient: LinearGradient(
      colors: [Colors.purple, Colors.blue],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ));

Widget resultado(String titulo, int valor, [bool invertido = false]) {
  var etiqueta = Text("$titulo: ", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w200));
  var resultado = Text("$valor", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold));
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(children: invertido ? [resultado, etiqueta] : [etiqueta, resultado]),
  );
}

double distanciaEnMetros(double lat1, double lon1, double lat2, double lon2) {
  double deg2rad(double deg) => deg * (pi / 180);
  double r = 6371000; // Radio de la Tierra en km
  double dLat = deg2rad(lat2 - lat1); // Diferencia de latitud en radianes
  double dLon = deg2rad(lon2 - lon1); // Diferencia de longitud en radianes
  double a = pow(sin(dLat / 2), 2) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * pow(sin(dLon / 2), 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = r * c; // Distancia en metros
  return distance;
}
