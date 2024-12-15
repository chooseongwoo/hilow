import 'package:flutter/material.dart';
import 'package:hilow/pages/game_history_page.dart';
import 'package:hilow/pages/game_playing_page.dart';
import 'package:hilow/widgets/custom_button_widget.dart';

void main() {
  runApp(const GameStartPage());
}

class GameStartPage extends StatelessWidget {
  const GameStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "높",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDB1111),
                  ),
                ),
                Text(
                  "낮",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF365AE9),
                  ),
                ),
                Text(
                  "이",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              "높음과 낮음,\n어느 쪽을 선택하시겠습니까?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  CustomButton(
                    text: "게임하러 가기",
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const GamePlayingPage(),
                      ));
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: "내역 보러 가기",
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const GameHistoryPage(),
                      ));
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
