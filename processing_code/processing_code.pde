/*
Image is reversed:  LEFT -> RIGHT
                    RIGHT -> LEFT
                    
                    123 -> { -> start
                    125 -> } -> stop
*/
import processing.serial.*;
import SimpleOpenNI.*;

boolean bot_mirror = false;

Serial myPort;
SimpleOpenNI  Kinect;

color[]       userClr = new color[]{ color(255,0,0),  // predefined color array 
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                   };
                                   
                                   
PVector com = new PVector();                                   
PVector com2d = new PVector();    


  // LEFT HAND 
   PVector LHand = new PVector();
   PVector LElbow = new PVector();
   PVector LShoulder = new PVector();
   PVector LHip = new PVector();   
  // RIGHT HAND 
   PVector RHand = new PVector();
   PVector RElbow = new PVector();
   PVector RShoulder = new PVector();
   PVector RHip= new PVector();

//Projective Vectors 
  // LEFT HAND 
   PVector lHand = new PVector();
   PVector lElbow = new PVector();
   PVector lShoulder = new PVector();
   PVector lHip = new PVector();   
  // RIGHT HAND 
   PVector rHand = new PVector();
   PVector rElbow = new PVector();
   PVector rShoulder = new PVector();
   PVector rHip= new PVector();


//variables for serial transmission to arduino
char skelData[] = new char[3];
int[] angles = new int[6];
float[] map_angles = new float[6];
String datain=new String();

int spoint[]=new int[11];
void setup()
{
  size ( 1280,480);
  ////The number of times draw() executes in each second is controlled by frameRate function 
  frameRate(200); 
  
  
  String portName = Serial.list()[1];
  println(Serial.list());
  myPort = new Serial(this, "COM17", 9600);
  //myPort.bufferUntil('\n');
  // enablinng and checking the kinect 
  Kinect = new SimpleOpenNI(this);
  if(Kinect.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  Kinect.enableDepth();
  Kinect.enableUser();
  Kinect.setMirror(true);
 
  background(200,0,0);
  stroke(0,0,255);
  strokeWeight(3);
  smooth();
}
int m = millis();
int lasttime=0;
// Function that loops untill the program is closed 
void draw() 
{
  Kinect.update(); 
  image(Kinect.depthImage(),0,0);
  
  
  //draw lines for human to align with
  strokeWeight(5);
  stroke(0, 255, 255);
  line(320, 0, 320, 480);
  line(0, 140, 640, 140);
  line(85, 0, 85, 480);
  line(555, 0, 555, 480);
  
  int[] userList = Kinect.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(Kinect.isTrackingSkeleton(userList[0]))
    {
      
    getUserData(userList[0]);
    makevector(1);
    updateAngles();
    mapangles();
    
   m=millis();
   if(m>(lasttime+500))
   {
     senddata();
   lasttime=m;
 }
   
   stroke(255,0,0);  // stroke(userClr[ (userList[i] - 1) % userClr.length ] );
   strokeWeight(3); 
   drawSkeleton(userList[0]);
    }
    
    // draw the center of mass
    if(Kinect.getCoM(userList[0],com))   // gets center of mass of the body 
    {
      Kinect.convertRealWorldToProjective(com,com2d);
      stroke(100,255,0);
      strokeWeight(2);
      /// Starting of drawing lines 
      beginShape(LINES);
        vertex(com2d.x,com2d.y - 300);
        vertex(com2d.x,com2d.y + 300);

        vertex(com2d.x - 300,com2d.y);
        vertex(com2d.x + 300,com2d.y);
      endShape();
      //Ending of drawing lines 
      
      fill(0,255,100);  // RGB
  
      text(Integer.toString(userList[0]),com2d.x,com2d.y); //  text(c, x, y)
      text( "   USER " , com2d.x,com2d.y);
  }
  }
}


/// Function for drawing skeleton 

void  drawSkeleton(int userId) 
  {
  stroke(0);
 strokeWeight(5);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_HIP);
  Kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_HIP);
 
 noStroke();
 fill(255,0,0);
 drawJoint(userId, SimpleOpenNI.SKEL_HEAD); 
 drawJoint(userId, SimpleOpenNI.SKEL_NECK);
 drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
 drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
 drawJoint(userId, SimpleOpenNI.SKEL_NECK);
 drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
 drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
 drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
 drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
 drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
 drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
 drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
 drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
 drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
 drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
 drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
 drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
}
  
 void drawJoint(int userId, int jointID) { 
 PVector joint = new PVector();
 
 float confidence = Kinect.getJointPositionSkeleton(userId, jointID,joint);
 if(confidence < 0.5){
 return; 
 }
  PVector convertedJoint = new PVector();
 Kinect.convertRealWorldToProjective(joint, convertedJoint);
 ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
 int dataP[] = { int(convertedJoint.x) , int(convertedJoint.y) };
 text(Integer.toString(dataP[0]),convertedJoint.x+5 , convertedJoint.y-20 );
 text(Integer.toString(dataP[1]),convertedJoint.x+5 , convertedJoint.y );
 
 //  text(c, x, y)
 text("++",0, 0 );
 }
 
///// Drawing skeleton function ends here   

//USER DATA FUNCTION 

void makevector(int userId)
{
  
  
  //REAL WORLD VECTORS 
  Kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,LHand);
  Kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,RHand);
  
  Kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,LElbow);
  Kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,RElbow);

  Kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,LShoulder);
  Kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,RShoulder);
  
  Kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP,RHip);
  Kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HIP,LHip);
 
  //PROJECTIVE VECTORS 
  Kinect.convertRealWorldToProjective(LHand, lHand);
  Kinect.convertRealWorldToProjective(RHand, rHand);
  
 Kinect.convertRealWorldToProjective(LElbow, lElbow);
  Kinect.convertRealWorldToProjective(RElbow, rElbow);

  Kinect.convertRealWorldToProjective(LShoulder, lShoulder);
  Kinect.convertRealWorldToProjective(RShoulder, rShoulder);
  
  Kinect.convertRealWorldToProjective(LHip, lHip);
  Kinect.convertRealWorldToProjective(RHip, rHip);
}

// Function updating the angle 

void updateAngles()
{
  
  angles[0]= angle(lShoulder,lElbow, lHand);
  angles[1]= angle(lElbow, lShoulder, lHip);
  angles[4]=angle(rHip, rShoulder, rElbow);
  angles[5]=angle( rHand, rElbow,rShoulder);
  angles[2]=sangle( lHip, lShoulder,lElbow);
  angles[3]=sangle( rHip,rShoulder,rElbow);
  
  
}

void getUserData(int userId)
{ 
  PVector jointPos = new PVector();
  
 
  

     
  
  //start trassmit data to arduino
  
 
  spoint[0]=int(LHand.x/10);
  spoint[1]=int(LHand.y/10);
  
  
  spoint[2]=int(RHand.x/10);
  spoint[3]=int(RHand.y/10);
textSize(20);
background(51);

  text("LEFT HAND",700 ,50);
  text(spoint[0],850,50);
  text(spoint[1],900,50);
  
 text("RIGHT HAND",700 ,100);
  text(spoint[2],850,100);
  text(spoint[3],900,100);
  
   text("ANGLES",700 ,150);
   text("LE "+angles[0]+"  LS  "+angles[1]+" RS "+angles[4]+" RE " +angles[5],700,200);
 
   text("ANGLES",700 ,250);
    
   text("LSO  " +angles[2]+"  RSO  "+angles[3],700,300);
   text("SERIAL " +datain,700,400);
  }

// Function for measuring angle 
int angle(PVector a, PVector b, PVector c)
{
float angle01 = atan2(a.y - b.y, a.x - b.x);
float angle02 = atan2(b.y - c.y, b.x - c.x);
int ang = int(degrees(angle02 - angle01)); // coverting radians to angle

if(ang<0)
ang=ang+360;

if(ang>300)
ang=0;

return ang;
}

int sangle(PVector a, PVector b, PVector c)
{
float angle01 = atan2(a.y - b.y, a.z - b.z);
float angle02 = atan2(b.y - c.y, b.z - c.z);
int ang = int(degrees(angle02 - angle01)-180); // coverting radians to angle

if(ang<0)
ang=ang+450;

if(ang>300)
ang=0;


return ang;
}

/// FUnction Ends here 

void mapangles()
{
  if(bot_mirror==true)
  {
  map_angles[0]=map(angles[0],100,0,0,900);
  map_angles[1]=map(angles[1],0,160,0,900);
  //SHOULDER ORIENTATION 
  map_angles[2]=map(angles[2],60,250,0,900);
  
  map_angles[3]=map(angles[3],250,70,0,900);
  
  
  map_angles[4]=map(angles[4],160,0,0,900);
  map_angles[5]=map(angles[5],0,100,0,900);
  
  }
  
if(bot_mirror==false)
  {
  map_angles[0]=map(angles[5],100,0,0,900);
  map_angles[1]=map(angles[4],0,160,0,900);
  //SHOULDER ORIENTATION 
  map_angles[2]=map(angles[3],60,250,0,900);
  
  map_angles[3]=map(angles[2],250,70,0,900);
  
  
  map_angles[4]=map(angles[1],160,0,0,900);
  map_angles[5]=map(angles[0],0,100,0,900);
  
  }
  
map_angles[0]=constrain(map_angles[0],0,900);
map_angles[1]=constrain(map_angles[1],0,900);
map_angles[2]=constrain(map_angles[2],0,900);
map_angles[3]=constrain(map_angles[3],0,900);
map_angles[4]=constrain(map_angles[4],0,900);
map_angles[5]=constrain(map_angles[5],0,900);


}

//SENDING DATA OVER SERIAL PORT 
void senddata()
{
 myPort.write('B'); // begin arduino communication
 
 for(int i=0 ;i<6;i++)
 {
   int data_t=int(map_angles[i])/10;
   int data_h=data_t/10;
   data_t=data_t%10;
 
      myPort.write('0');
      myPort.write(str(data_h));
      myPort.write(str(data_t));
    }

  myPort.write('E');
 //delay(500);// ends arduino communication 
}

////DONT TOUCH BELOW 
void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}
