import processing.serial.*;// シリアルライブラリを取り入れる
Serial Serial1;// Serial1というインスタンスを用意

import processing.video.*;//ビデオライブラリを取り入れる
//Movie mov_hono, mov_kaze, mov_zimen, mov_mizu;

Movie mv[]=new Movie[4]; //動画の入れ物を本数分作る
Movie playing;//再生中の動画入れ

//アウトプットする動画のサイズ。BenQの解像度
//int w = 1920, h = 1080;

void playRandomMovie() {//ランダムに動画を再生する

  int select=(int)random(0, mv.length); //一本選んで
  // println(select);
  playing=mv[select];//「再生中」に設定し
  playing.play();//再生開始
}

int value;

void serialEvent(Serial p) {
  //変数valueにシリアル通信で読み込んだ値を代入
  value = p.read();
  println(value);
}

void setup() {
  size(1920, 1080); 
  Serial1 = new Serial(this, "/dev/cu.usbmodem14101", 9600);  // シリアルポートの設定

  mv[0]=new Movie(this, "hono.mov");
  mv[1]=new Movie(this, "kaze.mov");
  mv[2]=new Movie(this, "zimen.mov");
  mv[3]=new Movie(this, "mizu.mp4");
}

void draw() {
  value = Serial1.read();
  if (value == 1) { 
    if (playing == null) {//再生中でなければ再生開始
      playRandomMovie();
    } else {
      if (playing.duration() == playing.time()) { //一本分再生終了
        //image(playing, 0, 0, 1920, 1080); 
        playing = null;
        playRandomMovie();//次をランダム再生
      }
    }
  }
  background(0);
}


void movieEvent(Movie m) {
  m.read();//動画更新
}
