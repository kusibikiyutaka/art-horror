// シリアルライブラリを取り入れる
import processing.serial.*;
// Serial1というインスタンスを用意
Serial Serial1;

import processing.video.*;
Movie mov_hono, mov_kaze, mov_zimen, mov_mizu;

Movie mv[]=new Movie[4]; //動画の入れ物を本数分作る
Movie playing;//再生中の動画入れ

//アウトプットする動画のサイズ
int w = 1080, h = 720;

void playRandomMovie() {//ランダムに動画を再生する
  if (playing!=null) {//再生中なら止める
    playing.stop();
  }
  int select=(int)random(0, mv.length); //一本選んで
  // println(select);
  playing=mv[select];//「再生中」に設定し
  playing.play();//再生開始
}


void setup() {
  size(w,h); 
  // シリアルポートの設定
  serial1 = new Serial(this, "/dev/tty.usbmodem1411", 9600);

  mv[0]=new Movie(this, "hono");
  mv[1]=new Movie(this, "kaze");
  mv[2]=new Movie(this, "zimen");
  mv[3]=new Movie(this, "mizu");
}

void draw() {
  if (serial1 == true) { 
    if (playing == null) {//再生中でなければ再生開始
      playRandomMovie();
    }
  } else {
    if (playing != null) {// 再生中なら再生終了
      playing.stop();
      playing=null;
    }
  }
  if (playing!=null) { //再生中なら描画処理
    image(playing, 0, 0, width, height);
    if (playing.duration()-playing.time()<0.01) { //一本分再生終了?
      playRandomMovie();//次をランダム再生
    }
  } else {
    background(0);
  }
  //状況表示
  fill(0);
  rect(0, 0, width, 20);
  fill(255, 0, 0);
  text(dist, width/2, 10);
}



void movieEvent(Movie m) {
  m.read();//動画更新
}
