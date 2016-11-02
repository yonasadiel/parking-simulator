import processing.serial.*;
import java.util.Properties;

Serial port;

float ang = 63.435;      //constant angle, made from arctan(long side/small side)
String val;       //input from potentiometer
int deg;
float acc,velo;
PImage img_bg, img_car;

Car mobil, dest;

void makeDest() {
  //new destination was made with margin 75px
  dest = new Car(random(width-300)+150, random(height-300)+150, random(180), 1);
}

void setup() {
  //Setting up proxy settings for college  
  /*
  Properties systemSettings = System.getProperties();

  systemSettings.put("http.proxyHost", "cache.itb.ac.id");
  systemSettings.put("http.proxyPort", "8080");
  systemSettings.put("http.proxyUser", "ya");
  systemSettings.put("http.proxyPassword", "underscoreitb");
  System.setProperties(systemSettings);
  */
  
  //port = new Serial(this, Serial.list()[1], 250000);
  
  size(720,640);
  mobil = new Car(width/2, height/2, 0, 0);
  makeDest();
  
  frameRate(60);
  
  acc = 0;
  
  img_bg = loadImage("bg.png");
  img_car = loadImage("car.png");
}

boolean checkCar() {
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

void draw() {
  image(img_bg,0,0);                       //overwrite all board
  dest.display();                       //show the destination first, so car will be on top of destination
  
  velo += acc;
  velo = velo * 4 / 5;
  if (velo > 0) velo = max(0,min( 5, velo));
  if (velo < 0) velo = min(0,max(-5, velo));
  
  mobil.move(velo);
  println(acc,' ',velo);
  mobil.display();                      //show the car
  
  if (checkCar()) {
    //if car has been already inside destination, make new destinantion
    makeDest(); 
  }
  
  val = "512";                          //when something went wrong, we make the car go forward
  
  /*if(port.available() > 0) {
    val = port.readStringUntil('\n');
    if(val != null) val = trim(val);    //remove non numeric from val
      else val = "512";
  }*/
  //deg = Integer.parseInt(val) * -40 / 1023 + 20;  //limit the turn into max of 20 degrees.
  //println(deg);
}

void keyPressed() {
  
  if (key == 'W' || key == 'w') acc =  0.5;  //when pressed W, car moving forward
  if (key == 'S' || key == 's') acc = -0.5;  //when pressed S, car moving backward
  
  //cheating, press A and D to rotate, used for debug only
  if (key == 'A' || key == 'a') deg = 10;     //when pressed A, car rotate to the left
  if (key == 'D' || key == 'd') deg = -10;     //when pressed D, car rotate to the right
  
}

void keyReleased() {
  
  if (key == 'W' || key == 'w') acc = 0;  //when pressed W, car moving forward
  if (key == 'S' || key == 's') acc = 0;  //when pressed S, car moving backward
  
  //cheating, press A and D to rotate, used for debug only
  if (key == 'A' || key == 'a') deg = 0;     //when pressed A, car rotate to the left
  if (key == 'D' || key == 'd') deg = 0;     //when pressed D, car rotate to the right
    
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