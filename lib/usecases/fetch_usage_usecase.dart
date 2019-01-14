import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:math';


class FetchUsageUsecase {
  Future<WaterUsage> begin() async {
    
    var url = new Uri.https("newiotfunctionsapp.azurewebsites.net", "/api/waterusage/myFancyWaterMeter/A/3/2018");
    
    var response = await http.get(url);
    
    Map data = JSON.decode(response.body);

    return new WaterUsage.fromJson(data); 
  }
}

class WaterUsage {
  
  UsageIdentifier usageIdentifier;

  List<DailyWaterUsage> days;

  WaterUsage.fromJson(Map json) {
    usageIdentifier = new UsageIdentifier.fromJson(json["identity"]);
    days = JsonConvert.fromJsonList<DailyWaterUsage>(json["days"], (d) { return new DailyWaterUsage.fromJson(d); });
    days.forEach((d) { d.month = usageIdentifier.month; d.year = usageIdentifier.year; });
  }

  DailyWaterUsage get today {
    var date = new DateTime.now().day;
    var orElse = () { return new DailyWaterUsage.empty(); };    
    return days.firstWhere((day) { return day.day == date; }, orElse: orElse);
  }

  WaterUsageRange get week {
    var date = new DateTime.now();
    var weekStart = date.day - (date.weekday - 1);
    var daysInWeek = days.where((d){return d.day >= weekStart;}).toList();
    return new WaterUsageRange(daysInWeek);
  }

  WaterUsageRange get lastSevenDays {

    var date = new DateTime.now();

    var result = new List.generate(7, (i){
      var day = date.subtract(new Duration(days: i));
      return days.firstWhere((e) => e.day == day.day, orElse: () => new DailyWaterUsage(day.day));
    })
    ..sort((DailyWaterUsage l, DailyWaterUsage r) => l.day.compareTo(r.day));

    return new WaterUsageRange(result);
  }

  String get title {
    var date = new DateTime(usageIdentifier.year, usageIdentifier.month, 1);
    var formatter = new DateFormat('MMMM yyyy');
    return formatter.format(date).toUpperCase();
  }

  double get milliliters => days.fold<double>(0.0, (v, d){return v += d.milliliters;});

  int get liters => ((milliliters / 1000).floor());

  double get kiloliters => milliliters / 1000000;

  double get average => days.fold(0.0, (p, e) => p += e.liters) / days.length;

  double get estimatedKiloliters {
    var now = new DateTime.now();
    var lastDayAsDate = (now.month < 12) ? new DateTime(now.year, now.month + 1, 0) : new DateTime(now.year + 1, 1, 0);
    return (average * lastDayAsDate.day) / 1000;
  }

  double get estimatedBill {
    var esitmatedUsage = estimatedKiloliters * 1000;

    var billAmount = 0.0;
    var bracketPortions = [6000, 4500, 9500, 15000, 999999999999999999];
    var bracketCosts = [29.93, 52.44, 114.0, 342.0, 912.0];
    var remainder = esitmatedUsage;

    for(int i = 0; i < bracketPortions.length; i++) {
      billAmount += (min(bracketPortions[i], remainder) / 1000) * bracketCosts[i];
      remainder = max(remainder - bracketPortions[i], 0.0);

      if(remainder == 0.0)
        break;  
    }

    return billAmount;
  }
}

class WaterUsageRange {
  WaterUsageRange(this.days);
  List<DailyWaterUsage> days;

  double get milliliters => days.fold<double>(0.0, (v, d){return v += d.milliliters;});
  double get liters => ((milliliters / 1000).floor().toDouble()); 
  double get average => days.fold(0.0, (p, e) => p += e.liters) / days.length;
}

class DailyWaterUsage {
  int day;
  int month;
  int year;
  double milliliters = 0.0;

  DailyWaterUsage(this.day);

  DailyWaterUsage.fromJson(Map json) {
    day = json["day"];
    milliliters = json["milliliters"];
  }

  DailyWaterUsage.empty() {
    day = 0;
    milliliters = 0.0;
  }

  double get liters {
    return (milliliters/1000).floor().toDouble();
  }

  String get shortDayLabel {
    if(day == null || month == null || year == null) {
      return "XXX";
    }

    var weekDay = new DateTime(year, month, day).weekday;

    switch (weekDay) {
      case DateTime.sunday:
      case DateTime.saturday:
        return "S";
        break;
      case DateTime.tuesday:
      case DateTime.thursday:
        return "T";
        break;
      case DateTime.monday:
        return "M";
        break;
      case DateTime.wednesday:
        return "W";
        break;
      case DateTime.friday:
        return "F";
        break;
      default:
        return "";
    }
  }
}

class UsageIdentifier {
  String deviceId;
  String sensorId;
  int month;
  int year;

  UsageIdentifier.fromJson(Map json) {
    deviceId = json["deviceId"];
    sensorId = json["sensorId"];
    month = json["month"];
    year = json["year"];
  }
}

class JsonConvert {
  static List<T> fromJsonList<T>(List<Map> jsonList, T f(Map e)) {
    return jsonList.map<T>(f).toList();
  }
}