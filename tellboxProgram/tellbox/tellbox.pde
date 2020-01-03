
/**
 * PROCESSING JSON load
 * @auther MSLABO
 * @version 1.0 2019/01
 
 getrainみたいな、便利関数を作ってあげて、メインの処理をわかりやすくする
 str関数...floatとかを文字列表現に変える。
 電話ボックスのコード。
   [jsonデータ、キーボードの入力、動画再生]
 **/

//音のライブラリ
import ddf.minim.*;
Minim audio;
AudioPlayer audio_player;
 
//OSC通信のライブラリ
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress netAdd;

//Resolumeへのライブラリ
import spout.*;
Spout spout;
//import codeanticode.syphon.*;
//SyphonServer syphon;

//動画再生のライブラリ
import processing.video.*;
Movie mov_disa, mov_sto, mov_clo, mov_sun;
//Movie mov_hono, mov_kaze, mov_zimen, mov_mizu;


JSONObject  jobject;
//import processing.serial.*;
//Serial serial;

String keys = "";

float alpha;
boolean fadeMode;

//disaster, storm, cloudy, sunny
boolean disa, sto, clo, sun;
//boolean hono, kaze, zimen, mizu;

boolean disa_play, sto_play, clo_play, sun_play;
//boolean hono_play, kaze_play, zimen_play, mizu_play;

//アウトプットする動画のサイズ
float w = 4080, h = 768;

void setup(){
  //serial = new Serial(this, "/dev/cu.usbmodem14101", 9600);
  //serial.bufferUntil(10);
  
  //spout = new Spout(this);
  //spout.createSender("Spout!!!");
  //syphon = new SyphonServer(this, "Syphon!!!");
  
   jobject = loadJSONObject("data.json");
   
   oscP5 = new OscP5(this, 10000);
   //一台のPCで完結するIPアドレス。自身のIPアドレスを参照。
   netAdd = new NetAddress("127.0.0.1", 10000);
   
  //パナソニック(1920*1080)3台分のプロジェクションサイズ。
  //キャノン(1920*1200)3台分のプロジェクションサイズ。
  //キャノン2台分のプロジェクションサイズ
   //size(3840, 1200);  
   size(4080, 768, P2D);  //Spout、Syphon
   //mov_disa = new Movie(this, "disaster.mp4");
   //mov_sto = new Movie(this, "storm.avi");
   //mov_clo = new Movie(this, "cloudy.avi");
   //mov_sun = new Movie(this, "sunny.avi");
   mov_disa = new Movie(this, "disaster.mp4");
   mov_sto = new Movie(this, "storm.mp4");
   mov_clo = new Movie(this, "cloudy.mp4");
   mov_sun = new Movie(this, "sunny.mp4");
   
  audio = new Minim(this);  
  audio_player = audio.loadFile("利用する音データの名前.mp3");
  movie.play();
   
   alpha = 0;
   fadeMode = false;
   disa = false;
   sto = false;
   clo = false;
   sun = false;
   disa_play = false;
   sto_play = false;
   clo_play= false;
   sun_play = false;
   frameRate(60);
}

void draw(){
  background(0,0,0);
  
  if(fadeMode == true){
  fadeIn();
  }else if(fadeMode == false){
  fadeOut();
  }
  
  if(disa_play == true){
  image(mov_disa, 0, 0, w, h);
  image(mov_sto, 0, 0, 0, 0);
  image(mov_clo, 0, 0, 0, 0);
  image(mov_sun, 0, 0, 0, 0);

  }else if(sto_play == true){
  image(mov_disa, 0, 0, 0, 0);
  image(mov_sto, 0, 0, w, h);
  image(mov_clo, 0, 0, 0, 0);
  image(mov_sun, 0, 0, 0, 0);

  }else if(clo_play == true){
  image(mov_disa, 0, 0, 0, 0);
  image(mov_sto, 0, 0, 0, 0);
  image(mov_clo, 0, 0, w, h);
  image(mov_sun, 0, 0, 0, 0);

  }else if(sun_play == true){
  image(mov_disa, 0, 0, 0, 0);
  image(mov_sto, 0, 0, 0, 0);
  image(mov_clo, 0, 0, 0, 0);
  image(mov_sun, 0, 0, w, h);

  //}else{
  //  println("NO MOVIE...");
  
  }
  
  //フェードに使う手前の画面
  colorMode(RGB,256);
  noStroke();
  fill(0,0,0,alpha);
  rect(0, 0, 5760, 1080);
  
  //spout.sendTexture();
  //syphon.sendScreen();  
}
  
  
// jsonデータから、降水量を参照。return 0 > xの場合、値なし。
float getRain(String date) {
  JSONArray jarray = jobject.getJSONArray("NAME");
  JSONObject rainjobject = jobject.getJSONObject("RAIN");
  float rain = -1.0f;
  
  for( int i = 0; i < jarray.size(); i++ ){
    String key = jarray.getString(i);

    if (key.equals(date)) {
      rain = rainjobject.getFloat(key); 
    }
  }  
  
  //降水量のしきい値[1:災害 2:大荒れ 3:曇り 4:晴れ 0:それ以外(エラー)]
    if(rain >= 30){
      fadeMode = true;
   sto = false;
   clo = false;
   sun = false;
      disa = true;
        //serial.write('1');
      println("Serial = 1 , rain >= 30, DISASTER!");
    }else if(rain < 30 && rain >= 15){
      fadeMode = true;
   disa = false;
   clo = false;
   sun = false;
       sto = true;
        //serial.write('2');
      println("Serial = 2, 30 > rain >= 15, STORM!");  
    }else if(rain < 15 && rain > 0){
      fadeMode = true;
   disa = false;
   sto = false;
   sun = false;
         clo = true;
       //serial.write('3');
      println("Serial = 3, 15 > rain > 0, CLOUDY!"); 
     }else if(rain == 0){
      fadeMode = true;
   disa = false;
   sto = false;
   clo = false;
         sun = true;
        //serial.write('4');
      println("Serial = 4, rain = 0, SUNNY!");
    }else{
        //serial.write('0');
      println("Serial = 0, rain error!");
  }  
  return rain;   
}



//黒の画像がフェードインしてくる
void fadeIn(){
  alpha += 6;
  //println("Movie fadeOut now...");
  if(fadeMode == true && alpha > 255){
  alpha = 255;
  changeMovie();
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


//真っ黒の瞬間に呼ばれる関数。動画を切り替える。照明へのOCSを投げる。
void changeMovie(){
  if(disa == true){
    mov_disa.loop();
    println("disaster!!!!change!!!!!");
     sto_play = false;
     clo_play= false;
     sun_play = false;
   disa_play = true;
   OscMessage msg = new OscMessage("/sequence");
   msg.add(255,0,0,0);
   oscP5.send(msg, netAdd);
  
  }else if(sto == true){
    mov_sto.loop();
    println("storrrrrrrrm!!!! change");
     disa_play = false;
     clo_play= false;
     sun_play = false;
    sto_play = true;
   OscMessage msg = new OscMessage("/sequence");
   msg.add(0,255,0,0);
   oscP5.send(msg, netAdd);

  }else if(clo == true){
    mov_clo.loop();
    println("cloudyyyyyyy...");
     disa_play = false;
     sto_play = false;
     sun_play = false;
   clo_play= true;
   OscMessage msg = new OscMessage("/sequence");
   msg.add(0,0,255,0);
   oscP5.send(msg, netAdd);
   
  }else if(sun == true){
    mov_sun.loop();
    println("SUN!!!");
     disa_play = false;
     sto_play = false;
     clo_play= false;
   sun_play = true;
   OscMessage msg = new OscMessage("/sequence");
   msg.add(0,0,0,255);
   oscP5.send(msg, netAdd);

  }else{
           println("NO MOVIE.......");
  }
}


  //キーボードで数値入力
void keyPressed(){
  switch( key ){
    case ENTER:
      println( "ENTER!" );
      //text(str(getRain(keys)), 0, 0, width, height);
      println(getRain(keys));
    break;
     //case BACKSPACE:
       case '-':
       println( "delete..." );
       keys = "";
     break;
     default:
      keys += key;
     break;
          //case RETURN:
          //  println( "ENTERキーが押された2" );
          //  text(str(getRain(keys)), 0, 0, width, height);
          //  break;
  }
  
  pushSound();
  
}


void movieEvent(Movie m) {
 //カレント位置の動画を取得
 m.read();
}  

void pushSound(){
  audio_player.rewind() ;
  audio_player.play();
  println("push!");
  delay(50);
}



