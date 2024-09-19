// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class Cell {
  String content;
  int colSpan;
  int rowSpan;
  TextEditingController controller;
  Color color;

  Cell({
    required this.content,
    this.colSpan = 1,
    this.rowSpan = 1,
    required this.controller,
    this.color = Colors.white,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'content': content,
      'colSpan': colSpan,
      'rowSpan': rowSpan,
      'controller': controller.text,
      'color': color.value,
    };
  }

  factory Cell.fromMap(Map<String, dynamic> map) {
    return Cell(
      content: map['content'] as String,
      colSpan: map['colSpan'] as int,
      rowSpan: map['rowSpan'] as int,
      controller: TextEditingController(text: map['controller'] as String),
      color: Color(map['color'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Cell.fromJson(String source) => Cell.fromMap(json.decode(source) as Map<String, dynamic>);
}
