void draw_time(int time) {
  int seconds = time % 60;  // Get current seconds
  int minutes = time / 60;   // Get total minutes
  
  fill(0);
  //text("Seconds: " + seconds, 200, 50);  // Display seconds
  //text("Minutes: " + minutes, 200, 100);  // Display minutes
    text("Seconds: " + nf(seconds, 2), width / 2, height / 2 - 20);  // Centered display for seconds
  text("Minutes: " + nf(minutes, 2), width / 2, height / 2 + 20);  // Centered display for minutes
}
