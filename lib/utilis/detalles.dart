import 'package:flutter/material.dart';

//plain old dart object
class Detalles {
  String ? name;
  Color ? primary;
  Color? secondary;
  Widget ? goto;

  Detalles(this.name,
      this.primary,
      this.secondary,
      this.goto);
}