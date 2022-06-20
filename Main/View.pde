class View {
  int x; int y;
  int w; int h;
  PImage img;
  float angle = radians(90);
  boolean doRotate = false;
  
  View(PImage imgi, int xi, int yi, int widthi, int heighti) {
    img = imgi;
    x = xi; y = yi;
    w = widthi; h = heighti;
  }
  
  float left(){
    return x - 0.5*w;
  }
  
  float right(){
    return x + 0.5*w; 
  }
  
  float top(){
    return y - 0.5*h;
  }
  
  float bottom(){
    return y + 0.5 * h; 
  }
  
  void depict() {
    if (doRotate){
      pushMatrix();
      translate(x, y);
      rotate(angle);  
      image(img, -0.5*w, -0.5*h, w, h);
      popMatrix();
    } else {
      image(img, left(), top(), w, h);
    }
  }
  
  void connectTo(View view) {
    strokeWeight(2);
    stroke(#FFDB76);
    line(x, y, view.x, view.y);
  }
  
  void rotateView(float x1, float y1, float x2, float y2){
    doRotate=true;
    float yDelta = Math.max(y1, y2) - Math.min(y1, y2);
    float xDelta = Math.max(x1, x2) - Math.min(x1, x2);
    
    
    angle = (float) Math.atan2 ( yDelta , xDelta);
    if (x2 > x1 && y2 < y1 || x1 > x2 && y1 < y2) {
       angle = -angle;
    }
    
    
    //if (angle < 0) {
    //  angle += radians(360); 
    //}
    //if (x2 < x1) {
    //  angle = -angle; 
    //}
    //print(degrees(angle), "\n");
  }
  
  int interpolate(float n1, float n2, float tta, float maxtta) {
    float u = ((((maxtta-tta)/maxtta)*(n2-n1)*.9)+n1);
    return Math.round(u);
  }
  
  void interpolateAndMove(float _x, float _y, float tta, float maxtta) {
    x = interpolate(_x, x, tta, maxtta); 
    y = interpolate(_y, y, tta, maxtta);
  }
  
  boolean mouseAbove(){
    return mouseX > left() && mouseX < right() && mouseY < bottom() && mouseY > top();
  }
}
