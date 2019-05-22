#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

#define SERVOMIN  150// this is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX   490// this is the 'maximum' pulse length count (out of 4096)

int pulselen;
int val;
String inputString = "";
boolean stringComplete = false;
boolean sendData = false;

void setup() {
    Serial.begin(9600);
  Serial.println("PROGRAM INITIATED");
  pwm.begin();
  pwm.setPWMFreq(50);  // Analog servos run at ~60 Hz updates
  delay(10);

}
int pos (int x)
{
  int k;
  k=map(x,5,175 ,SERVOMIN, SERVOMAX);
  return k;
  }
    

  void loop() {
 pwm.setPWM(0,0,pos(inputString.toInt()));
 Serial.println(inputString);
 delay(100); // Wait 100 milliseconds for next reading
 }


void serialEvent() {
  Serial.println("Serial event called ");
  inputString="";
  while (Serial.available()) {
    char inChar = Serial.read();
//Serial.println(inChar);
    if (inChar =='E') {
      
      sendData = false;
      stringComplete = true;
     Serial.println(inputString);
    }
    if (sendData)
    {
      inputString += inChar;
    Serial.println(inputString);
    }
    if (inChar == 'B')
     {
      sendData = true;
    
     }
  }
  
}
