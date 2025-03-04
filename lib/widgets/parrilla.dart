import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memo/db/sqlite.dart';
import '../config/config.dart';
import 'package:flip_card/flip_card.dart';

import '../db/datos.dart';

class Parrilla extends StatefulWidget {
  final Nivel? nivel;
  final VoidCallback actualizarMoves, actualizarPares, mostrarResultado;

  const Parrilla(this.nivel, this.actualizarMoves(), this.actualizarPares(),
      this.mostrarResultado,
      {Key? key})
      : super(key: key);

  @override
  ParrillaState createState() => ParrillaState();
}

class ParrillaState extends State<Parrilla> {
  int? prevclicked;

  bool? flag, habilitado;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controles = [];
    baraja = [];
    estados = [];
    barajar(widget.nivel!);
    prevclicked = -1;
    flag = false;
    habilitado = false;
    switch (widget.nivel!) {
      case Nivel.facil:
        totales = 8;
        break;
      case Nivel.medio:
        totales = 12;
        break;
      case Nivel.dificil:
        totales = 16;
        break;
      case Nivel.imposible:
        totales = 18;
        break;
    }
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        for (int i = 0; i < baraja.length; i++) {
          controles[i].toggleCard();
        }
        habilitado = true;
      });
    });
  }

  Future<bool> checkWin() async {
    bool tmp = false;
    if (totales == restantes) {
      Datos? rec = await Sqlite.ver();
      tmp = !tmp;
      Datos x =
          Datos(id: 1, fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),victorias: rec!.victorias!+1,derrotas: rec.derrotas);
      await Sqlite().update(x);
    }
    return tmp;
  }

  void reset() {
    setState(() {
      for (int i = 0; i < baraja.length; i++) {
        if (!estados[i]) {
          controles[i].toggleCard();
          estados[i] = true;
        }
      }
      prevclicked = -1;
      flag = false;
      habilitado = false;
      moves = 0;
      restantes = 0;
    });
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        habilitado = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: baraja.length,
      shrinkWrap: true,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (context, index) {
        return FlipCard(
            onFlip: () async {
              if (!habilitado!) return;
              setState(() {
                habilitado = false;
              });

              if (!flag!) {
                prevclicked = index;
                estados[index] = false;
                ++moves;
                widget.actualizarMoves();
                debugPrint("moves: $moves");
              } else {
                setState(() {
                  habilitado = false;
                });
              }
              flag = !flag!;
              estados[index] = false;

              if (prevclicked != index && !flag!) {
                if (baraja.elementAt(index) == baraja.elementAt(prevclicked!)) {
                  debugPrint("clicked:Son iguales");
                  ++moves;
                  ++restantes;
                  if (await checkWin()) {
                    widget.mostrarResultado();
                    restantes = 0;
                  }
                  widget.actualizarMoves();
                  widget.actualizarPares();
                  debugPrint("moves: $moves");
                  setState(() {
                    habilitado = true;
                  });
                } else {
                  Future.delayed(
                    Duration(seconds: 1),
                    () {
                      controles.elementAt(prevclicked!).toggleCard();
                      estados[prevclicked!] = true;
                      prevclicked = index;
                      controles.elementAt(index).toggleCard();
                      estados[index] = true;
                      setState(() {
                        habilitado = true;
                      });
                    },
                  );
                }
              } else {
                setState(() {
                  habilitado = true;
                });
              }
            },
            fill: Fill.fillBack,
            controller: controles[index],
            // autoFlipDuration: const Duration(milliseconds: 500),
            flipOnTouch: habilitado! ? estados.elementAt(index) : false,
            //side: CardSide.FRONT,
            back: Image.asset("images/quest.png"),
            front: Image.asset(baraja[index]));
      },
    );
  }
}
