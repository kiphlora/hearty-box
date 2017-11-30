
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
boolean smoothGap = false; // smooth or step gap changes
boolean debugMode = false; // ignore collisions

int hrIntro = 0;
int hrIntroMin = 0;
int hrIntroMax = 4;

float delayMouseInputBeforeReset = 1000;

float showMessageForPlayerToStartAfterDelay = 3000;


public void resetGame() {
  delayMouseInputBeforeReset = 1000;
  showMessageForPlayerToStartAfterDelay = 3000;
  
  // update gapHeight based on BPM
  updateGapHeight();
  
  // reset player variables
  resetPlayer();
  
  // construct new pillars
  buildPillars();
  
  // setup stars
  resetStars();
}

public void splashScreen() {
  // title screen
  background(0);
  fill(255);
  textSize(48);
  text("Hearty Box", gameWidth / 2, gameHeight / 2);
  textSize(28);
  text("Click to Start", gameWidth / 2, gameHeight / 2 + 100); 
}


public void hrCalibration() {
  // this is the intro page
  background(0);
  noStroke();
  
  // update the gapHeight based on BPM
  updateGapHeight();
  
  // draw background
  drawStars(1);
  drawCeilingAndFloor();
  
  // only update pillars' gaps and draw pillars
  updatePillarGap();
  drawPillars();
  
  // only draw the player
  drawPlayer();
  
  // draw UI
  drawToggleSwitches();
  drawHeart();
  
  // display the intro text
  // talk briefly about the heart rate sensor calibration
  // maybe also add in something about how to play
  displayHRIntroBox();
  
  switch (hrIntro) {
    case 0:
      displayHRIntroBox();
      text("For the best experience, wait a few seconds until the HR sensor finishes calibrating...", gameWidth / 2, gameHeight / 2 - 20);
      text("Press the left/right arrow keys for more info. Click at any time to begin.", gameWidth / 2, gameHeight / 2 + 20);
      break;
      
    case 1:
      displayHRIntroBox();
      text("The object of Hearty Box is to pass through as many of the gaps as possible.", gameWidth / 2, gameHeight / 2 - 20);
      text("Use the 'f' key to jump.", gameWidth / 2, gameHeight / 2 + 20);
      break;
      
    case 2:
      displayHRIntroBox();
      text("The gaps of the pillars will change based on your heart rate, measured in beats per minute (BPM).", gameWidth / 2, gameHeight / 2 - 20);
      text("Try to relax while playing. As your BPM rises, the gaps contract. But, as your BPM lowers, the gaps widen.", gameWidth / 2, gameHeight / 2 + 20);
      break;
      
    case 3:
      displayHRIntroBox();
      text("For a greater challenge, press the 's' key to connect your heart rate to speed, as well!", gameWidth / 2, gameHeight / 2 - 20);
      text("Feel free to toggle on/off 'BPM -> Gap' (using 'g') and 'BPM -> Speed' (using 's'), for added/reduced difficulty.", gameWidth / 2, gameHeight / 2 + 20); 
      break;
      
    case 4:
      displayHRIntroBox();
      text("Thanks for playing. Have fun!", gameWidth / 2, gameHeight / 2 - 20);
      text("Click to start.", gameWidth / 2, gameHeight / 2 + 20); 
      
  }
}

void displayHRIntroBox() {
  noStroke();
  fill(80);
  rect(0, gameHeight / 2 - 100, gameWidth, 200);
  fill(255);
  text((hrIntro + 1) + " / " + (hrIntroMax + 1), width - 30, gameHeight / 2 + 90);
}

public void findSensor() {
  // this is the screen where the user selects their HR sensor port
  background(0);
  noStroke();
  // GO FIND THE ARDUINO
  fill(eggshell);
  text("Select Your Serial Port",150,50);
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

public void playGame() {
  background(0);
  noStroke();
  
  // update the gapHeight based on BPM
  updateGapHeight();
  
  // draw the background
  drawStars(1);
  drawCeilingAndFloor();
  
  // update and draw the pillars
  updatePillars();
  
  // update and draw the player
  movePlayer();
  drawPlayer();
  
  // check for collisions
  if (!debugMode) checkCollisions();
  
  // draw the UI
  drawToggleSwitches();
  drawHeart();
}

public void restartGame() {
  // this is really the "game over" screen
  delayMouseInputBeforeReset -= et;
  
  background(0);
  noStroke();
  
  // update the gapHeight based on BPM
  updateGapHeight();
  
  // no longer move the stars, but draw them and the rest of the background
  drawStars(0);
  drawCeilingAndFloor();
  
  // only draw the pillars and player (no updating)
  drawPillars();
  drawPlayer();
  
  // draw UI
  drawToggleSwitches();
  drawHeart();
  
  // update the high score
  fill(80);
  rect(0, gameHeight / 2 - 100, gameWidth, 200);
  playerHighScore = max(playerHighScore, playerScore);
  
  // write game over message to the player
  fill(255);
  String gateText = "";
  if (playerScore == 1) gateText = "gate";
  else gateText = "gates";
  text("You passed through " + playerScore + " " + gateText + "!", gameWidth / 2, gameHeight / 2 - 20);
  
  // after a short delay, allow the player to restart (display this restart message)
  if (delayMouseInputBeforeReset < 0) {
    text("Click to restart.", gameWidth / 2, gameHeight / 2 + 20);
  }
}

public void waitForInput() {
  showMessageForPlayerToStartAfterDelay -= et;
  
  // the game is ready to start, but we're waiting for the player to begin jumping 
  background(0);
  noStroke();
  
  // update the gapHeight based on BPM
  updateGapHeight();
  
  // draw the background
  drawStars(1);
  drawCeilingAndFloor();
  
  // only update the pillar gap and draw the pillars
  updatePillarGap();
  drawPillars();
  
  // draw the player as an endless wobble
  drawPlayerWobble(total_et/200);
  
  // draw UI
  drawHeart();
  drawToggleSwitches();
  
  
  if (showMessageForPlayerToStartAfterDelay < 0) {
    // draw message for player to jump to begin
    fill(255);
    text("Press the 'f' key to jump.", gameWidth / 2 - 80, gameHeight / 2 - 50);
  }
}


