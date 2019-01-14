import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CountingText extends StatefulWidget {
  final double value;
  final String unit;
  final String caption;
  final int precision;

  CountingText({this.value, this.unit, this.caption, this.precision});
  
  @override
  CountingTextState createState() => new CountingTextState(); 
}

class CountingTextState extends State<CountingText> with TickerProviderStateMixin {

  AnimationController animation;
  Tween<double> tween = new Tween(begin: 0.0, end: 0.0);

  @override
  void initState() {
    super.initState();
    animation = new AnimationController(duration: const Duration(milliseconds: 650), vsync: this);
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CountingText oldWidget) { 
    super.didUpdateWidget(oldWidget);
    tween = new Tween(begin: oldWidget.value, end: widget.value);
    animation.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {

      return new LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        
        var paragraph = AnimatedTextPainter.buildParagraph(300.0, widget.value, widget.unit, widget.caption, widget.precision);
        
        return new CustomPaint(
          size: new Size(constraints.maxWidth, paragraph.height),
          painter: new AnimatedTextPainter(
            animation: tween.animate(new CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            unit: widget.unit,
            caption: widget.caption,
            precision: widget.precision
          )
        ); 
      });
  }
}


class AnimatedTextPainter extends CustomPainter {
  final String unit;
  final String caption;
  final int precision;
  final Animation<double> animation;
  
  AnimatedTextPainter({this.animation, this.unit, this.caption, this.precision = 0}): super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    var paragraph = AnimatedTextPainter.buildParagraph(size.width, animation.value, unit, caption, precision);
    
    canvas.drawParagraph(paragraph, new ui.Offset(0.0, paragraph.height * 0.5));
  }

  static ui.Paragraph buildParagraph(double width, double value, String unit, String caption, int precision) {

    double fontHeight = width * 0.4;

    var paragraphBuilder = new ui.ParagraphBuilder(new ui.ParagraphStyle(fontSize: 0.0, textAlign: TextAlign.center, lineHeight: 0.2,  fontFamily: "San Francisco"));

    paragraphBuilder.pushStyle(new ui.TextStyle(color: Colors.grey[900], fontSize: fontHeight, fontWeight: FontWeight.w900, fontFamily: "Helvetica"));
    paragraphBuilder.addText(value.toStringAsFixed(precision));

    paragraphBuilder.pushStyle(new ui.TextStyle(fontSize: fontHeight / 3, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic));
    paragraphBuilder.addText(" " + unit);

    paragraphBuilder.pushStyle(new ui.TextStyle(fontSize: fontHeight / 5, fontWeight: FontWeight.w600, fontStyle: FontStyle.normal));
    paragraphBuilder.addText("\n" + caption);

    var paragraph = paragraphBuilder.build();
    paragraph.layout(new ui.ParagraphConstraints(width: width));

    return paragraph;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}