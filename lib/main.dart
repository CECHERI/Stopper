import 'package:flutter/material.dart';

//main
void main() {
  runApp(
      MyApp(
        //리본 제거
        //debugShowCheckedModeBanner: false,
      ),
  );
}

//기본 껍데기
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar( ),
        body: Column(
          children: [
          // 이미지 추가
            Expanded(
              flex: 1, // 이미지가 차지하는 공간의 비율 조정
              child: Image.asset(
                'images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 2, // 아래의 버튼 리스트가 차지하는 공간의 비율 조정
              child: AddButtons(),
            ),
          ]
        ),
      ),
    );
  }
}

//기기 추가 버튼
class AddButtons extends StatefulWidget {
  @override
  _AddDevice createState() => _AddDevice();
}

//기기 추가 버튼 클릭 시 이미지 + 텍스트 추가
class _AddDevice extends State<AddButtons> {
  List<ButtonData> buttons = [];

  @override
  //기기 이미지 + 텍스트
  Widget build(BuildContext context) {
    return Scaffold(
    body: Column(
    children: [
    Expanded(
    child: ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50.0),  // 상하좌우 패딩 설정
      scrollDirection: Axis.horizontal,
      itemCount: buttons.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 30.0),  // 좌우 간격 설정
                //이미지
                child: InkWell(
                  onTap: () => _showEditDialog(index), //눌렀을 때 작은 창 띄우기
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
                      ),
                      ),
                    ],
                  ),
                ),
              );
              },
            ),
          ),
        ]
      ),
      //추가 버튼 상세 설정
      floatingActionButton: FloatingActionButton(
        onPressed: _addButton,
        child: Icon(Icons.add, color: Colors.black, size: 30),
        backgroundColor: Colors.transparent,  // 배경색을 투명하게 설정
        elevation: 0,  // 기본 그림자 제거
        highlightElevation: 0,  // 터치 시 그림자 제거
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  //버튼 초기값 : ON
  void _addButton() {
    setState(() {
      buttons.add(ButtonData('DEVICE${buttons.length + 1}', true, true));
    });
  }

  //기기 클릭시
  void _showEditDialog(int index) {
    TextEditingController nameController = TextEditingController(text: buttons[index].name);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentTextStyle: TextStyle(
              color: Colors.black54,  // AlertDialog 내용의 텍스트 색상
              fontSize: 17
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textAlign: TextAlign.center,  // 텍스트 필드의 텍스트를 가운데 정렬
                style: TextStyle(color: Colors.black54),  // 입력 텍스트 색상
                decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),  // 레이블 텍스트 색상
                    enabledBorder: OutlineInputBorder(  // 활성화된 텍스트 필드 테두리 색상
                      borderSide: BorderSide(color: Colors.transparent)
                    ),
                    focusedBorder: OutlineInputBorder(  // 포커스 받았을 때 테두리 색상
                      borderSide: BorderSide(color: Colors.transparent)
                    )
                ),
                onChanged: (text) {  // 사용자 입력이 바뀔 때마다 호출
                  setState(() {
                    buttons[index].name = text;  // 입력값으로 기기 이름 업데이트
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
                        value: buttons[index].isActive1,  // 첫 번째 스위치 상태
                        onChanged: (bool value) {
                          setState(() {
                            buttons[index].isActive1 = value;  // 첫 번째 스위치 상태 업데이트
                          });
                        },
                        activeTrackColor: Colors.black54,  // 스위치 트랙 색상 변경
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(' 알  림  '),
                      Switch(
                        value: buttons[index].isActive2,  // 두 번째 스위치 상태
                        onChanged: (bool value) {
                          setState(() {
                            buttons[index].isActive2 = value;  // 두 번째 스위치 상태 업데이트
                          });
                        },
                        activeTrackColor: Colors.black54,  // 스위치 트랙 색상 변경
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소', style: TextStyle(color: Colors.black54)),
            ),
            TextButton(
              onPressed: () {
                showApplyToAllDevicesDialog(index, nameController.text);
              },
              child: Text('저장', style: TextStyle(color: Colors.black54)),
            ),
          ],
        );
      },
    );
  }

  // '모든 기기에 적용 하시겠습니까?' 대화상자
  void showApplyToAllDevicesDialog(int index, String newName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('모든 기기에 적용하겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                // 변경사항을 현재 기기에만 적용
                setState(() {
                  buttons[index].name = nameController.text;
                  Navigator.of(context).pop();
                });

                setState(() {
                  buttons[index].name = newName.;
                });
                //Navigator.of(context).pop();  // 현재 대화상자 닫기
                //Navigator.of(context).pop();  // 편집 대화상자 닫기
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                // 변경사항을 모든 기기에 적용
                setState(() {
                  for (var button in buttons) {
                    button.name = newName;
                  }
                });
                //Navigator.of(context).pop();  // 현재 대화상자 닫기
                //Navigator.of(context).pop();  // 편집 대화상자 닫기
              },
            ),
          ],
        );
      },
    );
  }

}

class ButtonData {
  String name;
  bool isActive1;
  bool isActive2;

  ButtonData(this.name, this.isActive1, this.isActive2);
}
