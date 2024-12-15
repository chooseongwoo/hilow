import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider/game_provider.dart';
import '../database/database_helper.dart';
import '../models/bet_model.dart';

class GameHistoryPage extends ConsumerWidget {
  const GameHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMoney = ref.watch(currentMoneyProvider);
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "베팅 내역",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "보유 머니: ${numberFormat.format(currentMoney)}원",
              style: const TextStyle(
                color: Color(0xffFFDE72),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showResetConfirmationDialog(context, ref);
              },
              child: const Text("초기화"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Bet>>(
                future: fetchHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('오류: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('베팅 내역이 없습니다.'));
                  }

                  final bets = snapshot.data!;
                  return ListView.builder(
                    itemCount: bets.length,
                    itemBuilder: (context, index) {
                      final bet = bets[index];
                      return betCard(
                        number: (index + 1).toString(),
                        time: bet.time,
                        amount: "${bet.amount}원",
                        type: bet.type,
                        result: bet.result,
                        profit: "${bet.profit > 0 ? '+' : ''}${bet.profit}원",
                        total: "${bet.total}원",
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Bet>> fetchHistory() async {
    final dbHelper = DatabaseHelper.instance;
    final historyData = await dbHelper.fetchHistory();
    return historyData.map((json) => Bet.fromJson(json)).toList();
  }

  void _showResetConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("초기화 확인"),
          content: const Text("정말로 보유 머니를 100,000원으로 초기화 하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                if (Navigator.of(context).mounted) {
                  await ref
                      .read(currentMoneyProvider.notifier)
                      .updateMoney(100000);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

  Widget betCard({
    required String number,
    required String time,
    required String amount,
    required String type,
    required String result,
    required String profit,
    required String total,
  }) {
    return Card(
      color: const Color(0xFF2E2E2E),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "베팅 번호: $number",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: detailItem("시간", time)),
                Expanded(child: detailItem("금액", amount)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: detailItem("타입", type, highlight: true)),
                Expanded(child: detailItem("결과", result, highlight: true)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: detailItem("차익", profit)),
                Expanded(child: detailItem("총 머니", total)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget detailItem(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: highlight
                ? (value == "높음"
                    ? const Color(0xffDB1111)
                    : value == "낮음"
                        ? const Color(0xff365AE9)
                        : value == "무승부"
                            ? const Color(0xff4B8D3A)
                            : Colors.white)
                : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
