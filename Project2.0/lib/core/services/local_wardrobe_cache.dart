import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/wardrobe/domain/entities/wardrobe_item.dart';

class LocalWardrobeCache {
  static const String _keyPrefix = 'wardrobe_items_';

  static Future<List<WardrobeItem>> load(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_keyPrefix$uid');
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final decoded = json.decode(jsonString) as List<dynamic>;
      return decoded.map((entry) {
        final map = entry as Map<String, dynamic>;
        return WardrobeItem(
          id: (map['id'] as String?) ?? '',
          name: (map['name'] as String?) ?? '',
          category: (map['category'] as String?) ?? 'Other',
          color: (map['color'] as String?) ?? 'Neutral',
          imageUrl: map['imageUrl'] as String?,
          createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
              DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAll(String uid, List<WardrobeItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = items.map(_toMap).toList();
    await prefs.setString('$_keyPrefix$uid', json.encode(payload));
  }

  static Future<void> upsert(String uid, WardrobeItem item) async {
    final items = await load(uid);
    final index = items.indexWhere((existing) => existing.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
    await saveAll(uid, items);
  }

  static Map<String, dynamic> _toMap(WardrobeItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'category': item.category,
      'color': item.color,
      'imageUrl': item.imageUrl,
      'createdAt': item.createdAt.toIso8601String(),
    };
  }
}
