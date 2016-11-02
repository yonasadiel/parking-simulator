class Car {
  float x,y; //posisi pusat mobil
  float or;  //orientasi saat ini
  int cr,cg,cb; //warna yang akan diberi
  float d, dx, dy;
  float cx[] = new float[4];
  float cy[] = new float[4];
  int type;
  
  Car(float xin, float yin, float orin, int typein) {
    x = xin;
    y = yin;
    or = orin;
    type = typein;
    if (type == 0) { cr = 100; cg = 100; cb = 255; } // Type 0 = car, blue color
      else         { cr = 200; cg = 200; cb = 200; } // Type 1 = destination, grey color
    if (type == 0) { d = 67; dx = 60; dy = 30; } 
      else         { d = 100; dx = 85; dy = 45; }
    calcFourCorner();  
  }
  
  void calcFourCorner() {
    // Function below calculated from trigonometri
    // 0 is the left front of the car, 1 is the right front of the car
    // 2 is the right back of the car, 3 is the left back of the car,
    
    cx[0] = x+cos(radians(    ang+or))*d; cy[0] = y-sin(radians(    ang+or))*d;
    cx[1] = x+cos(radians(180-ang+or))*d; cy[1] = y-sin(radians(180-ang+or))*d;
    cx[2] = x+cos(radians(180+ang+or))*d; cy[2] = y-sin(radians(180+ang+or))*d;
    cx[3] = x+cos(radians(360-ang+or))*d; cy[3] = y-sin(radians(360-ang+or))*d;
  }
  
  void displayold() {
    fill(cr, cg, cb);
    calcFourCorner();
    
    quad (cx[0], cy[0], cx[1], cy[1], cx[2], cy[2], cx[3], cy[3]);
  }
  
  void display() {
    fill(cr,cg,cb);
    translate(x,y);
    rotate(radians(-or));
    
    if (type == 1) rect(-dy,-dx,dy*2,dx*2);
    if (type == 0) image(img_car, -dy, -dx, 2*dy, 2*dx);
    
    rotate(radians(or));
    translate(-x,-y);
  }
  
  void move(float dir) {
    y -= 40;
    
    // These function derived from trigonometri
    x += cos(radians(90+or+deg))*dir;
    y -= sin(radians(90+or+deg))*dir;
    
    y += 40;
    
    or = or + abs(acc) * deg / 15;
    calcFourCorner();
  }
}