import 'package:flutter/material.dart';

String getMajorityCrowdingLevel(List<String> levels) {
  if (levels.isEmpty) {
    return '投稿なし'; // 投稿がない場合は黒
  }

  Map<String, int> count = {'超渋滞': 0, '渋滞': 0, '少ない・普通': 0};

  for (var level in levels) {
    if (count.containsKey(level)) {
      count[level] = count[level]! + 1;
    }
  }

  if (count['超渋滞']! >= count['渋滞']! && count['超渋滞']! >= count['少ない・普通']!) {
    return '超渋滞';
  } else if (count['渋滞']! >= count['少ない・普通']!) {
    return '渋滞';
  } else {
    return '少ない・普通';
  }
}

// 混雑レベルに応じたマーカーの色を返す
Color getMarkerColor(String level) {
  switch (level) {
    case "超渋滞":
      return Colors.red; // 超渋滞
    case "渋滞":
      return Colors.orange; // 渋滞
    case "少ない・普通":
      return Colors.green;
    case "投稿なし":
      return Colors.black;
    default:
      return Colors.black;
  }
}
