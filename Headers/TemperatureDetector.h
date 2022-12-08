#include "DHTesp.h"

DHTesp dht;

class TempDetector {
  public:
    void initialization(byte dhtPin);
    TempAndHumidity getvalue();
};

void TempDetector::initialization (byte dhtPin){
  dht.setup(dhtPin, DHTesp::DHT11);
}

TempAndHumidity TempDetector::getvalue (){
  TempAndHumidity lastValues = dht.getTempAndHumidity(); // 取得溫溼度值
  return lastValues;
}
