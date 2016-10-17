import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class parkingsimulator extends PApplet {



Serial port;

float ang = 53;      //constant angle, made from arctan(long side/small side)
String val;       //input from potentiometer
int deg;

Ball mobil, dest;

class Ball {
  float x,y; //posisi pusat mobil
  float or;  //orientasi saat ini
  int cr,cg,cb; //warna yang akan diberi
  float d = 50;
  float cx[] = new float[4];
  float cy[] = new float[4];
  
  Ball(float xin, float yin, float orin, int type) {
    x = xin;
    y = yin;
    or = orin;
    if (type == 0) { cr = 100; cg = 100; cb = 255; } // Type 0 = car, blue color
      else         { cr = 150; cg = 150; cb = 150; } // Type 1 = destination, grey color
    if (type == 0) { d = 50; } 
      else         { d = 70; }
    calcFourCorner();  
  }
  
  public void calcFourCorner() {
    // Function below calculated from trigonometri
    // 0 is the left front of the car, 1 is the right front of the car
    // 2 is the right back of the car, 3 is the left back of the car,
    
    cx[0] = x+cos(radians(    ang+or))*d; cy[0] = y-sin(radians(    ang+or))*d;
    cx[1] = x+cos(radians(180-ang+or))*d; cy[1] = y-sin(radians(180-ang+or))*d;
    cx[2] = x+cos(radians(180+ang+or))*d; cy[2] = y-sin(radians(180+ang+or))*d;
    cx[3] = x+cos(radians(360-ang+or))*d; cy[3] = y-sin(radians(360-ang+or))*d;
  }
  
  public void display() {
    fill(cr, cg, cb);
    calcFourCorner();
    
    quad (cx[0], cy[0], cx[1], cy[1], cx[2], cy[2], cx[3], cy[3]);
  }
  
  public void move(int dir) {
    // These function derived from trigonometri
    x += cos(radians(90+or+deg))*dir;
    y -= sin(radians(90+or+deg))*dir;
    
    or = or + deg / 2;
    calcFourCorner();
  }
}

public void makeDest() {
  //new destination was made with margin 75px
  dest = new Ball(random(width-150)+75, random(height-150)+75, random(180), 1);
}

public void setup() {
  port = new Serial(this, Serial.list()[1], 250000);
  
  
  mobil = new Ball(width/2, height/2, 0, 0);
  makeDest();
}

public boolean checkCar() {
  boolean inRect = true;
  
  for (int i = 0; i < 4; i++) {
    float dx, dy; //calculate the differences between x and y
    
    //conditional below derived from gradient function,
    //checking whether a point is inside 4 corner of dest or not
    
    //checking the longer side
    dx = dest.cx[0] - dest.cx[3];
    dy = dest.cy[0] - dest.cy[3];
    
    if (dest.cy[0] * dx - dest.cx[0] * dy <= mobil.cy[i] * dx - mobil.cx[i] * dy) inRect = false;
    if (dest.cy[1] * dx - dest.cx[1] * dy >= mobil.cy[i] * dx - mobil.cx[i] * dy) inRect = false;
    
    //checking the smaller side
    dx = dest.cx[0] - dest.cx[1];
    dy = dest.cy[0] - dest.cy[1];
    
    if (dest.cy[0] * dx - dest.cx[0] * dy >= mobil.cy[i] * dx - mobil.cx[i] * dy) inRect = false;
    if (dest.cy[2] * dx - dest.cx[2] * dy <= mobil.cy[i] * dx - mobil.cx[i] * dy) inRect = false;
  }
  if (inRect) return true;
    else return false;
}

public void draw() {
  background(15);                       //overwrite all board
  dest.display();                       //show the destination first, so car will be on top of destination
  mobil.display();                      //show the car
  
  val = "512";                          //when something went wrong, we make the car go forward
  
  if(port.available() > 0) {
    val = port.readStringUntil('\n');
    if(val != null) val = trim(val);    //remove non numeric from val        
  }
  deg = Integer.parseInt(val) * -40 / 1023 + 20;  //limit the turn into max of 20 degrees.
}

public void keyPressed() {
  // Converting pressedKey into index, no matter what the case 
  int keyIndex = -1;
  if (key >= 'A' && key <= 'Z') {
    keyIndex = key - 'A';
  } else if (key >= 'a' && key <= 'z') {
    keyIndex = key - 'a';
  }
  
  if (keyIndex == 22) mobil.move(2);   //when pressed W, car moving forward
  if (keyIndex == 18) mobil.move(-2);  //when pressed S, car moving backward
  
  //cheating, press A and D to rotate, used for debug only
  //if (keyIndex == 0) mobil.or++;     //when pressed A, car rotate to the left
  //if (keyIndex == 3) mobil.or--;     //when pressed D, car rotate to the right
  
  if (checkCar()) {
    //if car has been already inside destination, make new destinantion
    makeDest(); 
  }
}

/* ARDUINO was set by Arduino Program, using
   "AnalogSerialInput" example, with a little change:

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 250000 bits per second:
  Serial.begin(250000);
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  int sensorValue = analogRead(A0);
  // print out the value you read:
  Serial.println(sensorValue);
  delay(50);        // delay in between reads for stability
}

*/
  public void settings() {  size(640,720); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "parkingsimulator" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
