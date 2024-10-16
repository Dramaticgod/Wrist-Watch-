/*
    Use function sendTimeToArduino(myPort)
    to send the current system time and date to Arduino.
*/


void sendTimeToArduino(Serial port)
{
  port.write(getFormattedDateTime());
}


String getFormattedDateTime() 
{
  int hh = hour();
  int mm = minute();
  int ss = second();
  int aa = (dayOfWeek() % 7) + 1; // Custom day of the week, where Sunday is 1 Monday is 2 and so on
  int dd = day();
  int m = month();
  int yy = year() % 100;

  // This makes sure that each number will be made of two digits
  // So even if day is for example 7th, it should be sent as "07"
  String hhStr = nf(hh, 2);
  String mmStr = nf(mm, 2);
  String ssStr = nf(ss, 2);
  String aaStr = nf(aa, 2);
  String ddStr = nf(dd, 2);
  String mStr = nf(m, 2);
  String yyStr = nf(yy, 2);

  // Create formatted string
  return hhStr + ":" + mmStr + ":" + ssStr + ":" + aaStr + ":" + ddStr + ":" + mStr + ":" + yyStr + "\r\n";
}

int dayOfWeek() 
{
  int y = year();
  int m = month();
  int d = day();

  // Zeller's Congruence formula to get the day of the week (1 = Sunday, 2 = Monday, etc.)
  // Thank ChatGPT for the rest of this function
  if (m < 3) {
    m += 12;
    y--;
  }

  int K = y % 100;
  int J = y / 100;

  int f = d + (13 * (m + 1)) / 5 + K + (K / 4) + (J / 4) - 2 * J;
  int dayOfWeek = (f % 7 + 7) % 7; // Ensure result is non-negative
  return dayOfWeek;
}
