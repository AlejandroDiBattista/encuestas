import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Indicador extends StatefulWidget {
  String etiqueta;
  double valor;

  Indicador({Key? key, required this.etiqueta, required this.valor}) : super(key: key);

  @override
  State<Indicador> createState() => _IndicadorState();
}

class _IndicadorState extends State<Indicador> {
  get etiqueta => widget.etiqueta;
  get valor => widget.valor;
  get texto => (0 < valor && valor < 1) ? '${(valor * 1000).toInt() / 10}%' : '${valor.toInt()}';
  @override
  Widget build(BuildContext context) => Container(
        width: 124,
        child: AspectRatio(
          aspectRatio: 2,
          child: Card(
            elevation: 8,
            color: Colors.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(texto, style: TextStyle(fontSize: 24)),
                  Text(etiqueta, style: TextStyle(fontSize: 14)),
                ]),
          ),
        ),
      );
}
