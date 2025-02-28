import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memo/config/config.dart';
import 'package:memo/widgets/botonera.dart';
import 'package:memo/widgets/parrilla.dart';

import '../app/home.dart';

class Tablero extends StatefulWidget {
  final Nivel? nivel;
  const Tablero(this.nivel, {Key? key}) : super(key: key);

  @override
  _TableroState createState() => _TableroState();
}

class _TableroState extends State<Tablero> {
  int segundos=0;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    moves = 0;
    startTimer();
  }

  void startTimer(){
    timer=Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        segundos++;
      });
    },);
  }

  stopTimer(){
    timer?.cancel();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  String formatTime(int segundos) {
    int minutes = segundos ~/ 60;
    int secs = segundos % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  void actualizarMoves() {
    setState(() {});
  }

  void actualizarPares() {
    setState(() {});
  }

  void mostrarResultado(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que se cierre tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Column(
            children: [
              Icon(Icons.timer, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "Your result: ${formatTime(segundos)}",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Congratulations!\nYou have found all the pairs.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Home()));
                },
                child: Text("Volver al inicio"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movimientos: $moves | ⏳ ${formatTime(segundos)} | $totales/$restantes"),
      ),
      body: Parrilla(widget.nivel, actualizarMoves, actualizarPares, () => mostrarResultado(context)),
    );
  }
}
