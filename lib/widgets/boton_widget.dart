import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Boton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String info;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? color;
  final bool destacar;

  const Boton(
      {this.icon = Icons.login,
      this.label = 'Ingresar',
      this.info = '',
      this.onPressed,
      this.onLongPress,
      this.color,
      this.destacar = false});

  // factory Boton.navegar(IconData icon, String label, dynamic go) =>
  //     Boton(icon: icon, label: label, onPressed: () => Get.to(go()));

  @override
  Widget build(BuildContext context) {
    final aux = this.color ?? Colors.green;

    return ElevatedButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: info.isEmpty ? 10 : 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28, color: aux),
                 Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Text(label, style: TextStyle(fontSize: info.isEmpty ? 18 : 20, color: aux)),
                  if (info.isNotEmpty)
                    Text(info, style: TextStyle(fontSize: 16, color: aux, fontWeight: FontWeight.w200)),
                ]),
                this.destacar
                    ? Icon(Icons.error, size: 28, color: Colors.red)
                    : Opacity(opacity: 0, child: Icon(icon, size: 28, color: aux))
              ],
            )));
  }
}
