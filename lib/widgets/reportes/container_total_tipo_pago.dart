import 'package:flutter/material.dart';

class ContainerTotalTipoPago extends StatelessWidget {
  final String tipoPago;
  final double totalPorTipo;
  final double porcentaje;
  final Color colorFondo;

  ContainerTotalTipoPago({super.key, required this.tipoPago, required this.totalPorTipo, required this.porcentaje, required this.colorFondo});

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            width: MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
              color:  colorFondo,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                Text("$tipoPago:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                Text("\$ $totalPorTipo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                Text("${porcentaje.toStringAsFixed(2)}%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
              ],
            ),
          );
  }
}