/*
challenge2-bubblerealtest, by Zhiping Zhang, a part of the work for challenge 2 of DBB100(2018-1) Creative Programming in TU/e,
This programming is to call the air pressure data from Aduino and use the data for generating dynamics bubble visual feedback and bubble sounds as auditory feedback.
The bubble drawing function is inspired by one of the Josie Hrenak 's processing work named BubbleGenerator_arrayList, which can be accessed from https://www.openprocessing.org/sketch/341837 
*/

import javafx.scene.media.Media;
import javafx.scene.media.MediaPlayer;
import javafx.embed.swing.JFXPanel;
import processing.serial.*;
import java.lang.Math;
import processing.sound.*;


Serial port;
float val = 90; // initital air pressure
float previous=90; // record previous pressure

PImage buble;  //image for bubbles
float counter;  //set a counter to record time
float br, bg, bb; //color variables
float x, y, dx, dy; // bubble starting positions and moving directions
int start_distance = 200; //the starting position from the edge
ArrayList bubbles;  // list for bubbles

// absolute path for background music
//please change the path before running this programming in your computer
String path = "C:\\Users\\Lenovo\\Documents\\TUE Master\\Creative Programming\\C2\\1113\\challenge2-zhiping zhang\\bubblerealtest\\1.mp3";
Media bg_music;
MediaPlayer mediaPlayer;
float record; // a variable to control how long the background music lasts at full volume
float bubble_stay_time = 50; // time for bubbles to "pop"
float vol_normal = 0.02; // music volume when no bubbles are created
float vol_bubble = 0.015; // music volume when generating bubbles
Sound s_blow_bubble; // Sound effect object for bubbles

// define different speed for bubbles at different pressure
float high_speed = 15;
float mid_speed = 10;
float low_speed = 5;

void setup() {
  fullScreen();
  background(0);
  buble = loadImage("bubbles.png");
  bubbles = new ArrayList();
  
  // connect to the arduino
  String arduinoPort=Serial.list()[0];
  port=new Serial(this, arduinoPort, 9600);
  
  final JFXPanel fxPanel = new JFXPanel();//for music

  // background music settings
  bg_music = new Media(new File(path).toURI().toString());
  mediaPlayer = new MediaPlayer(bg_music);
  mediaPlayer.setCycleCount(MediaPlayer.INDEFINITE); // loop the music
  //mediaPlayer.setRate(1.0); // set at which rate the music plays
  mediaPlayer.setVolume(vol_normal); // initialize the music volume
  mediaPlayer.play();
  
  // genrate sound effect for bubbles
  SinOsc sin = new SinOsc(this);
  sin.play(200, 0.2);
  
  // Create a Sound object for globally controlling the output volume.
  s_blow_bubble = new Sound(this);
}

void draw() {
  background(0);
  // set the bubble RGB color
  br = 255; 
  bg = 255; 
  bb = 255;
  
  if (port.available()>0) {
    val=port.read();
  }
  //println(val);//for checking
  
  // generate random integers for choosing the starting position for bubbles
  int upper = 5;
  int lower = 1;
  int choice = (int)(Math.random()*(upper - lower) ) +lower;
  //println("choose:" + choice);
  //println("counter:" +counter);
  //println("record:"+record);
  //println("volume:"+mediaPlayer.getVolume());
  
  // choose a starting corner for the bubbles
  if (choice == 1) {                        //left-bottom
    x = start_distance;
    y = height-start_distance;
    dy = -1;
  }
  else if (choice == 2){                    //right-top
    x = width - start_distance;
    y = start_distance;
    dx = -1;
  }
  else if (choice == 3){                   //right-bottom
    x = width - start_distance;
    y = height - start_distance;
    dx = -1;
    dy = -1;
  }
  else{                                    //left-top
    x = start_distance;
    y = start_distance;
    dx = 1;
    dy = 1;
  }
  
  // based on different pressure, set different color and speed for bubbles
  if (val-previous>20 && val-previous<=50) {
    bubbles.add(new Bubble(br, bg/2, bb,x,y,dx,dy, low_speed, low_speed));
    mediaPlayer.setVolume(vol_bubble);
    record = counter; // record the current "time"
    s_blow_bubble.volume(1); // sound effect for bubble blowing
  } else if (val-previous>50 && val-previous<=80) {
    bubbles.add(new Bubble(br/2, bg, bb, x, y, dx, dy, mid_speed, mid_speed));
    mediaPlayer.setVolume(vol_bubble);
    record = counter;
    s_blow_bubble.volume(1);
  } else if (val-previous>80) {
    bubbles.add(new Bubble(br, bg, bb, x, y, dx, dy, high_speed, high_speed));
    mediaPlayer.setVolume(vol_bubble);
    record = counter;
    s_blow_bubble.volume(1);
  }
  else{
    if(counter - record >= bubble_stay_time){ // make the full-volume music last for 10 iterations
      mediaPlayer.setVolume(vol_normal); // set the volume to the normal level
      record = counter;
    }
    s_blow_bubble.volume(0); // bubble sound effect off
  }

  // record the current pressure for commparison in the next iteration
  previous=val;

  // loop over all "bubble"s, update there positions
  for (int i = bubbles.size()-1; i >= 0; i--) { 
    Bubble bubble = (Bubble)bubbles.get(i);
    bubble.update();
    bubble.display();
  }

  counter += 1;
  if (counter % 30 == 0) { //bubbles "pop" after a certain amount of time passes
    if (bubbles.size() > 0) { //limits removal 
      bubbles.remove(0); //removes oldest bubble
      s_blow_bubble.volume(1); // sound effect for bubble popping
    }
  }
}


//BUBBLE CLASS
class Bubble {
  float dia = random(100, 300); //diameter

  //X Axis Variables
  float locX; //x 
  float locXF; //follower x
  float dirX; //direction on the X-axis
  float speedX; //moving direction on the X-axis
  //Y Axis Variables
  float locY; //y
  float locYF; //follower y
  float dirY;//direction on the Y-axis
  float speedY; //moving direction on the Y-axis

  //color variables 
  float r, g, b;
  
  // initialize a bubble
  Bubble(float cr, float cg, float cb, float x, float y, float dx, float dy, float sx, float sy) {  
    r = cr; 
    g = cg; 
    b = cb;
    
    locX = x;
    locXF = locX;
    locY = y;
    locYF = locY;
    dirX = random(1, 5) * dx;
    dirY = random(1, 5) * dy;
    speedX = sx;
    speedY = sy;
  } 

  void update() { // update the bubble position
    locX += speedX * dirX; //X velocity
    locY += speedY * dirY; //Y velocity 
    
    // bubble bounces when hitting the "wall"
    if (locX >= width - (dia/2)) { //right wall
      locX = width-(dia/2); 
      dirX *= -1;
      speedX = random(1, 3);
    }
    if (locX <= 0 + (dia/2)) { //left wall
      locX = 0 + (dia/2);
      dirX *= -1;
      speedX = random(1, 3);
    }
    // Y bounce
    if (locY >= height - (dia/2)) { //bottom wall
      locY = width-(dia/2);
      dirY *= -1;
      speedY = random(1, 3);
    }
    if (locY <= 0 + (dia/2)) { //top wall
      locY = 0 + (dia/2);
      dirY *= -1;
      speedY = random(1, 3);
    } 

    //movement
    locXF += (locX-locXF)*0.1;
    locYF += (locY-locYF)*0.1;
  } 

  void display() {

    imageMode(CENTER);
    tint(r, g, b);
    image(buble, locXF, locYF, dia, dia);
  }
}
