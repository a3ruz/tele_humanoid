#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

#define SERVOMIN  150// this is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX   490// this is the 'maximum' pulse length count (out of 4096)
/*
Image is reversed:  LEFT -> RIGHT
                    RIGHT -> LEFT
 data[0]  ->  LEFT ELBOW
 data[1]  ->  LEFT SHOULDER    
 data[2]  ->  RIGHT SHOULDER  
 data[3]  ->  RIGHT ELBOW
 data[4]  ->  LEFT SHOULDER ANGLE   
 data[5]  ->  RIGHT SHOULDER ANGLE
  212 -> { -> start
 222-> } -> stop

         NAME            SERVO NO      MIN          MAX            NEUTRAL    CALIBRATION MIN     CALIBRATION MAX  miimum for close , max for open 
         ________________________________________________________________________________________________________
     
         LHAND              0          080           020              115           016               000
         LSHOULDER          1          150           000              118           016               000
         LSHOULDER PITCH    4          178           030              080           030               004
         
         RHAND              3          160           090              115           016               000
         RSHOULDER          2          010           090              118           016               000
         RSHOULDER PITCH    5          180           000              080           025               010         
       
*///use smallletters for servo calibrted values,Block Letters for realtime data 
//------SERVO A
#define servoamin 3
#define servoamax 60
#define SERVOAMIN 0 
#define SERVOAMAX 90

//------SERVO B

#define servobmin 1
#define servobmax 175
#define SERVOBMIN 0
#define SERVOBMAX 90

//------SERVO C

#define servocmin 1 
#define servocmax 180 
#define SERVOCMIN 0
#define SERVOCMAX 90

//------SERVO D

#define servodmin 3
#define servodmax 180
#define SERVODMIN 0
#define SERVODMAX 90

//------SERVO E

#define servoemin 3
#define servoemax 180
#define SERVOEMIN 0
#define SERVOEMAX 90

//------SERVO F

#define servofmin 95
#define servofmax 165
#define SERVOFMIN 0
#define SERVOFMAX 90

int pulselen;

String inputString = "";
boolean stringComplete = false;
boolean sendData = false;

int SERVO[6];
void setup() {
    Serial.begin(9600);
   // Serial.print('3');
  Serial.println("PROGRAM INITIATED*");
  pwm.begin();
  pwm.setPWMFreq(50);  // Analog servos run at ~60 Hz updates
  delay(10);
      //          limit();



stringComplete = true;
inputString="090090000090000000";
}
int pos (int x)
{
  int k;
  k=map(x,0,180 ,SERVOMIN, SERVOMAX);
  return k;
  
}


void loop() {
  

     if (stringComplete) {
    //put data into data array
    int stringLength = inputString.length() / 3;
    String data[ stringLength ];

    for (int i = 0; i < stringLength; i++) {
      data[i] = inputString.substring( i * 3, (i * 3) + 3 );
      Serial.print(data[i]);
      Serial.print("    ");
    }
    Serial.println();

    SERVO[0]=( map(data[0].toInt(), SERVOAMIN,SERVOAMAX, servoamin ,servoamax) );
    SERVO[1]=( map(data[1].toInt(), SERVOBMIN,SERVOBMAX, servobmin ,servobmax) );
    SERVO[2]=( map(data[2].toInt(), SERVOCMIN,SERVOCMAX, servocmin ,servocmax) );
    SERVO[3]=( map(data[3].toInt(), SERVODMIN,SERVODMAX, servodmin ,servodmax) );
    SERVO[4]=( map(data[4].toInt(), SERVOEMIN,SERVOEMAX, servoemin ,servoemax) );
    SERVO[5]=( map(data[5].toInt(), SERVOFMIN,SERVOFMAX, servofmin ,servofmax) );
//limit();
 servoupdate();
    //prepare to take in new data
   
    stringComplete = false;
  }

}
/*void limit()
{
SERVO[0]= constrain(SERVO[0], servoamin, servoamax);
SERVO[1]= constrain(SERVO[1], servobmin, servobmax);
SERVO[2]= constrain(SERVO[2], servocmin, servocmax);
SERVO[3]= constrain(SERVO[3], servodmin, servodmax);
SERVO[4]= constrain(SERVO[4], servoemin, servoemax);
SERVO[5]= constrain(SERVO[5], servofmin, servofmax);
  
}*/

void servoupdate()
{
  
  for(int i=0 ;i<6;i++)
  pwm.setPWM(i,0,pos(SERVO[i]));
}
void serialEvent() {
  Serial.println("Serial event called ");
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
       inputString = "";
      sendData = true;
    
     }
  }
  
}
