float player_w = 30;
float player_h = 30;
float player_x = (gameWidth / 2) - 100;
float player_y = (gameHeight / 2) - player_h/2;

Body player = new Body(player_x, player_y, player_w, player_h, 4);

boolean playerHasCollided = false;
float player_vy = 0;
int playerScore = 0;
int playerHighScore = 0;


void drawPlayer(){
  if (playerHasCollided) {
    player.draw(255,157,0,255);
  }
  else {
    //player.draw(0,157,255,255);
    int r = int(clamp(map(BPM, 50, 140, 0, 255), 0, 255));
    player.draw(255,r,0,255);
  }
  
  if (debugMode) {
    if (player.y + player.h >= gameHeight) {
      player.y = gameHeight - player.h;
    }
  }
}

void drawPlayerWobble(float t) {
  player.y += 0.75 * sin(t);
  //player.draw(0,157,255,255);
  int r = int(clamp(map(BPM, 50, 140, 0, 255), 0, 255));
  player.draw(255,r,0,255);
}

void movePlayer() {
  if (!playerHasCollided) {
    player_vy += 0.31;
    player_vy = clamp(player_vy, -7, 7);
    player.y += player_vy;
  }
}

void resetPlayer() {
  float player_w = 30;
  float player_h = 30;
  float player_x = (gameWidth / 2) - 100;
  float player_y = (gameHeight / 2) - player_h/2;
  
  player = new Body(player_x, player_y, player_w, player_h, 4);
  
  playerHasCollided = false;
  player_vy = 0;
  playerScore = 0;
}

