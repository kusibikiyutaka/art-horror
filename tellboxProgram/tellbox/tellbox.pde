
/**
 * PROCESSING JSON load
 * @auther MSLABO
 * @version 1.0 2019/01
 
 getrainみたいな、便利関数を作ってあげて、メインの処理をわかりやすくする
 str関数...floatとかを文字列表現に変える。
 電話ボックスのコード。
   [jsonデータ、テンキー入力、動画の切り替え、ムービングライトのOSC通信、プッシュ音]
 **/

//音のライブラリ
import ddf.minim.*;

//ムービングライトへのOSC通信ライブラリ
import oscP5.*;
import netP5.*;

//Resolumeへの通信ライブラリ(Windows:spout  OSX:syphon)
import spout.*;
//import codeanticode.syphon.*;

//動画再生のライブラリ
import processing.video.*;

//シリアル通信のライブラリ
//import processing.serial.*;


Minim audio;
AudioPlayer push_audio, error_audio, success_audio;
OscP5 oscP5;
NetAddress netAdd;
Spout spout;
//SyphonServer syphon;
//Serial serial;
Movie mv[]=new Movie[4];
int Playing_ID = -1;
static final int USE_PORT = 0;
boolean permitPlaying;
//OscMessage osc[]=new OscMessage[4];


//日付データ
JSONObject  jobject;
String keys = "";

//アウトプットする動画のサイズ
float w = 4080, h = 768;

void setup(){
  //serial = new Serial(this, Serial.list()[USE_PORT], 9600);
  //serial.bufferUntil(10);
  
   spout = new Spout(this);
   spout.createSender("Spout!!!");
  //syphon = new SyphonServer(this, "Syphon!!!");
  
   jobject = loadJSONObject("data.json");
   
   oscP5 = new OscP5(this, 10000);
   //一台のPCで完結するIPアドレス。自身のIPアドレスを参照。
   netAdd = new NetAddress("127.0.0.1", 10000);
   
  //パナソニック(1920*1080)、キャノン(1920*1200)
  //4080(1360*3)*768
   size(4080, 768, P2D); 
   mv[0]=new Movie(this, "hono.mp4");
   mv[1]=new Movie(this, "kaze.mp4");
   mv[2]=new Movie(this, "zimen.mp4");
   mv[3]=new Movie(this, "mizu.mp4");
   
   Playing_ID = 0;
   playMovie();
   
   //osc[0]=new OscMessage();
      
   audio = new Minim(this);  
   push_audio = audio.loadFile("test.mp3");
   //error_audio = audio.loadFile("error.mp3");
   //success_audio = audio.loadFile("success.mp3");

   frameRate(60);
   
   permitPlaying = false;
   
}

void draw(){
  background(0,0,0);
  if(permitPlaying){
    if(!isPlaying()){
      playMovie();
    }
    permitPlaying = false;
  }
    if(isPlaying()){
  image(mv[Playing_ID], 0, 0);
    }else{
      sendOscIndex();
    }
 
  //spout.sendTexture();
  //syphon.sendScreen();  
}

  
  
/*ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー*/
// jsonデータを参照。return 0 > xの場合、値なし。
float getDate(String date) {
  JSONArray jarray = jobject.getJSONArray("NAME");
  JSONObject datejobject = jobject.getJSONObject("DATE");
  float pixie = -1.0f;
  
  for( int i = 0; i < jarray.size(); i++ ){
    String key = jarray.getString(i);

    if (key.equals(date)) {
      pixie = datejobject.getFloat(key); 
    }
  }  
  
//壁面動画とムービングライトのしきい値
    if(pixie >= 30){
     Playing_ID = 0;
     OscMessage msg = new OscMessage("/sequence");
   msg.add(255);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(0);
     oscP5.send(msg, netAdd);
     successSound();
     println("mv >>> "+ Playing_ID);
     
    }else if(pixie < 30 && pixie >= 15){
     Playing_ID = 1;
     OscMessage msg = new OscMessage("/sequence");
   msg.add(0);
   msg.add(255);
   msg.add(0);
   msg.add(0);
   msg.add(0);
     oscP5.send(msg, netAdd);
     successSound();
     println("mv >>> "+ Playing_ID);
     
    }else if(pixie < 15 && pixie > 0){
     Playing_ID = 2;
     OscMessage msg = new OscMessage("/sequence");
   msg.add(0);
   msg.add(0);
   msg.add(255);
   msg.add(0);
   msg.add(0);
     oscP5.send(msg, netAdd);
     successSound();
     println("mv >>> "+ Playing_ID);
     
    }else if(pixie == 0){
     Playing_ID = 3;
     OscMessage msg = new OscMessage("/sequence");
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(255);
   msg.add(0);
     oscP5.send(msg, netAdd);
     successSound();
     println("mv >>> "+ Playing_ID);
     
    }else{
     OscMessage msg = new OscMessage("/sequence");
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(0);
     oscP5.send(msg, netAdd);
     errorSound();
     println("No Movie......");
  }  
  return pixie;   
}
/*ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー*/



  //テンキーで数値入力
void keyPressed(){
  switch( key ){
    case ENTER:
    //case RETURN:
      println( "ENTER!" );
      permitPlaying = true;
      //text(str(getRain(keys)), 0, 0, width, height);
      println(getDate(keys));
    break;
     //case BACKSPACE:
       case '-':
       println( "delete..." );
       keys = "";
     break;
     default:
      keys += key;
     break;
  }
  
  pushSound();
  
}

void playMovie(){
  mv[Playing_ID].stop();
  mv[Playing_ID].noLoop();
  mv[Playing_ID].jump(0);
  mv[Playing_ID].play();
}


boolean isPlaying() {
  return mv[Playing_ID].duration() - mv[Playing_ID].time() > 0.01;
}

void sendOscIndex(){
   OscMessage msg = new OscMessage("/sequence");
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(255);
   oscP5.send(msg, netAdd);
   println("send Osc Index !!!");
}

void movieEvent(Movie m) {
 //カレント位置の動画を取得
 m.read();
}  

void pushSound(){
  push_audio.rewind() ;
  push_audio.play();
  println("push!");
  delay(50);
}

void errorSound(){
  error_audio.rewind() ;
  error_audio.play();
  println("error......");
  delay(50);
}

void successSound(){
  success_audio.rewind() ;
  success_audio.play();
  println("success!!!!!!");
  delay(50);
}
