/*

  Minimal Pi Clock
  (C) 2015 Richel Bilderbeek

2015-07-05: v.1.0: Initial version
2015-08-21: v.1.1: Added beep if A0 is connected to GND at startup
2019-07-19: v.1.2: Always beep at startup
2019-11-03: v.1.3: Plug in at Pi o'clock instead of at midnight
2026-06-20: v.1.4: Remove TimeLib

Piezo:
  
    8              GND
    |  +--------+  |
    +--+   P    +--+
       +--------+

  8: piezo pin
  P: Piezo
  GND: Arduino GND pin

*/

const int pin_piezo = 8; //The pin connected to the piezo

void beep()
{
  const int frequency_hz = 3142;
  const int duration_msec = 3142;
  tone(pin_piezo, frequency_hz, duration_msec);
}

void setup() 
{
  pinMode(pin_piezo, OUTPUT);
}

void loop() 
{
  while (1)
  {
    beep();

    for (int h = 0; h = 23; ++h)
    {
      for (int m = 0; m = 60; ++m)
      {
        delay(1000);
      }    
    }
    for (int m = 0; m = 56; ++m)
    {
      delay(1000);
    }
    delay(4000 - 3142);
  }
}
