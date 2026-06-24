import 'package:flutter/material.dart';

class BoostLogo extends StatelessWidget {
  final double size;
  final Color? bColor;
  final Color? plusColor;

  const BoostLogo({
    super.key,
    required this.size,
    this.bColor,
    this.plusColor,
  });

  @override
  Widget build(BuildContext context) {
    // ajusta a cor do B conforme o tema
    final bCol = bColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF111111));
    final plusCol = plusColor ?? const Color(0xFFE11D48);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BoostLogoPainter(
          bColor: bCol,
          plusColor: plusCol,
        ),
      ),
    );
  }
}

class BoostLogoPainter extends CustomPainter {
  final Color bColor;
  final Color plusColor;

  BoostLogoPainter({
    required this.bColor,
    required this.plusColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 512;
    final scaleY = size.height / 512;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // inclina o desenho
    canvas.translate(40, 0);
    const double angleRad = -12 * 3.1415926535 / 180;
    canvas.transform(Matrix4.skewX(angleRad).storage);

    // desenha o B
    final paintB = Paint()
      ..color = bColor
      ..style = PaintingStyle.fill;

    final outerB = Path()
      ..moveTo(120, 140)
      ..lineTo(210, 140)
      ..cubicTo(245, 140, 270, 155, 270, 190)
      ..cubicTo(270, 215, 255, 230, 235, 235)
      ..cubicTo(265, 240, 285, 260, 285, 295)
      ..cubicTo(285, 335, 250, 360, 205, 360)
      ..lineTo(120, 360)
      ..close();

    final hole1 = Path()
      ..moveTo(175, 185)
      ..lineTo(175, 225)
      ..lineTo(205, 225)
      ..cubicTo(220, 225, 230, 215, 230, 205)
      ..cubicTo(230, 195, 220, 185, 205, 185)
      ..close();

    final hole2 = Path()
      ..moveTo(175, 270)
      ..lineTo(175, 315)
      ..lineTo(210, 315)
      ..cubicTo(225, 315, 238, 305, 238, 292)
      ..cubicTo(238, 280, 225, 270, 210, 270)
      ..close();

    var finalB = Path.combine(PathOperation.difference, outerB, hole1);
    finalB = Path.combine(PathOperation.difference, finalB, hole2);

    canvas.drawPath(finalB, paintB);

    // desenha o +
    final paintPlus = Paint()
      ..color = plusColor
      ..style = PaintingStyle.fill;

    final plusPath = Path()
      ..moveTo(310, 250)
      ..lineTo(345, 250)
      ..lineTo(345, 215)
      ..lineTo(375, 215)
      ..lineTo(375, 250)
      ..lineTo(410, 250)
      ..lineTo(410, 280)
      ..lineTo(375, 280)
      ..lineTo(375, 315)
      ..lineTo(345, 315)
      ..lineTo(345, 280)
      ..lineTo(310, 280)
      ..close();

    canvas.drawPath(plusPath, paintPlus);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BoostLogoPainter oldDelegate) {
    return oldDelegate.bColor != bColor || oldDelegate.plusColor != plusColor;
  }
}
