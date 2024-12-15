import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';

final currentMoneyProvider = StateNotifierProvider<MoneyNotifier, int>((ref) {
  return MoneyNotifier();
});

class MoneyNotifier extends StateNotifier<int> {
  MoneyNotifier() : super(0) {
    _loadMoney();
  }

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> _loadMoney() async {
    final money = await _dbHelper.getMoney();
    state = money;
  }

  Future<void> updateMoney(int newMoney) async {
    state = newMoney;
    await _dbHelper.updateMoney(newMoney);
  }
}
