/*
  UIC CS 479 - Lab 1 Project
  Made by:
    -
    -
    -

  Sensor reading code based on SparkFun bioHub example code by Elias Santistevan.
  SDA -> SDA
  SCL -> SCL
  RESET -> PIN 4
  MFIO -> PIN 5

  Author: Elias Santistevan
  Date: 8/2019
  SparkFun Electronics

  If you run into an error code check the following table to help diagnose your
  problem:
  1 = Unavailable Command
  2 = Unavailable Function
  3 = Data Format Error
  4 = Input Value Error
  5 = Try Again
  255 = Error Unknown
*/

/*
  If you're using the arduino without display, you can skip all libraries and code used for it.
  Simply comment out this line to disable all display-related code.
*/
#define UsingDisplay true

#include <SparkFun_Bio_Sensor_Hub_Library.h>

#ifdef UsingDisplay
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <DS3231.h>

// Pins for the display
#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels
#define OLED_RESET -1    // Reset pin # (or -1 if sharing Arduino reset pin)
#define OLED_ADDRESS 0x3C
Adafruit_SSD1306 d(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

// Pins for RTC
#define DS3231_I2C_ADDRESS 0x68 // used for RTC

// Pins for the buttons
#define pinButtonUp 8
#define pinButtonOk 7
#define pinButtonDown 6

#endif

#define pinBuzzer 11

// Additional pins for the heart rate monitor
#define resPin 4
#define mfioPin 5

/*
  0 - display time, no timer
  1 - display timer, timer running
  2 - display timer, timer paused
  >= 10 - menu
*/
int mode = 0;

#ifdef UsingDisplay
/*
  There are two devices that run the same code.
  Basic version has only heart rate monitor and buzzer.
  "Pro" version adds display, buttons, and RTC.
  If display not detected (this var == 0), other related functions are disabled
  and device will only read heart rate and send serial data.

  Change this var when uploading the code.
*/
int usingDisplay = 1;

// debouncing class for simple buttons, default for them is high (internal pull up)
unsigned long lastButtonEvent = 0; // keeps time when was the button pressed last time
class button
{
public:
  // constructor that sets all variables to default
  button(byte buttonID_c)
  {
    pinMode(buttonID_c, INPUT_PULLUP);

    // update all variables
    buttonID = buttonID_c;
    buttonDebounce = 0;
    buttonLastState = HIGH;
    buttonCurrentState = HIGH;
    buttonPressUsed = true;
  }

  // returns 1 if pressed, returns 2 if being hold
  int state()
  {
    // read actual button state
    buttonCurrentState = digitalRead(buttonID);

    // check if it changed from last time, if it did take note of the time
    if (buttonCurrentState != buttonLastState)
      buttonDebounce = millis();

    // update the last state variable
    buttonLastState = buttonCurrentState;

    // check if button is being held down
    if (millis() - buttonDebounce > buttonHoldTimer && buttonCurrentState == LOW)
    {
      lastButtonEvent = millis();

      // prevent from setting the "isPressed" and "isHeld" signal simultaneously
      buttonPressUsed = true;

      return 2;
    }

    // now check if button is in its current state for long enough, but trigger only if button is let go
    else if ((millis() - buttonDebounce) > buttonDebounceDelay && millis() - buttonDebounce < buttonHoldTimer)
    {
      // remember to return true only once per button press
      // to prevent value increase when button is being hold
      if (!buttonPressUsed && buttonCurrentState == HIGH)
      {
        buttonPressUsed = true;

        // if so, update the optional variable, if set
        lastButtonEvent = millis();

        return 1;
      }

      // if not pressed, reset the 'use' variable
      if (buttonCurrentState == LOW)
        buttonPressUsed = false;
    }

    return 0;
  }

private:
  byte buttonID;                                // holds button id, like A1
  unsigned long buttonDebounce;                 // holds time when button changed last time
  int buttonLastState;                          // what was last button state
  int buttonCurrentState;                       // what is current state
  bool buttonPressUsed;                         // if button was determined to be pressed, use this to return true only once
  const unsigned long buttonDebounceDelay = 20; // minimum delay between change of signals
  const unsigned long buttonHoldTimer = 400;    // how long to hold the button before it's considered being hold
};

button buttonUp(pinButtonUp);
button buttonOK(pinButtonOk);
button buttonDown(pinButtonDown);

#endif

// Takes address, reset pin, and MFIO pin.
SparkFun_Bio_Sensor_Hub bioHub(resPin, mfioPin);

bioData body;

inline bool operator==(const bioData &lhs, const bioData &rhs)
{
  return (lhs.heartRate == rhs.heartRate && lhs.oxygen == rhs.oxygen && lhs.status == rhs.status);
}
inline bool operator!=(const bioData &lhs, const bioData &rhs)
{
  return !(lhs == rhs);
}

#ifdef UsingDisplay
// Convert normal decimal numbers to binary coded decimal
int decToBcd(int val)
{
  return ((val / 10 * 16) + (val % 10));
}

// Convert binary coded decimal to normal decimal numbers
int bcdToDec(int val)
{
  return ((val / 16 * 10) + (val % 16));
}

// used to set time to the module
struct timeStruct
{
  int second, minute, hour, dayOfWeek, dayOfMonth, month, year;

  bool operator==(const timeStruct &other) const
  {
    return (second == other.second &&
            minute == other.minute &&
            hour == other.hour &&
            dayOfWeek == other.dayOfWeek &&
            dayOfMonth == other.dayOfMonth &&
            month == other.month &&
            year == other.year);
  }

  bool operator!=(const timeStruct &other) const
  {
    return !(*this == other);
  }
};
void setDS3231time(int second, int minute, int hour, int dayOfWeek, int dayOfMonth, int month, int year)
{
  // sets time and date data to DS3231
  Wire.beginTransmission(DS3231_I2C_ADDRESS);
  Wire.write(0);                    // set next input to start at the seconds register
  Wire.write(decToBcd(second));     // set seconds
  Wire.write(decToBcd(minute));     // set minutes
  Wire.write(decToBcd(hour));       // set hours
  Wire.write(decToBcd(dayOfWeek));  // set day of week (1=Sunday, 7=Saturday)
  Wire.write(decToBcd(dayOfMonth)); // set date (1 to 31)
  Wire.write(decToBcd(month));      // set month
  Wire.write(decToBcd(year));       // set year (0 to 99)
  Wire.endTransmission();

  // Serial.print(F("Time set: "));
  // Serial.print(hour);
  // Serial.print(F(":"));
  // Serial.print(minute);
  // Serial.print(F(":"));
  // Serial.print(second);

  // Serial.print(F(" "));
  // Serial.print(month);
  // Serial.print(F("/"));
  // Serial.print(dayOfMonth);
  // Serial.print(F("/20"));
  // Serial.print(year);
  // Serial.print(F(", Day of week: "));
  // Serial.println(dayOfWeek);
}
// set time in format hh:mm:ss:dayOfWeek(sunday is 1):day:month:year(24 for 2024)
// all data must be represented in two digits
void setDS3231time(const String &data)
{
  Serial.print(F("setDS3231time received string: \""));
  Serial.print(data);
  Serial.println(F("\""));

  int h, m, s, dayOfWeek, day, month, year;
  h = data.substring(0, 2).toInt();
  m = data.substring(3, 5).toInt();
  s = data.substring(6, 8).toInt();
  dayOfWeek = data.substring(9, 11).toInt();
  day = data.substring(12, 14).toInt();
  month = data.substring(15, 17).toInt();
  year = data.substring(18, 20).toInt();

  setDS3231time(s, m, h, dayOfWeek, day, month, year);
}
int extractHours(unsigned long givenTime)
{
  return givenTime / 3600000;
}
int extractMinutes(unsigned long givenTime)
{
  return (givenTime % 3600000) / 60000;
}
int extractSeconds(unsigned long givenTime)
{
  return (givenTime % 60000) / 1000;
}
void readDS3231time(int &second, int &minute, int &hour)
{
  Wire.beginTransmission(DS3231_I2C_ADDRESS);
  Wire.write(0); // set DS3231 register pointer to 00h
  Wire.endTransmission();
  Wire.requestFrom(DS3231_I2C_ADDRESS, 7);
  // request seven bytes of data from DS3231 starting from register 00h
  second = bcdToDec(Wire.read() & 0x7f);
  minute = bcdToDec(Wire.read());
  hour = bcdToDec(Wire.read() & 0x3f);
}
void readDS3231time(int &second, int &minute, int &hour, int &dayOfWeek, int &dayOfMonth, int &month, int &year)
{
  Wire.beginTransmission(DS3231_I2C_ADDRESS);
  Wire.write(0); // set DS3231 register pointer to 00h
  Wire.endTransmission();
  Wire.requestFrom(DS3231_I2C_ADDRESS, 7);
  // request seven bytes of data from DS3231 starting from register 00h
  second = bcdToDec(Wire.read() & 0x7f);
  minute = bcdToDec(Wire.read());
  hour = bcdToDec(Wire.read() & 0x3f);
  dayOfWeek = bcdToDec(Wire.read());
  dayOfMonth = bcdToDec(Wire.read());
  month = bcdToDec(Wire.read());
  year = bcdToDec(Wire.read());
}
timeStruct readDS3231time()
{
  timeStruct toReturn;
  readDS3231time(toReturn.second, toReturn.minute, toReturn.hour, toReturn.dayOfWeek, toReturn.dayOfMonth, toReturn.month, toReturn.year);
  return toReturn;
}
void printZeroIfLessThanTen(unsigned long value)
{
  if (value < 10)
    d.print(0);
  d.print(value);
}
#endif

void scanForI2C()
{
  byte error, address; // variable for error and I2C address
  int nDevices;

  Serial.print(F("I2C devices online: "));

  nDevices = 0;
  for (address = 1; address < 127; address++)
  {
    // The i2c_scanner uses the return value of
    // the Write.endTransmisstion to see if
    // a device did acknowledge to the address.
    Wire.beginTransmission(address);
    error = Wire.endTransmission();

    if (error == 0)
    {

      Serial.print(F("0x"));
      if (address < 16)
        Serial.print(F("0"));
      Serial.print(address, HEX);
      Serial.print(F(", "));
      nDevices++;
    }
    else if (error == 4)
    {
      Serial.print(F("Unknown error at address 0x"));
      if (address < 16)
        Serial.print(F("0"));
      Serial.println(address, HEX);
    }
  }
  if (nDevices == 0)
    Serial.println(F("No I2C devices found\n"));
}

bool i2cDevicePresent(int address)
{
  Wire.beginTransmission(address);
  byte error = Wire.endTransmission();

  return error == 0;
}

void setup()
{
  Serial.begin(115200);
#ifdef UsingDisplay
  Wire.begin();

  // setDS3231time(0, 22, 16, 7, 21, 9, 24);

  // scanForI2C();

  if (i2cDevicePresent(OLED_ADDRESS))
    usingDisplay = 1;
  else
    usingDisplay = 0;

  // Setup screen
  if (usingDisplay == 1 && !d.begin(SSD1306_SWITCHCAPVCC, OLED_ADDRESS))
  {
    Serial.println(F("Display disabled or error. usingDisplay = 0"));
  }
  else
  {
    Serial.println(F("Display enabled. usingDisplay = 1"));
    d.setTextSize(1);
    d.setTextColor(WHITE);
    d.clearDisplay();
    d.display();
  }

#endif

  // Setup the heart rate monitor
  int result = bioHub.begin();
  if (result == 0) // Zero errors!
    Serial.println(F("Sensor started!"));
  else
    Serial.println(F("Could not communicate with the sensor!"));

  Serial.println(F("Configuring Sensor...."));
  int error = bioHub.configBpm(MODE_ONE); // Configuring just the BPM settings.
  if (error == 0)
  { // Zero errors!
    Serial.println(F("Sensor configured."));
  }
  else
  {
    Serial.println(F("Error configuring sensor."));
    Serial.print(F("Error: "));
    Serial.println(error);
  }

  pinMode(pinBuzzer, OUTPUT);
  // tone(pinBuzzer, 200, 500);
}

/*

  Call this function with # of beeps you want.
  It should be called in main loop without parameters.

*/
void beep(int numberOfBeeps = -1)
{
  static unsigned long lastBeepTime = 0;
  static int beepsLeft = 0;

  if (numberOfBeeps != -1)
    beepsLeft = numberOfBeeps * 2 - 1;

  if (beepsLeft > 0 && millis() - lastBeepTime > 350)
  {
    if (beepsLeft % 2 == 1)
      tone(pinBuzzer, 500, 350);

    lastBeepTime = millis();
    beepsLeft--;
  }
}

void loop()
{
#ifdef UsingDisplay
  bool updateDisplay = false;
  static timeStruct currentTime;               // time to display on the screen
  static unsigned long lastStopwatchValue = 0; // stopwatch value to print on the screen
  static unsigned long stopwatchTime = 0;      // offset or where to start counting time from
  static unsigned long lastTimeUpdate = 0;
#endif
  beep();

  // read sensor data and send it
  static unsigned long lastBodyUpdate = 0;
  if (millis() - lastBodyUpdate > 1000)
  {
    // comparision done only to know if we need to update the display
    bioData newBody = bioHub.readBpm();
    if (newBody != body)
    {
      body = newBody;
#ifdef UsingDisplay
      updateDisplay = true;
#endif
    }

    Serial.print(body.heartRate);
    Serial.print(";");
    Serial.print(body.confidence);
    Serial.print(";");
    Serial.print(body.oxygen);
    Serial.print(";");
    Serial.print(body.status);
    Serial.println(";");
    lastBodyUpdate = millis();
  }

  if (Serial.available() > 0)
  {
    String data = Serial.readString();
    data.trim();
    int length = data.length();

    if (length == 1 && data == "b")
    {
      beep(2);
    }
#ifdef UsingDisplay
    // set time, check function comment for the format
    else if (length == 20)
    {
      setDS3231time(data);
    }
#endif
    else
    {
      Serial.print(F("Received unknown command on serial ("));
      Serial.print(length);
      Serial.print(F(" characters): "));
      Serial.println(data);
    }
  }
#ifdef UsingDisplay
  // If display not detected, skip all display related functions.
  if (usingDisplay == 0)
  {
    return;
  }

  if (mode < 10)
  {
    /*
      Button functions if not in menu

      In stopwatch mode, up pauses, down resets, ok goes to menu
    */
    if (buttonUp.state() == 1)
    {
      // if timer running, pause it, if not running, unpause
      if (stopwatchTime == 0)
      {
        stopwatchTime = millis();
        lastStopwatchValue = 0;
        mode = 1;
      }
      else if (mode == 1)
      {
        mode = 2;
      }
      else
      {
        stopwatchTime = millis() - lastStopwatchValue;
        mode = 1;
        updateDisplay = true;
      }
    }

    if (buttonOK.state() == 2)
    {
      // temp way to set time - hold ok button
      setDS3231time(0, 54, 11, 3, 24, 9, 24);
    }

    if (buttonDown.state())
    {
      mode = 0;
      lastStopwatchValue = 0; // reset, so make it display 0
      stopwatchTime = 0;
      updateDisplay = true;
    }

    /*

        Time and stopwatch value updates

    */

    if (millis() - lastTimeUpdate > 250)
    {
      timeStruct tempTime = readDS3231time();
      if (currentTime != tempTime) // if time changed, queue display update
      {
        currentTime = tempTime;
        updateDisplay = true;
      }

      lastTimeUpdate = millis();
    }

    if (mode == 1 && millis() - stopwatchTime + lastStopwatchValue >= 100)
    {
      lastStopwatchValue = millis() - stopwatchTime;
      updateDisplay = true;
    }
  }

  /*

    Main menu

  */
  else if (mode >= 10)
  {
    /*
      Main menu:
      10 - Change to timer
    */

    return;
  }

  /*
      Code after this point executes only if mode < 10
  */

  if (updateDisplay)
  {
    d.clearDisplay();
    d.setCursor(0, 0);

    d.print(currentTime.hour);
    d.print(F(":"));
    printZeroIfLessThanTen(currentTime.minute);
    d.print(F(":"));
    printZeroIfLessThanTen(currentTime.second);
    d.print(F("   "));
    if (currentTime.month < 10)
      d.print(F(" "));
    d.print(currentTime.month);
    d.print(F("/"));
    d.print(currentTime.dayOfMonth);
    d.print(F("/20"));
    d.print(currentTime.year);

    if (mode == 1 || mode == 2)
    {
      d.setCursor(0, 10);
      d.print(extractHours(lastStopwatchValue));
      d.print(F(":"));
      printZeroIfLessThanTen(extractMinutes(lastStopwatchValue));
      d.print(F(":"));
      printZeroIfLessThanTen(extractSeconds(lastStopwatchValue));
      d.print(F("."));
      d.print((lastStopwatchValue / 100) % 10);
    }

    if (body.status != 0)
    {
      d.setCursor(0, 36);

      if (body.status == 1)
      {
        d.print(F("Object detected.\nReading..."));
      }
      else if (body.status == 2)
      {
        d.print(F("Not a finger\non the sensor."));
      }
      else if (body.status == 3)
      {
        d.print(F("Heart rate: "));
        d.println(body.heartRate);
        d.print(F("Oxygen: "));
        d.println(body.oxygen);
        d.print(F("Confidence level:"));
        if (body.confidence < 100)
          d.print(F(" "));
        d.print(body.confidence);
        d.println(F("%"));
      }
    }

    d.display();
    updateDisplay = false;
  }
#endif
}
