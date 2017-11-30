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

int gameWidth = 1280;
int gameHeight = 760;

float et = 0;
float total_et = 0;
float prevTime = 0;
float curTime = 0;

float minSpeed = 2;
float maxSpeed = 6;




void setup() {
  curTime = millis();
  prevTime = millis();
  size(gameWidth, gameHeight);  // Stage size
  frameRate(100);
  font = loadFont("Arial-BoldMT-24.vlw");
  textFont(font);
  textAlign(CENTER);
  rectMode(CORNER);
  ellipseMode(CENTER);
  
  resetGame();
}


void draw() {
  curTime = millis();
  et = curTime - prevTime;
  total_et += et;
  prevTime = curTime;
  
  if (gameState == SPLASH_SCREEN) {
    splashScreen();   
  }
  else if (gameState == HR_CALIBRATION) {
    hrCalibration();
  }
  else if (gameState == FIND_HR_SENSOR) {
    findSensor();
  }
  else if (gameState == PLAY_GAME) {
    playGame();
  }
  else if (gameState == RESTART_GAME) {
    restartGame();
  }
  else if (gameState == WAIT_FOR_INPUT) {
    waitForInput();
  }

}  //end of draw loop



float clamp(float value, float minimum, float maximum) {
  return max(minimum, min(value, maximum));
}

float interpolate(float start, float end, float p) {
  return (1 - p) * start + p * end;
}

