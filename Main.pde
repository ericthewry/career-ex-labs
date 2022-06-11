import java.util.concurrent.TimeUnit;

/* ATTENTION! Edit the following line to switch which lab you are working on! */

int labNumber = 2;

/*
 * -------------------------IGNORE CODE BELOW THIS LINE-------------------------
 */

int stepX,
    runX,
    resetX;

// shared baseline, height, and width for buttons
int buttonY,
    buttonW,
    buttonH;

color rectColor, 
      runningColor, 
      rectHighlight;

boolean rectOver,
        doOneStep,
        run;

boolean SHOW_QUEUE = labNumber > 1;
boolean PEOPLE = labNumber == 1;

Router clickSrc = null;
Router over = null;

Network myNetwork;

PImage img;
final int MAX_TTA = 5;

final int PACKET_SIZE = 40;

int laststep; 

// Called first
void setup() {

  rectOver = false;
  doOneStep = false;
  run = false;

  size(950, 650);
  rectColor = color(#1F9CFF);
  runningColor = color(#f9c720);
  rectHighlight = color(#74C1FF);
  runX = 508;
  stepX = 650;
  resetX = 792; 
  buttonY = 550;
  buttonW = 120; 
  buttonH = 50;
  myNetwork = new Network();
  myNetwork.sendAllPackets();
  laststep = millis();
}

// Called in an infinite loop
void draw() {
  background(255);
  myNetwork.drawNetwork();
  //step();
  
  // *********** Reset button
  fill(rectColor);
  stroke(#BECAD3);
  rect(resetX, buttonY, buttonW, buttonH, 5);
  fill(70);
  textSize(26);
  textAlign(CENTER, CENTER);
  text("Reset", resetX + (buttonW/2), buttonY + (buttonH/2.5));
  // *********** Step button
  fill(rectColor);
  stroke(#BECAD3);
  rect(stepX, buttonY, buttonW, buttonH, 5);
  fill(70);
  textSize(26);
  textAlign(CENTER, CENTER);
  text("Step", stepX + (buttonW/2), buttonY + (buttonH/2.5));
  // *********** Run button
  if (run){
    fill(runningColor);
  } else {
    fill(rectColor);
  }
  stroke(#BECAD3);
  rect(runX, buttonY, buttonW, buttonH, 5);
  textSize(26);
  textAlign(CENTER, CENTER);
  if (run) {
    fill(255,255,255);
    text("Pause", runX + (buttonW/2), buttonY + (buttonH/2.5));    
  } else {
    fill(70);
    text("Run", runX + (buttonW/2), buttonY + (buttonH/2.5));
  }

  // ********* makes the buttons do things
  int timeDiff = millis() - laststep;
  if (timeDiff < 0 || timeDiff > 350){
    if (doOneStep || run) {
      step();
      doOneStep = run;
      laststep = millis();
    }
  } 

}

// Moves time forward a step
void step() {
  myNetwork.stepAllRouters();
  myNetwork.unifyTransit();
  for (Transit t : new ArrayList<Transit>(myNetwork.inTransit)) {
    if (t.step()) {
      myNetwork.inTransit.remove(t);
    }
  }
}

// ********* important for reset button
boolean overReset()  {
  if (mouseX >= resetX && mouseX <= (resetX + buttonW) && 
      mouseY >= buttonY && mouseY <= (buttonY + buttonH)) {
    return true;
  } else {
    return false;
  }
}

// ********* important for step button
boolean overStep()  {
  if (mouseX >= stepX && mouseX <= (stepX + buttonW) && 
      mouseY >= buttonY && mouseY <= (buttonY + buttonH)) {
    return true;
  } else {
    return false;
  }
}

// ********** important for run button
boolean overRun()  {
  if (mouseX >= runX && mouseX <= (runX + buttonW) && 
      mouseY >= buttonY && mouseY <= (buttonY + buttonH)) {
    return true;
  } else {
    return false;
  }
}

// ******** important for the buttons
void mouseClicked() { 
  if (overReset()) {
    setup();
  }
  if (overStep()) {
    doOneStep = true;
    laststep = -10000;
  }
  if (overRun()) {
    print("runbutton\n");
    run = !run;
  }
  if (clickSrc == null) {
    clickSrc = myNetwork.overRouter();
    if (clickSrc != null) {
      clickSrc.mark();
    }
  } else {
    Router dst = myNetwork.overRouter();
    if (dst != null) {
      if (dst == clickSrc) {
        if (labNumber > 1) {          
          if (clickSrc instanceof EvilRouter) {
            Router newrouter = 
              labNumber == 2 
              ? new UnsafeRouter(clickSrc.getId(),  clickSrc.getX(), clickSrc.getY()) 
              : new DefenseRouter(clickSrc.getId(), clickSrc.getX(), clickSrc.getY());
            myNetwork.replaceRouter(clickSrc, newrouter);
            clickSrc = newrouter;
            println("turn ", clickSrc.getId(), " un-evil");
            clickSrc.mark();
          } else { 
            Router ddos = new EvilRouter(null, clickSrc.getId(), clickSrc.getX(), clickSrc.getY());
            myNetwork.replaceRouter(clickSrc, ddos);
            clickSrc = ddos;
            println("turn ", clickSrc.getId(), " evil");
            clickSrc.mark();
          }
        } else {
          clickSrc.unmark();
          clickSrc = null;
        }
      } else {
        clickSrc.sendAPacketTo(dst);
        clickSrc.unmark();
        clickSrc = null;
      }
    } else {
      clickSrc.unmark();
      clickSrc = null;
    }
  }
}

void mousePressed () {
  over = myNetwork.overRouter();
  if (over != null) over.mark();
  for (Router r : myNetwork.routers) {
    if (r != over) {
       r.unmark();
    }
  }
}

void mouseReleased() {
  over = myNetwork.overRouter();
  if (over != null) over.unmark();
  over = null;
}

void mouseDragged() {
  if (over != null && over.marked()){
    over.moveTo(mouseX, mouseY); 
  }
}

Router getRouter(int i){
  return myNetwork.routers[i]; 
}

// ************** Controls run via keyboard commands

void keyPressed() {
  if (key == ' ' || key == 'r' || key == 'p') {
    run = !run;
  }
  if (key == 's' || key == '\t' ) {
    doOneStep = true; 
  }
}
