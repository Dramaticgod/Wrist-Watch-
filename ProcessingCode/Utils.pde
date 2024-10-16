// Function to calculate the average of an array of integers
float average(int[] values) {
  int sum = 0;
  for (int i = 0; i < values.length; i++) {
    sum += values[i];
  }
  return (float) sum / values.length;
}

// Function to calculate the average of an array of floats
float average(float[] values) {
  float sum = 0;
  for (int i = 0; i < values.length; i++) {
    sum += values[i];
  }
  return sum / values.length;
}


float dynamicAverage(ArrayList<Integer> dynamicIntegers) {
  if (dynamicIntegers.size() == 0) {
    return 0; // Return 0 to avoid division by zero
  }
  
  int sum = 0; // Variable to store the sum of integers
  for (int value : dynamicIntegers) {
    sum += value; // Add each value to the sum
  }
  
  return (float)sum / dynamicIntegers.size(); // Calculate and return the average
}
