#include <SoftwareSerial.h>
SoftwareSerial ble(0,1);
int ble_command;
//RIGHTmotor
int enB = 3;
int in3 = 5;
int in4 = 4;
//LEFTmotor
int enA = 6;
int in1 = 8;
int in2 = 7;

void setup() {
  Serial.begin(9600);
  ble.begin(9600);
  ble_command = 0;
  pinMode(enA, OUTPUT);
  pinMode(enB, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);

  //Turn Off motors
  digitalWrite(in1, LOW);
  digitalWrite(in2, LOW);
  digitalWrite(in3, LOW);
  digitalWrite(in4, LOW);
  
  // put your setup code here, to run once:

}

void loop() {
  if(ble.available()>0){
    //get values from iphone
     ble_command = ble.read();
    Serial.println(ble_command);
  }
  if(ble_command == 0){
    digitalWrite(in1, LOW);
    digitalWrite(in2, LOW);
    digitalWrite(in3, LOW);
    digitalWrite(in4, LOW);
    
  } else if(ble_command == 1){
      analogWrite(enA, 255);
      analogWrite(enB, 255);

     // Forward
      digitalWrite(in1, HIGH);
      digitalWrite(in2, LOW);
      digitalWrite(in3, HIGH);
      digitalWrite(in4, LOW);
  } else if(ble_command == 2){
      analogWrite(enA, 255);
      analogWrite(enB, 255);

     // RIGHT
      digitalWrite(in1, HIGH);
      digitalWrite(in2, LOW);
      digitalWrite(in3, LOW);
      digitalWrite(in4, HIGH);
  } else if(ble_command == 3){
      analogWrite(enA, 255);
      analogWrite(enB, 255);

     // BACK
      digitalWrite(in1, LOW);
      digitalWrite(in2, HIGH);
      digitalWrite(in3, LOW);
      digitalWrite(in4, HIGH);
  } else if(ble_command == 4){
      analogWrite(enA, 255);
      analogWrite(enB, 255);

     // LEFT
      digitalWrite(in1, LOW);
      digitalWrite(in2, HIGH);
      digitalWrite(in3, HIGH);
      digitalWrite(in4, LOW);
  } else {
    //Turn Off motors
    digitalWrite(in1, LOW);
    digitalWrite(in2, LOW);
    digitalWrite(in3, LOW);
    digitalWrite(in4, LOW);
  }
  

}
