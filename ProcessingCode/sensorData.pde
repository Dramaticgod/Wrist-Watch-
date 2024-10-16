// Custom Class to store and parse data recieved over serial

public class SensorData {
  public int heartrate;
  public int confidence;
  public int oxygen;
  public int status;
  public String rawSerial;   // raw input that we recieve over serial
  public int inputDataStatus;   // set to 1 when data is read successfully

  // Constructor
  public SensorData() {  
    heartrate = 0;
    confidence = 0;
    oxygen = 0;
    status = 0;
    rawSerial = "";
    inputDataStatus = 0;
  }

  // Method to parse and update sensor data
  public void updateFromSerial(String serialData) {
    rawSerial = trim(serialData);

    if (rawSerial == null || rawSerial.isEmpty()) {
      inputDataStatus = 0;
      return;
    }

    String[] serialDataSplit = rawSerial.split(";");    //split incoming data into 4 parts of an array

    if (serialDataSplit.length != 4) {
      inputDataStatus = 0;
      println("Invalid data: " + rawSerial);
      return;
    }

    try {
      heartrate = Integer.parseInt(serialDataSplit[0]);
      confidence = Integer.parseInt(serialDataSplit[1]);
      oxygen = Integer.parseInt(serialDataSplit[2]);
      status = Integer.parseInt(serialDataSplit[3]);
      inputDataStatus = 1;          // if read successfully change data status to 1 
    } catch (NumberFormatException e) {
      inputDataStatus = 0;
      println("Error parsing data: " + rawSerial);      //catch any other errors 
    }
  }
}
