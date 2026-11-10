import 'package:flutter/material.dart';

import '../utils/CanChiUtils.dart';

/// Màu nền, chữ dùng chung (giấy dó, mực nâu).
class Palette {
  Palette._();

  static const Color paper = Color(0xFFF7F2E8);
  static const Color card = Colors.white;
  static const Color ink = Color(0xFF2E2A24);
  static const Color muted = Color(0xFF6F665A);
  static const Color line = Color(0xFFE6DCC8);
}

/// Bộ màu theo ngũ hành mệnh của năm sinh (thay cho màu Material thô trước đây).
class ElementTheme {
  const ElementTheme(this.name, this.primary, this.dark, this.light);

  final String name;
  final Color primary;
  final Color dark;
  final Color light;

  static const ElementTheme kim = ElementTheme('Kim', Color(0xFFB08A1E), Color(0xFF6E5308), Color(0xFFFFF4D6));
  static const ElementTheme moc = ElementTheme('Mộc', Color(0xFF2E7D4F), Color(0xFF1B5234), Color(0xFFE3F2E8));
  static const ElementTheme thuy = ElementTheme('Thủy', Color(0xFF1F5F99), Color(0xFF123C63), Color(0xFFE1EEF8));
  static const ElementTheme hoa = ElementTheme('Hoả', Color(0xFFB8322A), Color(0xFF7A1A14), Color(0xFFFBE4E1));
  static const ElementTheme tho = ElementTheme('Thổ', Color(0xFF8D5A2B), Color(0xFF5C3816), Color(0xFFF5E8DA));

  static ElementTheme of(DateTime year) {
    final String n = getNguHanh(year);
    if (n.contains('Kim')) return kim;
    if (n.contains('Mộc')) return moc;
    if (n.contains('Thủy')) return thuy;
    if (n.contains('Hoả')) return hoa;
    return tho;
  }
}
