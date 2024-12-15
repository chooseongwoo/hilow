import 'package:flutter/material.dart';

class CustomBetButton extends StatelessWidget {
  final String text;
  final String times;
  final Color color;
  final VoidCallback onPressed;
  final bool isSelected;

  const CustomBetButton({
    super.key,
    required this.text,
    required this.times,
    required this.color,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.3,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 45),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xffFFFFFF),
                  ),
                ),
                Text(
                  "($times)",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xffFFFFFF),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
