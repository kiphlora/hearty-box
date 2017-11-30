
void mousePressed(){
  if (gameState == SPLASH_SCREEN) {
    gameState = FIND_HR_SENSOR;
  }
  else if (gameState == HR_CALIBRATION) {
    gameState = WAIT_FOR_INPUT;
  }
  else if (gameState == FIND_HR_SENSOR) {
    if(!serialPortFound){
      for(int i=0; i<=numPorts; i++){
        if(button[i].pressRadio(mouseX,mouseY)){
          if(i == numPorts){
            if(Serial.list().length > numPorts){
              println("New Ports Opened!");
              int diff = Serial.list().length - numPorts;  // was serialPorts.length
              serialPorts = expand(serialPorts,diff);
              //button = (Radio[]) expand(button,diff);
              numPorts = Serial.list().length;
            }else if(Serial.list().length < numPorts){
              println("Some Ports Closed!");
              numPorts = Serial.list().length;
            }else if(Serial.list().length == numPorts){
              return;
            }
            refreshPorts = true;
            return;
          }else
  
          try{
            port = new Serial(this, Serial.list()[i], 115200);  // make sure Arduino is talking serial at this baud rate
            delay(1000);
            println(port.read());
            port.clear();            // flush buffer
            port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
            serialPortFound = true;
            //gameState = 0;
          }
          catch(Exception e){
            println("Couldn't open port " + Serial.list()[i]);
            fill(255,0,0);
            textFont(font,16);
            textAlign(LEFT);
            text("Couldn't open port " + Serial.list()[i],60,70);
            textFont(font);
            textAlign(CENTER);
          }
        }
      }
    }
  }
  else if (gameState == PLAY_GAME) {
    player_vy = -5.5;
  }
  else if (gameState == RESTART_GAME) {
    if (delayMouseInputBeforeReset < 0) {
      resetGame();
      gameState = WAIT_FOR_INPUT;
    }
  }
  else if (gameState == WAIT_FOR_INPUT) {
    player_vy = -5.5;
    gameState = PLAY_GAME;
  }
    
}

void mouseReleased(){
}

void keyPressed(){
  
 if (gameState == HR_CALIBRATION) {
   if (keyCode == LEFT) {
     hrIntro = int(clamp(hrIntro - 1, hrIntroMin, hrIntroMax));
   }
   else if (keyCode == RIGHT) {
     hrIntro = int(clamp(hrIntro + 1, hrIntroMin, hrIntroMax));
   }
 }
 else {
   hrIntro = 0;
 }
 
 switch(key){
   case 's':
     mapSpeedToHR = !mapSpeedToHR;
     break;
    
   case 'g':
     mapGapToHR = !mapGapToHR;
     break;
   
   case 'd':
     debugMode = !debugMode;
     break;  
     
   case 'm':
     //smoothGap = !smoothGap;
     break;
     
   case 'f':
     player_vy = -5.5;
     if (gameState == WAIT_FOR_INPUT) {
       gameState = PLAY_GAME;
     }
     break;
    
    
   default:
     break;
 }
}
