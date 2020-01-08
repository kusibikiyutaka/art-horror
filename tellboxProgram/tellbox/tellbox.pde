
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

   Playing_ID = 0;
   playMovie();
         
   audio = new Minim(this);  
   error_audio = audio.loadFile("error.mp3");
   success_audio = audio.loadFile("success.mp3");
   
   frameRate(60);
}

void draw(){
  background(0,0,0);
  //ゼロ映像が再生されてて、エンターキーを押したら、playMovie
  if(permitPlaying && !isPlaying()){
      playMovie();
    }     
  permitPlaying = false;
 
  
  if(isPlaying()){
    image(mv[Playing_ID], 0, 0);
    sendOscIndex();
    delay(10);
  }else if(!isPlaying()){
    image(mv[0], 0, 0);
    sendOscIndex();
    delay(10);
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
     successSound();
     Playing_ID = 1;  //水の映像

    }else if(pixie < 30 && pixie >= 15){
     successSound();
     Playing_ID = 2;  //火の映像
     
    }else if(pixie < 15 && pixie > 0){
     successSound();
     Playing_ID = 3;  //風の映像
     
    }else if(pixie == 0){
     successSound();
     Playing_ID = 4;  //地の映像
     
    }else{
     errorSound();
     Playing_ID = 0;  //ゼロ映像
  }  
  
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
  if(Playing_ID == 0){
    mv[Playing_ID].loop();
  }else{
    mv[Playing_ID].noLoop();
  }
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
    //ゼロ映像時
  if(Playing_ID == 0){
   OscMessage msg = new OscMessage("/sequence");
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(255);
   oscP5.send(msg, netAdd);
   println("zero movie!!!");
   
   //青:水
  }else if(Playing_ID == 1){
   OscMessage msg = new OscMessage("/sequence");
   msg.add(255);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   oscP5.send(msg, netAdd);
   
   //赤:火
  }else if(Playing_ID == 2){
   OscMessage msg = new OscMessage("/sequence");
   msg.add(0);
   msg.add(255);
   msg.add(0);
   msg.add(0);
   msg.add(0);
   oscP5.send(msg, netAdd);
   
   //緑:風
  }else if(Playing_ID == 3){
   OscMessage msg = new OscMessage("/sequence");
   msg.add(0);
   msg.add(0);
   msg.add(255);
   msg.add(0);
   msg.add(0);
   oscP5.send(msg, netAdd);
    
    //白:地
  }else if(Playing_ID == 4){
   OscMessage msg = new OscMessage("/sequence");
   msg.add(0);
   msg.add(0);
   msg.add(0);
   msg.add(255);
   msg.add(0);
   oscP5.send(msg, netAdd);
  }
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
