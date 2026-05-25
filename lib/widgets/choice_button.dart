import 'package:flutter/material.dart';

class ChoiceButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const ChoiceButton({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                selected ? const Color(0xFF1E3A8A) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}