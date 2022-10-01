/* 
 * 回傳錯誤代碼:
 * -1 -> 連線逾時
 * -2 -> 數據毀損
 * -3 -> 數據未傳送完整
 */
 
float GetPM25Data()//讀取PM2.5感測器，鮑率：2400; 檢查位元：無; 停止位元：1 位;資料位元：8; 數據包長度為7位元組
{
  int cnt = 0, pmval, readcmd[7], rbytes = 0;
  unsigned char gdata = 0, eFlag = 0;
  float pm25;
  while (Serial2.available() > 0) {
    gdata = Serial2.read();//保存接收字符

    if (gdata == 0xaa && eFlag == 0) eFlag = 1; //起始位是0xAA
    if (eFlag == 1) readcmd[rbytes++] = gdata;
    cnt++;
    if (cnt > 100) return -1; //連線超時
    if (rbytes == 7) break; //一共7組數據
  }
  if (rbytes == -3) return 0;

/* 用序列埠傳入讀到的值
  Serial.print("[ ");
    for (rbytes = 0; rbytes < 7; rbytes++ ) {
      Serial.print(readcmd[rbytes]);
      Serial.print(",");
    }
    Serial.println(" ]");
    Serial.println(rbytes);
*/

  if (readcmd[6] != 0xff) return -2;   //結束位元為OxFF

  pmval = readcmd[1];
  pmval <<= 8; //左移8位 Vout(H)*256
  pmval += readcmd[2]; //Vout(H)*256+Vout(L)
  pm25 = pmval * 5.0 / 1024.0; //計算PM2.5值，：Vout=(Vout(H)*256+Vout(L))/1024*5
  pm25 /= 3.5; //係数3.5
  return pm25;
}

float GetPM25Data_u() //嘗試直到讀出有效的數值
{
  float pm25Value = -1;
  while(true){ // 確保有偵測到數值
    pm25Value = GetPM25Data();   // 取得pm25
    if (pm25Value >= 0 ) return pm25Value;
  }
}
