
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
            gameState = 0;
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
      restartGame();
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

 switch(key){
   case 's':    // pressing 's' or 'S' will take a jpg of the processing window
   case 'S':
     mapSpeedToHR = !mapSpeedToHR;
     break;
     
   case 'r':
   case 'R':
     
     //player_vy -= 3.5;
     player_vy = -5.5;
     break;

   case 't':
     player.x = 0;
     player.y = 200;
     transitionHandler.scheduleTransition(player, "x", 600,   0, 500, "cubic");
     transitionHandler.scheduleTransition(player, "y", 500,   0, 500, "linear");
     
     // code the delay so these start once the above ones end
     transitionHandler.scheduleTransition(player, "x", 600,   0, 1000, 1500, "cubic");
     transitionHandler.scheduleTransition(player, "y", 500, 200, 1000, 2500, "linear");
     break;
   
   case 'f':
    if (gameState == PLAY_GAME) {
      player_vy = -5.5;
    }
    else if (gameState == WAIT_FOR_INPUT) {
      player_vy = -5.5;
      gameState = PLAY_GAME;
    }
    break;
    
   case 'g':
     mapGapToHR = !mapGapToHR;
     break;
   
   case 'd':
     debugMode = !debugMode;
     break;  
    
    
   default:
     break;
 }
}
