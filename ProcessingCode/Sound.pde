/*
INSTRUCTIONS
Run setup_sound() in setup()
Run  to set stress
Run check_stress() in draw() only after setup_stress() has been run at keast once

Run play_music() whenever you want to play music
*/
import processing.sound.*;
SoundFile CalmMusic;
SoundFile Buzzer;

int stress_rate = 0;

void setup_sound() {
  CalmMusic = new SoundFile(this, "calm.mp3");
  Buzzer = new SoundFile(this, "buzzer.mp3");
}

//pass in heartrate when stressed
void setup_stress(int n) {
  stress_rate = n;
}

void play_music() {
  CalmMusic.play();
}

void play_buzzer() {
  Buzzer.jump(0.0);
}

//pass in current heartrate. plays buzzer if current hr is in stress range
void check_stress(int hr) {
if (hr > stress_rate) {play_buzzer();}
}
