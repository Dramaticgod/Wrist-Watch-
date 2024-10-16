/*
INSTRUCTIONS
Run setup_colorTable() in setup() BEFORE setup_BarChart()
Run setup_BarChart() in setup()
Run draw_BarChart() in draw() BEFORE update_BarChart()
Run update_BarChart() in draw(). pass in SensorData
*/
BarChart barChart;

FloatList zoneTimes;

float last_valid_bar;

void setup_BarChart() {
  barChart = new BarChart(this);
  zoneTimes = new FloatList();
  for (int i = 0; i < 6; i++) {zoneTimes.append(0.0);}
  barChart.setData(zoneTimes.toArray());
  barChart.setMinValue(0);
  //barChart.setMaxValue(1);

  textFont(createFont("Serif",10),1);
   
  barChart.showValueAxis(false);
  //barChart.setValueFormat("#");
  
  barChart.setBarLabels(new String[] {"Peak", "Cardio", "Aerobic", "Basic", "Low", "Rest"});
  setup_colorTable();
  barChart.showCategoryAxis(true);
  //barChart.transposeAxes(true);
  barChart.setBarColour(new float[] {0.9, 0.8, 0.7, 0.6, 0.5, 0.0}, cTable);
}

void draw_BarChart() {
  pushMatrix();
  barChart.draw(width-400,15,400,250); 
  popMatrix();
}

void update_BarChart(float hr) {
  //ignores garbage data
  if (hr <= 0.0) {hr = last_valid_bar;}
  else {last_valid_bar = hr;}
  zoneTimes.add(get_zone_i(hr), 1);
  barChart.setMaxValue(zoneTimes.max());
  barChart.setData(zoneTimes.toArray());
}
