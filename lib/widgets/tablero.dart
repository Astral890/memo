import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:memo/config/config.dart';
import 'package:memo/widgets/parrilla.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movimientos: $moves | ⏳ ${formatTime(segundos)} | $totales/$restantes"),
      ),
      body: Parrilla(widget.nivel, actualizarMoves, actualizarPares),
    );
  }
}
