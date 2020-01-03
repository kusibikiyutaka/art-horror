//アウトプットする動画のサイズ。BenQの解像度
//int w = 1920, h = 1080;

import processing.serial.*;
import processing.video.*;

Serial arduinoSerial;
Movie mv[]=new Movie[4];
int Playing_ID = -1;
int Serial_Val = -1;
static final int USE_PORT = 0;





void setup() {
  size(1920, 1080);
  
  // draw serial list
  drawSerialList();
  
  // Serial connect
  //  "/dev/cu.usbmodem14101"
  arduinoSerial = new Serial(this, Serial.list()[USE_PORT], 9600);

  mv[0]=new Movie(this, "hono.mp4");
  mv[1]=new Movie(this, "kaze.mp4");
  mv[2]=new Movie(this, "zimen.mp4");
  mv[3]=new Movie(this, "mizu.mp4");
  
  Playing_ID = getRdmVideoIndex();
  playRandomMovie();
}



void draw() {
  background(0);
  
  Serial_Val = arduinoSerial.read();
  
  if (Serial_Val == 1) {
    if (!isPlaying()) {
      playRandomMovie();
    }
    Serial_Val = -1;
  }
  
  if (isPlaying()) {
    image(mv[Playing_ID], 0, 0);
  }
}



void playRandomMovie() {
  mv[Playing_ID].stop();
  
  Playing_ID = getRdmVideoIndex();
  mv[Playing_ID].noLoop();
  mv[Playing_ID].jump(0);
  mv[Playing_ID].play();
  
  println("play >> " + Playing_ID);
}

boolean isPlaying() {
  return mv[Playing_ID].duration() - mv[Playing_ID].time() > 0;
}

int getRdmVideoIndex() {
  return int(random(mv.length));
}

void drawSerialList() {
  for (int i = 0; i < Serial.list().length; i++) {
    println(Serial.list()[i]);
  }
}

void serialEvent(Serial p) {
  Serial_Val = p.read();
}

void movieEvent(Movie m) {
  m.read();//動画更新
}
