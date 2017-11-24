/*
THIS PROGRAM WORKS WITH PulseSensorAmped_Arduino ARDUINO CODE
THE PULSE DATA WINDOW IS SCALEABLE WITH SCROLLBAR AT BOTTOM OF SCREEN
PRESS 'S' OR 's' KEY TO SAVE A PICTURE OF THE SCREEN IN SKETCH FOLDER (.jpg)
PRESS 'R' OR 'r' KEY TO RESET THE DATA TRACES
MADE BY JOEL MURPHY AUGUST, 2012
UPDATED BY JOEL MURPHY SUMMER 2016 WITH SERIAL PORT LOCATOR TOOL
UPDATED BY JOEL MURPHY WINTER 2017 WITH IMPROVED SERIAL PORT SELECTOR TOOL

THIS CODE PROVIDED AS IS, WITH NO CLAIMS OF FUNCTIONALITY OR EVEN IF IT WILL WORK
      WYSIWYG
      
Modified by Brett Moran in November 2017 to turn it into a game called "Hearty Box".
*/

import processing.serial.*;  // serial library lets us talk to Arduino
PFont font;
PFont portsFont;

Serial port;

int Sensor;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int IBI;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM;         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] ScaledY;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] rate;      // USED TO POSITION BPM DATA WAVEFORM
float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
color eggshell = color(255, 253, 248);
int heart = 0;   // This variable times the heart image 'pulse' on screen
boolean beat = false;    // set when a heart beat is detected, then cleared when the BPM graph is advanced

// SERIAL PORT STUFF TO HELP YOU FIND THE CORRECT SERIAL PORT
String serialPort;
String[] serialPorts = new String[Serial.list().length];
boolean serialPortFound = false;
Radio[] button = new Radio[Serial.list().length*2];
int numPorts = serialPorts.length;
boolean refreshPorts = false;



class Body {
  public float x;
  public float y;
  public float w;
  public float h;
  public float[] xbounds;
  public float[] ybounds;
  
  public Body(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    updateBounds();
  }
  
  public void draw(int r, int g, int b, int a) {
    fill(r,g,b,a);
    rect(this.x, this.y, this.w, this.h);
  }
  
  public void updateBounds(){
    this.xbounds = createBounds(this.x, this.x + this.w);
    this.ybounds = createBounds(this.y, this.y + this.h);
  }
}

class Pillar {
  public Body top;
  public Body gap;
  public Body bottom;
  public boolean isAlive;
  public float[] ys;
  public float gapCenter;
  public boolean playerInGap;
  
  public Pillar(float x, float w, float[] ys){
    this.ys = ys;
    this.top    = new Body(x, ys[0], w, ys[1] - ys[0]);
    this.gap    = new Body(x+w-5, ys[1], 5, ys[2] - ys[1]);
    this.bottom = new Body(x, ys[2], w, ys[3] - ys[2]);
    this.isAlive = true; 
    this.gapCenter = ys[1] + (ys[2] - ys[1])/2;
    this.playerInGap = false;
  }
  
  public int[] gapDist(float d, float duration) {
    float top_h_start = this.top.h;
    float bottom_y_start = this.bottom.y;
    float bottom_h_start = this.bottom.h;
    
    float gap = bottom_y_start - top_h_start;
    float diff = abs(gap - d);
    
    float top_h_end;
    float bottom_y_end;
    float bottom_h_end;
    
    if (gap > d) {
      // shrink gap
      top_h_end = top_h_start + diff/2;
      bottom_y_end = bottom_y_start - diff/2;
      bottom_h_end = bottom_h_start + diff/2;
    }
    else {
      top_h_end = top_h_start - diff/2;
      bottom_y_end = bottom_y_start + diff/2;
      bottom_h_end = bottom_h_start - diff/2;
    }
    
    int th = transitionHandler.scheduleTransition(this.top, "h", top_h_start, top_h_end, 0, duration, "cubic");
    int by = transitionHandler.scheduleTransition(this.bottom, "y", bottom_y_start, bottom_y_end, 0, duration, "cubic");
    int bh = transitionHandler.scheduleTransition(this.bottom, "h", bottom_h_start, bottom_h_end, 0, duration, "cubic");
    
    return new int[] {th, by, bh};
  }

  public void movePillar(float d) {
    this.top.x -= d;
    this.gap.x -= d;
    this.bottom.x -= d;
  }
  
  public void draw() {
    this.top.draw(200,200,200,255);
    this.gap.draw(0,0,0,0);
    this.bottom.draw(200,200,200,255);
  }
}

boolean intersect(float[] bounds_a, float[] bounds_b) {
  float[] a = bounds_a;
  float[] b = bounds_b;
  
  if (a[0] > b[1] || a[1] < b[0]) return false;
  else return true;
}


boolean collision(Body a, Body b) {
  a.updateBounds();
  b.updateBounds();
  if (intersect(a.xbounds, b.xbounds) && 
      intersect(a.ybounds, b.ybounds)) return true;
  else return false;
}

float[] createBounds(float a1, float a2) {
  return new float[] {a1, a2};
}


ArrayList<Pillar> pillars;


class TransitionHandler {
  ArrayList<Transition> transitionList;
  int count;
  
  public TransitionHandler() {
    transitionList = new ArrayList<Transition>();
    count = 0;
  }
  
  public int scheduleTransition(Body body, String attr, float start, float end, float delay, float duration, String easing) {
    count++;
    int uid = count;
    Transition t = new Transition(body, attr, start, end, delay, duration, easing, uid);
    transitionList.add(t);
    return uid;
  }
  
  public int scheduleTransition(Body body, String attr, float end, float delay, float duration, String easing) {
    count++;
    int uid = count;
    Transition t = new Transition(body, attr, end, delay, duration, easing, uid); 
    transitionList.add(t);
    return uid;
  }
  
  
  public void update(float dt) {
    for (int i=transitionList.size()-1; i>=0; i--) {
      Transition t = transitionList.get(i);
      t.update(dt);
      if (t.hasEnded()){
        transitionList.remove(i);
      }
    }
  }
  
  public void removeTransition(int uid) {
    for (int i=transitionList.size()-1; i>=0; i--) {
      Transition t = transitionList.get(i);
      if (t.getUID() == uid) {
        transitionList.remove(i);
      }
    }
  }
  
}
 
class Transition {
  Body body;
  String attr;
  float start;
  float end;
  float delay; 
  float duration;
  int easing;
  int uid;
  float elapsedTime;
  boolean hasEnded;
  
  public Transition(Body body, String attr, float start, float end, float delay, float duration, String easing, int uid) {
    init(body, attr, start, end, delay, duration, easing, uid);
  }
  public Transition(Body body, String attr, float end, float delay, float duration, String easing, int uid) {
    this.body = body;
    this.attr = attr;
    float temp_start = getBodyAttrValue();
    init(body, attr, temp_start, end, delay, duration, easing, uid);
  }
  
  private void init(Body body, String attr, float start, float end, float delay, float duration, String easing, int uid) {
    this.body = body;
    this.attr = attr;
    this.start = start;
    this.end = end;
    this.delay = delay;
    this.duration = duration;
    this.easing = getEasingType(easing);
    this.uid = uid;
    this.elapsedTime = 0;
    this.hasEnded = false;
  }
  
  public int getEasingType(String type) {
    if (type == "cubic") return 0;
    else if (type == "linear") return 1;
    else return 1;
  }
  
  public float getBodyAttrValue() {
    if (this.attr == "x")
      return this.body.x;
    else if (this.attr == "y")
      return this.body.y;
    else if (this.attr == "w")
      return this.body.w;
    else if (this.attr == "h")
      return this.body.h;
    else return 0;
  }
  
  public void setBodyAttrValue(float value) {
    if (this.attr == "x")
      this.body.x = value;
    else if (this.attr == "y")
      this.body.y = value;
    else if (this.attr == "w")
      this.body.w = value;
    else if (this.attr == "h")
      this.body.h = value;
  }
  
  public int getUID() { return this.uid; }
  
  public boolean hasEnded() {
    return this.hasEnded;
  }
  
  public float interpolation(float t) {
    return this.start * (1 - t) + this.end * t;
  }
  
  public float cubicEasing(float t) {
    return ((t *= 2) <= 1 ? t * t * t : (t -= 2) * t * t + 2) / 2;
  }
  
  public float linearEasing(float t) {
    return t;
  }
  
  public void update(float dt) {
    if (this.delay > 0) {
      this.delay -= dt;
    }
    else {
      this.elapsedTime += dt;
      
      float normalTime = this.elapsedTime / this.duration;
      float easedTime;
      
      if (normalTime <= 0) {
        easedTime = 0;
      }
      else if (normalTime >= 1) {
        easedTime = 1;
        this.hasEnded = true;
      }
      else {
        if (this.easing == 0)
          easedTime = cubicEasing(normalTime);
        else
          easedTime = linearEasing(normalTime);
      }
      
      float value = interpolation(easedTime);
      setBodyAttrValue(value);
    }
  }
}


TransitionHandler transitionHandler = new TransitionHandler();

float et = 0;
float total_et = 0;
float time2;

Pillar createPillar(float prevMidY, float var, float x, float w, float top, float bottom, float ymin, float ymax, float gapH) {
  float nextGapMidY = (randomGaussian() * var) + prevMidY;
  float gapMidY = clamp(nextGapMidY, ymin, ymax);
  
  float gapTop = gapMidY - gapH/2;
  float gapBottom = gapMidY + gapH/2;
  
  Pillar nextGate = new Pillar(x, w, new float[] {top, gapTop, gapBottom, bottom});
  
  return nextGate;
}


float top;
float bottom;
float gapMidY;
float gapTop;
float gapBottom;
float stdDev;
float gapTopPad;
float gapBottomPad;
float gapYmin;
float gapYmax;


// num pillars (min)
int numPillars = 12;

// width of pillars
float pw = 50;

// horizontal gap b/w pillars
float phg = 150;

// vertical gap b/w pillars
int STD_GAP_HEIGHT = 180;
float pvg = STD_GAP_HEIGHT;

float prev_gap = pvg;

float mingap = 130;
float maxgap = 200;

float minSpeed = 2;
float maxSpeed = 6;

float time = 0;
int playerHighScore = 0;

float delayMouseInputBeforeReset = 1000; 

int FIND_HR_SENSOR = 0;
int HR_CALIBRATION = 1;
int PLAY_GAME = 2;
int RESTART_GAME = 3;
int SPLASH_SCREEN = 4;
int WAIT_FOR_INPUT = 5;

//int gameState = HR_CALIBRATION; 
int gameState = SPLASH_SCREEN;

boolean mapSpeedToHR = false;
boolean mapGapToHR = true;
boolean debugMode = false; 


Body player = new Body((width / 2) - 100, (height / 2) - (30 / 2), 30, 30);
boolean playerHasCollided = false;
float player_vy = 0;
int playerScore = 0;

class Point {
  public float x;
  public float y;
  
  public Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

ArrayList<Point> stars;
int numStars = 200;


void drawStars(int speed) {
  for (int i=stars.size()-1; i>=0; i--) {
    Point p = stars.get(i);
    if (p.x < 0) {
      stars.remove(i);
      stars.add(new Point(random(width + 10, 2*width), random(0, height)));
    }
    else {
      p.x -= speed;
      fill(255);
      ellipse(p.x, p.y, 3, 3);
    }
  }
}

void drawCeilingAndFloor() {
  fill(100);
  rect(0,0,width,top);
  rect(0,bottom,width,height-bottom);
}

void restartGame() {
  float pwidth = 30;
  float pheight = 30;
  float px = (width / 2) - 100;
  float py = (height / 2) - (pheight / 2);
  prev_gap = STD_GAP_HEIGHT;
  player = new Body(px, py, pwidth, pheight);
  playerHasCollided = false;
  player_vy = 0;
  playerScore = 0;
  
  top = 50;
  bottom = height - 50;
  gapMidY = (bottom - top) / 2;
  pvg = pvg;
  gapTop = gapMidY - pvg/2;
  gapBottom = gapMidY + pvg/2;
  stdDev = 100;
  gapTopPad = 50;
  gapBottomPad = 50;
  gapYmin = top + gapTopPad + pvg/2;
  gapYmax = bottom - gapBottomPad - pvg/2;
  
  // Scrollbar constructor inputs: x,y,width,height,minVal,maxVal
  pillars = new ArrayList<Pillar>();
   
  Pillar firstGate = new Pillar(width + 400 -pw-phg, pw, new float[] {top, gapTop, gapBottom, bottom});
  Pillar prevGate = firstGate;
  pillars.add(firstGate);
  
  for (int i=0; i<numPillars-1; i++) {
    float x = i * (phg + pw) + width + 400;
    float w = pw;
    
    Pillar nextGate = createPillar(prevGate.gapCenter, stdDev, x, w, top, bottom, gapYmin, gapYmax, pvg);
    pillars.add(nextGate);
    prevGate = nextGate;
  }

  drawStars(1);
  drawPlayer();
  drawPillars();
  //background(0);
  drawHeart();
}

void setup() {
  time = millis();
  time2 = millis();
  size(1280, 760);  // Stage size
  frameRate(100);
  font = loadFont("Arial-BoldMT-24.vlw");
  textFont(font);
  textAlign(CENTER);
  rectMode(CORNER);
  ellipseMode(CENTER);
  
  stars = new ArrayList<Point>();
  for (int i=0; i<numStars; i++) {
    stars.add(new Point(random(0,2*width), random(0,height)));
  }
  
  drawStars(2);
  restartGame();
  
}

void draw() {
  time2 = millis();
  et = time2 - time;
  total_et += et;
  time = time2;
  
  if (gameState == SPLASH_SCREEN) {
    background(0);
    fill(255);
    textSize(48);
    text("Hearty Box", width / 2, height / 2);
    textSize(28);
    text("Click to Start", width / 2, height / 2 + 100);    
  }
  else if (gameState == HR_CALIBRATION) {
    background(0);
    noStroke();
    
    drawStars(1);
    drawCeilingAndFloor();
    drawPillars();
    drawPlayer();
    drawToggleSwitches();
    drawHeart();
    
    
    
    noStroke();
    fill(80);
    rect(0, height / 2 - 100, width, 200);
    fill(255);
    text("For the best experience, wait a few seconds until the HR sensor finishes calibrating... Then click to begin.", width / 2, height / 2);
  }
  else if (gameState == FIND_HR_SENSOR) {
    background(0);
    noStroke();
    // GO FIND THE ARDUINO
    fill(eggshell);
    text("Select Your Serial Port",245,30);
    listAvailablePorts();    
    
    if(serialPortFound){
      // ONLY RUN THE VISUALIZER AFTER THE PORT IS CONNECTED
      background(0);
      noStroke();
      
      gameState = HR_CALIBRATION;
    
    } else { // SCAN BUTTONS TO FIND THE SERIAL PORT
    
      autoScanPorts();
      
      if(refreshPorts){
        refreshPorts = false;
        drawHeart();
        listAvailablePorts();
      }
      
      for(int i=0; i<numPorts+1; i++){
        button[i].overRadio(mouseX,mouseY);
        button[i].displayRadio();
      }
    }
  }
  else if (gameState == PLAY_GAME) {
    background(0);
    noStroke();
    drawStars(1);
    drawCeilingAndFloor();
    if (mapSpeedToHR) movePillars(clamp(map(BPM, 60, 130, minSpeed, maxSpeed), minSpeed, maxSpeed));
    else movePillars(3);
    if (mapGapToHR) changePillarGapByHR();
    else resetPillarGap();
    drawPillars();
    updatePlayer();
    drawPlayer();
    if (!debugMode) checkCollisions();
    changePillars();
    drawToggleSwitches();
    drawHeart();
    
    transitionHandler.update(et);  
  }
  else if (gameState == RESTART_GAME) {
    delayMouseInputBeforeReset -= et;
    background(0);
    noStroke();
    drawStars(0);
    drawCeilingAndFloor();
    drawPillars();
    drawPlayer();
    drawToggleSwitches();
    drawHeart();
    
    fill(80);
    rect(0, height / 2 - 100, width, 200);
    playerHighScore = max(playerHighScore, playerScore);
    fill(255);
    String gateText = "";
    if (playerScore == 1) gateText = "gate";
    else gateText = "gates";
    text("You passed through " + playerScore + " " + gateText + "!", width / 2, height / 2);
    if (delayMouseInputBeforeReset < 0) {
      text("Click to restart.", width / 2, height / 2 + 40);
    }
  }
  else if (gameState == WAIT_FOR_INPUT) {
    background(0);
    noStroke();
    drawStars(1);
    drawCeilingAndFloor();
    drawPillars();
    drawPlayerWobble(total_et/200);
    drawHeart();
    drawToggleSwitches();
  }

}  //end of draw loop

//
//void changePillarGapByHR() {
//  float gap = map(BPM, 60, 130, maxgap, mingap);
//  for (Pillar p : pillars) {
//    pvg = gap;
//    p.gapDist(clamp(gap, mingap, maxgap));
//  }
//}

float interpolate(float a, float b, float p) {
  return a * (1 - p) + b * p;
}

float getGapFromBPM() {
  if (BPM < 60) return interpolate(maxgap, mingap, 0);
  else if (BPM >= 60 && BPM < 75) return interpolate(maxgap, mingap, 0.10);
  else if (BPM >= 75 && BPM < 90) return interpolate(maxgap, mingap, 0.25);
  else if (BPM >= 90 && BPM < 105) return interpolate(maxgap, mingap, 0.35);
  else if (BPM >= 105 && BPM < 120) return interpolate(maxgap, mingap, 0.6);
  else if (BPM >= 120 && BPM < 135) return interpolate(maxgap, mingap, 0.85);
  else return interpolate(maxgap, mingap, 1);
}

void resetPillarGap() {
  for (Pillar p : pillars) {
    pvg = STD_GAP_HEIGHT;
    p.gapDist(pvg, 1000);
  }
  prev_gap = pvg;
}

void changePillarGapByHR() {
  float gap = getGapFromBPM();
  pvg = gap;
  if (gap - prev_gap != 0) {   
    for (Pillar p : pillars) {
      //float[] ys = p.gapDist(clamp(gap, mingap, maxgap));
      p.gapDist(clamp(gap, mingap, maxgap), 1000);
    }
  }
  prev_gap = gap;
  
  
}

void checkCollisions() {
  int collisionCount = 0;
  if (player.x < 0 || player.x + player.w > width || player.y < top || player.y + player.h > bottom) {
   collisionCount = 1; 
  }
  else {
    for (int i=0; i<pillars.size(); i++) {
      Pillar p = pillars.get(i);
      if (collision(player, p.gap)) {
        if (!p.playerInGap) {
          playerScore++;
          p.playerInGap = true;
        }
      }
      if (collision(player, p.top) || collision(player, p.bottom)){
        collisionCount++;
        break;
      }
    }
  }
  
  if (collisionCount > 0) playerHasCollided = true;
  else playerHasCollided = false;
  
  if (playerHasCollided) {
    handleCollision();
  }
}

void handleCollision() {
  gameState = RESTART_GAME;
  delayMouseInputBeforeReset = 1000;
}


void drawPlayer(){
  if (playerHasCollided) {
    player.draw(255,157,0,255);
  }
  else {
    //player.draw(0,157,255,255);
    int r = int(map(BPM, 70, 110, 0, 255));
    player.draw(255,r,0,255);
  }
}

void drawPlayerWobble(float t) {
  player.y += 0.75 * sin(t);
  //player.draw(0,157,255,255);
  int r = int(map(BPM, 70, 110, 0, 255));
  player.draw(255,r,0,255);
}

void updatePlayer() {
  if (!playerHasCollided) {
    player_vy += 0.31;
    player_vy = clamp(player_vy, -7, 7);
    player.y += player_vy;
  }
}

void movePillars(float dx) {
  if (!playerHasCollided) {
    for (int i=pillars.size()-1; i>=0; i--) {
      pillars.get(i).movePillar(dx);
    }
  }
}

void changePillars() {
  // flag pillars for removal
  for (int i=pillars.size()-1; i>=0; i--) {
    Pillar p = pillars.get(i);
    if (p.top.x + p.top.w < -10) {
      p.isAlive = false;
    }
  }
  
  // remove pillars
  for (int i=pillars.size()-1; i>=0; i--) {
    if (!pillars.get(i).isAlive) {
      pillars.remove(i);
    }
  }
  
  // add new pillars
  int diff = numPillars - pillars.size();
  for (int i=0; i<diff; i++) {
    int indexOfLastItem = pillars.size() - 1;
    Pillar prev = pillars.get(indexOfLastItem);
    float x = prev.top.x + phg + pw;
    float w = pw;
    
    Pillar nextGate = createPillar(prev.gapCenter, stdDev, x, w, top, bottom, gapYmin, gapYmax, pvg);
    pillars.add(nextGate); 
  }
}

float clamp(float value, float minimum, float maximum) {
  return max(minimum, min(value, maximum));
}

void drawPillars(){
  for (int i=pillars.size()-1; i>=0; i--) {
    Pillar b = pillars.get(i);
    b.draw();
  }
}
//
//void drawPulseWaveform(){
//  // DRAW THE PULSE WAVEFORM
//  // prepare pulse data points
//  RawY[RawY.length-1] = (1023 - Sensor) - 212;   // place the new raw datapoint at the end of the array
//  zoom = scaleBar.getPos();                      // get current waveform scale value
//  offset = map(zoom,0.5,1,150,0);                // calculate the offset needed at this scale
//  for (int i = 0; i < RawY.length-1; i++) {      // move the pulse waveform by
//    RawY[i] = RawY[i+1];                         // shifting all raw datapoints one pixel left
//    float dummy = RawY[i] * zoom + offset;       // adjust the raw data to the selected scale
//    ScaledY[i] = constrain(int(dummy),44,556);   // transfer the raw data array to the scaled array
//  }
//  stroke(250,0,0);                               // red is a good color for the pulse waveform
//  noFill();
//  beginShape();                                  // using beginShape() renders fast
//  for (int x = 1; x < ScaledY.length-1; x++) {
//    vertex(x+10, ScaledY[x]);                    //draw a line connecting the data points
//  }
//  endShape();
//}
//
//void drawBPMwaveform(){
//// DRAW THE BPM WAVE FORM
//// first, shift the BPM waveform over to fit then next data point only when a beat is found
// if (beat == true){   // move the heart rate line over one pixel every time the heart beats
//   beat = false;      // clear beat flag (beat flag waset in serialEvent tab)
//   for (int i=0; i<rate.length-1; i++){
//     rate[i] = rate[i+1];                  // shift the bpm Y coordinates over one pixel to the left
//   }
//// then limit and scale the BPM value
//   BPM = min(BPM,200);                     // limit the highest BPM value to 200
//   float dummy = map(BPM,0,200,555,215);   // map it to the heart rate window Y
//   rate[rate.length-1] = int(dummy);       // set the rightmost pixel to the new data point value
// }
// // GRAPH THE HEART RATE WAVEFORM
// stroke(0,135,255);                          // color of heart rate graph
// strokeWeight(2);                          // thicker line is easier to read
// noFill();
// beginShape();
// for (int i=0; i < rate.length-1; i++){    // variable 'i' will take the place of pixel x position
//   vertex(i+510, rate[i]);                 // display history of heart rate datapoints
// }
// endShape();
//}

void drawHeart(){
  // DRAW THE HEART AND MAYBE MAKE IT BEAT
    int r = int(map(BPM, 70, 110, 0, 255));
    fill(255,r,0);
    stroke(255,r,0);
    // the 'heart' variable is set in serialEvent when arduino sees a beat happen
    heart--;                    // heart is used to time how long the heart graphic swells when your heart beats
    heart = max(heart,0);       // don't let the heart variable go into negative numbers
    if (heart > 0){             // if a beat happened recently,
      strokeWeight(7);          // make the heart big
    }
    smooth();   // draw the heart with two bezier curves
    
    Point c0 = new Point(width-50, 20);
    Point c1R = new Point(c0.x + 20, c0.y - 30);
    Point c1L = new Point(c0.x - 20, c0.y - 30);
    Point c2R = new Point(c0.x + 70, c0.y);
    Point c2L = new Point(c0.x - 70, c0.y);
    Point c3 = new Point(width-50, 70);
    
    bezier(c0.x, c0.y,   c1R.x, c1R.y,   c2R.x, c2R.y,   c3.x, c3.y);
    bezier(c0.x, c0.y,   c1L.x, c1L.y,   c2L.x, c2L.y,   c3.x, c3.y);
    strokeWeight(1);          // reset the strokeWeight for next time
    
    fill(0,154,255);
    noStroke();
    rect(width-150, 10, 40, 60);
    textSize(20);
    
    fill(0,0,0);
    text(BPM,width-50,47);       // print the Beats Per Minute
    
    fill(0,0,0);
    text(playerScore, width - 130, 47); // print the player's current score 
    
    fill(255, 200, 0);
    rect(10,10,40,60);
    fill(0,0,0);
    text(playerHighScore, 30, 47);
    
}

void drawToggleSwitches() {
  Point gapPoint = new Point(0.25*width, 10);
  Point speedPoint = new Point(0.28*width, 10);
  Point debugPoint = new Point(0.31*width, 10);
  float info_x = gapPoint.x - 5;
  float info_y = gapPoint.y - 5;
  float info_w = debugPoint.x + 35 - info_x;
  float info_h = gapPoint.y + 35 - info_y;
  fill(255);
  rect(info_x, info_y, info_w, info_h, 5);
  
  if (mapGapToHR) {
    noStroke();
    fill(0,200,200,255);
    rect(gapPoint.x, gapPoint.y, 30, 30, 5);
    textSize(14);
    fill(255);
    text("G", gapPoint.x + 16, gapPoint.y + 20);
  }
  else {
    noFill();
    stroke(0,200,200,255);
    rect(gapPoint.x, gapPoint.y, 30, 30, 5);
    textSize(14);
    fill(0,200,200,255);
    text("G", gapPoint.x + 16, gapPoint.y + 20);
  }
  
  if (mapSpeedToHR) {
    noStroke();
    fill(0,157,255,255);
    rect(speedPoint.x, speedPoint.y, 30, 30, 5);
    textSize(14);
    fill(255);
    text("S", speedPoint.x + 16, speedPoint.y + 20);
  }
  else {
    noFill();
    stroke(0,157,255,255);
    rect(speedPoint.x, speedPoint.y, 30, 30, 5);
    textSize(14);
    fill(0,157,255,255);
    text("S", speedPoint.x + 16, speedPoint.y + 20);
  }
  
  if (debugMode) {
    noStroke();
    fill(255,0,0,255);
    rect(debugPoint.x, debugPoint.y, 30, 30, 5);
    textSize(14);
    fill(255);
    text("D", debugPoint.x + 16, debugPoint.y + 20);
  }
  else {
    noFill();
    stroke(255,0,0,255);
    rect(debugPoint.x, debugPoint.y, 30, 30, 5);
    textSize(14);
    fill(255,0,0,255);
    text("D", debugPoint.x + 16, debugPoint.y + 20);
  }
  
}

void listAvailablePorts(){
  println(Serial.list());    // print a list of available serial ports to the console
  serialPorts = Serial.list();
  fill(0);
  textFont(font,16);
  textAlign(LEFT);
  // set a counter to list the ports backwards
  int yPos = 0;
  int xPos = 35;
  for(int i=serialPorts.length-1; i>=0; i--){
    button[i] = new Radio(xPos, 95+(yPos*20),12,color(180),color(80),color(255),i,button);
    fill(255, 255, 255);
    text(serialPorts[i],xPos+15, 100+(yPos*20));

    yPos++;
    if(yPos > height-30){
      yPos = 0; xPos+=200;
    }
  }
  int p = numPorts;
   fill(233,0,0);
  button[p] = new Radio(35, 95+(yPos*20),12,color(255),color(255),color(255),p,button);
    text("Refresh Serial Ports List",50, 100+(yPos*20));

  textFont(font);
  textAlign(CENTER);
}

void autoScanPorts(){
  if(Serial.list().length != numPorts){
    if(Serial.list().length > numPorts){
      println("New Ports Opened!");
      int diff = Serial.list().length - numPorts;	// was serialPorts.length
      serialPorts = expand(serialPorts,diff);
      numPorts = Serial.list().length;
    }else if(Serial.list().length < numPorts){
      println("Some Ports Closed!");
      numPorts = Serial.list().length;
    }
    refreshPorts = true;
    return;
  }
}

//void resetDataTraces(){
//  for (int i=0; i<rate.length; i++){
//     rate[i] = 555;      // Place BPM graph line at bottom of BPM Window
//    }
//  for (int i=0; i<RawY.length; i++){
//     RawY[i] = height/2; // initialize the pulse window data line to V/2
//  }
//}
