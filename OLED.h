#include <U8g2lib.h>

#ifdef U8X8_HAVE_HW_SPI
#include <SPI.h>
#endif
#ifdef U8X8_HAVE_HW_I2C
#include <Wire.h>
#endif

U8G2_SSD1306_128X64_NONAME_F_HW_I2C u8g2(U8G2_R0, /* reset=*/ U8X8_PIN_NONE);

class SSD1306 {
  public:
    void initialization();
    void printline(String context);
    void sendbuffer();
    void clearbuffer();
    
  private:
    int yPos = 14;
};

void SSD1306::initialization() {
  u8g2.begin();
  u8g2.enableUTF8Print();    // 啟動 UTF8 支援
  return;
}

void SSD1306::printline (String context) {
  u8g2.setFont(u8g2_font_unifont_t_chinese1);  // 使用 chinese1字型檔
  u8g2.setCursor(0, yPos);
  u8g2.print(context);
  yPos += 16;
  return;
}

void SSD1306::sendbuffer () {
  u8g2.sendBuffer();
  return;
}

void SSD1306::clearbuffer () {
  yPos = 14;
  u8g2.clearBuffer();
  return;
}

//void updateOLED(double Temperature, int Humidity, float pm25){
//  u8g2.setFont(u8g2_font_unifont_t_chinese1);
//  u8g2.firstPage();
//  do {
//    u8g2.setCursor(0, 14);
//    u8g2.print("溫度: " + String(Temperature) + "°C");
//    u8g2.setCursor(0, 35);
//    u8g2.print("濕度: " + String(Humidity) + "%");
//    u8g2.setCursor(0, 56);
//    u8g2.print("PM2.5: " + String(pm25) + "mg/m³");
//    
//  } while (u8g2.nextPage());
//}
