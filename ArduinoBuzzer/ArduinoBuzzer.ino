
#include <SPI.h>
#include <pitches.h>

// Pin configuration for the buzzer
#define BUZZER_PIN 8  

// Hedwig's Theme melody and duration data
int lowFoodMelody[] = {
  REST, 2, NOTE_D4, 4,
  NOTE_G4, -4, NOTE_AS4, 8, NOTE_A4, 4,
  NOTE_G4, 2, NOTE_D5, 4,
  NOTE_C5, -2, 
  NOTE_A4, -2,
  NOTE_G4, -4, NOTE_AS4, 8, NOTE_A4, 4,
  NOTE_F4, 2, NOTE_GS4, 4,
  NOTE_D4, -1, 
  NOTE_D4, 4,
  // Additional notes can be added as needed
};

int lowFoodNotes = sizeof(lowFoodMelody) / sizeof(lowFoodMelody[0]) / 2;
int lowFoodTempo = 144;
int lowFoodWholeNote = (60000 * 4) / lowFoodTempo;
int lowFoodDivider = 0, lowFoodNoteDuration = 0;

int melody[] = {
    NOTE_AS4, NOTE_AS4, NOTE_AS4,
    NOTE_F5, NOTE_C6, NOTE_AS5, NOTE_A5, NOTE_G5, NOTE_F6, NOTE_C6,
    NOTE_AS5, NOTE_A5, NOTE_G5, NOTE_F6, NOTE_C6, NOTE_AS5, NOTE_A5,
    NOTE_AS5, NOTE_G5, NOTE_C5, NOTE_C5, NOTE_C5, NOTE_F5, NOTE_C6,
    NOTE_AS5, NOTE_A5, NOTE_G5, NOTE_F6, NOTE_C6, NOTE_AS5, NOTE_A5,
    NOTE_G5, NOTE_F6, NOTE_C6, NOTE_AS5, NOTE_A5, NOTE_AS5, NOTE_G5,
    NOTE_C5, NOTE_C5, NOTE_D5, NOTE_D5, NOTE_AS5, NOTE_A5, NOTE_G5,
    NOTE_F5, NOTE_F5, NOTE_G5, NOTE_A5, NOTE_G5, NOTE_D5, NOTE_E5,
    NOTE_C5, NOTE_C5, NOTE_D5, NOTE_D5, NOTE_AS5, NOTE_A5, NOTE_G5,
    NOTE_F5, NOTE_C6, NOTE_G5, NOTE_G5, REST, NOTE_C5, NOTE_D5,
    NOTE_D5, NOTE_AS5, NOTE_A5, NOTE_G5, NOTE_F5, NOTE_F5, NOTE_G5,
    NOTE_A5, NOTE_G5, NOTE_D5, NOTE_E5, NOTE_C6, NOTE_C6, NOTE_F6,
    NOTE_DS6, NOTE_CS6, NOTE_C6, NOTE_AS5, NOTE_GS5, NOTE_G5, NOTE_F5,
    NOTE_C6
};

int durations[] = {
    8, 8, 8, 2, 2, 8, 8, 8, 2, 4, 8, 8, 8, 2, 4, 8, 8, 8, 2, 8,
    8, 8, 2, 2, 8, 8, 8, 2, 4, 8, 8, 8, 2, 4, 8, 8, 8, 2, 8, 16,
    4, 8, 8, 8, 8, 8, 8, 8, 8, 4, 8, 4, 8, 16, 4, 8, 8, 8, 8, 8,
    8, 16, 2, 8, 8, 4, 8, 8, 8, 8, 8, 8, 8, 8, 4, 8, 4, 8, 16, 4,
    8, 4, 8, 4, 8, 4, 8, 1
};

const unsigned long playDuration = 60000; // 60 seconds 
unsigned long startTime = 0;

void setup() {
    Serial.begin(9600);
    pinMode(BUZZER_PIN, OUTPUT); // Setup buzzer pin as an output
  
}

void loop() {
    readSerial();
}

void playStressMode() {
    unsigned long lowFoodStartTime = millis();
    int buzzDuration = 500; // Duration of each buzz in milliseconds
    int pauseDuration = 500; // Pause between buzzes in milliseconds

    for (int i = 0; i < 2; i++) { // Play buzzing sound twice
        tone(BUZZER_PIN, NOTE_A4, buzzDuration); // Play buzzing sound (A4 note)
        delay(buzzDuration); // Wait for the buzz duration
        noTone(BUZZER_PIN); // Stop the tone
        delay(pauseDuration); // Wait for the pause duration before next buzz
    }
}

void playCalmMode() {
    int notes = sizeof(melody) / sizeof(melody[0]); 
    for (int note = 0; note < notes; note++) {
        int duration = 1000 / durations[note];
        tone(BUZZER_PIN, melody[note], duration);  
        int pauseBetweenNotes = duration * 1.30;   
        delay(pauseBetweenNotes);
        noTone(BUZZER_PIN);
        if ((millis() - startTime) >= playDuration) break;
    }
}

void readSerial() {
    if (Serial.available() > 0) {
        char receivedChar = Serial.read();
        if (receivedChar == 'C') {
            startTime = millis();
            playCalmMode();
        } 
        else if (receivedChar == 'S') {
            startTime = millis();
            playStressMode();
        }
    }
}
