import 'package:flutter/material.dart';

class PropertyResolver {
  static String string(
    Map<String, dynamic> props,
    String key, [
    String fallback = '',
  ]) {
    final v = props[key];
    if (v is String) return v;
    if (v != null) return v.toString();
    return fallback;
  }

  static double? doubleOrNull(Map<String, dynamic> props, String key) {
    final v = props[key];
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static double doubleVal(
    Map<String, dynamic> props,
    String key,
    double fallback,
  ) => doubleOrNull(props, key) ?? fallback;

  static int intVal(Map<String, dynamic> props, String key, int fallback) {
    final v = props[key];
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static bool boolVal(Map<String, dynamic> props, String key, bool fallback) {
    final v = props[key];
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is int) return v != 0;
    return fallback;
  }

  static Color? colorOrNull(Map<String, dynamic> props, String key) =>
      parseColor(props[key]);

  static Color? parseColor(dynamic value) {
    if (value == null) return null;
    if (value is Color) return value;
    if (value is int) return Color(value);
    if (value is String) {
      var s = value.trim();
      if (s.startsWith('#')) s = s.substring(1);
      // handle #RGB, #RRGGBB, #AARRGGBB
      if (s.length == 3) {
        s = s.split('').map((c) => '$c$c').join();
        s = 'FF$s';
      } else if (s.length == 6) {
        s = 'FF$s';
      } else if (s.length == 8) {
        // already AARRGGBB
      } else {
        return null;
      }
      final v = int.tryParse(s, radix: 16);
      if (v != null) return Color(v);
    }
    return null;
  }

  static EdgeInsets paddingFrom(Map<String, dynamic> style) {
    // style.padding can be number or map {top, bottom, left, right, horizontal, vertical, all}
    final p = style['padding'];
    if (p == null) return EdgeInsets.zero;
    if (p is num) return EdgeInsets.all(p.toDouble());
    if (p is Map) {
      final m = Map<String, dynamic>.from(p as Map);
      if (m.containsKey('all')) {
        final v = (m['all'] as num).toDouble();
        return EdgeInsets.all(v);
      }
      final top =
          (m['top'] as num?)?.toDouble() ??
          (m['vertical'] as num?)?.toDouble() ??
          0;
      final bottom =
          (m['bottom'] as num?)?.toDouble() ??
          (m['vertical'] as num?)?.toDouble() ??
          0;
      final left =
          (m['left'] as num?)?.toDouble() ??
          (m['horizontal'] as num?)?.toDouble() ??
          0;
      final right =
          (m['right'] as num?)?.toDouble() ??
          (m['horizontal'] as num?)?.toDouble() ??
          0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    }
    return EdgeInsets.zero;
  }

  static EdgeInsets marginFrom(Map<String, dynamic> style) {
    final m = style['margin'];
    if (m == null) return EdgeInsets.zero;
    if (m is num) return EdgeInsets.all(m.toDouble());
    if (m is Map) {
      final map = Map<String, dynamic>.from(m as Map);
      if (map.containsKey('all')) {
        return EdgeInsets.all((map['all'] as num).toDouble());
      }
      final top =
          (map['top'] as num?)?.toDouble() ??
          (map['vertical'] as num?)?.toDouble() ??
          0;
      final bottom =
          (map['bottom'] as num?)?.toDouble() ??
          (map['vertical'] as num?)?.toDouble() ??
          0;
      final left =
          (map['left'] as num?)?.toDouble() ??
          (map['horizontal'] as num?)?.toDouble() ??
          0;
      final right =
          (map['right'] as num?)?.toDouble() ??
          (map['horizontal'] as num?)?.toDouble() ??
          0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    }
    return EdgeInsets.zero;
  }

  static Alignment alignmentFrom(dynamic value, Alignment fallback) {
    if (value is String) {
      switch (value) {
        case 'topLeft':
          return Alignment.topLeft;
        case 'topCenter':
          return Alignment.topCenter;
        case 'topRight':
          return Alignment.topRight;
        case 'centerLeft':
          return Alignment.centerLeft;
        case 'center':
          return Alignment.center;
        case 'centerRight':
          return Alignment.centerRight;
        case 'bottomLeft':
          return Alignment.bottomLeft;
        case 'bottomCenter':
          return Alignment.bottomCenter;
        case 'bottomRight':
          return Alignment.bottomRight;
      }
    }
    return fallback;
  }

  static MainAxisAlignment mainAxisFrom(
    dynamic v, [
    MainAxisAlignment fallback = MainAxisAlignment.start,
  ]) {
    if (v is String) {
      switch (v) {
        case 'start':
          return MainAxisAlignment.start;
        case 'end':
          return MainAxisAlignment.end;
        case 'center':
          return MainAxisAlignment.center;
        case 'spaceBetween':
          return MainAxisAlignment.spaceBetween;
        case 'spaceAround':
          return MainAxisAlignment.spaceAround;
        case 'spaceEvenly':
          return MainAxisAlignment.spaceEvenly;
      }
    }
    return fallback;
  }

  static CrossAxisAlignment crossAxisFrom(
    dynamic v, [
    CrossAxisAlignment fallback = CrossAxisAlignment.center,
  ]) {
    if (v is String) {
      switch (v) {
        case 'start':
          return CrossAxisAlignment.start;
        case 'end':
          return CrossAxisAlignment.end;
        case 'center':
          return CrossAxisAlignment.center;
        case 'stretch':
          return CrossAxisAlignment.stretch;
        case 'baseline':
          return CrossAxisAlignment.baseline;
      }
    }
    return fallback;
  }

  static FontWeight fontWeightFrom(dynamic v) {
    if (v is String) {
      switch (v.toLowerCase()) {
        case 'thin':
        case 'w100':
          return FontWeight.w100;
        case 'extralight':
        case 'w200':
          return FontWeight.w200;
        case 'light':
        case 'w300':
          return FontWeight.w300;
        case 'normal':
        case 'w400':
          return FontWeight.w400;
        case 'medium':
        case 'w500':
          return FontWeight.w500;
        case 'semibold':
        case 'w600':
          return FontWeight.w600;
        case 'bold':
        case 'w700':
          return FontWeight.w700;
        case 'extrabold':
        case 'w800':
          return FontWeight.w800;
        case 'black':
        case 'w900':
          return FontWeight.w900;
      }
    }
    if (v is int) {
      return FontWeight.values[(v ~/ 100).clamp(1, 9) - 1];
    }
    return FontWeight.normal;
  }

  static TextAlign textAlignFrom(dynamic v) {
    if (v is String) {
      switch (v) {
        case 'left':
          return TextAlign.left;
        case 'right':
          return TextAlign.right;
        case 'center':
          return TextAlign.center;
        case 'justify':
          return TextAlign.justify;
        case 'start':
          return TextAlign.start;
        case 'end':
          return TextAlign.end;
      }
    }
    return TextAlign.start;
  }

  static double? borderRadiusFrom(Map<String, dynamic> style) {
    final v = style['borderRadius'] ?? style['radius'];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
