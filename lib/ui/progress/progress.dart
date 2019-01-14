import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

class ProgressData {
    final double value;
    final Color forground;
    final Color background;
    final Color overflow;
    final String label;

    ProgressData({this.value, this.forground = Colors.black54, this.background = Colors.black12, this.overflow = Colors.black87, this.label = "WEEKLY LIMIT"});
}

class Progress extends StatefulWidget {

  final ProgressData outerData;
  final ProgressData innerData;

  Progress({this.outerData, this.innerData});
  
  @override
  ProgressState createState() => new ProgressState(); 
}

class ProgressState extends State<Progress> with TickerProviderStateMixin {

  AnimationController animation;
  Tween<double> outerTween = new Tween(begin: 0.0, end: 0.0);
  Tween<double> innterTween = new Tween(begin: 0.0, end: 0.0);

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
  void didUpdateWidget(Progress oldWidget) { 
    super.didUpdateWidget(oldWidget);
    outerTween = new Tween(begin: oldWidget.outerData.value, end: widget.outerData.value);
    innterTween = new Tween(begin: oldWidget.innerData.value, end: widget.innerData.value);
    animation.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return new Stack(children: <Widget>[
          new CustomPaint(
              size: new Size(constraints.maxWidth, constraints.maxWidth),
              painter: new ProgressPainter(
                data: widget.outerData, 
                animation: outerTween.animate(new CurvedAnimation(parent: animation, curve: Curves.easeOut))
              )
            ), 
            new CustomPaint(
              size: new Size(constraints.maxWidth, constraints.maxWidth),
              painter: new ProgressPainter(
                data: widget.innerData, 
                animation: innterTween.animate(new CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                offset: 1
              )
            )
        ]);
    },);
    
  }
}

class ProgressPainter extends CustomPainter {
  
  final ProgressData data;
  final Animation<double> animation;
  final int offset;
  
  ProgressPainter({this.data, this.animation, this.offset = 0}): super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    
    var strokeWidth = size.width / 16;
    
    final Paint paint = new Paint()
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth
      ..color = data.background
      ..style = PaintingStyle.stroke;
    
    var offsetPixels = strokeWidth / 2;
    var gap = 2;
    offsetPixels += offset * (strokeWidth + gap);

    var arcSpace = new Rect.fromLTWH(offsetPixels, offsetPixels, size.width - offsetPixels - offsetPixels, size.height - offsetPixels - offsetPixels);

    canvas.drawOval(arcSpace, paint);

    paint.color = data.forground;
    paint.strokeCap = StrokeCap.round;

    canvas.drawArc(arcSpace, (pi * 1.5), 2 * (pi * (animation.value / 100)), false, paint);

    double fontHeight = strokeWidth;

    var labelHeight = strokeWidth * 0.8;

    var paragraphBuilder = new ui.ParagraphBuilder(new ui.ParagraphStyle(fontSize: labelHeight, textAlign: TextAlign.right))
    ..pushStyle(new ui.TextStyle(color: data.forground, fontSize: labelHeight))
    ..addText(data.label);

    var paragraph = paragraphBuilder.build()
    ..layout(new ui.ParagraphConstraints(width: size.width));


    canvas.drawParagraph(paragraph, new ui.Offset(-(size.width / 2) - labelHeight, ((strokeWidth + gap) * offset) + (strokeWidth - labelHeight)));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}