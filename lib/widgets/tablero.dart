import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:memo/config/config.dart';
import 'package:memo/db/sqlite.dart';
import 'package:memo/widgets/parrilla.dart';

import '../app/home.dart';
import '../db/datos.dart';

class Tablero extends StatefulWidget {
  final Nivel? nivel;

  const Tablero(this.nivel, {Key? key}) : super(key: key);

  @override
  _TableroState createState() => _TableroState();
}

class _TableroState extends State<Tablero> {
  final GlobalKey<ParrillaState> pKey = GlobalKey();
  int segundos = 0;
  Datos? info;
  Timer? timer;
  bool isSideMenuExpanded = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    moves = 0;
    startTimer();
    getData();
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
    _scrollController.dispose();
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

  Future<void> getData() async {
    info = await Sqlite.ver();
    setState(() {});
  }

  void mostrarResultado(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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

  void newGame() async {
    reiniciar();
    Datos? rec = await Sqlite.ver();
    Datos x = Datos(
        id: 1,
        fecha: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        victorias: rec!.victorias,
        derrotas: rec.derrotas! + 1);
    await Sqlite().update(x);
    debugPrint("Lose: Perdiste negro");
  }

  Future<void> confirmacion(
      BuildContext context, String message, Function onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Continuar'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
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
            width: isSideMenuExpanded ? 175.0 : 0,
            color: Colors.blue,
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
                          confirmacion(
                              context, "Estas seguro que deseas salir?", () {
                            if (Platform.isAndroid || Platform.isIOS) {
                              SystemNavigator.pop();
                            }
                            if (Platform.isLinux || Platform.isWindows) {
                              exit(0);
                            }
                          });
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
                          confirmacion(context,
                              "Estas seguro que deseas reiniciar?", reiniciar);
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
                          confirmacion(
                              context, "Estas seguro que deseas seguir?", () async {
                                await getData();
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  title: Text("Display de informacion"),
                                  content: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.date_range_rounded),
                                        title: Text("Fecha"),
                                        subtitle: Text(info?.fecha.toString() ??
                                            "Cargando"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.thumb_up),
                                        title: Text("Victorias"),
                                        subtitle: Text(info?.victorias
                                                .toString() ??
                                            "Cargando"),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.thumb_down),
                                        title: Text("Derrotas"),
                                        subtitle: Text(info?.derrotas
                                                .toString() ??
                                            "Cargando"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          });
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
                          confirmacion(
                              context,
                              "Estas seguro de que quieres continuar? Se marcara como juego perdido",
                              newGame);
                        },
                      )
                    ],
                  )
                : null,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
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
      bottomNavigationBar: BottomAppBar(
          color: Colors.blue,
          height: 60,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  if (Platform.isAndroid || Platform.isIOS) {
                    SystemNavigator.pop();
                  }
                  if (Platform.isLinux || Platform.isWindows) {
                    exit(0);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.restart_alt),
                onPressed: reiniciar,
              ),
              IconButton(
                icon: Icon(Icons.not_started),
                onPressed: newGame,
              ),
            ],
          )),
    );
  }
}
