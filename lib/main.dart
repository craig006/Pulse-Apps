import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:pulse/ui/animated_text/animated_text.dart';
import 'package:pulse/ui/bar_chart/bar.dart';
import 'package:pulse/ui/theme/application_theme.dart';
import 'ui/progress/progress.dart';
import 'usecases/fetch_usage_usecase.dart';

void main(){
  //debugPaintSizeEnabled = true;
  //debugPaintLayerBordersEnabled = true;
  runApp(new MyApp());
} 


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
		return new ApplicationTheme (child:
			new MaterialApp(
				title: "Hello World",
				color: Colors.green,
				debugShowMaterialGrid: false,
				showSemanticsDebugger: false,
				checkerboardOffscreenLayers: false,
				debugShowCheckedModeBanner: false,
				showPerformanceOverlay: false,
				theme: new ThemeData(),
				onGenerateRoute: generate,
				onUnknownRoute: unKnownRoute,
			)
		);
  }

  Route unKnownRoute(RouteSettings settings) {
    return new PageRouteBuilder(pageBuilder: (BuildContext context,
        Animation<double> animation, Animation<double> secondaryAnimation) {
      return new Padding(
        padding: new EdgeInsets.all(20.0),
      );
    });
  }

  Route generate(RouteSettings settings) {
    Route page;
    switch (settings.name) {
      case "/":
        page = new PageRouteBuilder(pageBuilder: (BuildContext context,
            Animation<double> animation, Animation<double> secondaryAnimation) {
          return new CirclePage(title: "5 SENTRAAL");
        }, transitionsBuilder: (_, Animation<double> animation,
            Animation<double> second, Widget child) {
          return new FadeTransition(
            opacity: animation,
            child: new FadeTransition(
              opacity: new Tween<double>(begin: 1.0, end: 0.0).animate(second),
              child: child,
            ),
          );
        });
        break;
    }
    return page;
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return new DefaultTextStyle(
        style: Theme.of(context).textTheme.body1,
        child: new CupertinoPageScaffold(
            navigationBar: new CupertinoNavigationBar(middle: new Text(widget.title)),
            child: new SafeArea(
          child: new Padding(
              padding: new EdgeInsets.all(40.0),
              child: new Form(
                child: new Column(
                  verticalDirection: VerticalDirection.up,
                  children: <Widget>[
                    new Container(height: 100.0),
                    new PulseFormField(),
                    new Container(height: 60.0),
                    new PulseFormField(),
                  ],
                ),
              )),
        )));
  }
}

class CirclePage extends StatefulWidget {
  CirclePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  CirclePageState createState() => new CirclePageState();
}

class CirclePageState extends State<CirclePage> {
  final random = new Random();
  double dailyLimit = 150.0;
  double completedToday = 0.0;
  double completedWeek = 0.0;
  double todayUsage = 0.0;
  double lastSevenDaysAverage = 0.0;
  String title = "";
  double monthKiloliters = 0.0;
  double monthAverage = 0.0;
  double esitmatedMonthUsage = 0.0;
  double bill = 0.0;

  List<Bar> lastSevenDaysBars = new List<Bar>();

  @override
  void initState() {
    super.initState();
    changeData();
  }

  void changeData() {
		resetData();
    var usecase = new FetchUsageUsecase();
    usecase.begin().then((value) {
      setState(() {
        
        var app = ApplicationTheme.of(context);
        completedToday = (value.today.liters / dailyLimit) * 100;
        completedWeek = (value.week.liters / (dailyLimit * 7)) * 100;
        todayUsage = value.today.liters;

        var lastSevenDays = value.lastSevenDays;
        lastSevenDaysAverage = lastSevenDays.average;
        lastSevenDaysBars = lastSevenDays.days.map<Bar>((d){
          return new Bar(d.liters, 
            color: d.liters > dailyLimit ? app.themeData.waterTertiaryAccentColor : app.themeData.waterSecondaryAccentColor,
            label: d.shortDayLabel);
        }).toList();

        title = value.title;

        monthKiloliters = value.kiloliters;
        monthAverage = value.average;
        esitmatedMonthUsage = value.estimatedKiloliters;
        bill = value.estimatedBill;

      });
    });
  }

  void resetData() {
    setState(() {
      completedToday = 0.0;
      completedWeek = 0.0;
      todayUsage = 0.0;
      lastSevenDaysBars = new List<Bar>();
      monthKiloliters = 0.0;
      monthAverage = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {

		var app = ApplicationTheme.of(context);

    return new DefaultTextStyle(
        style: app.themeData.defaultTextStyle.dark,
        child: new CupertinoPageScaffold(
            navigationBar: new CupertinoNavigationBar(middle: new Text(widget.title), 
              trailing: new Material(child: new IconButton(icon:new Icon(Icons.refresh), onPressed: changeData,),)),
            child: new SafeArea(
              child: new ListView(children: <Widget>[
                new Center(
                  child: new Padding(padding: new EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                    child: new Column(children: <Widget>[
                      new Container(height: 40.0, width: 100.0),
                      new Stack(alignment: Alignment.center, children: <Widget>[
                        new Padding(padding: new EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                          child: 
                        new Progress(
                         outerData: new ProgressData(value: completedWeek, background: app.themeData.waterSecondaryAccentColor[50], forground: app.themeData.waterSecondaryAccentColor, label: "WEEKLY LIMIT"),
                         innerData: new ProgressData(value: completedToday, background: app.themeData.waterPrimaryAccentColor[50], forground: app.themeData.waterPrimaryAccentColor, label: "DAILY LIMIT"))),
                        new Padding(
                         padding: new EdgeInsets.fromLTRB(70.0, 0.0, 70.0, 0.0),
                          child: new CountingText(value: todayUsage, caption: "USED TODAY", unit: "L", precision: 0,),
                        )
                        
                      ]),
                      new Container(height: 40.0, width: 100.0),
											new Text("LAST 7 DAYS", style: app.themeData.titleTextStyle.dark,),
                      new Container(height: 10.0, width: 100.0),
                      new Text("AVERAGE DAILY USAGE IS " + lastSevenDaysAverage.floor().toString() + "l", style: app.themeData.labelTextStyle.dark),
                      new Container(height: 15.0, width: 100.0),
                      new VerticalBarChart(bars: lastSevenDaysBars, labelColor: app.themeData.accentTextColor, lineColor: app.themeData.accentTextColor),
                      new Container(height: 40.0, width: 100.0),
                      new Text(title, style: app.themeData.titleTextStyle.dark,),
                      new Container(height: 10.0, width: 100.0),
                      new Text("AVERAGE DAILY USAGE IS " + monthAverage.floor().toString() + "l", style: app.themeData.labelTextStyle.dark),
                      new Container(height: 30.0, width: 100.0),
                      new Padding(
                         padding: new EdgeInsets.fromLTRB(70.0, 0.0, 70.0, 0.0),
                          child: new CountingText(value: monthKiloliters, caption: "USED SO FAR", unit: "kl", precision: 2,),
                        ),
                      new Container(height: 30.0, width: 100.0),

                      new FractionallySizedBox(child: 
                        new Container(height: 1.0, color: app.themeData.offWhite,)
                      ),
                      new Container(height: 30.0, width: 100.0),
                      
                      new Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                        new Center(child: 
                        new Column(children: <Widget>[
                          new Text("ESTIMATED TOTAL", style: app.themeData.labelTextStyle.dark,),
                          new Container(height: 20.0, width: 100.0),
                          new Container(height: 40.0, width: 100.0, alignment: Alignment.center,
                          decoration: new BoxDecoration(color: app.themeData.waterSecondaryAccentColor, borderRadius: new BorderRadius.all(new Radius.circular(3.0))),
                          child: new Text(esitmatedMonthUsage.toStringAsFixed(1) + "KL", style: app.themeData.titleTextStyle.light),
                          
                      ),
                        ],)),
                        new Center(child: 
                        new Column(children: <Widget>[
                          new Text("ESTIMATED BILL", style: app.themeData.labelTextStyle.dark,),
                          new Container(height: 20.0, width: 100.0),
                          new Container(height: 40.0, width: 100.0, alignment: Alignment.center,
                          decoration: new BoxDecoration(color: app.themeData.waterSecondaryAccentColor, borderRadius: new BorderRadius.all(new Radius.circular(3.0))),
                          child: new Text("R" + bill.toStringAsFixed(2), style: app.themeData.titleTextStyle.light)
                      )
                        ],))
                      ],),
                      
                      new Container(height: 40.0, width: 100.0),
                  ])))
              ],)
                )));
  }
}

class PulseFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text("Cell number1"),
          new TextFormField(
              decoration: new InputDecoration(hintText: "hintText"))
        ]);
  }
}
