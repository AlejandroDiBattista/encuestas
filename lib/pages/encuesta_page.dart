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
  Encuesta encuesta = Encuesta.bienvenida();

  bool cargando = false;
  bool estadisticas = false;

  @override
  void initState() {
    super.initState();

    // cargando = true;

    Encuesta.bajar().then((v) {
      encuesta = v;
      cargando = false;
      actualizar();
    });
  }

  void actualizar() => setState(() {});

  void marcarRespuesta(int respuesta) {
    if (encuesta.actual.respuesta == respuesta) respuesta = 0;
    encuesta.responder(respuesta);
    avanzarPregunta();
  }

  void retrocederPregunta() {
    encuesta.anterior();
    actualizar();
  }

  void avanzarPregunta() {
    encuesta.siguiente();
    if (encuesta.esFinal && encuesta.actual.esContestada) {
      encuesta.guardar();
      encuesta.reiniciar();
    }
    actualizar();
  }

  void finalizarEncuesta() {
    encuesta.guardar();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = encuesta.actual;
    final respuestas = pregunta.respuestas;

    return Scaffold(
      appBar: crearTitulo(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Encuesta PASO 2023'),
          Text('${encuesta.posicion + 1} de ${encuesta.length}', style: const TextStyle(fontSize: 15))
        ],
      )),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: crearFondo(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            crearDescripcion(pregunta),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: respuestas.asMap().entries.map((item) => crearRespuesta(item.key)).toList(),
            ),
            cargando ? Center(child: CircularProgressIndicator()) : crearNavegacion(),
            // if (pregunta.opcionUnica) Spacer(),
          ],
        ),
      ),
    );
  }

  Widget crearNavegacion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
      child: Row(
        mainAxisAlignment: !encuesta.esInicial ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
        children: [
          if (!encuesta.esInicial) crearBoton('Anterior', retrocederPregunta),
          SizedBox(height: 32),
          if (encuesta.actual.esContestada) crearBoton('Siguiente', avanzarPregunta),
        ],
      ),
    );
  }

  SizedBox crearBoton(String texto, VoidCallback accion) {
    return SizedBox(
        width: 120,
        child: OutlinedButton(onPressed: accion, child: Text(texto, style: TextStyle(color: Colors.white))));
  }

  Widget crearDescripcion(Pregunta pregunta) => Expanded(
      child: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(pregunta.descripcion.replaceAll(".", "\n"),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: Colors.white),
                  textAlign: TextAlign.center))));

  Widget crearRespuesta(int i) {
    final pregunta = encuesta.actual;
    final respuesta = pregunta.respuestas[i];
    final bool seleccionado = (i + 1) == pregunta.respuesta;
    final par = respuesta.split(".");

    final texto = par[0].trim();
    final info = par.length > 1 ? par[1].trim() : "";

    final color = (seleccionado ? Colors.yellow : Colors.black);
    final compacta = pregunta.opcionUnica;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.4), // Ajusta el nivel de transparencia aquí
          padding: EdgeInsets.all(16),
        ),
        onPressed: () => marcarRespuesta(i + 1),
        child: SizedBox(
          width: compacta ? 120 : Get.width - 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Column(
                // crossAxisAlignment: compacta ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  Text(
                    texto,
                    style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold),
                    textAlign: compacta ? TextAlign.center : TextAlign.start,
                  ),
                  if (info.isNotEmpty)
                    Text(info, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w100)),
                ],
              ),
              Spacer(),
              if (estadisticas && !compacta)
                Text("${12}", style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w100))
            ],
          ),
        ),
      ),
    );
  }
}
