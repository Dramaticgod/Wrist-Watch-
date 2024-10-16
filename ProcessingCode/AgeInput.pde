/*
INSTRUCTIONS
Run setup_Age_Input() in setup() to move around the AgeInputter
Run draw_AgeInput() in draw() to display AgeInputter

Place enter_num() under keyPressed()
Age Inputter will automatically deactivate once Enter is hit
age from GraphingGlobals will automatically be set as a result

Call getAgeNum() to return the age once inputted
*/ 
int AgeNum = 0;
String StrAgeNum = "0";

boolean age_set = false;

int age_input_x;
int age_input_y;

void setup_Age_Input(int x, int y) {
  age_input_x = x;
  age_input_y = y;
}

void draw_AgeInput() {
  if (!age_set) {
    int x = age_input_x;
    int y = age_input_y;
    textSize(40);
    fill(0);
    text("  Enter your age using the keyboard", x, y);
    text("                        Age: " + StrAgeNum, x, y+50);
  }
}

int getAgeNum() {
  return min(AgeNum, 220);
}

void enter_num() {
  if (!age_set) {
    if( key >= '0' && key <= '9'){
      if (StrAgeNum == "0") {
        if (key == '0') {return;}
        else {StrAgeNum = "";}
        
      }
      StrAgeNum += key; 
    }
    if( key == ENTER || key == RETURN ){
      AgeNum = int( StrAgeNum );
      StrAgeNum = "";
      age_set = true;
      set_age(getAgeNum());
    }
    if (key == BACKSPACE)
      StrAgeNum= StrAgeNum.substring(0, max(0, StrAgeNum.length()-1));
      if (StrAgeNum == "") {StrAgeNum = "0";}
  }
}
