
ArrayList<Point> stars;
int numStars = 200;

void resetStars() {
  stars = new ArrayList<Point>();
  for (int i=0; i<numStars; i++) {
    stars.add(new Point(random(0,2*gameWidth), random(0,gameHeight)));
  }
}


void drawStars(int speed) {
  for (int i=stars.size()-1; i>=0; i--) {
    Point p = stars.get(i);
    if (p.x < 0) {
      stars.remove(i);
      stars.add(new Point(random(gameWidth + 10, 2*gameWidth), random(0, gameHeight)));
    }
    else {
      p.x -= speed;
      fill(255);
      ellipse(p.x, p.y, 3, 3);
    }
  }
}




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
    
    Point c0 = new Point(gameWidth-50, 20);
    Point c1R = new Point(c0.x + 20, c0.y - 30);
    Point c1L = new Point(c0.x - 20, c0.y - 30);
    Point c2R = new Point(c0.x + 70, c0.y);
    Point c2L = new Point(c0.x - 70, c0.y);
    Point c3 = new Point(gameWidth-50, 70);
    
    bezier(c0.x, c0.y,   c1R.x, c1R.y,   c2R.x, c2R.y,   c3.x, c3.y);
    bezier(c0.x, c0.y,   c1L.x, c1L.y,   c2L.x, c2L.y,   c3.x, c3.y);
    strokeWeight(1);          // reset the strokeWeight for next time
    
    fill(0,154,255);
    noStroke();
    rect(gameWidth-150, 10, 40, 60, 2);
    textSize(20);
    
    fill(0,0,0);
    text(BPM,gameWidth-50,47);       // print the Beats Per Minute
    
    fill(0,0,0);
    text(playerScore, gameWidth - 130, 47); // print the player's current score 
    
    fill(255, 200, 0);
    rect(10,10,40,60,2);
    fill(0,0,0);
    text(playerHighScore, 30, 47);
    
    if (debugMode) text(getGapFromBPM(), gameWidth - 240, 44);
    
}

void drawToggleSwitches() {
  Point gapPoint = new Point(0.25*gameWidth, 10);
  Point speedPoint = new Point(0.28*gameWidth, 10);
  //Point debugPoint = new Point(0.31*gameWidth, 10);
  //Point smoothPoint = new Point(0.34*gameWidth, 10);
  
  float info_x = gapPoint.x - 5;
  float info_y = gapPoint.y - 5;
  float info_w = speedPoint.x + 35 - info_x;
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
  
  /*
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
  
  if (smoothGap) {
    noStroke();
    fill(30,30,30,255);
    rect(smoothPoint.x, smoothPoint.y, 30, 30, 5);
    textSize(14);
    fill(255);
    text("M", smoothPoint.x + 16, smoothPoint.y + 20);
  }
  else {
    noFill();
    stroke(30,30,30,255);
    rect(smoothPoint.x, smoothPoint.y, 30, 30, 5);
    textSize(14);
    fill(30,30,30,255);
    text("M", smoothPoint.x + 16, smoothPoint.y + 20);
  }
  */
}


