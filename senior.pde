// Import the Meter and Serial libraries
import meter.*;
import processing.serial.*;

// Create instances of the Meter class
Meter m1;
Meter m2;
Meter m3;

// Declare variables to store the heart rate, SPO2, and temperature readings
int heartRate;
int spo2;
int temperature;

// Declare variables to store the heart rate, SPO2, and temperature readings
Serial myPort;

void setup() {
  // Open the serial port for communication at 115200 baud
  myPort = new Serial(this, "COM5", 115200);

  // Set the size of the window and the background color
  size(1500, 300);
  background(245,218,223);

  // Create the meter objects, with 1/2 circles
  m1 = new Meter(this, 30, 15, false); // full circle - true, 1/2 circle - false
  m2 = new Meter(this, 530, 15, false);
  m3 = new Meter(this, 1030, 15, false);

  // Set the minimum and maximum scale values for each meter
  m1.setMinScaleValue(0);
  m1.setMaxScaleValue(200);
  m2.setMinScaleValue(0);
  m2.setMaxScaleValue(100);
  m3.setMinScaleValue(0);
  m3.setMaxScaleValue(50);

  // Display the digital meter value and title for each meter
  m1.setDisplayDigitalMeterValue(true);
  m1.setTitle("Heart rate");
  m2.setDisplayDigitalMeterValue(true);
  m2.setTitle("SP02");
  m3.setDisplayDigitalMeterValue(true);
  m3.setTitle("Temperature");

  // Set the scale labels for each meter
  String[] scaleLabels1 = {"0", "20", "40", "60", "80", "100", "120", "140", "160", "180", "200"};
  String[] scaleLabels2 = {"0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"};
  String[] scaleLabels3 = {"0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50"};
 
  // Set the number of short ticks between long ticks for each meter
  m1.setScaleLabels(scaleLabels1);
  m1.setShortTicsBetweenLongTics(9);
  m2.setScaleLabels(scaleLabels2);
  m2.setShortTicsBetweenLongTics(9);
  m3.setScaleLabels(scaleLabels3);
  m3.setShortTicsBetweenLongTics(9);
  
  // Set the range for the heart rate meter
  m1.setMinScaleValue(0);
  m1.setMaxScaleValue(200);         // Scale maximum value
  m1.setMinInputSignal(0);
  m1.setMaxInputSignal(200);        // Scale max reading
  
  // Set the range for the SPO2 meter
  m2.setMinScaleValue(0);
  m2.setMaxScaleValue(100);         // Scale maximum value
  m2.setMinInputSignal(0);
  m2.setMaxInputSignal(100);        // Scale max reading
  
  // Set the range for the temperature meter
  m3.setMinScaleValue(0);
  m3.setMaxScaleValue(50);         // Scale maximum value
  m3.setMinInputSignal(0);
  m3.setMaxInputSignal(50);        // Scale max reading
}

void draw() {
  // Check if data is available on the serial port
  if (myPort.available() > 0) {
    // Read data as string
    String data = myPort.readStringUntil('\n').trim();

    // Split the string by comma to get the readings
    String[] readings = split(data, ",");
    int heartRate = int(readings[0]);
    int spo2 = int(readings[1]);
    int temperature = int(readings[2]);

    // Update the meters with the readings
    m1.updateMeter(heartRate);
    m2.updateMeter(spo2);
    m3.updateMeter(temperature);
    
    // Print the readings to the console - for checking purposes 
    System.out.println("Heart rate = " + heartRate) ;
    System.out.println("sp02 = " + spo2) ;
    System.out.println("Temperature = " + temperature) ;
  }

  // Use a delay to see the changes.
  delay(100);
}
