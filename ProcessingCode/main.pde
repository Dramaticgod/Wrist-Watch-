import processing.serial.*;

Serial myPort;
SensorData sensor;

// Timer variable
int startTime;
int totalMinutes;
int displayTime = 0;
Button timerButton;

// Stressed and Calm Variables
Button stressButton;
Button calmButton;
int calmTimer = 0;
int stressTimer= 0;
int calmInterval = 6000;    //TODO CHANGE TIME FOR TESTING CALM AND STRESS BASED UPON YOUR NEED, 60 seconds as of now
boolean calmPressed = false;
boolean stressPressed = false;
ArrayList<Integer> calmHR;
ArrayList<Integer> stressHR;
float calmAvg = 0;
float stressAvg =0;
boolean stressTriggered = false;
boolean calmTriggered = false;
int temp = 0;

// HeartBeat Variable 
boolean restingHR = false;
float restingHeartBeat = 0;
Button restingHRButton;
boolean restingHRTrigger = false; // To check if Resting HR is clicked or not 
int restingHRStartTime = millis(); // Record the Time for RestingHR
int restingHRArrayInd = 0;
int[] restingHRArray = new int[100];

//Button
Button avgHRButton;
int[] avgHR = new int[100];
int avgInd = 0;

//Arduino Variables
int arduinoConnection = 0; // Initially set to 0 (no connection)
int lastUpdate = 0;
int refreshInterval = 500; // Refresh interval in milliseconds
String portName = "COM7"; // Change this to the desired port

// data refresh 
int[] hrData = new int[30];
int hrInd = 0;
float heartrate = 0;
//age

void setup() {
  
  //ARDUINO connection Setup 
  println("Available ports: " + Serial.list());
  boolean portFound = false;
  for (String port : Serial.list()) {
    if (port.equals(portName)) {
      portFound = true;
      break;
    }
  }
  
  //Connecting to Arduino connection, if successful arduinoConnection = 1
  if (portFound) {
    println("Connecting to Arduino on port: " + portName);
    myPort = new Serial(this, portName, 115200);
    myPort.bufferUntil('\n');
    arduinoConnection = 1; // Set to 1 since the port was found
  } else {
    println("Arduino not connected");
  }
  
  
  size(800, 600);  //screen size 
  set_age(21); //default age is 21 will get updated later on 
  set_rest_rate(50); 
  
  
  setup_LineChart();  //setting up Line Chart
  setup_BarChart();   //setting up Bar Chart
  
  setup_Age_Input(100,200);    //setting up Age Input Box
  
  setup_sound();
  
  //Setting up different UI Buttons 
  restingHRButton = new Button(70,10,150,100, "Resting HeartBeat", color(100,150,200),color(255,255,255));
  timerButton =new Button(240,10,150,100, "00:00", color(255,102,102), color(255,255,255));
  calmButton = new Button(70,130,150,100, "Calm Mode", color(100,150,200), color(255,255,255));
  stressButton = new Button(240,130,150,100, "Stress Mode", color(255,102,102), color(255,255,255));
  avgHRButton = new Button(70, 240 , 320, 40, "Avg BPM : ", color(60,179,113), color(255,255,255));
  //Setting up timer 
  startTime = millis();
  //frameRate(1);
  
  //setting up Calm and Stressed Arrays 
  calmHR = new ArrayList<Integer>();
  stressHR = new ArrayList<Integer>();
  
  //Setting up Data
  sensor = new SensorData();
  
  //Text Size
  textSize(20);
  
}

void draw() {
  refreshSensorData(sensor);
  //DEBUG STATEMENT to check if sensor object is updated
  //println(sensor.status + ";" + sensor.confidence + ";" + sensor.heartrate + ";" + sensor.oxygen );
  background(255);    // background color
  
  if(age_set == false){      // if age is not given put the UI box for age 
    draw_AgeInput();
  }
  else if(age_set == true) {    // if age is already given by the USER
    // Resting Heart Rate
    set_age(AgeNum);         // reinit our graph with the new age 
    textSize(20);           // changing text size to 20 , since age box used 40
    restingHRButton.display();      // Get the resting HeartBeat
     
    //TODO change to 1 if you have an actual device, if you do not use 0 in the condition
    if(sensor.inputDataStatus == 1){   // making sure arduino input is valid     
       if (restingHRTrigger) {        // if we are getting valid heartbeat, we get average of 30 inputs and that is the resting HR
       if (millis() - restingHRStartTime < 30000 && restingHR == false) {      // if restingHeartbeat was already recorded dont do this
        if( sensor.heartrate > 10 && restingHRArrayInd < 100){
            restingHRButton.updateLabel("Calculating");
            restingHRArray[restingHRArrayInd] = sensor.heartrate;
            restingHRArrayInd++;
            if (restingHRArrayInd == 99){
              restingHeartBeat = average(restingHRArray);    //update restingHeartBeat Global variable
              restingHR = true;
            }
         }
       }
        else if (restingHR == true){       // if resting HeartBeat is already recorded then we print the heartbeat, graphs, etc 
          restingHRButton.updateLabel("HB : " + str(restingHeartBeat));
          //display the buttons
          timerButton.display();
          calmButton.display();
          stressButton.display();
          restingHRButton.display();
          avgHRButton.display();
          
          //display the graphs
          draw_LineChart(); 
          draw_BarChart();
          
          //update the Timer and the graphs
          updateTimerButton();
    
          update_LineChart(sensor.heartrate);
          update_BarChart(sensor.heartrate);
          updateAVGHR(float(sensor.heartrate));
          
        
          handleStressMode(sensor.heartrate);
          handleCalmMode(sensor.heartrate);
        }
      }    
    }
  }
 
  
}

// Function to refresh sensor data
void refreshSensorData(SensorData sensor) {
  String rawSerial = "";
  //debug 
  //println("refreshSensortData is being called");
  //println(arduinoConnection);
  
  //TODO for debugging test, put the line  -> sensor.heartrate = int(random(80,151)); under this comment
  //sensor.heartrate = int(random(90,95));
  if (arduinoConnection == 1) { 
    if (myPort.available() > 0) {
      // Read the data from the serial port if available
      rawSerial = trim(myPort.readStringUntil('\n'));
      //debug
      println(rawSerial);
      if (rawSerial != null && !rawSerial.isEmpty()) {
        sensor.updateFromSerial(rawSerial);
      }
    }
  }
}

// Function to update the button label with live time
void updateTimerButton() {
  int elapsedTime = millis() - startTime; // Calculate elapsed time
  int seconds = (elapsedTime / 1000) % 60; // Get seconds
  int minutes = (elapsedTime / 1000) / 60; // Get minutes
  String timeLabel = nf(minutes, 1) + ":" + nf(seconds, 2); // Format the time as "m:ss"
  timerButton.updateLabel(timeLabel); // Update the button label
}

// Function to handle when stress UI is Clicked
void handleStressMode(int heartrate) {
  /// Check if calm mode is active
  if (stressPressed) {
    stressTriggered = true;
    // Add the current heart rate to the calmHR array
    if (heartrate >= 0) {
      if(heartrate != 0 ){
        println("heartrate : " + heartrate);
        stressHR.add(heartrate);
        stressAvg = dynamicAverage(stressHR);
        stressButton.updateLabel("Stress HR: " + str(int(calmAvg)));
        stressButton.display();
      }
    }
    
    // Check if the calm interval (60 seconds) has passed
    println(millis() - stressTimer + "Average: " + stressAvg);
    if (millis() - stressTimer > calmInterval && stressTriggered) {
      print("IF CONDITION TRIGGERED");
      // Calm mode completed after 60 seconds
      if ((calmAvg - stressAvg > 10) || (calmAvg == 0 && stressAvg > 80) || stressAvg > 60) {   
         //TODO NEED VALID ARDUINO CONNECTION FOR THIS ON SERIAL PORT OTHERWISE NULL EXCEPTION
         println("b SENT TO ARDUINO");
        /*for (int i = 0; i<5;i++){
          myPort.write('b');
        }*/
        myPort.write('b');
        stressButton.updateLabel("STRESSED");
        stressButton.display();
        delay(2000);
      }
      stressPressed = false; // Deactivate calm mode
      //stressHR.clear(); // Clear the calm HR data for the next session
      stressTriggered = false;
      
    }
    stressButton.updateLabel("Stress Mode");
    stressButton.display();
  }
}

//Function to handlge Calm Mode when clicked
void handleCalmMode(int heartrate) {
  /// Check if calm mode is active
  if (calmPressed) {
    calmTriggered = true;
    // Add the current heart rate to the calmHR array
    
    if (heartrate >= 0) {
      println("heartrate : " + heartrate);
      if (heartrate != 0){
        temp = heartrate;
        calmHR.add(temp);
        calmAvg = dynamicAverage(calmHR);
      }
      calmButton.updateLabel("Calm HR: " + str(int(calmAvg)));
      calmButton.display();
    }
    
    
    
    // Check if the calm interval (60 seconds) has passed
    println(millis() - calmTimer);
    if (millis() - calmTimer > calmInterval && calmTriggered) {
      // Calm mode completed after 60 seconds
      calmPressed = false; // Deactivate calm mode
      println("PLAYING MUSIC");
      play_music();
      calmHR.clear(); // Clear the calm HR data for the next session
      calmTriggered = false;
    }
    calmButton.updateLabel("Calm Mode");
    calmButton.display();
  }
}



void updateAVGHR(float heartrate){
    if(avgInd > 99) {
      int res = int(average(avgHR));
      avgHRButton.updateLabel("Avg BPM : " + str(res));
      avgHRButton.display();
      avgInd = 0;
    }
    else{
      if(heartrate != 0){
          avgHR[avgInd] = int(heartrate);
      }
      avgInd++;
      //println(avgInd);
    }

}

// Inbuilt function to check for mouse click
void mousePressed() {
  if (restingHRButton.isClicked(mouseX, mouseY)) {
    println("Resting HR Button Clicked");
    restingHRTrigger = true; // Start measuring resting heart rate
    restingHRStartTime = millis(); // Record the start time
  }
  
  if (timerButton.isClicked(mouseX, mouseY)){
    startTime = millis();
  }
  
  if (calmButton.isClicked(mouseX, mouseY)) {
    calmPressed = true;  // Activate calm mode
    calmTimer = millis();   // Start calm mode timer
  }
  
  if(stressButton.isClicked(mouseX, mouseY)){
    stressPressed = true;
    stressTimer = millis();
  }
}


//Inbuilt function to check for keyboard presses 
void keyPressed(){
  enter_num();

}
