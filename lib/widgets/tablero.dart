import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memo/config/config.dart';
import 'package:memo/widgets/parrilla.dart';

import '../app/home.dart';

class Tablero extends StatefulWidget {
  final Nivel? nivel;
  const Tablero(this.nivel, {Key? key}) : super(key: key);

  @override
  _TableroState createState() => _TableroState();
}

class _TableroState extends State<Tablero> {
  final GlobalKey<ParrillaState> pKey = GlobalKey();
  int segundos = 0;
  Timer? timer;
  bool isSideMenuExpanded =
      false; // Estado para controlar la expansión del SideMenu
  ScrollController _scrollController =
      ScrollController(); // Controlador de desplazamiento

  @override
  void initState() {
    super.initState();
    moves = 0;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        segundos++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  @override
  void dispose() {
    stopTimer();
    _scrollController.dispose(); // Limpia el controlador de desplazamiento
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                "Felicidades!\nHaz encontrado todos los pares en $moves movimientos",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },
                child: Text("Volver al inicio"),
              ),
            ],
          ),
        );
      },
    );
  }

  void toggleSideMenu() {
    setState(() {
      isSideMenuExpanded = !isSideMenuExpanded;
    });
  }

  void reiniciar() {
    segundos = 0;
    pKey.currentState?.reset();
  }

  void newGame() {
    reiniciar();
    debugPrint("Lose: Perdiste negro");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("M: $moves | ⏳ ${formatTime(segundos)} | $totales/$restantes"),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: toggleSideMenu,
          ),
        ],
      ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: isSideMenuExpanded ? 250.0 : 0,
            child: isSideMenuExpanded
                ? Column(
                    children: [
                      ListTile(
                        leading: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: 24, maxWidth: 24),
                          child: Icon(Icons.exit_to_app),
                        ),
                        title: Text('Salir'),
                        onTap: () {
                          if (Platform.isAndroid || Platform.isIOS) {
                            // Navigator.pop(context);
                            //SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                            SystemNavigator.pop();
                          }
                          if (Platform.isLinux || Platform.isWindows) {
                            exit(0);
                          }
                        },
                      ),
                      ListTile(
                        leading: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: 24, maxHeight: 24),
                          child: Icon(Icons.restart_alt),
                        ),
                        title: Text("Reiniciar"),
                        onTap: () {
                          reiniciar();
                        },
                      ),
                      ListTile(
                        leading: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: 24, maxWidth: 24),
                          child: Icon(Icons.contact_support),
                        ),
                        title: Text('Consultar'),
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                title: Text("Display de informacion"),
                                content: Column(
                                  children: [ListTile(
                                    leading: Icon(Icons.date_range_rounded),
                                    title: Text("Fecha"),
                                    subtitle: Text("ES HOY"), // Aquí se añade el texto "ES HOY" como subtítulo
                                  ),
                                    ListTile(
                                      leading: Icon(Icons.thumb_up),
                                      title: Text("Victorias"),
                                      subtitle: Text("5"), // Aquí se añade el número de victorias como subtítulo
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.thumb_down),
                                      title: Text("Derrotas"),
                                      subtitle: Text("36"), // Aquí se añade el número de derrotas como subtítulo
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: 24, maxHeight: 24),
                          child: Icon(Icons.not_started),
                        ),
                        title: Text('Juego nuevo'),
                        onTap: () {
                          newGame();
                        },
                      )
                    ],
                  )
                : null,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller:
                  _scrollController, // Asigna el controlador de desplazamiento
              child: Parrilla(
                widget.nivel,
                actualizarMoves,
                actualizarPares,
                key: pKey,
                () => mostrarResultado(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
