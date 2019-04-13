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

         NAME            SERVO NO      MIN          MAX            NEUTRAL    CALIBRATION MIN     CALIBRATION MAX
         ________________________________________________________________________________________________________
     
         LHAND              0          080           150              115           0                 180
         LSHOULDER          1          073           163              118           0                 180
         LSHOULDER PITCH    4          000           159              080           0                 180
         
         RHAND              3          150           080              115           0                 180
         RSHOULDER          2          163           070              118           0                 180
         RSHOULDER PITCH    5          159           000              080           0                 180
         
       
*/
//------SERVO A
#define servoamin 20
#define servoamax 35
#define SERVOAMIN 5  
#define SERVOAMAX 180

//------SERVO B

#define servobmin 20
#define servobmax 35
#define SERVOBMIN 5 
#define SERVOBMAX 180

//------SERVO C

#define servocmin 20 
#define servocmax 35 
#define SERVOCMIN 5 
#define SERVOCMAX 180

//------SERVO D

#define servodmin 20 
#define servodmax 35 
#define SERVODMIN 5  
#define SERVODMAX 180

//------SERVO E

#define servoemin 20
#define servoemax 35 
#define SERVOEMIN 5 
#define SERVOEMAX 180

//------SERVO F

#define servofmin 20
#define servofmax 35 
#define SERVOFMIN 5 
#define SERVOFMAX 180

int pulselen;

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
int SERVO[6];
void loop() {
  
 /* TEST PROGRAM ######################################  
pwm.setPWM(0,0,pos(90));  
pwm.setPWM(1,0,pos(90));
  pwm.setPWM(2,0,pos(180));
 pwm.setPWM(3,0,pos(90));
  pwm.setPWM(4,0,pos(90));
   pwm.setPWM(5,0,pos(90));
 delay (500);

pwm.setPWM(0,0,pos(0));
 pwm.setPWM(1,0,pos(0));
   pwm.setPWM(2,0,pos(90));
  pwm.setPWM(3,0,pos(0));
  pwm.setPWM(4,0,pos(0));
   pwm.setPWM(5,0,pos(180));
 delay(500);
 // pwm.setPWM(1,0,pos(90));
 //  pwm.setPWM(2,0,pos(90));
  //  pwm.setPWM(3,0,pos(90));
   //  pwm.setPWM(4,0,pos(90));
    //  pwm.setPWM(5,0,pos(90));
      ####################################################### */
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

    SERVO[0]=( map(data[0].toInt(), servoamin ,servoamax, SERVOAMAX,SERVOAMIN) );
    SERVO[1]=( map(data[1].toInt(), servobmin ,servobmax, SERVOBMAX,SERVOBMIN) );
    SERVO[2]=( map(data[2].toInt(), servocmin ,servocmax, SERVOCMAX,SERVOCMIN) );
    SERVO[3]=( map(data[3].toInt(), servodmin ,servodmax, SERVODMAX,SERVODMIN) );
    SERVO[4]=( map(data[4].toInt(), servoemin ,servoemax, SERVOEMAX,SERVOEMIN) );
    SERVO[5]=( map(data[5].toInt(), servofmin ,servofmax, SERVOFMAX,SERVOFMIN) );

 servoupdate();
    //prepare to take in new data
    inputString = "";
    stringComplete = false;
  }

}

void servoupdate()
{
  for(int i=0 ;i<6;i++)
  pwm.setPWM(i,0,pos(SERVO[i]));
}
void serialEvent() {
  while (Serial.available()) {
    int inChar = Serial.read();

    if (inChar == 212) {
      sendData = false;
      stringComplete = true;
    }
    if (sendData)
      inputString += inChar;
    if (inChar == 222)
      sendData = true;
  }
}
