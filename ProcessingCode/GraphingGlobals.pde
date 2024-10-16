import org.gicentre.utils.stat.*;
import org.gicentre.utils.colour.*;

//const
color COLOR_MAX = #d13945;
color COLOR_HARD = #e9af52;
color COLOR_MID = #329f62;
color COLOR_LIGHT = #5398d8;
color COLOR_LOW = #a4a4a4;
color COLOR_ZERO = #000000;

//var
ColourTable cTable;
int time = 0;
float max_rate = 0.0;
int age = 0;
float rest_rate = 0.0;


//CALL TO SET MAX_RATE
void set_age(int n) {
  if (n > 220) {n = 220;}
  if (n < 0) {n = 0;}
  age = n;
  max_rate = 220 - n;
}

// probably can be set directly, possibly used for stress setting too
void set_rest_rate(int n) {
  rest_rate = n;
}

Zone[] zones = {
(new Zone("Maximum", COLOR_MAX)),
(new Zone("Hard", COLOR_HARD)),
(new Zone("Moderate", COLOR_MID)),
(new Zone("Light", COLOR_LIGHT)),
(new Zone("Very Light", COLOR_LOW)),
(new Zone("Resting", COLOR_ZERO))
}; 

Zone get_zone(float n) {
  return zones[get_zone_i(n)];

}

int get_zone_i(float n) {
  for (int i = 0; i < 5; i++) {
    if (n >= max_rate*(0.9-i*0.1)) {return i;}
  }
  return 5;
}


void setup_colorTable() {
  cTable = new ColourTable();
  cTable.addDiscreteColourRule(0.0, COLOR_ZERO);
  cTable.addDiscreteColourRule(0.5, COLOR_LOW);
  cTable.addDiscreteColourRule(0.6, COLOR_LIGHT);
  cTable.addDiscreteColourRule(0.7, COLOR_MID);
  cTable.addDiscreteColourRule(0.8, COLOR_HARD);
  cTable.addDiscreteColourRule(0.9, COLOR_MAX);
}
