import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ApplicationTheme extends InheritedWidget {

  
  final ApplicationThemeData themeData = new ApplicationThemeData();

  ApplicationTheme({Widget child}): super(child: child);

  static ApplicationTheme of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ApplicationTheme);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

class ColorTextStyle {
  TextStyle _textStyle;
  Color _light;
  Color _dark;

  ColorTextStyle(this._textStyle, this._dark, this._light);
  TextStyle operator [](Color color) => _textStyle.apply(color: color);
  TextStyle get light => _textStyle.apply(color: _light);
  TextStyle get dark => _textStyle.apply(color: _dark);

}

class ApplicationThemeData {

  //colors
  Color defaultTextColor;
  Color lightTextColor;
  Color accentTextColor;
  Color accentColor;
  Color offWhite;

  ColorSwatch<int> waterPrimaryAccentColor = const ColorSwatch<int>(0xFF00ABA9, 
  const <int, Color>{
       50: const Color(0xFFD1F0EF),
      500: const Color(0xFF00ABA9),
    }
  );

  ColorSwatch<int> waterSecondaryAccentColor = const ColorSwatch<int>(0xFF1AA1E2, 
  const <int, Color>{
       50: const Color(0xFFCEEBF9),
      500: const Color(0xFF1AA1E2),
    }
  );

  ColorSwatch<int> waterTertiaryAccentColor = const ColorSwatch<int>(0xFFFF7700, 
  const <int, Color>{
       50: const Color(0xFFFFD5B0),
      500: const Color(0xFFFF7700),
    }
  );
  
 

  //font sizes
  double defaultFontSize;
  double heroFontSize;
  double labelFontSize;
  double titleFontSize;

  //text styles
  ColorTextStyle defaultTextStyle;
  ColorTextStyle heroTextStyle;
  ColorTextStyle labelTextStyle;
  ColorTextStyle titleTextStyle;

  ApplicationThemeData() {
    //colors
    defaultTextColor = new Color.fromARGB(255, 54, 54, 54);
    accentColor = new Color.fromARGB(255, 1, 72, 119);
    accentTextColor = accentColor;
    lightTextColor = Colors.white;
    offWhite = new Color.fromARGB(255, 216, 216, 216);
    
    //font sizes
    defaultFontSize = 14.0;
    heroFontSize = 26.0;
    labelFontSize = 12.0;
    titleFontSize = 18.0;

    //text styles
    defaultTextStyle = new ColorTextStyle(new TextStyle(fontSize: defaultFontSize), defaultTextColor, lightTextColor);
    heroTextStyle = new ColorTextStyle(new TextStyle(fontSize: heroFontSize, fontWeight: FontWeight.bold), defaultTextColor, lightTextColor);
    titleTextStyle = new ColorTextStyle(new TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold), defaultTextColor, lightTextColor);
    labelTextStyle = new ColorTextStyle(new TextStyle(fontSize: labelFontSize), accentTextColor, lightTextColor);
  
  }

}