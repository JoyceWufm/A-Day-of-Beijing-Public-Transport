import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.providers.StamenMapProvider;
import de.fhpotsdam.unfolding.providers.ThunderforestProvider;
import de.fhpotsdam.unfolding.providers.Google;
import de.fhpotsdam.unfolding.providers.EsriProvider;
import de.fhpotsdam.unfolding.providers.GeoMapApp;
import de.fhpotsdam.unfolding.events.EventDispatcher;
import de.fhpotsdam.unfolding.events.MapEvent;
import de.fhpotsdam.unfolding.events.PanMapEvent;
import de.fhpotsdam.unfolding.events.ZoomMapEvent;
import de.fhpotsdam.unfolding.interactions.MouseHandler;
import de.fhpotsdam.unfolding.ui.BarScaleUI;
import de.fhpotsdam.unfolding.ui.CompassUI;
import controlP5.*;
import java.awt.*;
import java.util.List;
import javax.swing.JFrame;
import java.util.Arrays;
import java.awt.*;
import java.awt.event.*;
import java.util.Arrays;
import java.io.*;
import java.io.File;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.text.ParseException; 
import java.util.Date;
import java.text.SimpleDateFormat; 

//***********************************parameters of movement analysis************************************//
UnfoldingMap mapwd;
UnfoldingMap mapwk;
UnfoldingMap map1;
UnfoldingMap map2;
UnfoldingMap map3;
UnfoldingMap map4;
List<Marker> Trajectorywd = new ArrayList<Marker>();
List<Marker> Trajectorywk = new ArrayList<Marker>();
List<Marker> Trajectory = new ArrayList<Marker>();
Location BeijingLocation = new Location(39.9459631, 116.391248);


//colorsets and strings of transport mode legend
int [] colorset = {161, 255, 0, 41, 235, 255, 255, 72, 0, 27, 134, 228, 136, 142, 226, 255, 44, 161, 255, 147, 141};
String [] transportm = {"Bike", "Bus", "Car", "Subway", "Taxi", "Train", "Walk"};
boolean [] tm = {false, false, false, false, false, false, false}; //transport mode selection, false means selected, true means unselected
int t1 = 1; //ID of trajectory, 1 means trajectory in weekday, 2 means trajectory in weekend
int t2 = 2;
int lx = 770; //legend x
int ly = 190; //legend y
int tx = 1330; //read me x
int ty = 820; //read me y
int bw = 35; //button width
int bl = 20; //button length
int runtimes = 0; //time since sketch started
int runtimep; //previous run time s
int speed=100; //speed of trajectory display
int timeh=0; //current time of trajectory in hours
int timem=0;//current time of trajectory in minutes
boolean s = false; // s = true, time is runing, s = false, paused
boolean modeswitch = false; //modeswitch = false, in movement analysis mode, modeswitch = true, in stay point mode

//parameters for graphes 
int w1=1180, h1=880;//weekends
int w2=380, h2=880;//weekdays
int w3=810, h3=880;//sector
int r; //timephrase

int radiu=70;//
String[][] data1=new String[24][7];
String[][] data2=new String[24][7];

//parameters for the timeslider
ControlP5 controlP5;
Toggle switchButton;
controlP5.Slider sliderbutton;
controlP5.Button backwardsbutton;
controlP5.Button forwardsbutton;
controlP5.Button playbutton;
controlP5.Button speeddownbutton;
controlP5.Button speedupbutton;

//***********************************parameters of stay point analysis************************************//
String filefolder;
int skipline= 6, col=7, zoomlevel;
SimpleDateFormat sdftime = new SimpleDateFormat("HH:mm:ss");
UnfoldingMap map; 
EventDispatcher eventDispatcher; 
MouseHandler mouseHandler; 
MarkerManager<Marker> markerManager;
public static int interval = 80000000; // the time interval for showing data, in seconds
public float staythre = 86400; // the threshold for stay interval to pick interest places, in seconds
public float disthre = 0.5;  // the threshold for moving circle to pick interest places, in kilometers
float barYt, barYd, pointerXt, pointerXd, xOffsett = 160, xOffsetd = 0;
ArrayList<ArrayList<Movement>> rawdata; //rawdata for stay-point
ArrayList<Location> interestlo;
ArrayList<String> interestna;
float[] arcStartPositions = new float[3]; 
float arcBoundSize, arcMaxBoundSize = 70, arcLength;
boolean flag=false, overPointert=false, overPointerd=false, locked=false, mousescroll=false;
BarScaleUI barScale; 
CompassUI compass;
PImage compimage;

PFont font;
PImage logo;
// The font must be located in the sketch's 
// "data" directory to load successfully


