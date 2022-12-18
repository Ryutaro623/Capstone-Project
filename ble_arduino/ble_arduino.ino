#include <SoftwareSerial.h>
SoftwareSerial ble(0,1);
void setup() {
  Serial.begin(9600);
  ble.begin(9600);
  // put your setup code here, to run once:

}

void loop() {
  while(ble.available()){
    int ble_char = (int)ble.read();
    Serial.println(ble_char);
  }
  // put your main code here, to run repeatedly:

}
