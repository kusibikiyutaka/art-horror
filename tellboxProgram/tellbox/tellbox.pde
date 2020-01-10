
/**
 * PROCESSING JSON load
 * @auther MSLABO
 * @version 1.0 2019/01
 
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

Minim audio;
AudioPlayer error_audio, success_audio, push_audio;
OscP5 oscP5;
NetAddress netAdd;
//Spout spout;
//SyphonServer syphon;
Movie mv[]=new Movie[5];
int Playing_ID = -1;
static final int USE_PORT = 0;
boolean permitPlaying;

float alpha;
boolean fadeMode;

//日付データ
JSONObject  jobject;
String keys = "";

//アウトプットする動画のサイズ
float w = 4080, h = 768;

void setup(){
   //spout = new Spout(this);
   //spout.createSender("Spout!!!");
  //syphon = new SyphonServer(this, "Syphon!!!");
  
   jobject = loadJSONObject("data.json");
   
   oscP5 = new OscP5(this, 10000);
   //一台のPCで完結するIPアドレス。自身のIPアドレスを参照。
   netAdd = new NetAddress("127.0.0.1", 10000);
   
  //パナソニック(1920*1080)、キャノン(1920*1200)
  //4080(1360*3)*768
   size(4080, 768, P2D); 
   mv[0]=new Movie(this, "zero.mp4");
   mv[1]=new Movie(this, "mizu.mp4");
   mv[2]=new Movie(this, "hono.mp4");
   mv[3]=new Movie(this, "kaze.mp4");
   mv[4]=new Movie(this, "zimen.mp4");
  
   fadeMode = false;
   Playing_ID = 0;
   playMovie();
         
   audio = new Minim(this);  
   error_audio = audio.loadFile("error.mp3");
   success_audio = audio.loadFile("success.mp3");
   
   frameRate(60);
}

void draw(){
  background(0,0,0);
  
  if(fadeMode == true){
    fadeIn();
  }else if(fadeMode == false){
    fadeOut();
  }
  
  //ゼロ映像が再生されてて、エンターキーを押したら、playMovie
  if(permitPlaying){
      playMovie();
    }     
  permitPlaying = false;
  
  if(isPlaying()){
    image(mv[Playing_ID], 0, 0);
    sendOscIndex();
    delay(10);
    
  }else if(!isPlaying()){
    permitPlaying = true;
    Playing_ID = 0;
    sendOscIndex();
    delay(10);
  }
  
  //フェードに使う手前の画面
  colorMode(RGB,256);
  noStroke();
  fill(0,0,0,alpha);
  rect(0, 0, 5760, 1080);
    
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
    if(pixie == 0){
     successSound();
     Playing_ID = 1;  //水の映像

    }else if(pixie < 20 && pixie >= 10){
     successSound();
     Playing_ID = 2;  //火の映像
     
    }else if(pixie < 10 && pixie > 0){
     successSound();
     Playing_ID = 3;  //風の映像
     
    }else if(pixie >= 20){
     successSound();
     Playing_ID = 4;  //地の映像
     
    }else{
     errorSound();
     Playing_ID = 0;  //ゼロ映像
  }  
  fadeMode = true;
  println("mv >>> "+ Playing_ID);

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

//ゼロ映像ならループ、それ以外は一度だけ再生
void playMovie(){
  mv[Playing_ID].stop();
  mv[Playing_ID].noLoop();
  mv[Playing_ID].jump(0);
  mv[Playing_ID].play();
}

boolean isPlaying() {
  return mv[Playing_ID].duration() - mv[Playing_ID].time() > 0.01;
}

//boolean notPlaying() {
//  return mv[Playing_ID].duration() - mv[Playing_ID].time() == 0;
//}



void sendOscIndex(){
  OscMessage msg = new OscMessage("/sequence");
  
    //ゼロ映像時
  if(Playing_ID == 0){
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(255);
   
   //青:水
  }else if(Playing_ID == 1){
   msg.add(255);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   
   //赤:火
  }else if(Playing_ID == 2){
   msg.add(0);
   msg.add(255);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   
   //緑:風
  }else if(Playing_ID == 3){
   msg.add(0);
   msg.add(0);
   msg.add(255);
   msg.add(0);
   msg.add(0);
    
    //白:地
  }else if(Playing_ID == 4){
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(255);
   msg.add(0);
  }
   oscP5.send(msg, netAdd);
   println(Playing_ID + " 's Movie");
}

void movieEvent(Movie m) {
 //カレント位置の動画を取得
 m.read();
}  

void pushSound(){
  push_audio = audio.loadFile(int(random(0,9))+".mp3");
  push_audio.rewind();
  push_audio.play();
  println("push!");
  delay(10);
}

void errorSound(){
  error_audio.rewind();
  error_audio.play();
  println("error......");
  delay(10);
}

void successSound(){
  success_audio.rewind();
  success_audio.play();
  println("success!!!!!!");
  delay(10);
}


//黒の画像がフェードインしてくる
void fadeIn(){
  alpha += 6;
  //println("Movie fadeOut now...");
  if(fadeMode == true && alpha > 255){
  alpha = 255;
  fadeMode = false;
  //println("START fadeOut");
  }
}

//黒の画像がフェードアウトしてくる
void fadeOut(){
  //println("Movie fadeIn now...");
  alpha -= 6;
  if(alpha < 0){
  alpha = 0;
  }
}
