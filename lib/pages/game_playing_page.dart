import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hilow/pages/game_history_page.dart';
import '../provider/game_provider.dart';
import '../widgets/custom_bet_type_widget.dart';
import '../constants/card_images.dart';

class GamePlayingPage extends ConsumerStatefulWidget {
  const GamePlayingPage({super.key});

  @override
  ConsumerState<GamePlayingPage> createState() => _GamePlayingPageState();
}

class _GamePlayingPageState extends ConsumerState<GamePlayingPage>
    with SingleTickerProviderStateMixin {
  int currentCardIndex = 0;
  int nextCardIndex = 1;
  int timer = 10;
  Timer? countdownTimer;
  String? selectedBet;
  String resultMessage = "+0원";
  final TextEditingController betAmountController = TextEditingController();
  final numberFormat = NumberFormat('#,###');
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  late Animation<double> _slideAnimation;
  bool isGamePaused = false;
  bool isCardFlipped = false;

  String getCardName(int index) {
    final suits = ['♠', '♣', '♥', '♦'];
    final values = [
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'A',
      'J',
      'Q',
      'K',
    ];

    final suitIndex = index ~/ 13;
    final rankIndex = index % 13;

    return '${suits[suitIndex]} ${values[rankIndex]}';
  }

  @override
  void initState() {
    super.initState();
    startCountdown();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 0, end: -200).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    betAmountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void startCountdown() {
    if (isGamePaused) return;

    countdownTimer?.cancel();
    timer = 10;
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (this.timer > 0) {
          this.timer--;
        } else {
          timer.cancel();
          if (selectedBet != null && betAmountController.text.isNotEmpty) {
            checkBet();
          } else {
            nextGame();
          }
        }
      });
    });
  }

  void nextGame() {
    if (isGamePaused) return;

    setState(() {
      _animationController.forward().then((_) {
        currentCardIndex = nextCardIndex;
        nextCardIndex = Random().nextInt(cardImages.length);
        selectedBet = null;
        betAmountController.clear();
        isGamePaused = false;
        _animationController.reset();
        startCountdown();
      });
    });
  }

  void checkBet() {
    final money = ref.read(currentMoneyProvider);
    final betAmount =
        int.tryParse(betAmountController.text.replaceAll(',', '')) ?? 0;

    if (betAmount <= 0 || selectedBet == null) {
      setState(() {
        resultMessage = "베팅 금액과 유형을 선택하세요!";
      });
      return;
    }

    if (betAmount > money) {
      setState(() {
        resultMessage = "보유 금액보다 높은 금액은 베팅할 수 없습니다!";
      });
      return;
    }

    int profit = 0;
    String result = "패배";

    if (selectedBet == '높음' && nextCardIndex > currentCardIndex) {
      profit = (betAmount * 2).toInt();
      result = "승리";
    } else if (selectedBet == '무' && nextCardIndex == currentCardIndex) {
      profit = (betAmount * 8).toInt();
      result = "승리";
    } else if (selectedBet == '낮음' && nextCardIndex < currentCardIndex) {
      profit = (betAmount * 1.85).toInt();
      result = "승리";
    } else {
      profit = -betAmount;
    }

    isGamePaused = true;
    Future.delayed(const Duration(seconds: 1), () {
      _animationController.forward().then((_) {
        setState(() {
          if (profit >= 0) {
            ref.read(currentMoneyProvider.notifier).updateMoney(money + profit);
            resultMessage = "+${numberFormat.format(profit)}원";
          } else {
            ref.read(currentMoneyProvider.notifier).updateMoney(money + profit);
            resultMessage = "-${numberFormat.format(profit.abs())}원";
          }
        });

        Future.delayed(const Duration(seconds: 4), () {
          showResultAlert(result, profit);
          setState(() {
            currentCardIndex = nextCardIndex;
            nextCardIndex = Random().nextInt(cardImages.length);
            selectedBet = null;
            betAmountController.clear();
            isGamePaused = false;
            _animationController.reset();
            startCountdown();
          });
        });
      });
    });
  }

  void showResultAlert(String result, int profit) {
    if (!isGamePaused) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("결과: $result"),
          content: Text(profit > 0
              ? "+${numberFormat.format(profit)}원"
              : "-${numberFormat.format(profit.abs())}원"),
          actions: [
            TextButton(
              child: const Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedCard() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value),
            child: _flipAnimation.value < pi / 2
                ? Image.asset("assets/images/cards/back.png", width: 90)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: Image.asset(cardImages[nextCardIndex], width: 90),
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final money = ref.watch(currentMoneyProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const GameHistoryPage(),
              ));
            },
            child: const Text(
              "내역",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xff6B1C2A),
            width: MediaQuery.of(context).size.width,
            height: 260,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 50, 40, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Image.asset(cardImages[currentCardIndex], width: 90),
                      const SizedBox(height: 8),
                      Text(
                        "현재 카드: ${getCardName(currentCardIndex)}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      )
                    ],
                  ),
                  _buildAnimatedCard(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xff26CB57),
                  width: 8,
                ),
              ),
              child: Center(
                child: Text(
                  "$timer",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBetButton(
                text: "높음",
                times: "2배",
                color: const Color(0xffDB1111),
                onPressed: () {
                  setState(() => selectedBet = '높음');
                },
                isSelected: selectedBet == '높음',
              ),
              CustomBetButton(
                text: "무",
                times: "8배",
                color: const Color(0xff4B8D3A),
                onPressed: () {
                  setState(() => selectedBet = '무');
                },
                isSelected: selectedBet == '무',
              ),
              CustomBetButton(
                text: "낮음",
                times: "1.85배",
                color: const Color(0xff365AE9),
                onPressed: () {
                  setState(() => selectedBet = '낮음');
                },
                isSelected: selectedBet == '낮음',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: betAmountController,
                      style: const TextStyle(color: Colors.black),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final number =
                              int.tryParse(value.replaceAll(',', '')) ?? 0;
                          betAmountController.text =
                              numberFormat.format(number);
                          betAmountController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                                offset: betAmountController.text.length),
                          );
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        hintText: "베팅할 금액",
                        hintStyle: const TextStyle(
                            color: Color(0xffAAAAAA), fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isGamePaused
                      ? null
                      : () {
                          checkBet();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isGamePaused ? Colors.grey : const Color(0xffFF4F4F),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 27),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "베팅하기",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffffffff)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: double.infinity,
            height: 1,
            color: const Color(0xffffffff),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      "보유 머니",
                      style: TextStyle(color: Color(0xffffffff)),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${numberFormat.format(money)}원",
                      style: const TextStyle(color: Color(0xffFFDE72)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "베팅 결과",
                      style: TextStyle(color: Color(0xffffffff)),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      resultMessage,
                      style: const TextStyle(color: Color(0xffFFDE72)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
