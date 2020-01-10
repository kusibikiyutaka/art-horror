#include<Wire.h>
  // BMX055　加速度センサのI2Cアドレス
#define Addr_Accl 0x19  // (JP1,JP2,JP3 = Openの時)

//しきい値
#define min_threshold -18
#define max_threshold 8.7

// センサーの値を保存するグローバル関数
float xAccl = 0.00;
float yAccl = 0.00;
float zAccl = 0.00;
    
    /* 加速度センサの値の構造体 */
    struct Coordinate {
      long cx;
      long cy;
      long cz;
    };

    /* 角度の構造体 */
    struct Angle {
      int ax;
      int ay;
      int az;
    };
    

void setup() {
   // Wire(Arduino-I2C)の初期化
    Wire.begin();
    // デバック用シリアル通信
    Serial.begin(9600);
    //BMX055 初期化
    BMX055_Init();
    delay(300);
}

void loop() {
//  Serial.println("--------------------------------------");

   Coordinate c = getCoordinate();
   
  //9軸ジャイロのシリアルモニタから、最大値、最小値
    //X
    //Accl= -10.34,-0.04,-0.0
    //Accl= 9.66,0.21,-0.03
    //
    //Y
    //Accl= -1.02,-10.26,-0.30
    //Accl= -0.20,10.04,-0.87
    //
    //Z
    //Accl= -0.25,0.03,9.68
    //Accl= -1.06,1.19,-10.52
    
      Angle a = angleCalculation(c);
//      showAngle(a);

      //BMX055 加速度の読み取り
      BMX055_Accl();
      delay(10);
      serialSendValue(c.cz);
      delay(10);
}

/**
 * 加速度センサーの値を取得する関数
 */
Coordinate getCoordinate() {
  Coordinate c;
  long x = 0, y = 0, z = 0;

  // 各データを100回読込んで平均化する
  for (int i = 0; i < 100; i++) {
    x = x + xAccl;  // Ｘ軸を読込む
    y = y + yAccl;  // Ｙ軸を読込む
    z = z + zAccl;  // Ｚ軸を読込む
  }
  c.cx = x / 100;
  c.cy = y / 100;
  c.cz = z / 100;
  return c;
}

/**
 * センサの値から各座標の角度を計算する関数
 */
Angle angleCalculation(Coordinate c){
   // BMX0559軸ジャイロ、シリアルモニタより、最大値、最小値
  float MAX_X = 9.66, MAX_Y = 10.04, MAX_Z = 9.68 ;
  float MIN_X = -10.34, MIN_Y = -10.26, MIN_Z = -10.52;

  // 各座標の1度あたりの角度を計算
  float oneAngleX = (MAX_X - MIN_X) / 180.000;
  float oneAngleY = (MAX_Y - MIN_Y) / 180.000;
  float oneAngleZ = (MAX_Z - MIN_Z) / 180.000;

  // 各座標の角度を計算
  Angle a;
  a.ax = (c.cx - MIN_X) / oneAngleX - 90;
  a.ay = (c.cy - MIN_Y) / oneAngleY - 90;
  a.az = (c.cz - MIN_Z) / oneAngleZ - 90;
  return a;
}
    
/** 
 * 角度を表示する関数
 */
void showAngle(Angle a) {
//  Serial.print(a.ax);
//  Serial.print(",");
//  Serial.print(a.ay);
//  Serial.print(",");
//  Serial.println(a.az);
}
    
/**
 * 加速度センサーの値を表示する関数
 */
void showCoordinate(Coordinate c) {
//  Serial.print("x:");
//  Serial.print(c.cx);
//  Serial.print(" y:");
//  Serial.print(c.cy);
//  Serial.print(" z:");
//  Serial.println(c.cz);

}

void serialSendValue(long val) {
//  Serial.println(val);
//  return;
    if (val <= min_threshold) {
      Serial.write(1);
      //Serial.print("ax Send Serial 1 !!!");
      delay(10);
    }
}

void BMX055_Init()
{
  //------------------------------------------------------------//
  Wire.beginTransmission(Addr_Accl);
  Wire.write(0x0F); // Select PMU_Range register
  Wire.write(0x03);   // Range = +/- 2g
  Wire.endTransmission();
  delay(100);
 //------------------------------------------------------------//
  Wire.beginTransmission(Addr_Accl);
  Wire.write(0x10);  // Select PMU_BW register
  Wire.write(0x08);  // Bandwidth = 7.81 Hz
  Wire.endTransmission();
  delay(100);
  //------------------------------------------------------------//
  Wire.beginTransmission(Addr_Accl);
  Wire.write(0x11);  // Select PMU_LPW register
  Wire.write(0x00);  // Normal mode, Sleep duration = 0.5ms
  Wire.endTransmission();
  delay(100);
}


void BMX055_Accl() {
  int data[6];
  for (int i = 0; i < 6; i++) {
    
    Wire.beginTransmission(Addr_Accl);
    Wire.write((2 + i));// Select data register
    Wire.endTransmission();
    Wire.requestFrom(Addr_Accl, 1);// Request 1 byte of data
    // Read 6 bytes of data
    // xAccl lsb, xAccl msb,
    // yAccl lsb, yAccl msb,
    // zAccl lsb, zAccl msb
    if (Wire.available() == 1)
      data[i] = Wire.read();
  }
  // Convert the data to 12-bits
  xAccl = ((data[1] * 256) + (data[0] & 0xF0)) / 16;
  if (xAccl > 2047)  xAccl -= 4096;
  yAccl = ((data[3] * 256) + (data[2] & 0xF0)) / 16;
  if (yAccl > 2047)  yAccl -= 4096;
  zAccl = ((data[5] * 256) + (data[4] & 0xF0)) / 16;
  if (zAccl > 2047)  zAccl -= 4096;
  xAccl = xAccl * 0.0098; // renge +-2g
  yAccl = yAccl * 0.0098; // renge +-2g
  zAccl = zAccl * 0.0098; // renge +-2g
}
