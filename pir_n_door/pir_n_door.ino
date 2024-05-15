#include <Servo.h>

Servo myservo;

int LED = 2;                                     // LED 출력 2번핀
int sensor = 7;                                 // 센서 입력값 7번핀
int sensor2 = 12;
int door = 4;
int value = 0;       
int value2 = 0;                            // loop에서 사용할 value 변수 설정
int value3 = 0 ;

void setup() 
{
    Serial.begin(9600);
    myservo.attach(9); //아두이노의 디지털 9번핀을 서보모터 제어에 사용
    pinMode (LED, OUTPUT);          // 핀모드 LED 출력으로 설정
    pinMode (sensor, INPUT);          //  핀모드 센서 입력값으로 설정
    pinMode (door, INPUT); 
}

void loop() 
{
    value = digitalRead(door);        // 변수 value에 디지털 센서값 저장
    value2 = digitalRead(sensor);
    value3 = digitalRead(sensor2);

    if(value==LOW){
      Serial.println("문닫힘");
      digitalWrite(LED, LOW);             //  LED를 꺼라
      myservo.write(92); // 정지
    }
    else if(value == HIGH)                  // value가 high라면
    {
      Serial.println("문열림");
      if ((value3 == HIGH) && (value2 == HIGH)) {
        //Serial.println("낮다");
        Serial.println("둘 다 감지");
        digitalWrite(LED, LOW);
        myservo.write(0); // 정지
      }

      else if (value2 == HIGH)  {
        Serial.println("아동 감지");
        digitalWrite(LED, HIGH);            // LED를 켜라
        myservo.write(180); // 역방향으로 최고속도 회전
        //myservo.write(0);  // 정방향으로 최고속도 회전
        delay(500);
      }

      else {
        Serial.println("어른 감지");
        digitalWrite(LED, LOW);
        myservo.write(92); // 정지
      }
    }
    else                              // 그렇지 않다면
    {
      Serial.println("문닫힘일걸?");
      digitalWrite(LED, LOW);             //  LED를 꺼라
      myservo.write(92); // 정지
    }

}