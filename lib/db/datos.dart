class Datos {
  int? id;
  String? fecha;
  int? victorias;
  int? derrotas;
  Datos({this.id, this.fecha, this.victorias, this.derrotas});

  Map<String, dynamic> toMap() {
    return {'id':id,'fecha': fecha, 'victorias': victorias, 'derrotas': derrotas};
  }
}
