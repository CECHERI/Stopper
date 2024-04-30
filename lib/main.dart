import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stopper/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Image.asset(
                'images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 2,
              child: AddButtons(),
            ),
          ],
        ),
      ),
    );
  }
}

class AddButtons extends StatefulWidget {
  @override
  _AddDevice createState() => _AddDevice();
}

class _AddDevice extends State<AddButtons> {
  List<ButtonData> buttons = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50.0),
                scrollDirection: Axis.horizontal,
                itemCount: buttons.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0),
                    child: InkWell(
                      onTap: () => _showEditDialog(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 150,
                            width: 150,
                            child: Image.asset('images/devices.png', fit: BoxFit.cover),
                          ),
                          Text(buttons[index].name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addButton,
        child: Icon(Icons.add, color: Colors.black, size: 30),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _addButton() {
    setState(() {
      buttons.add(ButtonData('DEVICE${buttons.length + 1}', true, true));
    });
  }

  void _showEditDialog(int index) {
    TextEditingController nameController = TextEditingController(text: buttons[index].name);
    bool tempIsActive1 = buttons[index].isActive1;
    bool tempIsActive2 = buttons[index].isActive2;
    bool originalIsActive1 = tempIsActive1; // 초기 활성화 스위치 상태 저장
    bool originalIsActive2 = tempIsActive2; // 초기 알림 스위치 상태 저장

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                backgroundColor: Colors.white,
                contentTextStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 17
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                      decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent)
                          )
                      ),
                      onChanged: (text) {
                        setState(() {
                          buttons[index].name = text;
                        });
                      },
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('활성화  '),
                            Switch(
                              value: tempIsActive1,
                              onChanged: (bool value) {
                                setState(() {
                                  tempIsActive1 = value;
                                });
                              },
                              activeTrackColor: Colors.black54,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(' 알  림  '),
                            Switch(
                              value: tempIsActive2,
                              onChanged: (bool value) {
                                setState(() {
                                  tempIsActive2 = value;
                                });
                              },
                              activeTrackColor: Colors.black54,
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.black45),
                        onPressed: () {
                          setState(() {
                            buttons.removeAt(index);
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          _saveDeviceStateToFirestore(
                              buttons[index],
                              tempIsActive1 ? true : false,
                              tempIsActive2 ? true : false
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text('저장', style: TextStyle(color: Colors.black54)),
                      ),
                    ],
                  ),
                ]
            );
          },
        );
      },
    ).then((_) {
      // 팝업이 닫힌 후에 기존 데이터를 다시 불러와서 스위치의 초기 상태를 설정
      setState(() {
        buttons[index].isActive1 = originalIsActive1;
        buttons[index].isActive2 = originalIsActive2;
      });
    });
  }





  void _saveDeviceStateToFirestore(ButtonData button, bool isActive1, bool isActive2) {
    // Firestore에 연결
    FirebaseFirestore.instance.collection('device').doc(button.name).set({
      'isActive1': isActive1 ? '1' : '0', // 활성화 스위치 상태 저장
      'isActive2': isActive2 ? '1' : '0', // 알림 스위치 상태 저장
    });
  }
}

class ButtonData {
  String name;
  bool isActive1;
  bool isActive2;

  ButtonData(this.name, this.isActive1, this.isActive2);
}
