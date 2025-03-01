import 'dart:async';

import 'package:flutter/material.dart';
import '../config/config.dart';
import 'package:flip_card/flip_card.dart';

class Parrilla extends StatefulWidget {
  final Nivel? nivel;
  final VoidCallback actualizarMoves, actualizarPares, mostrarResultado;

  const Parrilla(this.nivel, this.actualizarMoves(), this.actualizarPares(), this.mostrarResultado, {Key? key}) : super(key: key);

  @override
  ParrillaState createState() => ParrillaState();
}

class ParrillaState extends State<Parrilla>  {
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
    switch(widget.nivel!){
      case Nivel.facil:
        totales=8;
        break;
      case Nivel.medio:
        totales=12;
        break;
      case Nivel.dificil:
        totales=16;
        break;
      case Nivel.imposible:
        totales=18;
        break;
    }
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        for (int i = 0; i < baraja.length; i++) {
          controles[i].toggleCard();
        }
        habilitado = true; // Habilitar interacción después de voltear
      });
    });
  }

  bool checkWin(){
    bool tmp=false;
    if(totales==restantes){
      tmp=!tmp;
    }
    return tmp;
  }

  void reset(){
    setState(() {
      for (int i = 0; i < baraja.length; i++) {
        if (!estados[i]) {
          controles[i].toggleCard();
          estados[i]=true;
        }
      }
      prevclicked = -1;
      flag = false;
      habilitado = false;
      moves=0;
      restantes=0;
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
            onFlip: () {
              if (!habilitado!) return; // Bloquea el clic si aún no está habilitado
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
                  if(checkWin()){
                    widget.mostrarResultado();
                    restantes=0;
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
