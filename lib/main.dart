import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stopper/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'style.dart';

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
            // 로고
            Expanded(
              flex: 1,
              child: Image.asset(
                'images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
            // 기기 추가 버튼
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
  void initState() {
    super.initState();
    _fetchButtonsFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
                scrollDirection: Axis.horizontal,
                itemCount: buttons.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: InkWell(
                      onTap: () => _showEditDialog(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 150,
                            width: 150,
                            child: Image.asset(
                                'images/devices.png', fit: BoxFit.cover),
                          ),
                          Text(buttons[index].dvName, style: AppStyles.subTextStyle,)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ]
      ),

      // 기기 추가 버튼
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

  void _fetchButtonsFromFirestore() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('device').get();
    setState(() {
      buttons = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ButtonData(
          data['name'],
          data['isActive1'] == '1',
          data['isActive2'] == '1',
          dvName: data['dvName'], // Include dvName in the data retrieval
        );
      }).toList();
    });
  }

  void _addButton() {
    setState(() {
      buttons.add(ButtonData('DEVICE${buttons.length + 1}', true, true, dvName: 'DEVICE${buttons.length + 1}'));
    });
    setState(() {});
  }

  void _showEditDialog(int index) {
    TextEditingController nameController = TextEditingController(text: buttons[index].dvName); // dvName 사용
    bool tempIsActive1 = buttons[index].isActive1;
    bool tempIsActive2 = buttons[index].isActive2;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              contentTextStyle: TextStyle(
                color: Colors.black54,
                fontSize: 17,
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
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {
                        buttons[index].dvName = text;
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
                  ),
                ],
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.black45),
                      onPressed: () {
                        _deleteDeviceFromFirestore(buttons[index]);
                        setState(() {
                          buttons.removeAt(index);
                        });
                        //await _fetchButtonsFromFirestore();  // Firestore 데이터를 다시 불러옴
                        Navigator.of(context).pop();
                      },
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        showApplyToAllDevicesDialog(index, tempIsActive1, tempIsActive2);
                      },
                      child: Text('저장', style: TextStyle(color: Colors.black54)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    ).then((_) async {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('device').doc(buttons[index].dvName).get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          String? isActive1DB = data['isActive1'] as String?;
          String? isActive2DB = data['isActive2'] as String?;
          if (isActive1DB != null && isActive2DB != null) {
            setState(() {
              buttons[index].isActive1 = isActive1DB == '1';
              buttons[index].isActive2 = isActive2DB == '1';
            });
          }
        }
      }
    });
  }

  void showApplyToAllDevicesDialog(int index, bool newIsActive1, bool newIsActive2) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
          content: Text('모든 기기에 적용하겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                setState(() {
                  buttons[index].isActive1 = newIsActive1;
                  buttons[index].isActive2 = newIsActive2;
                });
                _saveDeviceStateToFirestore(buttons[index], newIsActive1, newIsActive2);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                setState(() {
                  for (var button in buttons) {
                    button.isActive1 = newIsActive1;
                    button.isActive2 = newIsActive2;
                  }
                });
                _saveDeviceStateToFirestoreForAll(newIsActive1, newIsActive2);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteDeviceFromFirestore(ButtonData button) {
    FirebaseFirestore.instance.collection('device').doc(button.dvName).delete();
    setState(() {});
  }

  void _saveDeviceStateToFirestore(ButtonData button, bool isActive1, bool isActive2) {
    FirebaseFirestore.instance.collection('device').doc(button.dvName).set({
      'name': button.name,
      'isActive1': isActive1 ? '1' : '0',
      'isActive2': isActive2 ? '1' : '0',
      'dvName': button.dvName,
    });
  }

  void _saveDeviceStateToFirestoreForAll(bool isActive1, bool isActive2) {
    for (var button in buttons) {
      _saveDeviceStateToFirestore(button, isActive1, isActive2);
    }
  }
}

class ButtonData {
  String name;
  String dvName;
  bool isActive1;
  bool isActive2;

  ButtonData(this.name, this.isActive1, this.isActive2, {required this.dvName});
}
