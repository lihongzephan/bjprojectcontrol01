// This program display the Home Page

// Import Flutter Darts
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:flutter/services.dart';
import 'package:simple_permissions/simple_permissions.dart';
//import 'package:flutter_tts/flutter_tts.dart';

// Import Self Darts
import 'LangStrings.dart';
import 'ScreenVariables.dart';
import 'GlobalVariables.dart';
import 'Utilities.dart';

// Import Pages
import 'BottomBar.dart';

// Class for stt
const languages = const [
  const Language('Chinese', 'zh_CN'),
  const Language('English', 'en_US'),
  const Language('Francais', 'fr_FR'),
  const Language('Pусский', 'ru_RU'),
  const Language('Italiano', 'it_IT'),
  const Language('Español', 'es_ES'),
];

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

enum TtsState { playing, stopped }

// Home Page
class ClsHome extends StatelessWidget {
  final intState;

  ClsHome(this.intState);

  final ctlMaxWords = TextEditingController();
  final ctlWaitTime = TextEditingController();
  final ctlAutoPrintTime = TextEditingController();
  final ctlRBUSDis = TextEditingController();
  final ctlServerIP = TextEditingController();

  void funCheckJoyStick() {
    int x = (gv.dblAlignX * 10).toInt();
    int y = (gv.dblAlignY * 10).toInt();

    int intLeft = 0;
    int intRight = 0;

    // Checking
    if (x > 0) {
      if (y >= x) {
        intLeft = -1;
        intRight = -1;
      } else if (y <= -x) {
        intLeft = 1;
        intRight = 1;
      } else {
        intLeft = 1;
        intRight = -1;
      }
    } else if (x == 0) {
      if (y > 0) {
        intLeft = -1;
        intRight = -1;
      } else if (y == 0) {
        intLeft = 0;
        intRight = 0;
      } else {
        intLeft = 1;
        intRight = 1;
      }
    } else {
      if (y >= -x) {
        intLeft = -1;
        intRight = -1;
      } else if (y <= x) {
        intLeft = 1;
        intRight = 1;
      } else {
        intLeft = -1;
        intRight = 1;
      }
    }
    //print(intLeft.toString() + ' , ' + intRight.toString());
    // Socket emit
    if (intLeft != gv.intLastLeft || intRight != gv.intLastRight) {
      //ut.funDebug('Send move rb to server, id: ' + gv.strLoginID);
      gv.socket.emit('RBMoveRobot', [
        gv.strID,
        ['F', intLeft, intRight, 0]
      ]);
      gv.intLastLeft = intLeft;
      gv.intLastRight = intRight;
    }
  }

  void funMaxWordsChange() {
    gv.intMaxWords = int.parse(ctlMaxWords.text);
    if (gv.intMaxWords == 0) {
      gv.intMaxWords = gv.intDefaultMaxWords;
    }
    gv.setString('intMaxWords', gv.intMaxWords.toString());
    //funSocketEmitChangeSettings();
  }

  void funWaitTimeChange() {
    gv.intWaitTime = int.parse(ctlWaitTime.text);
    if (gv.intWaitTime == 0) {
      gv.intWaitTime = gv.intDefaultWaitTime;
    }
    if (gv.intWaitTime < 1) {
      gv.intWaitTime = 1;
    }
    gv.setString('intWaitTime', gv.intWaitTime.toString());
    //funSocketEmitChangeSettings();
  }

  void funAutoPrintTimeChange() {
    gv.intAutoPrintTime = int.parse(ctlAutoPrintTime.text);
    if (gv.intAutoPrintTime == 0) {
      gv.intAutoPrintTime = gv.intDefaultAutoPrintTime;
    }
    if (gv.intAutoPrintTime < 1) {
      gv.intAutoPrintTime = 1;
    }
    gv.setString('intAutoPrintTime', gv.intAutoPrintTime.toString());
    //funSocketEmitChangeSettings();
  }

  void funRBUSDisChange() {
    gv.bolAutoMove = false;
    gv.intRBUSDis = int.parse(ctlRBUSDis.text);
    if (gv.intRBUSDis == 0) {
      gv.intRBUSDis = gv.intDefaultRBUSDis;
    }
    if (gv.intRBUSDis < 20) {
      gv.intRBUSDis = 20;
    }
    gv.setString('intRBUSDis', gv.intRBUSDis.toString());
    //funSocketEmitChangeSettings();
  }

  void funHomeChangeMoveMode() {
    if (gv.bolAutoMove) {
      gv.bolAutoMove = false;
    } else {
      gv.bolAutoMove = true;
    }
    funSocketEmitChangeSettings();
    gv.storeHome.dispatch(Actions.Increment);
  }

  void funSocketEmitChangeSettings() {
    gv.socket.emit('CtlChangeSettings', [
      gv.strID,
      gv.intMaxWords,
      gv.intWaitTime * 1000,
      gv.intAutoPrintTime * 60000,
      gv.intRBUSDis,
      gv.bolAutoMove,
    ]);
    ut.showToast(ls.gs('changeSettingsSuccess'));
    ut.funDebug('Press change settings button');
  }

  void funConnectServer() {
    if (ctlServerIP.text.isNotEmpty) {
      gv.serverIP = ctlServerIP.text;
      gv.URI = 'http://' + gv.serverIP + ':10541';
      gv.initSocket();
    }

  }

  Widget MoveModeButton() {
    var text = ls.gs('Mode:Manual');
    var color = Colors.greenAccent;
    if (gv.bolAutoMove) {
      text = ls.gs('Mode:Auto');
      color = Colors.blueAccent;
    } else {
      text = ls.gs('Mode:Manual');
      color = Colors.greenAccent;
    }
    return RaisedButton(
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(sv.dblDefaultRoundRadius)),
      textColor: Colors.white,
      color: color,
      onPressed: () => funHomeChangeMoveMode(),
      child: Text(text, style: TextStyle(fontSize: sv.dblDefaultFontSize * 1)),
    );
  }

  Widget ChangeSettingsButton() {
    var text = ls.gs('ChangeSettings');
    var color = Colors.cyanAccent;

    return RaisedButton(
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(sv.dblDefaultRoundRadius)),
      textColor: Colors.white,
      color: color,
      onPressed: () => funSocketEmitChangeSettings(),
      child: Text(text, style: TextStyle(fontSize: sv.dblDefaultFontSize * 1)),
    );
  }

  Widget ConnectButton() {
    var text = ls.gs('Connect');
    var color = Colors.greenAccent;
    return RaisedButton(
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(sv.dblDefaultRoundRadius)),
      textColor: Colors.white,
      color: color,
      onPressed: () => funConnectServer(),
      child: Text(text, style: TextStyle(fontSize: sv.dblDefaultFontSize * 1)),
    );
  }

  Widget Body() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: sv.dblScreenWidth,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: sv.dblDefaultFontSize * 5,
                          width: sv.dblScreenWidth / 3,
                          child: TextField(
                            controller: ctlMaxWords,
                            decoration: new InputDecoration(
                                labelText: ls.gs('MaxWords')),
                            keyboardType: TextInputType.number,
                            onChanged: (a) => funMaxWordsChange(),
                          ),
                        ),
                        Container(
                          width: sv.dblScreenWidth / 6,
                        ),
                        Container(
                          height: sv.dblDefaultFontSize * 5,
                          width: sv.dblScreenWidth / 3,
                          child: TextField(
                            controller: ctlWaitTime,
                            decoration: new InputDecoration(
                                labelText: ls.gs('WaitTime')),
                            keyboardType: TextInputType.number,
                            onChanged: (a) => funWaitTimeChange(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: sv.dblDefaultFontSize * 5,
                          width: sv.dblScreenWidth / 3,
                          child: TextField(
                            controller: ctlAutoPrintTime,
                            decoration: new InputDecoration(
                                labelText: ls.gs('AutoPrintTime')),
                            keyboardType: TextInputType.number,
                            onChanged: (a) => funAutoPrintTimeChange(),
                          ),
                        ),
                        Container(
                          width: sv.dblScreenWidth / 6,
                        ),
                        Container(
                          height: sv.dblDefaultFontSize * 5,
                          width: sv.dblScreenWidth / 3,
                          child: TextField(
                            controller: ctlRBUSDis,
                            decoration: new InputDecoration(
                                labelText: ls.gs('RBUSDis')),
                            keyboardType: TextInputType.number,
                            onChanged: (a) => funRBUSDisChange(),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: SizedBox(
                        height: sv.dblDefaultFontSize * 2.5,
                        width: sv.dblScreenWidth / 2,
                        child: MoveModeButton(),
                      ),
                    ),
                    Container(
                      height: sv.dblDefaultFontSize,
                    ),
                    Container(
                      child: SizedBox(
                        height: sv.dblDefaultFontSize * 2.5,
                        width: sv.dblScreenWidth / 2,
                        child: ChangeSettingsButton(),
                      ),
                    ),
                    Container(
                      height: sv.dblDefaultFontSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: gv.bolAutoMove,
            child: Container(
              height: sv.dblBodyHeight * 0.35,
              width: sv.dblScreenWidth,
              child: Align(
                alignment: Alignment(gv.dblAlignX, gv.dblAlignY),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (dragDetails1) {
                    // print('Start: ' + dragDetails1.toString());
                  },
                  onPanUpdate: (dragDetails2) {
                    // print('Update: ' + dragDetails2.toString());
                    gv.dblAlignX = (dragDetails2.globalPosition.dx * 2 -
                            sv.dblScreenWidth) /
                        sv.dblScreenWidth;
                    //gv.dblAlignY = ((dragDetails2.globalPosition.dy - sv.dblTopHeight * 1.5) * 2 - sv.dblScreenHeight / 2) / sv.dblScreenHeight * 2;
                    // 自己container的height - 上面所有widget的height， 再除以自己Container的height，最后减0.5再乘以2
                    gv.dblAlignY = ((dragDetails2.globalPosition.dy -
                                    sv.dblBodyHeight * 0.65 -
                                    sv.dblTopHeight) /
                                (sv.dblBodyHeight * 0.35) -
                            0.5) *
                        2;
                    //print(gv.dblAlignY);
                    if (gv.dblAlignY > 1) {
                      gv.dblAlignY = 1;
                    }
                    if (gv.dblAlignY < -1) {
                      gv.dblAlignY = -1;
                    }
                    gv.storeHome.dispatch(Actions.Increment);
                    funCheckJoyStick();
                  },
                  onPanEnd: (dragDetails1) {
                    gv.dblAlignX = 0;
                    gv.dblAlignY = 0;
                    gv.storeHome.dispatch(Actions.Increment);
                    gv.socket.emit('RBMoveRobot', [
                      gv.strID,
                      ['F', 0, 0, 0]
                    ]);
                    gv.intLastLeft = 0;
                    gv.intLastRight = 0;
                  },
                  child: Container(
                    height: sv.dblScreenWidth / 5,
                    width: sv.dblScreenWidth / 5,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(sv.dblScreenWidth / 10),
                      color: Colors.lightBlue,
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 8.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ConnectBody() {
    return Container(
      child: Container(
        width: sv.dblScreenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: sv.dblScreenWidth / 2,
              child: TextField(
                controller: ctlServerIP,
                decoration: new InputDecoration(labelText: ls.gs('ServerIP')),
                keyboardType: TextInputType.number,
                onChanged: (a) => gv.serverIP = ctlServerIP.text,
              ),
            ),
            Text(' '),
            Container(
              // height: sv.dblBodyHeight / 4,
              // width: sv.dblScreenWidth / 4,
              child: Center(
                child: SizedBox(
                  height: sv.dblDefaultFontSize * 2.5,
                  width: sv.dblScreenWidth / 3,
                  child: ConnectButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//  void funInitFirstTime() {
//    // WebRTC
//    if (gv.rtcSelfId == '') {
//      initRenderers();
//      _connect();
//    }
//  }

  @override
  Widget build(BuildContext context) {
    try {
      //    if (intCountState == 1) {
      //      intCountState += 1;
      //      funInitFirstTime();
      //    }
      ctlMaxWords.text = gv.intMaxWords.toString();
      ctlWaitTime.text = gv.intWaitTime.toString();
      ctlAutoPrintTime.text = gv.intAutoPrintTime.toString();
      ctlRBUSDis.text = gv.intRBUSDis.toString();

      ctlServerIP.text = gv.serverIP;

      if (gv.bolFirstTimeLoginSuccess == true) {
        return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: PreferredSize(
            child: AppBar(
              title: Text(
                ls.gs('Home'),
                style: TextStyle(fontSize: sv.dblDefaultFontSize),
              ),
            ),
            preferredSize: new Size.fromHeight(sv.dblTopHeight),
          ),
          body: Body(),
          bottomNavigationBar: ClsBottom(),
        );
      } else {
        return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: PreferredSize(
            child: AppBar(
              title: Text(
                ls.gs('Home'),
                style: TextStyle(fontSize: sv.dblDefaultFontSize),
              ),
            ),
            preferredSize: new Size.fromHeight(sv.dblTopHeight),
          ),
          body: ConnectBody(),
          bottomNavigationBar: ClsBottom(),
        );
      }
    } catch (err) {
      ut.funDebug('home wigdet build error: ' + err.toString());
      return Container();
    }
  }
}
