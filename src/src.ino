/*

  Minimal Pi Clock
  (C) 2015 Richel Bilderbeek

2015-07-05: v.1.0: Initial version
2015-08-21: v.1.1: Added beep if A0 is connected to GND at startup
2019-07-19: v.1.2: Always beep at startup
2019-11-03: v.1.3: Plug in at Pi o'clock instead of at midnight

Piezo:
  
    8              GND
    |  +--------+  |
    +--+   P    +--+
       +--------+

  8: piezo pin
  P: Piezo
  GND: Arduino GND pin

*/

#include <Time.h>

//If NDEBUG is #defined, it is a release version
//If NDEBUG is commented out, it is a debug version
//#define NDEBUG

const int pin_piezo = 8; //The pin connected to the piezo

void TestTime()
{
  //  setTime(hours, minutes, seconds, days, months, years);
  const int hours = 11;
  const int minutes = 22;
  const int seconds = 33;
  const int days = 0;
  const int months = 0;
  const int years = 0;
  setTime(hours, minutes, seconds, days, months, years);
  setTime(15,14,0,0,0,0);
}

void beep()
{
  const int frequency_hz = 3142;
  const int duration_msec = 3142;
  tone(pin_piezo, frequency_hz, duration_msec);
}

void setup() 
{
  pinMode(pin_piezo, OUTPUT);
  TestTime();
  //No need to do a beep here: the sketch starts at pi o'clock and will detect this
  //beep(); 
}

void loop() 
{
  // Is it Pi o'clock yet? That is, 3:14 PM, also known as 15:14
  bool is_pi_oclock = false;
  int last_sec = -1; //The previous second, used to detect a change in time, to be sent to serial monitor
  
  while (1)
  {
    //Show the time
    const int s = second();
    const int m =  minute();
    const int h = hour();

    if (last_sec == s) 
    {
      continue;
    }

    last_sec = s;

    //Detect pi o'clock
    if (h == 15 && m == 14) 
    {
      //Already beeped?
      if (!is_pi_oclock)
      {
        is_pi_oclock = true;
        beep();
      }
    }
    else 
    { 
      is_pi_oclock = false; 
    }
  }
}
