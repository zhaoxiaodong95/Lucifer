// Import the necessary libraries

import processing.serial.*;
import cc.arduino.*;

// Set up 7 - seg display mode

int disp = 1;

// Set up x and y positions immediately to be used globally

int x = 0;
int y = 0;

Arduino mega; // Create the Arduino object

// Variables for the pins on the top motor's driver
// The top motor is denoted as motor A

int stpA = 2;
int dirA = 3;
int MS1A = 4;
int MS2A = 5;
int ENA = 6;

// Similar declarations are then made for the bottom motor's driver

int stpB = 7;
int dirB = 8;
int MS1B = 9;
int MS2B = 10;
int ENB = 11;

// Set up a variable to store the read value for each pixel
double value = 0;

// Since processing cannot determine an Arduino pin's current state...
// ... we use a boolean to keep track of it
// This is for Stepper B, or the pan stepper, as it rotates back and forth

boolean dir = true;

// Create the background image object
// Defined to be 600 x 600 as is the size of the window
// And it will be read from the program folder

PImage bg = createImage(600,600,RGB);

// Create the image object
// Define it to be 300x300 pixels
// And initalize the pixel array

PImage img = createImage(300, 300, ALPHA);

// Create a font object to write textual output

PFont fnt;

// Create an integer array to store histogram values

int [] histogram = new int[255];

// Boolean that will only turn to true once the begin button is clicked

boolean begin = false;

void setup()
{
  
  // Set up the background image
  
  bg = loadImage("bg.jpg");

  // Initalize the pixel array

  img.loadPixels();

  // Initalize the font object
  // And set the active font as such

  fnt = createFont("Roboto", 10);
  textFont(fnt);

  // Define the size of the output window

  size(600,600);

  // Define the Arduino Object

  mega = new Arduino(this, Arduino.list()[0], 57600);

  // Define the Arduino pin modes

  mega.pinMode(stpA, Arduino.OUTPUT);
  mega.pinMode(dirA, Arduino.OUTPUT);
  mega.pinMode(MS1A, Arduino.OUTPUT);
  mega.pinMode(MS2A, Arduino.OUTPUT);
  mega.pinMode(ENA, Arduino.OUTPUT);

  mega.pinMode(stpB, Arduino.OUTPUT);
  mega.pinMode(dirB, Arduino.OUTPUT);
  mega.pinMode(MS1B, Arduino.OUTPUT);
  mega.pinMode(MS2B, Arduino.OUTPUT);
  mega.pinMode(ENB, Arduino.OUTPUT);

  // Set the default pin modes

  // Ensure that the step pin is set to LOW

  mega.digitalWrite(stpA, Arduino.LOW);
  mega.digitalWrite(stpB, Arduino.LOW);

  // Pull both of the enabler pins to LOW
  // This allows control of the stepper motor...
  // ... through the Arduino and motor driver

  //println("Enabler A and B both set to LOW");

  mega.digitalWrite(ENA, Arduino.LOW);
  mega.digitalWrite(ENB, Arduino.LOW);

  // Hard set the direction of both motors to LOW
  // Direction of A remains low while B changes later
  // Motor A only rotates on one direction, anyway, since...
  // ... the motor assembly scans the image line by line

  //println("Direction A hardset to LOW");

  mega.digitalWrite(dirA, Arduino.LOW);
  mega.digitalWrite(dirB, Arduino.LOW);

  // Set up a countdown to ensure that all necessary...
  // ... pins and initalizations for the Arduino are complete

  for(int i = 0; i < 5; i++)
  {

    println("Starting in: " + (5-i) + ".");
    delay(1000);

  }

  // We now begin looping

  //println("Sequence begin.");

}

void sense()
{
  
  value = 0;

  // Begin reading the values
  // Each pixel is imaged 5 times quickly
  // The exposures are stacked as a method...
  // ... to increase sensitivity
  // It can also be thought of as taking...
  // ... five images, finding the average, then...
  // ... amplifying the output by 5
  
  value = 5 * mega.analogRead(10);
  
  if(value > 254)
  {
    value = 254;
  }
  
  //println("Value: " + value);

}

void turnMotor()
{

  // Write the microstepping pins
  // Will be set to quarter steps for actual runs

  mega.digitalWrite(MS1A, Arduino.LOW);
  mega.digitalWrite(MS2A, Arduino.HIGH);

  mega.digitalWrite(MS1B, Arduino.LOW);
  mega.digitalWrite(MS2B, Arduino.HIGH);
  
  if(y == 299)
  {
    up(300, false);
    println("We're done here.");
    save("we done bois.jpg");
    begin = false;
  }
  
  if(dir) // If the current direction is clockwise...
  {
    if((x+1) == 300) // First check to see if the next x value will be the end of the image
    {
      y++; // Increment the y value

      delay(10); // Have a slight delay, might not be necessary in final rev. 

      mega.digitalWrite(stpA, Arduino.HIGH);
      delay(1);
      mega.digitalWrite(stpA, Arduino.LOW);
      delay(1);

      //println("dir is true, set dirB HIGH");
      mega.digitalWrite(dirB, Arduino.HIGH);
      
      dir = false; 
        
      delay(10);
    }

    else // Otherwise just step forward with the motor
    {
      //println("Motor B Stepped.");
      x++;

      mega.digitalWrite(stpB, Arduino.HIGH);
      delay(1);
      mega.digitalWrite(stpB, Arduino.LOW);
      delay(1);

    }
  }

  else
  {
    if((x-1) == -1)
    {
      y++;

      delay(10);

      //println("Motor A Stepped.");

      mega.digitalWrite(stpA, Arduino.HIGH);
      delay(1);
      mega.digitalWrite(stpA, Arduino.LOW);
      delay(1);

      //println("dir is false, set dirB LOW");
      mega.digitalWrite(dirB, Arduino.LOW);
      dir = true;

      delay(10);
    }

    else
    {
      //println("Motor B Stepped.");
      x--;

      mega.digitalWrite(stpB, Arduino.HIGH);
      delay(1);
      mega.digitalWrite(stpB, Arduino.LOW);
      delay(1);
    }
  }
}

void up(int steps, boolean speed)
{

  // Write the microstepping pins
  // Will be set to quarter steps for actual runs
  
  if(speed)
  {

    mega.digitalWrite(MS1A, Arduino.LOW);
    mega.digitalWrite(MS2A, Arduino.LOW);
  
    mega.digitalWrite(MS1B, Arduino.LOW);
    mega.digitalWrite(MS2B, Arduino.LOW);
    
  }
  
  else
  {

    mega.digitalWrite(MS1A, Arduino.LOW);
    mega.digitalWrite(MS2A, Arduino.HIGH);
  
    mega.digitalWrite(MS1B, Arduino.LOW);
    mega.digitalWrite(MS2B, Arduino.HIGH);
    
  }
  
  // Set direction to CCW
  mega.digitalWrite(dirA, Arduino.HIGH);
  
  // Step it down some number of times
  
  for(int i = 0; i < steps; i++)
  {    
    mega.digitalWrite(stpA, Arduino.HIGH);
    delay(1);
    mega.digitalWrite(stpA, Arduino.LOW);
    delay(1);
  }
  
}

void down(int steps, boolean speed)
{

  // Write the microstepping pins
  // Will be set to quarter steps for actual runs

  
  if(speed)
  {

    mega.digitalWrite(MS1A, Arduino.LOW);
    mega.digitalWrite(MS2A, Arduino.LOW);
  
    mega.digitalWrite(MS1B, Arduino.LOW);
    mega.digitalWrite(MS2B, Arduino.LOW);
    
  }
  
  else
  {

    mega.digitalWrite(MS1A, Arduino.LOW);
    mega.digitalWrite(MS2A, Arduino.HIGH);
  
    mega.digitalWrite(MS1B, Arduino.LOW);
    mega.digitalWrite(MS2B, Arduino.HIGH);
    
  }
  
  // Set direction to clockwise
  mega.digitalWrite(dirA, Arduino.LOW);
  
  // Step it down some number of times
  
  for(int i = 0; i < steps; i++)
  {
    mega.digitalWrite(stpA, Arduino.HIGH);
    delay(1);
    mega.digitalWrite(stpA, Arduino.LOW);
    delay(1);
  }
  
}

void left(int steps, boolean speed)
{

  // Write the microstepping pins
  // Will be set to quarter steps for actual runs
  
  
  
  if(speed)
  {

    mega.digitalWrite(MS1A, Arduino.LOW);
    mega.digitalWrite(MS2A, Arduino.LOW);
  
    mega.digitalWrite(MS1B, Arduino.LOW);
    mega.digitalWrite(MS2B, Arduino.LOW);
    
  }
  
  else
  {

    mega.digitalWrite(MS1A, Arduino.LOW);
    mega.digitalWrite(MS2A, Arduino.HIGH);
  
    mega.digitalWrite(MS1B, Arduino.LOW);
    mega.digitalWrite(MS2B, Arduino.HIGH);
    
  }
  
  // Set direction to CCW
  mega.digitalWrite(dirB, Arduino.HIGH);
  
  // Step it down some number of times
  
  for(int i = 0; i < steps; i++)
  {
    mega.digitalWrite(stpB, Arduino.HIGH);
    delay(1);
    mega.digitalWrite(stpB, Arduino.LOW);
    delay(1);
  }
  
}

void right(int steps, boolean speed)
{
  
  if(speed)
  {

    mega.digitalWrite(MS1A, Arduino.LOW);
    mega.digitalWrite(MS2A, Arduino.LOW);
  
    mega.digitalWrite(MS1B, Arduino.LOW);
    mega.digitalWrite(MS2B, Arduino.LOW);
    
  }
  
  else
  {

    mega.digitalWrite(MS1A, Arduino.LOW);
    mega.digitalWrite(MS2A, Arduino.HIGH);
  
    mega.digitalWrite(MS1B, Arduino.LOW);
    mega.digitalWrite(MS2B, Arduino.HIGH);
    
  }
  
  // Set direction to clockwise
  mega.digitalWrite(dirB, Arduino.LOW);
  
  // Step it down some number of times
  
  for(int i = 0; i < steps; i++)
  {
    mega.digitalWrite(stpB, Arduino.HIGH);
    delay(1);
    mega.digitalWrite(stpB, Arduino.LOW);
    delay(1);
  }
  
}

void mouseClicked()
{
  
  if(begin == false)
  {
    if(mouseX > 360 && mouseX < 570 && mouseY > 90 && mouseY < 210)
    {
      up(150, false);
      left(150, false);
      mega.digitalWrite(dirA, Arduino.LOW);
      mega.digitalWrite(dirB, Arduino.LOW);
      begin = true;
    }
    else if(mouseX > 360 && mouseX < 390 && mouseY > 30 && mouseY < 60)
    {
      left(1, true);
    }
    else if(mouseX > 420 && mouseX < 450 && mouseY > 30 && mouseY < 60)
    {
      up(1, true);
    }
    else if(mouseX > 480 && mouseX < 510 && mouseY > 30 && mouseY < 60)
    {
      down(1, true);
    }
    else if(mouseX > 540 && mouseX < 570 && mouseY > 30 && mouseY < 60)
    {
      right(1, true);
    }
    else if(mouseX > 360 && mouseX < 450 && mouseY > 240 && mouseY < 330)
    {
      right(300, false);
      down(300, false);
      left(300, false);
      up(300, false);
    }
    else if(mouseX > 480 && mouseX < 570 && mouseY > 240 && mouseY < 330)
    {
      up(150, false);
      left(150, false);
      delay(1000);
      right(150, false);
      down(150, false);
    }
    else if(mouseX > 480 && mouseX < 570 && mouseY > 360 && mouseY < 570)
    {
      disp++;
      if(disp == 4)
      {
        disp = 1;
      }
    }
  }
  
}

void sevSeg(int num)
{
  
  int pinOne = 22;
  
  // Temporary variables to store the binary digits

  boolean bin8 = false;
  boolean bin4 = false;
  boolean bin2 = false;
  boolean bin1 = false;

  // Pin one is a0 on the 74LS47 for the hundreds, thus pin two is a1 and so on...
  // Thus pin one + 4 is a0 (this time denoted b0) for the tens
  // And adding another 4 gets you to c0, which is for the ones

  int a0 = pinOne;
  int a1 = pinOne + 1;
  int a2 = pinOne + 2;
  int a3 = pinOne + 3;

  int b0 = pinOne + 4; 
  int b1 = pinOne + 5;
  int b2 = pinOne + 6;
  int b3 = pinOne + 7;

  int c0 = pinOne + 8;
  int c1 = pinOne + 9;
  int c2 = pinOne + 10;
  int c3 = pinOne + 11;

  // Set all the pins to output mode

  mega.pinMode(a0, Arduino.OUTPUT);
  mega.pinMode(a1, Arduino.OUTPUT);
  mega.pinMode(a2, Arduino.OUTPUT);
  mega.pinMode(a3, Arduino.OUTPUT);
  
  mega.pinMode(b0, Arduino.OUTPUT);
  mega.pinMode(b1, Arduino.OUTPUT);
  mega.pinMode(b2, Arduino.OUTPUT);
  mega.pinMode(b3, Arduino.OUTPUT);
  
  mega.pinMode(c0, Arduino.OUTPUT);
  mega.pinMode(c1, Arduino.OUTPUT);
  mega.pinMode(c2, Arduino.OUTPUT);
  mega.pinMode(c3, Arduino.OUTPUT);

  // Set all the pins to output low so defaults to all zeroes

  mega.digitalWrite(a0, Arduino.LOW);
  mega.digitalWrite(a1, Arduino.LOW);
  mega.digitalWrite(a2, Arduino.LOW);
  mega.digitalWrite(a3, Arduino.LOW);
  
  mega.digitalWrite(b0, Arduino.LOW);
  mega.digitalWrite(b1, Arduino.LOW);
  mega.digitalWrite(b2, Arduino.LOW);
  mega.digitalWrite(b3, Arduino.LOW);
  
  mega.digitalWrite(c0, Arduino.LOW);
  mega.digitalWrite(c1, Arduino.LOW);
  mega.digitalWrite(c2, Arduino.LOW);
  mega.digitalWrite(c3, Arduino.LOW);

  // Convert into digits

  int dig1 = num / 100;         // Hundreds digit
  int dig2 = (num % 100) / 10;  // Tens digit
  int dig3 = (num % 100) % 10;  // Ones digit

  // Writing seven segment "A"
  // First, convert to binary
  // I know this is messy, but it's pretty utilitarian, so I'm not modifying it

  if((dig1 / 8) == 1)
  {
    bin8 = true;
  }

  if(((dig1 % 8) / 4) == 1)
  {
    bin4 = true;
  }

  if((((dig1 % 8) % 4) / 2) == 1)
  {
    bin2 = true;
  }
  
  if((((dig1 % 8) % 4) % 2) == 1)
  {
    bin1 = true;
  }

  // Now to write a similar series of if statements to write the pins

  if(bin1)
  {
    mega.digitalWrite(a0, Arduino.HIGH);
  }

  if(bin2)
  {
    mega.digitalWrite(a1, Arduino.HIGH);
  }

  if(bin4)
  {
    mega.digitalWrite(a2, Arduino.HIGH);
  }

  if(bin8)
  {
    mega.digitalWrite(a3, Arduino.HIGH);
  }

  // The rest of this code has not been commented for brevity
  // However, it is the same algorithm as the above
  // Simply the variable names are changed
  // It is assumed that the reader is able to understand it as such

  if((dig2 / 8) == 1)
  {
    bin8 = true;
  }

  if(((dig2 % 8) / 4) == 1)
  {
    bin4 = true;
  }

  if((((dig2 % 8) % 4) / 2) == 1)
  {
    bin2 = true;
  }
  
  if((((dig2 % 8) % 4) % 2) == 1)
  {
    bin1 = true;
  }

  if(bin1)
  {
    mega.digitalWrite(b0, Arduino.HIGH);
  }

  if(bin2)
  {
    mega.digitalWrite(b1, Arduino.HIGH);
  }

  if(bin4)
  {
    mega.digitalWrite(b2, Arduino.HIGH);
  }

  if(bin8)
  {
    mega.digitalWrite(b3, Arduino.HIGH);
  }
  

  if((dig3 / 8) == 1)
  {
    bin8 = true;
  }

  if(((dig3 % 8) / 4) == 1)
  {
    bin4 = true;
  }

  if((((dig3 % 8) % 4) / 2) == 1)
  {
    bin2 = true;
  }
  
  if((((dig3 % 8) % 4) % 2) == 1)
  {
    bin1 = true;
  }

  if(bin1)
  {
    mega.digitalWrite(c0, Arduino.HIGH);
  }

  if(bin2)
  {
    mega.digitalWrite(c1, Arduino.HIGH);
  }

  if(bin4)
  {
    mega.digitalWrite(c2, Arduino.HIGH);
  }

  if(bin8)
  {
    mega.digitalWrite(c3, Arduino.HIGH);
  }
  
}

void draw()
{
  
  // Background image drawn first
  
  image(bg, 0, 0, 600, 600);
  
  if(begin == true)
  {
    
    sense();
  
    //println("Input at (" + x + ", " + y + ") is: " + value);
    //println("Average is: " + (value/5));
  
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Image drawing
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    // Set the pixel colour to be based off the read...
    // ... value and then update the pixel array
  
    img.pixels[y*300+x] = color((int)value);
    img.updatePixels();
  
    // Add current value to histogram data
    
    //println("Added another " + value + " to the histogram");
  
    histogram[(int)value] ++;
  
    // Image is then drawn
    
    image(img, 30, 30, 300, 300);
  
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Histogram drawing
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    // And then draw the histogram
    
    stroke(255);
  
    for(int i = 0; i < 255; i++)
    {
  
      int max = max(histogram);
      //println("Max: " + max);
  
      //println("Histogram at : " + (i + 1));
      //println("Value is: " + histogram[i]);
      //println("Drawn from " + (30+i) + " to " + (210/max)*histogram[i]);
      //line(30 + i, 570, 30 + i, 570 - (210.0/max)*histogram[i]);
      rect(30+i, 570 - (210.0/max)*histogram[i], (300.0/200.0)*3, (210.0/max)*histogram[i]);
  
    }
  
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Text Drawing
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    // We the draw the text for the scanning section
  
    // First, we set it so that the colour is white
  
    fill(255);
  
    // Output the text
  
    text("Scanning", 360, 390);
    text("X: " + (x+1), 370,405);
    text("Y: " + (y+1), 370, 420);
    text("Intensity: " + (int)value, 340, 435);
    text("Lux: " + (int)value * (1000.0/1024.0), 340, 450);
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Text Drawing based on mouse hover
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    int mX;
    int mY;
  
    if(mouseX < 30)       { mX = 0;           }
    else if(mouseX > 330) { mX = 299;         }
    else                  { mX = mouseX - 31; }
    
    if(mX < 0)
    {
      mX = 0;
    }
  
    if(mouseY < 30)       { mY = 0;           }
    else if(mouseY > 330) { mY = 299;         }
    else                  { mY = mouseY - 31; }
    
    if(mY < 0)
    {
      mY = 0;
    }
  
    // Output the text
  
    text("Hovering", 360, 480);
    text("X: " + mX, 370,495);
    text("Y: " + mY, 370, 510);
    
    if(red(color(img.pixels[mY*300+mX])) == 0)
    {
      text("Intensity: Undefined", 340, 525);
      text("Lux: Undefined", 350, 540);
    }
    
    else
    {
      text("Intensity: " + red(color(img.pixels[mY*300+mX])), 430, 525);
      text("Lux: " + red(color(img.pixels[mY*300+mX])) * (1000.0/1024.0), 430, 540);
    }
    
    turnMotor();
    
  }
  
  else
  {
    
    fill(255);
    text("Waiting for input...", 130, 180);
    
  }

}