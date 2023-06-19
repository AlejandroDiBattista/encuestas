import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modelos/pregunta.dart';
import '../utils.dart';

class EncuestaPage extends StatefulWidget {
  const EncuestaPage({super.key});

  @override
  _EncuestaPageState createState() => _EncuestaPageState();
}

class _EncuestaPageState extends State<EncuestaPage> {
  int actual = 0;
  List<int> respuestas = [];

  Preguntas preguntas = Pregunta.preguntas;

  bool cargando = true;
  @override
  void initState() {
    super.initState();

    cargando = true;
    preguntas = Pregunta.ejemplos;
    preguntas.forEach((element) => respuestas.add(0));

    Pregunta.cargar().then((value) {
      preguntas = Pregunta.preguntas;
      print("Preguntas cargadas ${Pregunta.preguntas.length}");
      print("$preguntas");
      preguntas.forEach((element) => respuestas.add(0));
      cargando = false;
      actualizar();
    });
  }

  void actualizar() => setState(() {});

  void seleccionarRespuesta(int respuesta) {
    respuestas[actual] = (respuestas[actual] == respuesta) ? 0 : respuesta;
    if (respuestas[actual] > 0) {
      avanzarPregunta();
    }
    actualizar();
  }

  void retrocederPregunta() {
    if (actual > 0) {
      actual--;
    }
    actualizar();
  }

  void avanzarPregunta() {
    if (respuestas[actual] > 0) {
      if (actual < preguntas.length - 1) actual++;
    }
    actualizar();
  }

  void finalizarEncuesta() {
    Pregunta.guardarRespuestas(respuestas);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = preguntas[actual];
    final respuestas = pregunta.respuestas;

    return Scaffold(
      appBar: crearTitulo(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Encuesta'),
          Text('${actual + 1} de ${preguntas.length}', style: const TextStyle(fontSize: 15)),
        ],
      )),
      body: Container(
        decoration: crearFondo(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildDescripcion(pregunta),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: respuestas.asMap().entries.map((item) => creardRespuesta(item.value, item.key)).toList(),
            ),
            cargando ? Center(child: CircularProgressIndicator()) : buildNavegacion(),
          ],
        ),
      ),
    );
  }

  Widget buildNavegacion() {
    final esUltimaPregunta = actual == preguntas.length - 1;
    final conRespuesta = respuestas[actual] > 0 || preguntas[actual].respuestas.isEmpty;
    print("$respuestas");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Row(
        mainAxisAlignment: actual > 0 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
        children: [
          if (actual > 0)
            SizedBox(
              width: 120,
              child: OutlinedButton(onPressed: retrocederPregunta, child: const Text('Anterior')),
            ),
          SizedBox(height: 32),
          if (conRespuesta && !esUltimaPregunta)
            SizedBox(
              width: 120,
              child: OutlinedButton(onPressed: avanzarPregunta, child: Text('Siguiente')),
            ),
          if (conRespuesta && esUltimaPregunta)
            SizedBox(
              width: 120,
              child: FilledButton(
                  onPressed: finalizarEncuesta,
                  child: Text('Finalizar', style: TextStyle(fontWeight: FontWeight.bold))),
            ),
        ],
      ),
    );
  }

  Widget buildDescripcion(Pregunta pregunta) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            pregunta.descripcion,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget creardRespuesta(String respuesta, int i) {
    final bool seleccionado = (actual < respuestas.length) && (respuestas[actual] == i + 1);
    final par = respuesta.split("|").first.split(":");

    final texto = par[0].trim();
    final info = par.length > 1 ? par[1].trim() : "";
    print('[$texto] - [$info] $seleccionado');

    final color = (seleccionado ? Colors.red : Colors.green);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => seleccionarRespuesta(i + 1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: Get.width - 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto, style: TextStyle(fontSize: 20, color: color)),
                if (info.isNotEmpty) Text(info, style: TextStyle(fontSize: 16, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
