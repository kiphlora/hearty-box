
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
      int diff = Serial.list().length - numPorts;  // was serialPorts.length
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
