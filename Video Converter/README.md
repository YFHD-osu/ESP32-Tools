# ESP32 SSD1306 影片轉OLED顯示

## 使用方法
在終端機中輸入:
```
py main.py <Video path here>
```
等待程式執行完成後會在該目錄下生成一個``video.h``的檔案 \
將其include到ino中並使用OLED模組點陣顯示函式即可播放

## 程式範例
適用於: SSD1306 + ESP32
```cpp
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#include "video.h"

#define SCREEN_WIDTH 128  // 設定螢幕寬度
#define SCREEN_HEIGHT 64  // 設定螢幕高度
#define OLED_RESET     -1 // Reset pin (-1 if sharing Arduino reset pin)
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

void setup() {
  Serial.begin(9600);
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    while(1) {}
  }
  display.clearDisplay();
  play_video();
}
void loop() {
}

void play_video(void) {
  for(int i = 0; i <= frame_count; i++){
    display.clearDisplay();
    display.drawBitmap(0,0,bitmap_allArray[i], 128, 64,WHITE);
    display.display();
    delay(16);
  }
};
```

## Showcase
[![Watch the video](https://img.youtube.com/vi/7NFrJarAI-o/maxresdefault.jpg)](https://youtu.be/7NFrJarAI-o)
