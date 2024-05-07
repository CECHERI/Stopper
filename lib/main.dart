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
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50.0),
              scrollDirection: Axis.horizontal,
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                return _buildButton(index);
              },
            ),
          ),
        ],
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

  @override
  Widget _buildButton(int index) {
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
            Text(
              buttons[index].dvName, // dvName을 표시
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
      // Provide dvName as 'DEVICE${buttons.length + 1}'
    });
  }

  void _showEditDialog(int index) {
    TextEditingController nameController = TextEditingController(text: buttons[index].dvName); // dvName 사용
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
                        buttons[index].dvName = text; // dvName을 변경한 값으로 설정
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
                        Navigator.of(context).pop();
                      },
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        _saveDeviceStateToFirestore(
                          buttons[index],
                          tempIsActive1 ? true : false,
                          tempIsActive2 ? true : false,
                        );
                        Navigator.of(context).pop();
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
    ).then((_) {
      // 팝업이 닫힌 후에 기존 데이터를 다시 불러와서 스위치의 초기 상태를 설정
      setState(() {
        // 데이터베이스에서 가져온 값에 따라 스위치의 초기 상태 설정
        buttons[index].isActive1 = tempIsActive1;
        buttons[index].isActive2 = tempIsActive2;
      });
    }).then((_) async {
      // Firestore에서 isActive1, isActive2 값 가져오기
      DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('device').doc(buttons[index].dvName).get(); // dvName 사용
      if (snapshot.exists) {
        // 데이터베이스에서 isActive1, isActive2 값 가져오기
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?; // 캐스팅
        if (data != null) {
          // null 체크
          String? isActive1DB = data['isActive1'] as String?; // 캐스팅
          String? isActive2DB = data['isActive2'] as String?; // 캐스팅
          if (isActive1DB != null && isActive2DB != null) {
            // null 체크
            setState(() {
              // isActive1, isActive2 값에 따라 스위치의 초기 상태 설정
              buttons[index].isActive1 = isActive1DB == '1'; // '1'이면 true, 그 외에는 false로 설정
              buttons[index].isActive2 = isActive2DB == '1'; // '1'이면 true, 그 외에는 false로 설정
            });
          }
        }
      }
    });
  }
  void _deleteDeviceFromFirestore(ButtonData button) {
    // Firestore에서 해당 문서 삭제
    FirebaseFirestore.instance.collection('device').doc(button.name).delete();
  }
  void _saveDeviceStateToFirestore(ButtonData button, bool isActive1, bool isActive2) {
    // Firestore에 연결
    FirebaseFirestore.instance.collection('device').doc(button.name).set({
      'name': button.name,
      'isActive1': isActive1 ? '1' : '0', // 활성화 스위치 상태 저장
      'isActive2': isActive2 ? '1' : '0', // 알림 스위치 상태 저장
      'dvName': button.dvName,
    });
  }
}

class ButtonData {
  String name;
  String dvName; // 디바이스 이름을 저장할 필드 추가
  bool isActive1;
  bool isActive2;

  ButtonData(this.name, this.isActive1, this.isActive2, {required this.dvName}); // 초기화 시 디바이스 이름과 동일하게 설정
}