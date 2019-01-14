import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

class Bar {
  double value;
  Color color;
  String label;

  Bar(this.value, {this.color = Colors.grey,  this.label = ""});

  static Bar lerp(Bar begin, Bar end, double t) {
    return new Bar(ui.lerpDouble(begin.value, end.value, t), color: end.color == Colors.grey ? begin.color: end.color);
  }

  static Bar get empty => new Bar(0.0);
}

class BarTween extends Tween<Bar> {
  BarTween({Bar begin, Bar end}) : super(begin: begin, end: end);

  @override
  Bar lerp(double t) => Bar.lerp(begin, end, t);
}

class Chart {

  List<Bar> bars;

  Chart({this.bars});

  Bar barForIndex(int index) {

    if(bars.length > index) {
      return bars[index];
    }

    return Bar.empty;
  }

  static Chart lerp(Chart begin, Chart end, double t) {
    
    var maxItems = max(begin.bars.length, end.bars.length);
    return new Chart(bars: new List.generate(maxItems, (i) {
      var beginBar = begin.barForIndex(i);
      var endBar = end.barForIndex(i);
      
      return Bar.lerp(beginBar, endBar, t);
    }));
  }
}

class ChartTween extends Tween<Chart> {
  ChartTween({Chart begin, Chart end}) : super(begin: begin, end: end);

  @override
  Chart lerp(double t) => Chart.lerp(begin, end, t);
}


class VerticalBarChart extends StatefulWidget {
  
  final Chart chart;
  final Color labelColor;
  final Color lineColor;
  
  VerticalBarChart({List<Bar> bars, this.labelColor, this.lineColor}): chart = new Chart(bars: bars);
  
  @override
  VerticalBarChartState createState() => new VerticalBarChartState(); 

  double chartScale() {
    return max(100.0, chart.bars.fold(0.0, (p, e) => max(e.value, p)));
  }
}

class VerticalBarChartState extends State<VerticalBarChart> with TickerProviderStateMixin {

  double chartScale = 100.0;
  AnimationController animation;

  List<Bar> beginBars = new List.generate(7, (i) => new Bar(0.0));
  List<Bar> endBars = new List.generate(7, (i) => new Bar(0.0));

  ChartTween tween = new ChartTween(begin: new Chart(bars: []), end :new Chart(bars: []));

  @override
  void initState() {
    super.initState();
    tween = new ChartTween(begin: widget.chart, end: widget.chart);
    animation = new AnimationController(duration: const Duration(milliseconds: 650), vsync: this);
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VerticalBarChart oldWidget) { 
    super.didUpdateWidget(oldWidget);
    tween = new ChartTween(begin: oldWidget.chart, end: widget.chart);
    chartScale = max(oldWidget.chartScale(), widget.chartScale());
    animation.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return new CustomPaint(
          size: new Size(constraints.maxWidth, 200.0),
          painter: new ChartPainter(
            animation: tween.animate(new CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            scaleValue: chartScale,
            lineColor: widget.lineColor,
            labelColor: widget.labelColor
          )
        ); 
    });
  }
}

class ChartPainter extends CustomPainter {
  
  double scaleValue = 100.0;
  Color labelColor;
  Color lineColor;

  final Animation<Chart> animation;

  ChartPainter({this.animation, this.scaleValue, this.labelColor, this.lineColor}): super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    
    var chart = animation.value;

    var labelSize = 12.0;
    var labelGutterHeight = labelSize + 8;
    var maxBarHeight = size.height - labelGutterHeight - labelGutterHeight;

    var ratio = maxBarHeight / scaleValue; 

    var barSpacing = 5.0;

    var totalSpacing = barSpacing * (chart.bars.length - 1);
    var barWidth = ((size.width - totalSpacing) / chart.bars.length);

    var x = 0.0;

    final Paint paint = new Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    for(var bar in chart.bars) {

      var barHeight = bar.value * ratio;

      paint.color = bar.color;

      canvas.drawRect(new Rect.fromLTWH(x, labelGutterHeight + maxBarHeight - barHeight, barWidth, barHeight), paint); 
      
      var paragraphBuilder = new ui.ParagraphBuilder(new ui.ParagraphStyle(textAlign: TextAlign.center))
      ..pushStyle(new ui.TextStyle(color: labelColor, fontSize: 9.0))
      ..addText(bar.label);

      var paragraph = paragraphBuilder.build()
      ..layout(new ui.ParagraphConstraints(width: barWidth));

      canvas.drawParagraph(paragraph, new ui.Offset(x, size.height - labelSize));
      

      paragraphBuilder = new ui.ParagraphBuilder(new ui.ParagraphStyle(textAlign: TextAlign.center))
      ..pushStyle(new ui.TextStyle(color: bar.color, fontSize: labelSize, fontWeight: FontWeight.bold))
      ..addText(bar.value.floor().toString());

      paragraph = paragraphBuilder.build()
      ..layout(new ui.ParagraphConstraints(width: barWidth));

      canvas.drawParagraph(paragraph, new ui.Offset(x, maxBarHeight - barHeight));

      x += barWidth + barSpacing;
    }

    paint.style = PaintingStyle.stroke;
    paint.color = lineColor;
    paint.strokeWidth = barSpacing;
    paint.strokeCap = StrokeCap.round;

    canvas.drawLine(new Offset(-barSpacing, size.height - labelGutterHeight), new Offset(size.width + barSpacing, size.height - labelGutterHeight), paint);

    
    
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}