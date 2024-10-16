/*
INSTRUCTIONS
Run setup_LineChart() in setup()
Run draw_LineChart() in draw() BEFORE update_LineChart()
Run update_LineChart() in draw(). pass in SensorData
*/
XYChart LineChart;

FloatList LineChartX;
FloatList LineChartY;

color curr_color;

float curr = 0;
float des = 0;

int gh = 250;
int y_offset = 300;
int x_offset = 66;


int updateInterval = 1000; // Throttle updates to every 10 seconds (10000 ms)
int lastUpdateTime = 0;     // Track the last update time
float accumulatedData = 0;   // To accumulate data between updates
int dataCount = 0;           // To count how many data points were accumulated


void setup_LineChart() {
  LineChart = new XYChart(this);
  LineChartX = new FloatList();
  LineChartY = new FloatList();


  LineChart.showXAxis(false);
  LineChart.showYAxis(true);

  LineChart.setPointSize(0);
  //LineChart.setLineWidth(3);
  
  textFont(createFont("Serif",10),15);
  LineChart.setAxisColour(0);
 // LineChart.setAxisLabel();
}


void draw_LineChart(){
  // range of heartrates
  LineChart.setMinY(0);
  LineChart.setMaxY(max_rate);
  
  pushMatrix();
  
  //translate(50, height - 310); 
  textAlign(LEFT);
  textSize(20);
  LineChart.draw(50, 285, 700, 270); 

  strokeWeight(1);
  
  //float f = 27.5;
  //float g = max_rate/15;
  
  textSize(15);
  // draws indicator lines for sections
  for (int i = 0; i < 5; i++) {
    stroke(zones[i].zoneColor);
    float x = y_offset+gh*(i*0.1+0.1);
    line(x_offset, x, 673, x);
    fill(zones[i].zoneColor);
    text(zones[i].name, x_offset+4, x);
  }

  stroke(COLOR_ZERO);
  float n = y_offset+gh*(1-rest_rate/max_rate);
  line(x_offset, n, 673, n);
  fill(0);
  text("Resting", x_offset+4, n-4);
  stroke(COLOR_LOW);
  line(x_offset, gh+y_offset, 673, gh+y_offset);
  line(x_offset, y_offset-3, 673, y_offset-3);
  
  // Set X-axis labels at 10-minute intervals
  int interval = 10; // 10 minutes per interval
  int total_time = 60; // Total time for the chart is 60 minutes
  for (int i = 0; i <= total_time / interval; i++) {
    float x = 50 + i * (573 / (total_time / interval)); // Calculate position along X-axis
    text(i * interval, x, 580); // Label at each 10-minute mark
  }
  
  
  
  popMatrix();
}

void update_LineChart(float hr) {
  int currentTime = millis();
  //values <= 0 will be rejected and the most recent value will be displayed instead
  if (hr > 0.0) {des = hr; }
  
  
  //sets color if valid
  float diff = des - curr;
  if ((diff <= 5.0 && diff >= 0)|| (des - curr >= -5.0 && diff <= 0)) {
     curr = des;
  } else if (diff > 0) {curr += 5;}
  else {curr -= 5;}
  

if (LineChartY.size() > 1) {
    for (int i = 1; i < LineChartY.size(); i++) {
      // Calculate the x and y positions of the previous and current points
      float prevX = x_offset + (i - 1) * 4; // Previous point's x-position
      float prevY = y_offset + gh * (1 - LineChartY.get(i - 1) / max_rate); // Previous point's y-position

      float currX = x_offset + i * 4; // Current point's x-position
      float currY = y_offset + gh * (1 - LineChartY.get(i) / max_rate); // Current point's y-position

      // Draw a line connecting the previous point to the current point
      strokeWeight(4);
      color zoneColor = get_zone(LineChartY.get(i)).zoneColor;
      // Set the stroke color based on the zone
      stroke(zoneColor);
      line(prevX, prevY, currX, currY);

      // Draw the current data point as a small ellipse
      fill(get_zone(LineChartY.get(i)).zoneColor); // Color of the data point
      noStroke();
      ellipse(currX, currY, 7, 2); // Draw point as a small ellipse
    }
  }
  if (currentTime - lastUpdateTime >= updateInterval) {
      LineChartX.append(time);
    LineChartY.append(curr); 
  
  //deletes old data, causing a scroll effect
  //larger x value holds more values for longer, meaning slower scroll
  int x = 150;
  if (LineChartX.size() > x && LineChartY.size() > x) {
    LineChartX.remove(0);
    LineChartY.remove(0);
  }
  
  LineChart.setData(LineChartX.toArray(), LineChartY.toArray());
  
  accumulatedData = 0;
  dataCount = 0;
  
  lastUpdateTime = currentTime;
  }
  
}

void set_curr_hr(float n) {curr = n;}

//float avg_ab(float a, float b) {return (a+b)/2;}

//returns most recent data point
float get_recent_line() {
  if (LineChartY.size() <= 0) {return 0.0;}
  return LineChartY.get(LineChartY.size()-1);
}
