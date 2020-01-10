/**
 * PROCESSING JSON load
 * @auther MSLABO
 * @version 1.0 2019/01
 
 tellbox code
   [json data、keypad input、switch Video、OSC for Liighting、Push sound]
 **/

//Sound Library
import ddf.minim.*;

//OSC Library
import oscP5.*;
import netP5.*;

//Spout Library fot Resolume(Windows:spout  OSX:syphon)
import spout.*;
//import codeanticode.syphon.*;

//Movie Library
import processing.video.*;

Minim audio;
AudioPlayer error_audio, success_audio, push_audio;
OscP5 oscP5;
NetAddress netAdd;
Spout spout;
//SyphonServer syphon;
Movie mv[] = new Movie[5];
Movie zero;
int Playing_ID = -1;
static final int USE_PORT = 0;

boolean elementPlayingF = false;
boolean zeroPlayF = true;
boolean errorF = false;

float alpha;
boolean fadeMode;

//date data
JSONObject jobject;
String keys = "";

//size of mv
float w = 4080, h = 768;

void setup() {
  spout = new Spout(this);
  spout.createSender("Spout!!!");
  //syphon = new SyphonServer(this, "Syphon!!!");

  jobject = loadJSONObject("data.json");

  oscP5 = new OscP5(this, 10000);
  //IPAdress (All own PC Adress is 127.0.0.1)
  netAdd = new NetAddress("127.0.0.1", 10000);

  //Panasonic(1920*1080)、Canon(1920*1200)
  //4080(1360*3)*768
  size(4080, 768, P2D);
  
  //size(1280, 768, P2D);
  zero = new Movie(this, "zero.mp4");
  mv[0] = new Movie(this, "mizu.mp4");
  mv[1] = new Movie(this, "hono.mp4");
  mv[2] = new Movie(this, "kaze.mp4");
  mv[3] = new Movie(this, "zimen.mp4");

  fadeMode = false;
  Playing_ID = 0;
  playZeroMovie();

  audio = new Minim(this);
  error_audio = audio.loadFile("error.mp3");
  success_audio = audio.loadFile("success.mp3");

  frameRate(60);
  
  
}

void draw() {
  background(0, 0, 0);

  if (fadeMode) {
   fadeIn();
  } else {
   fadeOut();
  }
  
  if (isElementPlaying()) {
    // draw element
    image(mv[Playing_ID], 0, 0);
  } else {
    elementPlayingF = false;
  }

  if (zeroPlayF && !elementPlayingF) {
    // draw zero
    image(zero, 0, 0);
  } else if (!zeroPlayF && !elementPlayingF) {
    // play zero kick
    playZeroMovie();
  }

  sendOscIndex();

  //Using the rect for FadeMode
  colorMode(RGB, 256);
  noStroke();
  fill(0, 0, 0, alpha);
  rect(0, 0, 5760, 1080);

  spout.sendTexture();
  //syphon.sendScreen();
}


/*ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー*/
// read json data. if return 0 > x, nothing value(float pixie).
float getDate(String date) {
  JSONArray jarray = jobject.getJSONArray("NAME");
  JSONObject datejobject = jobject.getJSONObject("DATE");
  float pixie = -1.0f;

  for (int i = 0; i < jarray.size(); i++) {
   String key = jarray.getString(i);

   if (key.equals(date)) {
    pixie = datejobject.getFloat(key);
   }
  }
  println("pixie >> " + pixie);
  errorF = false;

  //Threshold　of mv and Osc
  //if (pixie >= 30) {
  // successSound();
  // Playing_ID = 0; //water

  //} else if (pixie < 30 && pixie >= 15) {
  // successSound();
  // Playing_ID = 1; //fire

  //} else if (pixie < 15 && pixie > 0) {
  // successSound();
  // Playing_ID = 2; //wind

  //} else if (pixie == 0) {
  // successSound();
  // Playing_ID = 3; //ground
  
  //Threshold　of mv and Osc
  if(pixie == 0){
   successSound();
   Playing_ID = 1;  //water

  }else if(pixie < 20 && pixie >= 10){
   successSound();
   Playing_ID = 2;  //fire
   
  }else if(pixie < 10 && pixie > 0){
   successSound();
   Playing_ID = 3;  //wind
   
  }else if(pixie >= 20){
   successSound();
   Playing_ID = 4;  //ground

  } else {
   errorSound();
   //Playing_ID = 0; //zero mv
   elementPlayingF = false;
   errorF = true;
   playZeroMovie();
  }
  fadeMode = true;
  println("mv >>> " + Playing_ID);

  return pixie;
}
/*ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー*/



//presse number also enter
void keyPressed() {
 switch (key) {
   case ENTER:
    //case RETURN:
    println("ENTER!");
    elementPlayingF = true;
    //text(str(getRain(keys)), 0, 0, width, height);
    println(getDate(keys));
    if (!errorF) {
      playElementMovie();
      stopZeroMovie();
    }
    keys = "";
    break;
    //case BACKSPACE:
   case '-':
    println("delete...");
    keys = "";
    break;
   default:
    keys += key;
    break;
  }

  pushSound();

}

//if zero mv >>> loop ,else >>> noLoop
void playElementMovie() {
  mv[Playing_ID].stop();
  mv[Playing_ID].noLoop();
  mv[Playing_ID].jump(0);
  mv[Playing_ID].play();
  println("play mov >> " + Playing_ID);
}

boolean isElementPlaying() {
  return (mv[Playing_ID].duration()*.98 - mv[Playing_ID].time()) > 0;
}

void stopZeroMovie() {
  zero.stop();
  zeroPlayF = false;
  println("stop zero mov");
}

void playZeroMovie() {
  //zero.loop();
  
  zero.jump(0);
  //zero.play();
  zero.loop();
  zeroPlayF = true;
  println("play zero mov");
}

void sendOscIndex() {
  OscMessage msg = new OscMessage("/sequence");
  //zero mv
  if (zeroPlayF) {
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(255);
  }

  //zero mv
  //if (Playing_ID == 0) {
  // msg.add(0);
  // msg.add(0);
  // msg.add(0);
  // msg.add(0);
  // msg.add(255);

   //blue:water
  if (Playing_ID == 0) {
   msg.add(255);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(0);

   //red:fire
  } else if (Playing_ID == 1) {
   msg.add(0);
   msg.add(255);
   msg.add(0);
   msg.add(0);
   msg.add(0);

   //green:wind
  } else if (Playing_ID == 2) {
   msg.add(0);
   msg.add(0);
   msg.add(255);
   msg.add(0);
   msg.add(0);

   //white:ground
  } else if (Playing_ID == 3) {
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(255);
   msg.add(0);
  }
  oscP5.send(msg, netAdd);
  //println(Playing_ID + " 's Movie");
  delay(10);
}

void movieEvent(Movie m) {
  m.read();
}

void pushSound() {
  push_audio = audio.loadFile(int(random(0, 9)) + ".mp3");
  push_audio.rewind();
  push_audio.play();
  println("push!");
  delay(10);
}

void errorSound() {
  error_audio.rewind();
  error_audio.play();
  println("error......");
  delay(10);
}

void successSound() {
  success_audio.rewind();
  success_audio.play();
  println("success!!!!!!");
  delay(10);
}


//fadeIn rect
void fadeIn() {
  alpha += 6;
  //println("Movie fadeOut now...");
  if (fadeMode == true && alpha > 255) {
   alpha = 255;
   fadeMode = false;
   //println("START fadeOut");
  }
}

//fadeOut rect
void fadeOut() {
  //println("Movie fadeIn now...");
  alpha -= 6;
  if (alpha < 0) {
   alpha = 0;
  }
}
