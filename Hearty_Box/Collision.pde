
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


void checkCollisions() {
  int collisionCount = 0;
  if (player.x < 0 || player.x + player.w > gameWidth || player.y < ceiling || player.y + player.h > floor) {
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


