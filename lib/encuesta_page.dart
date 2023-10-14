import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pregunta.dart';
import 'utils.dart';

class EncuestaPage extends StatefulWidget {
  const EncuestaPage({super.key});

  @override
  _EncuestaPageState createState() => _EncuestaPageState();
}

class _EncuestaPageState extends State<EncuestaPage> {
  Encuesta encuesta = Encuesta.bienvenida();

  bool cargando = false;
  bool estadisticas = false;
  bool desarrollador = false;
  int contarDesarrollador = 0;

  @override
  void initState() {
    super.initState();

    Encuesta.bajar().then((v) {
      encuesta = v;
      cargando = false;
      actualizar();
    });
  }

  void actualizar() => setState(() {});

  void marcarRespuesta(int respuesta) {
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
      estadisticas = false;
    }
    actualizar();
  }

  void mostrarEstadisticas() async {
    estadisticas = !estadisticas;
    if (estadisticas) {
      await encuesta.cargarResultados();
    }
    actualizar();
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = encuesta.actual;
    final respuestas = pregunta.respuestas;

    return Scaffold(
      appBar: crearTitulo(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Encuesta 1 vpubuelta 2023'),
              Text('${pregunta.id}'),
              Text('${encuesta.posicion + 1} de ${encuesta.length}', style: const TextStyle(fontSize: 15))
            ],
          ),
          actions: [
            if (desarrollador)
              IconButton(
                  onPressed: mostrarEstadisticas,
                  icon: Icon(Icons.bar_chart, color: estadisticas ? Colors.yellow : Colors.grey)),
          ]),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: crearFondo(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            crearDescripcion(pregunta),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: respuestas.asMap().entries.map((item) => crearRespuesta(item.key)).toList()),
            cargando ? Center(child: CircularProgressIndicator()) : crearNavegacion(),
          ],
        ),
      ),
    );
  }

  Widget crearNavegacion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
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

  Widget crearBoton(String texto, VoidCallback accion) {
    return SizedBox(
        width: 120,
        child: OutlinedButton(onPressed: accion, child: Text(texto, style: TextStyle(color: Colors.white))));
  }

  Widget crearDescripcion(Pregunta pregunta) => Expanded(
          child: InkWell(
        onTap: modoDesarrollador,
        child: Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(pregunta.descripcion.replaceAll(".", "\n"),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: Colors.white),
                    textAlign: TextAlign.center))),
      ));

  Widget crearRespuesta(int i) {
    final pregunta = encuesta.actual;
    final respuesta = pregunta.respuestas[i];
    final seleccionado = (i + 1) == pregunta.respuesta;

    final par = respuesta.split(".");

    final opcion = par[0].trim();
    final info = par.length > 1 ? par[1].trim() : "";

    final unica = pregunta.opcionUnica;
    final color = (seleccionado && !unica ? Colors.yellow : Colors.white);
    final cantidad = encuesta.resultados.cantidad('${pregunta.id}.${i + 1}');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.3), // Ajusta el nivel de transparencia aquí
          padding: EdgeInsets.all(16),
        ),
        onPressed: () => marcarRespuesta(i + 1),
        child: SizedBox(
          width: unica ? 120 : Get.width - 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Column(
                children: [
                  Text(opcion,
                      style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.normal),
                      textAlign: unica ? TextAlign.center : TextAlign.start),
                  if (info.isNotEmpty)
                    Text(info, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w100))
                ],
              ),
              Spacer(),
              if (estadisticas && !unica)
                Text("$cantidad", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w100))
            ],
          ),
        ),
      ),
    );
  }

  void modoDesarrollador() {
    if (desarrollador) {
      contarDesarrollador--;
      desarrollador = contarDesarrollador > 0;
    } else {
      contarDesarrollador++;
      desarrollador = contarDesarrollador >= 7;
    }
    actualizar();
  }
}
