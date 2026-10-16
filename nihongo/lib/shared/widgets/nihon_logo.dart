import 'package:flutter/material.dart';

class NihonLogo extends StatelessWidget {
  const NihonLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nihon',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'n',
            style: TextStyle(
              color: Color(0xFF1670D2),
              fontSize: 54,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          SizedBox(
            width: 58,
            height: 64,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF171717), width: 4),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'い',
                    style: TextStyle(
                      color: Color(0xFFE23832),
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: 1,
                  child: Transform.rotate(
                    angle: 0.78,
                    child: Container(
                      width: 6,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171717),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'hon',
            style: TextStyle(
              color: Color(0xFF1670D2),
              fontSize: 54,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}