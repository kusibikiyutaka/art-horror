//アウトプットする動画のサイズ。BenQの解像度
//int w = 1920, h = 1080;

import processing.serial.*;
import processing.video.*;

Serial arduinoSerial;
Movie mv[]=new Movie[4];
int Playing_ID = -1;
int Serial_Val = -1;
static final int USE_PORT = 1;





void setup() {
  fullScreen(2);
  //size(1920, 1080);
  
  // draw serial list
  drawSerialList();
  
  // Serial connect
  // 櫛引のMacBookのシリアルポートは、　"/dev/cu.usbmodem14101"   Serial.list()[USE_PORT]
  arduinoSerial = new Serial(this, "/dev/cu.usbmodem14101", 115200);

  mv[0]=new Movie(this, "hono.mov");
  mv[1]=new Movie(this, "denki.mov");
  mv[2]=new Movie(this, "yami.mov");
  mv[3]=new Movie(this, "mizu.mov");
  
  Playing_ID = getRdmVideoIndex();
  playRandomMovie();
}



void draw() {
  background(0);
  
  //Serial_Val = arduinoSerial.read();
  
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
  return mv[Playing_ID].duration() - mv[Playing_ID].time() > 0.1;
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
  println(Serial_Val);
  delay(500);
}

void movieEvent(Movie m) {
  m.read();//動画更新
}
