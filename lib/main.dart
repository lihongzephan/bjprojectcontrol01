// Import Flutter Darts
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

// Import Self Darts
import 'GlobalVariables.dart';
import 'LangStrings.dart';
import 'ScreenVariables.dart';

// Import Pages
import 'PageHome.dart';
import 'PageSelectLanguage.dart';
import 'PageSettingsMain.dart';
import 'Utilities.dart';

// Main Program
void main() {
  // Set Orientation to PortraitUp
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    // Init Screen Variables
    sv.Init();

    // Init Global Vars and SharedPreference
    gv.Init().then((_) {
      // Get Previous Selected Language from SharedPreferences, if any
      gv.gstrLang = gv.getString('strLang');
      if (gv.gstrLang != '') {
        // Set Current Language
        ls.setLang(gv.gstrLang);

        // Already has Current Language, so set first page to SettingsMain
        gv.gstrCurPage = 'SettingsMain';
        gv.gstrLastPage = 'SettingsMain';
      } else {
        // First Time Use, set Current Language to English
        ls.setLang('EN');
      }

      gv.serverIP = gv.getString('serverIP');


      if (gv.getString('intMaxWords') == '') {
        ut.funDebug('Default');
        gv.intMaxWords = gv.intDefaultMaxWords;
      } else {
        ut.funDebug('getString');
        gv.intMaxWords = int.parse(gv.getString('intMaxWords'));
      }

      if (gv.getString('intWaitTime') == '') {
        ut.funDebug('Default');
        gv.intWaitTime = gv.intDefaultWaitTime;
      } else {
        ut.funDebug('getString');
        gv.intWaitTime = int.parse(gv.getString('intWaitTime'));
      }

      if (gv.getString('intAutoPrintTime') == '') {
        ut.funDebug('Default');
        gv.intAutoPrintTime = gv.intDefaultAutoPrintTime;
      } else {
        ut.funDebug('getString');
        gv.intAutoPrintTime = int.parse(gv.getString('intAutoPrintTime'));
      }

      if (gv.getString('intRBUSDis') == '') {
        ut.funDebug('Default');
        gv.intRBUSDis = gv.intDefaultRBUSDis;
      } else {
        ut.funDebug('getString');
        gv.intRBUSDis = int.parse(gv.getString('intRBUSDis'));
      }

      //gv.intMaxWords = int.parse(gv.getString('intMaxWords'));
      //gv.intWaitTime = int.parse(gv.getString('intWaitTime'));
      //gv.intAutoPrintTime = int.parse(gv.getString('intAutoPrintTime'));
      //gv.intRBUSDis = int.parse(gv.getString('intRBUSDis'));

//      gv.intMaxWords = gv.getString('intMaxWords');
//      gv.intWaitTime = gv.getString('intWaitTime');
//      gv.intAutoPrintTime = gv.getString('intAutoPrintTime');
//      gv.intRBUSDis = gv.getString('intRBUSDis');

      // Run MainApp
      runApp(new MyApp());

      // Init socket.io
      // gv.initSocket();
    });
  });
}

// Main App
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable Show Debug

      home: MainBody(),
    );
  }
}

class MainBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Here Return Page According to gv.gstrCurPage
    switch (gv.gstrCurPage) {
      case 'Home':
        return StoreProvider(
          store: gv.storeHome,
          child: StoreConnector<int, int>(
            builder: (BuildContext context, int intTemp) {
              return ClsHome(intTemp);
            },
            converter: (Store<int> sintTemp) {
              return sintTemp.state;
            },
          ),
        );
        break;
      case 'SelectLanguage':
        return ClsSelectLanguage();
        break;
      case 'SettingsMain':
        return StoreProvider(
          store: gv.storeSettingsMain,
          child: StoreConnector<int, int>(
            builder: (BuildContext context, int intTemp) {
              return ClsSettingsMain(intTemp);
            },
            converter: (Store<int> sintTemp) {
              return sintTemp.state;
            },
          ),
        );
        break;
    }
  }
}
