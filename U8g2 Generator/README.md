# ESP32 工具

# ESP32 SSD1306 u8g2 中文字型自動生成器

使用方法:
> (1) 將 ``Generator.ps1`` 下載並放置在與.ino相同的目錄下
> 
>![放置於相同的目錄下](https://github.com/YFHD-osu/ESP32-Tools/assets/92370642/b85c1933-17ac-49f6-bcb9-2660d5d2817f)
> 
> (2) 右健 ``Generator.ps1`` 並點擊 ``用PowerShell執行``
>
> ![用PowerShell執行](https://github.com/YFHD-osu/ESP32-Tools/assets/92370642/90b29bab-8acc-4d0c-99ff-fe88f358eb1b)
> 
> 註: 大部分的電腦預設是不可以直接執行.ps1檔案的，所以可以透過此只性來解除限制:
> 
> 設置開放執行: ``` Set-ExecutionPolicy -ExecutionPolicy Unrestricted ```
> 
> 還原為預設值: ``` Set-ExecutionPolicy -ExecutionPolicy Default ```

## 程式範例:
> 適用於: SSD1306 + ESP32
> ```  
> #include <U8g2lib.h>
> 
> U8G2_SSD1306_128X64_NONAME_1_HW_I2C u8g2(U8G2_R0, /* reset=*/ U8X8_PIN_NONE);
>
> void setup() {
>   u8g2.begin();
>   u8g2.enableUTF8Print();  //啟用UTF8文字的功能  
> }
> 
> void loop() {
>   u8g2.setFont(u8g2_font_unifont_t_chinese1); //使用u8g2_font_unifont_t_chinese1當作字體
>   u8g2.firstPage();
>   do {
>   u8g2.setCursor(0, 14);
>   u8g2.print("中文1");
>   u8g2.setCursor(0, 35);
>   u8g2.print("中文2");
>   u8g2.setCursor(0, 56);
>   u8g2.print("中文3");
>   } while (u8g2.nextPage());
> }
> ```
