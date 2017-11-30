

class Point {
  public float x;
  public float y;
  
  public Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}


class Body {
  public float x;
  public float y;
  public float w;
  public float h;
  public float ul;
  public float ur;
  public float lr;
  public float ll;
  public Point center; 
  public float[] xbounds;
  public float[] ybounds;
  
  public Body(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.ul = 0;
    this.ur = 0;
    this.lr = 0;
    this.ll = 0;
    this.center = new Point(this.x + this.w/2, this.y + this.h/2);
    updateBounds();
  }
  
  public Body(float x, float y, float w, float h, float r) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.ul = r;
    this.ur = r;
    this.lr = r;
    this.ll = r;
    this.center = new Point(this.x + this.w/2, this.y + this.h/2);
    updateBounds();
  }
  
  public Body(float x, float y, float w, float h, float ul, float ur, float lr, float ll) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.ul = ul;
    this.ur = ur;
    this.lr = lr;
    this.ll = ll;
    this.center = new Point(this.x + this.w/2, this.y + this.h/2);
    updateBounds();
  } 
  
  public void draw(int r, int g, int b, int a) {
    fill(r,g,b,a);
    rect(this.x, this.y, this.w, this.h, this.ul, this.ur, this.lr, this.ll);
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
  public boolean playerInGap;
  
  public Pillar(Body top, Body gap, Body bottom){
    this.top = top;
    this.gap = gap;
    this.bottom = bottom;
    this.isAlive = true; 
    this.playerInGap = false;
  }
  
  
  public void updateGap(float newGapHeight, float vel) {
    // vel is how quickly this pillar's gap will expand/contract to match newGapHeight
    
    if (this.gap.h > newGapHeight) {
      // shrink gap
      this.gap.y += vel;
      this.gap.h -= vel;
      
      this.top.h += vel;
      this.bottom.y -= vel;
      this.bottom.h += vel;
    }
    else if (this.gap.h < newGapHeight){
      // expand gap (or do nothing)
      this.gap.y -= vel;
      this.gap.h += vel;
      
      this.top.h -= vel;
      this.bottom.y += vel;
      this.bottom.h -= vel;
    }
  } 
//  public void gapDist(float d, float duration) {
//    
//    float top_h_start = this.top.h;
//    float bottom_y_start = this.bottom.y;
//    float bottom_h_start = this.bottom.h;
//    
//    float gap = bottom_y_start - top_h_start;
//    float diff = abs(gap - d);
//    
//    float top_h_end;
//    float bottom_y_end;
//    float bottom_h_end;
//    
//    if (gap > d) {
//      // shrink gap
//      top_h_end = top_h_start + diff/2;
//      bottom_y_end = bottom_y_start - diff/2;
//      bottom_h_end = bottom_h_start + diff/2;
//    }
//    else {
//      top_h_end = top_h_start - diff/2;
//      bottom_y_end = bottom_y_start + diff/2;
//      bottom_h_end = bottom_h_start - diff/2;
//    }
//    
//    int th = transitionHandler.scheduleTransition(this.top, "h", top_h_start, top_h_end, 0, duration, "cubic");
//    int by = transitionHandler.scheduleTransition(this.bottom, "y", bottom_y_start, bottom_y_end, 0, duration, "cubic");
//    int bh = transitionHandler.scheduleTransition(this.bottom, "h", bottom_h_start, bottom_h_end, 0, duration, "cubic");
//      
//  }
//  
  public void movePillar(float d) {
    this.top.x -= d;
    this.gap.x -= d;
    this.bottom.x -= d;
  }
  
  public void draw() {
    //this.top.draw(0,0,255,200);
    //this.gap.draw(255,0,0,200);
    //this.bottom.draw(0,255,0,200);
    
    this.top.draw(100,100,100,255);
    this.gap.draw(0,0,0,0);
    this.bottom.draw(100,100,100,255);
    
    //int r = int(clamp(map(BPM, 70, 110, 230, 60), 60, 230));
    //this.top.draw(r,r,r,255);
    //this.bottom.draw(r,r,r,255);
  }
}




//////////////////////////////
// pillar building variables
//////////////////////////////
float stdDev = 100;
float padding = 50;

float ceiling = padding;
float floor = gameHeight - padding;

float gapPadding = 20;
float gapCeiling = ceiling + gapPadding;
float gapFloor = floor - gapPadding;


float minGapHeight = 120;
float maxGapHeight = 170;
float gapHeight = maxGapHeight;



float pillarWidth = 50;
float pillarStride = 150; // horizontal distance between pillars



int numPillars = 12;
ArrayList<Pillar> pillars = new ArrayList<Pillar>();

//////////////////////////////
// create pillar functions
//////////////////////////////
void buildPillars() {
  pillars = new ArrayList<Pillar>();
  
  float initial_x = gameWidth + pillarWidth + pillarStride;
  float initial_cy = gameHeight/2;
  Pillar initialPillar = createPillarAt(initial_x, initial_cy);
  pillars.add(initialPillar);
  
  Pillar previousPillar = initialPillar;
  
  for (int i=0; i<numPillars-1; i++) {
    Pillar p = createRNormPillar(previousPillar);
    pillars.add(p);
    previousPillar = p;
  }
}



Pillar createRNormPillar(Pillar previousPillar) {
  Body previousGap = previousPillar.gap;
  float previousGapCenter = previousGap.center.y;
  
  float center = (randomGaussian() * stdDev) + previousGapCenter;
  
  // use maxGapHeight instead of gapHeight because, when new pillars are being created while
  // the BPM is high (i.e. gaps are smaller), then this might cause the gaps to exceed the 
  // [gapCeiling, gapFloor] bounds if BPM goes back down (i.e. gaps grow) 
  center = clamp(center, gapCeiling + maxGapHeight/1.5, gapFloor - maxGapHeight/1.5);
  
  float x = previousGap.x + pillarWidth + pillarStride;
  float y = center - gapHeight/2;
  float w = pillarWidth;
  float h = gapHeight;
  Body gap = new Body(x, y, w, h);
  
  y = ceiling;
  h = gap.y - ceiling;
  Body top = new Body(x, y, w, h, 0, 0, 3, 3);
  
  y = gap.y + gap.h;
  h = floor - y;
  Body bottom = new Body(x, y, w, h, 3, 3, 0, 0);
  
  Pillar p = new Pillar(top, gap, bottom);
  
  return p;
}

Pillar createPillarAt(float x, float cy) {
  float y = cy - gapHeight/2;
  float w = pillarWidth;
  float h = gapHeight;
  Body gap = new Body(x, y, w, h);
  
  y = ceiling;
  h = gap.y - ceiling;
  Body top = new Body(x, y, w, h);
  
  y = gap.y + gap.h;
  h = floor - y;
  Body bottom = new Body(x, y, w, h);
  
  Pillar p = new Pillar(top, gap, bottom);
  
  return p;
}



void updateGapHeight() {
  gapHeight = getGapFromBPM();
}

float getGapFromBPM() {
  if (mapGapToHR) {
    if (smoothGap) {
      float mappedValue = map(BPM, 50, 140, maxGapHeight, minGapHeight); 
      return clamp(mappedValue, minGapHeight, maxGapHeight);
    }
    else {
      if (BPM < 60) return interpolate(maxGapHeight, minGapHeight, 0);
      else if (BPM >= 60 && BPM < 75) return interpolate(maxGapHeight, minGapHeight, 0.15);
      else if (BPM >= 75 && BPM < 90) return interpolate(maxGapHeight, minGapHeight, 0.3);
      else if (BPM >= 90 && BPM < 105) return interpolate(maxGapHeight, minGapHeight, 0.45);
      else if (BPM >= 105 && BPM < 120) return interpolate(maxGapHeight, minGapHeight, 0.6);
      else if (BPM >= 120 && BPM < 135) return interpolate(maxGapHeight, minGapHeight, 0.75);
      else return interpolate(maxGapHeight, minGapHeight, 1);
    }
  }
  else {
    return interpolate(maxGapHeight, minGapHeight, 0.3);
  }
}


void updatePillars() {
  // remove dead pillars
  removeDeadPillars();
  
  // add new pillars to replace dead ones
  addPillars();
  
  // move the pillars
  if (mapSpeedToHR) movePillars(clamp(map(BPM, 60, 130, minSpeed, maxSpeed), minSpeed, maxSpeed));
  else movePillars(3);
  
  // update pillars' gaps
  updatePillarGap();
  
  // draw pillars
  drawPillars();
}


void updatePillarGap() {
  for (Pillar p : pillars) {    
    p.updateGap(gapHeight, 0.2);
  }
}

void drawPillars(){
  for (int i=pillars.size()-1; i>=0; i--) {
    Pillar p = pillars.get(i);
    p.draw();
    
    // display pillar body heights (debugging)
    if (debugMode) {
      fill(200);
      int gh = int(p.gap.h);
      int th = int(p.top.h);
      int bh = int(p.bottom.h);
      text(gh, p.gap.x + p.gap.w/2, p.gap.y + 0.5 * p.gap.h);
      text(th, p.top.x + p.top.w/2, p.top.y + 0.5 * p.top.h);
      text(bh, p.bottom.x + p.bottom.w/2, p.bottom.y + 0.5 * p.bottom.h);
      //text(p.bottom.y - p.top.h, p.top.x, p.bottom.y + 0.5 * p.bottom.h);
    }
    
  }
}

void movePillars(float dx) {
  if (!playerHasCollided) {
    for (int i=pillars.size()-1; i>=0; i--) {
      pillars.get(i).movePillar(dx);
    }
  }
}


void removeDeadPillars() {
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
}

void addPillars() {
  // add new pillars
  int diff = numPillars - pillars.size();
  for (int i=0; i<diff; i++) {
    int indexOfLastItem = pillars.size() - 1;
    Pillar previousPillar = pillars.get(indexOfLastItem);

    Pillar p = createRNormPillar(previousPillar);
    pillars.add(p); 
  }  
}





void drawCeilingAndFloor() {
  fill(100);
  
  // ceiling
  rect(0, 0, gameWidth, padding);
  
  // floor
  rect(0, floor, gameWidth, padding);
}


