import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Processing_Interface extends PApplet {

/*****************************************************************************
GEOM90007 Spatial Visualisation
Assignment 3: Major Project
Haoyu Pang 744692
Cheng Li 788552
Fumi Wu 744870
Kaiming Sun 763821

Aims:        Present and explore the Geolife data to reveal the travel patterns
             and stay points of travellers.
             
Decriptions: This interface visualise the trajectory dataset collected through
             GPS. There are two modes, movement analysis and stay point anaylysis.
             Movement analysis presents the movement in different hours in
             weekend and weekday with the transport mode used.
             Stay point analysis presents the possible areas within specific
             radius that people stay for a specific time.
             
Functions:   1. mapping trajectories;
             2. present different transport mode usages in star charts;
             3. present trajotory number in weekday and weekend;
             4. add play functions to pause or speed up the visualisation;
             5. transport mode selection button in the legend;
             6. slider to select the stay radius and stay time of stay point 
                analysis;
             7. basic panning and zooming of maps.
             
Data:        Geolife Trajectories 1.3
Environment: Processing 2.2.1
Libraries:   Unfolding maps 0.9.6, ControlP5 2.1.5
Sources:     GeoLife GPS Trajectories in Microsof Research Asia
             Unfolding maps examples
*****************************************************************************/

/********************************************************************
Description: load data and create maps and buttons
********************************************************************/
public void setup() 
{
  size(1600, 1000, P2D);  

  List<Feature> trwd = GeoJSONReader.loadData(this, "Weekday.geojson");
  Trajectorywd = MapUtils.createSimpleMarkers(trwd);

  List<Feature> trwk = GeoJSONReader.loadData(this, "Weekend.geojson");
  Trajectorywk = MapUtils.createSimpleMarkers(trwk);

  //map displaying weekday and weekend data with StamenMap as a basemap
  map1 = new UnfoldingMap(this, "Weekday", 40, 100, 670, 600, true, false, new StamenMapProvider.TonerLite());
  map1.zoomAndPanTo(BeijingLocation, 12);
  map1.addMarkers(Trajectorywd); 
  
  map2 = new UnfoldingMap(this, "Weekend", 900, 100, 670, 600, true, false, new StamenMapProvider.TonerLite());
  map2.zoomAndPanTo(BeijingLocation, 12);  
  map2.addMarkers(Trajectorywk);

  //map displaying weekday and weekend data with ThunderforestMap as a basemap
  map3 = new UnfoldingMap(this, "Weekday", 40, 100, 670, 600, true, false, new ThunderforestProvider.Transport());
  map3.zoomAndPanTo(BeijingLocation, 12);
  map3.addMarkers(Trajectorywd); 

  map4 = new UnfoldingMap(this, "Weekend", 900, 100, 670, 600, true, false, new ThunderforestProvider.Transport());
  map4.zoomAndPanTo(BeijingLocation, 12);  
  map4.addMarkers(Trajectorywk);

  mapwd = map1;
  mapwk = map2;
  MapUtils.createDefaultEventDispatcher(this, mapwd, mapwk, map1, map2, map3, map4);
  
  data1 = loadData("weekends.csv");
  data2 = loadData("weekdays.csv");

  //String datestarts = "20090329"; // 2009 03 7/8/14/15/21/22/28/29 
  rawdata = new ArrayList<ArrayList<Movement>>(); 
  // Arraylist for interesting places: coordinates and names 
  interestlo= new ArrayList<Location>(
  Arrays.asList(new Location(39.99f, 116.26f), new Location(40.01f, 116.30f), new Location(39.989f, 116.306f), 
  new Location(40.00f, 116.32f), new Location(40.064f, 116.582f), new Location(40.068f, 116.129f), 
  new Location(40.0261f, 116.388f), new Location(39.915f, 116.316f ), new Location(39.927f, 116.383f)));
  interestna= new ArrayList<String>(
  Arrays.asList("Summer Palace", "Yuanmingyuan Ruins Park", "Peking University", "Tsinghua University", "Capital Airport", 
  "Beiqing Jiaoye Xiuxian Park", "Dongxiaokou Forest Park", "Yuyuantan Park", "Beihai Park"));
  //The location of pointer for defining threshold  
  pointerXt = width-180;
  pointerXd = width-20;
  filefolder = dataPath("");
  println(filefolder);
  readFile();
//  f = new PFrame();
  compimage=loadImage("compass.png");

  font = createFont("calibrib.ttf", 50);
  textFont(font);

  drawslider();
//  switchButton = controlP5.addToggle("switchmode")
//    .setPosition(80, 50)
//      .setSize(60, 30)
//        .setValue(modeswitch);
        
  logo = loadImage("beijing.png");
}

/********************************************************************
Description: Display different functions
********************************************************************/
public void draw() 
{
  background(250, 243, 225);
  timer(); //control timing of the program
  mapwd.draw(); //visualize weekday trajectory
  shadeTra(t1); 
  mapwk.draw(); //visualize weekend trajectory
  shadeTra(t2);  
  transport(); //draw the transport legend
  infoDisplay(); //display almost text information
  

  stroke(0);
    
    gweekend();
    gweekday();
    frame();
    graduation();
    piechart();
    
    stroke(0);
    arrow();
    
    saveFrame("Output1/traffic_######.tif");
}

/********************************************************************
Description: display all the text information in program
********************************************************************/
public void infoDisplay()
{
  image(logo, 710, 100);
  textSize(40);
  fill(0);
  text("Beijing Residents Trajectory", 600, 50);
  textSize(30);
  fill(0, 102, 153);
  text("Movement Analysis", 80, 30);
  textSize(18);
//  text("Mode Switch", 150, 70);
  fill(0);
  textSize(30);
  text("Weekday", 340, 90);
  text("Weekend", 1180, 90);
  textSize(13);
  fill(0, 102, 153);  
  text("Read Me", tx, ty);
  text("SPACE - start & pause", tx, ty+bl);
  text(" TAB  - change basemap", tx, ty+2*bl);
  text("  <   - backwards", tx, ty+3*bl);
  text("  >   - forwards", tx, ty+4*bl);
  text("  z   - zoom to layer", tx, ty+5*bl);
  text("Click legend button to select transport mode", tx, ty+6*bl);
  textSize(15);
  fill(255, 0, 0);
  text("CURRENT TIME  " + timeh + ":" + timem, 740, 650);
}

/********************************************************************
Description: draw the transport mode legend and shade them according
             to selection
********************************************************************/
public void transport() 
{
  textSize(15);
  fill(0, 102, 153);
  text("Transport", lx-10, ly+50);

  for (int i = 0; i < 7; i++) //draw the legend
  {
    stroke(0, 100);
    if (tm[i] == true) //if the transport is unselected, nofill
    {
      noFill();
    } 
    else
    {
      fill(color(colorset[3*i], colorset[3*i+1], colorset[3*i+2]));
    }
    rect(lx, ly+65+2*i*bl, bw, bl);    
    fill(0, 102, 153);
    text(transportm[i], lx+40, ly+75+2*i*bl+bl/3);
  }
}

/********************************************************************
Description: control the timing during program running
********************************************************************/
public void timer()
{
  textSize(13);
  controlP5.getController("time").setValue(runtimes);
  line(400, 748, 1192, 748);
  fill(255,0,0);
  for (int i =0; i<25; i++)
  {
    line(400+i*33, 743, 400+i*33, 753);
    text(i, 395 +i*33, 768);
  }
  if ((runtimes < 1 || runtimes > 28800) && s == true)
  {
    //origint = 0;
    runtimes = 1;
    //pausets = 0;
    runtimep = 0;
  } else if (runtimes > 0 && runtimes < 28800 && s == true)
  {
    runtimep = runtimes;
    runtimes = runtimes + speed;
  }
  timeh= runtimes/1200;
  timem= (runtimes%1200)/20;
}

/********************************************************************
Description: Shade the trajectory
********************************************************************/
public void shadeTra(int n)
{
  switch(n) //select trajectory which needs to be shaded
  {
  case 1: 
    Trajectory = Trajectorywd;
    break; 

  case 2: 
    Trajectory = Trajectorywk;
    break;
  }
  shadePoint();
}

public void shadePoint()
{
  for (Marker marker : Trajectory) 
  {
    Object tmode = marker.getProperty("Tmode");
    String ID = "" + tmode; //get trajectory transport info  
    int id = Integer.parseInt(ID);
    if (tm[id-1] != true) //if false, means this type of transport is selected, need to be shaded
    {
      Object times = marker.getProperty("time");
      String secs = "" + times; 
      Float sec = Float.parseFloat(secs);
      if (sec > runtimep*2 && sec < runtimep*2+(runtimes-runtimep)*2)  //only shade point within a time phrase
      {
        marker.setHidden(false);
        float transp = map(sec, runtimep*2, runtimep*2+(runtimes-runtimep)*2, 0, 230); //transfer the time of trajectory point into transparency
        if (sec > runtimep*2+(runtimes-runtimep)*2-21)//only point at current time will be shaded with stroke 
        {
          marker.setStrokeColor(50);
          marker.setStrokeWeight(2);
          marker.setColor(color(colorset[3*(id-1)], colorset[3*(id-1)+1], colorset[3*(id-1)+2], transp)); //, transp
        } else
        {
          marker.setStrokeWeight(0);
          marker.setColor(color(colorset[3*(id-1)], colorset[3*(id-1)+1], colorset[3*(id-1)+2], transp)); //, transp
        }
      } else //if the point is without a time phrase, do not need to be shade
      {
        marker.setHidden(true);
      }
    } else //if true, means this type of transport is unselected, do not need to be shaded
    {
      marker.setHidden(true);
    }
  }
}

/********************************************************************
Description: Control trajectory displaying
********************************************************************/
public void play() 
{
  s = !s; 
  if (s == false)
  {
    //pausets = millis()/4;
    controlP5.getController("play").setLabel("Play");
  } else if (s == true)
  {
    //origint = origint + millis()/4 - pausets;
    controlP5.getController("play").setLabel("Pause");
  }
} // toggle

/********************************************************************
Description: Slider Functions 
********************************************************************/
public void time(int value) 
{
  runtimes = value;
}

public void forwards()
{
  runtimes = runtimes + 300;
}

public void backwards()
{
  runtimes = runtimes - 300;
}

public void speedup()
{
  if (speed <= 300 && speed >=100)
  {
    speed = speed+100;
  } else if (speed <100)
  {
    speed = speed + 25;
  }
}

public void speeddown()
{
  if (speed > 100)
  {
    speed = speed - 100;
  } else if (speed <= 100&& speed >25)
  {
    speed = speed - 25;
  }
}
//set up buttons for the time slider
public void drawslider()
{
  controlP5 = new ControlP5(this);
  sliderbutton = controlP5.addSlider("time", 0, 28800, 400, 710, 792, 30).setSliderMode(Slider.FLEXIBLE).setLabel("");
  backwardsbutton =controlP5.addButton("backwards", 0, 1245, 710, 30, 30).setLabel("<");
  forwardsbutton =controlP5.addButton("forwards", 0, 1325, 710, 30, 30).setLabel(">");
  playbutton = controlP5.addButton("play", 0, 1280, 710, 40, 30);
  speeddownbutton = controlP5.addButton("speeddown", 0, 1210, 710, 30, 30).setLabel("<<");
  speedupbutton = controlP5.addButton("speedup", 0, 1360, 710, 30, 30).setLabel(">>");
  controlP5.getController("time").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE);
}

/********************************************************************
Description: Switch to stay point mode
********************************************************************/
//void switchmode(boolean mode)
//{
//  modeswitch =  mode;
//  if (modeswitch == true)
//  {
//  f.show();
//  }
//}

/********************************************************************
Description: Draw piechart and diagrams
********************************************************************/
/********************************************************************
Description: Draw weekdend starplot
********************************************************************/
public void gweekend()
{
  float dat1;
  float dat2;
  float dat3;
  float dat4;
  int ji = floor(runtimes/1200);
  if (ji >= 0 && ji < 24)
  {
    for (int jj = 0; jj < 7; jj++)
    {
      if (ji == 23)
      {
        if (jj == 6)
        {
          dat1 = Float.parseFloat(data1[ji][jj]);
          dat2 = Float.parseFloat(data1[0][jj]);
          dat3 = Float.parseFloat(data1[ji][0]);
          dat4 = Float.parseFloat(data1[0][0]);
        } else
        {
          dat1 = Float.parseFloat(data1[ji][jj]);
          dat2 = Float.parseFloat(data1[0][jj]);
          dat3 = Float.parseFloat(data1[ji][jj+1]);
          dat4 = Float.parseFloat(data1[0][jj+1]);
        }
      } else
      {
        if (jj == 6)
        {
          dat1 = Float.parseFloat(data1[ji][jj]);
          dat2 = Float.parseFloat(data1[ji+1][jj]);
          dat3 = Float.parseFloat(data1[ji][0]);
          dat4 = Float.parseFloat(data1[ji+1][0]);
        } else
        {
          dat1 = Float.parseFloat(data1[ji][jj]);
          dat2 = Float.parseFloat(data1[ji+1][jj]);
          dat3 = Float.parseFloat(data1[ji][jj+1]);
          dat4 = Float.parseFloat(data1[ji+1][jj+1]);
        }
      }

      float offset1 = (dat2 - dat1)/(1200/speed); //100 speed
      float offset2 = (dat4 - dat3)/(1200/speed); //100 speed
      int i = (runtimes % 1200)/speed; //100 speed
      triangle(w1, h1, w1+cos((jj+1)*TWO_PI/7)*radiu*((dat1+offset1*i)/54), h1+sin((jj+1)*TWO_PI/7)*radiu*((dat1+offset1*i)/54), w1+cos((jj+2)*TWO_PI/7)*radiu*((dat3+offset2*i)/54), h1+sin((jj+2)*TWO_PI/7)*radiu*((dat3+offset2*i)/54));
    }
  }
}
/********************************************************************
Description: Draw weekday starplot
********************************************************************/
public void gweekday()
{
  float dat1;
  float dat2;
  float dat3;
  float dat4;
  int ji = floor(runtimes/1200);
  if (ji >= 0 && ji < 24)
  {
    for (int jj = 0; jj < 7; jj++)
    {
      if (ji == 23)
      {
        if (jj == 6)
        {
          dat1 = Float.parseFloat(data2[ji][jj]);
          dat2 = Float.parseFloat(data2[0][jj]);
          dat3 = Float.parseFloat(data2[ji][0]);
          dat4 = Float.parseFloat(data2[0][0]);
        } else
        {
          dat1 = Float.parseFloat(data2[ji][jj]);
          dat2 = Float.parseFloat(data2[0][jj]);
          dat3 = Float.parseFloat(data2[ji][jj+1]);
          dat4 = Float.parseFloat(data2[0][jj+1]);
        }
      } else
      {
        if (jj == 6)
        {
          dat1 = Float.parseFloat(data2[ji][jj]);
          dat2 = Float.parseFloat(data2[ji+1][jj]);
          dat3 = Float.parseFloat(data2[ji][0]);
          dat4 = Float.parseFloat(data2[ji+1][0]);
        } else
        {
          dat1 = Float.parseFloat(data2[ji][jj]);
          dat2 = Float.parseFloat(data2[ji+1][jj]);
          dat3 = Float.parseFloat(data2[ji][jj+1]);
          dat4 = Float.parseFloat(data2[ji+1][jj+1]);
        }
      }

      float offset1 = (dat2 - dat1)/(1200/speed); //100 speed
      float offset2 = (dat4 - dat3)/(1200/speed); //100 speed
      int i = (runtimes % 1200)/speed; //100 speed
      triangle(w2, h2, w2+cos((jj+1)*TWO_PI/7)*radiu*((dat1+offset1*i)/67), h2+sin((jj+1)*TWO_PI/7)*radiu*((dat1+offset1*i)/67), w2+cos((jj+2)*TWO_PI/7)*radiu*((dat3+offset2*i)/67), h2+sin((jj+2)*TWO_PI/7)*radiu*((dat3+offset2*i)/67));
    }
  }
}
/********************************************************************
Description: Draw frame of starplot
********************************************************************/
public void frame()
{
  for(int cc=1;cc<8;cc++)
  {if (cc==7)
  {
   line(w1+cos(cc*TWO_PI/7)*radiu*1/3, h1+sin(cc*TWO_PI/7)*radiu*1/3, w1+cos(TWO_PI/7)*radiu*1/3, h1+sin(TWO_PI/7)*radiu*1/3);
   line(w1+cos(cc*TWO_PI/7)*radiu*2/3, h1+sin(cc*TWO_PI/7)*radiu*2/3, w1+cos(TWO_PI/7)*radiu*2/3, h1+sin(TWO_PI/7)*radiu*2/3);  
   line(w1+cos(cc*TWO_PI/7)*radiu*1, h1+sin(cc*TWO_PI/7)*radiu*1, w1+cos(TWO_PI/7)*radiu*1, h1+sin(TWO_PI/7)*radiu*1);
}
  else{
  line(w1+cos(cc*TWO_PI/7)*radiu*1/3, h1+sin(cc*TWO_PI/7)*radiu*1/3, w1+cos((cc+1)*TWO_PI/7)*radiu*1/3, h1+sin((cc+1)*TWO_PI/7)*radiu*1/3);
  line(w1+cos(cc*TWO_PI/7)*radiu*2/3, h1+sin(cc*TWO_PI/7)*radiu*2/3, w1+cos((cc+1)*TWO_PI/7)*radiu*2/3, h1+sin((cc+1)*TWO_PI/7)*radiu*2/3);
  line(w1+cos(cc*TWO_PI/7)*radiu*1, h1+sin(cc*TWO_PI/7)*radiu*1, w1+cos((cc+1)*TWO_PI/7)*radiu*1, h1+sin((cc+1)*TWO_PI/7)*radiu*1);
 
}
  }
  for(int dd=1;dd<8;dd++)
  {if (dd==7)
  {
   line(w2+cos(dd*TWO_PI/7)*radiu*1/3, h2+sin(dd*TWO_PI/7)*radiu*1/3, w2+cos(TWO_PI/7)*radiu*1/3, h2+sin(TWO_PI/7)*radiu*1/3);
   line(w2+cos(dd*TWO_PI/7)*radiu*2/3, h2+sin(dd*TWO_PI/7)*radiu*2/3, w2+cos(TWO_PI/7)*radiu*2/3, h2+sin(TWO_PI/7)*radiu*2/3);
   line(w2+cos(dd*TWO_PI/7)*radiu*1, h2+sin(dd*TWO_PI/7)*radiu*1, w2+cos(TWO_PI/7)*radiu*1, h2+sin(TWO_PI/7)*radiu*1);
  
}
  else{
  line(w2+cos(dd*TWO_PI/7)*radiu*1/3, h2+sin(dd*TWO_PI/7)*radiu*1/3, w2+cos((dd+1)*TWO_PI/7)*radiu*1/3, h2+sin((dd+1)*TWO_PI/7)*radiu*1/3);
  line(w2+cos(dd*TWO_PI/7)*radiu*2/3, h2+sin(dd*TWO_PI/7)*radiu*2/3, w2+cos((dd+1)*TWO_PI/7)*radiu*2/3, h2+sin((dd+1)*TWO_PI/7)*radiu*2/3);
  line(w2+cos(dd*TWO_PI/7)*radiu*1, h2+sin(dd*TWO_PI/7)*radiu*1, w2+cos((dd+1)*TWO_PI/7)*radiu*1, h2+sin((dd+1)*TWO_PI/7)*radiu*1);
 }
  }
  pushMatrix();
  translate(w1, h1);
  stroke(0);
  strokeWeight(1);
  star(0, 0, 0, 70, 7);
  popMatrix();
  pushMatrix();
  translate(w2, h2);
  stroke(0);
  strokeWeight(1);
  star(0, 0, 0, 70, 7);
  popMatrix();
  fill(255);
  ellipse(w3, h3, 140, 140);
  stroke(0);
  strokeWeight(1);
  textSize(20);
  fill(50);
  //label the weekends7
  text("bike", w1+cos(TWO_PI/7)*(radiu+10), h1+sin(TWO_PI/7)*(radiu+10)); 
  text("bus", w1+cos(2*TWO_PI/7)*(radiu+55), h1+sin(2*TWO_PI/7)*(radiu+15)); 
  text("car", w1+cos(3*TWO_PI/7)*(radiu+40), h1+sin(3*TWO_PI/7)*(radiu+10)); 
  text("subway", w1+cos(4*TWO_PI/7)*(radiu+85), h1+sin(4*TWO_PI/7)*(radiu+10)); 
  text("taxi", w1+cos(5*TWO_PI/7)*(radiu+10), h1+sin(5*TWO_PI/7)*(radiu+10)); 
  text("train", w1+cos(6*TWO_PI/7)*(radiu+10), h1+sin(6*TWO_PI/7)*(radiu+10)); 
  text("walk", w1+cos(7*TWO_PI/7)*(radiu+10), h1+sin(7*TWO_PI/7)*(radiu+10)); 
  //label the weekdays
  text("bike", w2+cos(TWO_PI/7)*(radiu+10), h2+sin(TWO_PI/7)*(radiu+10)); 
  text("bus", w2+cos(2*TWO_PI/7)*(radiu+55), h2+sin(2*TWO_PI/7)*(radiu+15)); 
  text("car", w2+cos(3*TWO_PI/7)*(radiu+40), h2+sin(3*TWO_PI/7)*(radiu+10)); 
  text("subway", w2+cos(4*TWO_PI/7)*(radiu+85), h2+sin(4*TWO_PI/7)*(radiu+10)); 
  text("taxi", w2+cos(5*TWO_PI/7)*(radiu+10), h2+sin(5*TWO_PI/7)*(radiu+10)); 
  text("train", w2+cos(6*TWO_PI/7)*(radiu+10), h2+sin(6*TWO_PI/7)*(radiu+10)); 
  text("walk", w2+cos(7*TWO_PI/7)*(radiu+10), h2+sin(7*TWO_PI/7)*(radiu+10));
}

public void star(float x, float y, float radius1, float radius2, int npoints) //********
{
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0f;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
/********************************************************************
Description: Draw piechart
********************************************************************/
public void piechart()
{
  float dat1;
  float dat2;
  float dat3;
  float dat4;
  float weekday1=0;
  float weekend1=0;
  float weekday2=0;
  float weekend2=0;
  int ji = floor(runtimes/1200);
  if (ji >= 0 && ji < 24 && runtimes > 0)
  {
    if (ji == 23)
    {
      for (int jj = 0; jj < 7; jj++)
      {
        dat3 = Float.parseFloat(data1[0][jj]);
        weekend2= dat3+weekend2;
        dat4 = Float.parseFloat(data2[0][jj]);
        weekday2= dat4+weekday2;
        dat1 = Float.parseFloat(data1[ji][jj]);
        weekend1= dat1+weekend1;
        dat2 = Float.parseFloat(data2[ji][jj]);
        weekday1= dat2+weekday1;
      }
    } else
    {
      for (int jj = 0; jj < 7; jj++)
      {
        dat3 = Float.parseFloat(data1[ji+1][jj]);
        weekend2= dat3+weekend2;
        dat4 = Float.parseFloat(data2[ji+1][jj]);
        weekday2= dat4+weekday2;
        dat1 = Float.parseFloat(data1[ji][jj]);
        weekend1= dat1+weekend1;
        dat2 = Float.parseFloat(data2[ji][jj]);
        weekday1= dat2+weekday1;
      }
    }

    stroke(255, 0, 0);
    strokeWeight(4);
    float offset1 = (weekday2/(weekend2+weekday2) - weekday1/(weekend1+weekday1))/(1200/speed); //100 speed
    r = floor((runtimes % 1200)/speed); //100 speed 
    //line(w3,h3,w3+cos(PI/2+TWO_PI*(weekend1/(weekend1+weekday1)+offset1*r))*radiu,h3+sin(PI/2+TWO_PI*(weekend1/(weekend1+weekday1)+offset1*r))*radiu);
    fill(64, 3, 255);
    strokeWeight(1);
    arc(w3, h3, 2*radiu, 2*radiu, PI/2, PI/2+TWO_PI*((weekday1/(weekend1+weekday1)+offset1*r)));
  }
}
/********************************************************************
Description: Draw graduation of piechart
********************************************************************/
public void graduation()
{
  stroke(0);
  line(w3, h3, w3, h3+70);//0%
  line(w3+cos(7*TWO_PI/20)*(radiu-5), h3+sin(7*TWO_PI/20)*(radiu-5), w3+cos(7*TWO_PI/20)*radiu, h3+sin(7*TWO_PI/20)*radiu);//10%
  line(w3+cos(9*TWO_PI/20)*(radiu-5), h3+sin(9*TWO_PI/20)*(radiu-5), w3+cos(9*TWO_PI/20)*radiu, h3+sin(9*TWO_PI/20)*radiu);//20%
  line(w3+cos(11*TWO_PI/20)*(radiu-5), h3+sin(11*TWO_PI/20)*(radiu-5), w3+cos(11*TWO_PI/20)*radiu, h3+sin(11*TWO_PI/20)*radiu);//30%
  line(w3+cos(13*TWO_PI/20)*(radiu-5), h3+sin(13*TWO_PI/20)*(radiu-5), w3+cos(13*TWO_PI/20)*radiu, h3+sin(13*TWO_PI/20)*radiu);//40%
  line(w3+cos(15*TWO_PI/20)*(radiu-5), h3+sin(15*TWO_PI/20)*(radiu-5), w3+cos(15*TWO_PI/20)*radiu, h3+sin(15*TWO_PI/20)*radiu);//50%
  line(w3+cos(17*TWO_PI/20)*(radiu-5), h3+sin(17*TWO_PI/20)*(radiu-5), w3+cos(17*TWO_PI/20)*radiu, h3+sin(17*TWO_PI/20)*radiu);//60%
  line(w3+cos(19*TWO_PI/20)*(radiu-5), h3+sin(19*TWO_PI/20)*(radiu-5), w3+cos(19*TWO_PI/20)*radiu, h3+sin(19*TWO_PI/20)*radiu);//60%
  line(w3+cos(21*TWO_PI/20)*(radiu-5), h3+sin(21*TWO_PI/20)*(radiu-5), w3+cos(21*TWO_PI/20)*radiu, h3+sin(21*TWO_PI/20)*radiu);//60%
  line(w3+cos(23*TWO_PI/20)*(radiu-5), h3+sin(23*TWO_PI/20)*(radiu-5), w3+cos(23*TWO_PI/20)*radiu, h3+sin(23*TWO_PI/20)*radiu);//60%
  fill(0);
  textSize(10);
  text("0%", w3-5, h3+radiu+15); 

  text("10%", w3+cos(7*TWO_PI/20)*(radiu+25), h3+sin(7*TWO_PI/20)*(radiu+15)); 
  text("20%", w3+cos(9*TWO_PI/20)*(radiu+25), h3+sin(9*TWO_PI/20)*(radiu+15)); 
  text("30%", w3+cos(11*TWO_PI/20)*(radiu+20), h3+sin(11*TWO_PI/20)*(radiu+15)); 
  text("40%", w3+cos(13*TWO_PI/20)*(radiu+15), h3+sin(13*TWO_PI/20)*(radiu+10)); 
  text("50%", w3+cos(15*TWO_PI/20)*(radiu+15), h3+sin(15*TWO_PI/20)*(radiu+5)); 
  text("60%", w3+cos(17*TWO_PI/20)*(radiu+10), h3+sin(17*TWO_PI/20)*(radiu+5)); 
  text("70%", w3+cos(19*TWO_PI/20)*(radiu+5), h3+sin(19*TWO_PI/20)*(radiu+15)); 
  text("80%", w3+cos(21*TWO_PI/20)*(radiu+5), h3+sin(21*TWO_PI/20)*(radiu+15)); 
  text("90%", w3+cos(23*TWO_PI/20)*(radiu+5), h3+sin(23*TWO_PI/20)*(radiu+15)); 
  textSize(20);
  text("Weekday", w3+cos(7*TWO_PI/20)*(radiu+100), h3+sin(7*TWO_PI/20)*(radiu+50));
  text("Weekend", w3+cos(24*TWO_PI/20)*(radiu+33), h3+sin(24*TWO_PI/20)*(radiu+33));
}
/********************************************************************
Description: load data of weekday's and weekend's transportation method
********************************************************************/
public String[][] loadData(String fileName)
{
  String[] rows = loadStrings(fileName);
  String[][] dataa = new String [24][7];
  int i = 0;
  for (String row : rows) 
  {
    String[] columns = row.split(",");
    if (columns.length >= 7) 
    {
      for (int j = 0; j < 7; j=j+1)
      {
        dataa [i][j]=columns[j];
      }
      i = i +1;
    }
  }
  return dataa;
}
/********************************************************************
Description: Detect moouse press on the transport button to select 
             transport mode. If tm[i] = false, means selected, if 
             true, means unselected
********************************************************************/
public void mousePressed() //transport mode selected
{
    if (mouseButton == LEFT)
    {
      if (mouseX >= lx && mouseX <= lx+bw && mouseY >= ly+65 && mouseY <= ly+65+bl)
      {
        tm[0] =! tm[0];
      } else if (mouseX >= lx && mouseX <= lx+bw && mouseY >= ly+65+2*bl && mouseY <= ly+65+3*bl)
      { 
        tm[1] =! tm[1];
      } else if (mouseX >= lx && mouseX <= lx+bw && mouseY >= ly+65+4*bl && mouseY <= ly+65+5*bl)
      {
        tm[2] =! tm[2];
      } else if (mouseX >= lx && mouseX <= lx+bw && mouseY >= ly+65+6*bl && mouseY <= ly+65+7*bl)
      {
        tm[3] =! tm[3];
      } else if (mouseX >= lx && mouseX <= lx+bw && mouseY >= ly+65+8*bl && mouseY <= ly+65+9*bl)
      {
        tm[4] =! tm[4];
      } else if (mouseX >= lx && mouseX <= lx+bw && mouseY >= ly+65+10*bl && mouseY <= ly+65+11*bl)
      {
        tm[5] =! tm[5];
      } else if (mouseX >= lx && mouseX <= lx+bw && mouseY >= ly+65+12*bl && mouseY <= ly+65+13*bl)
      {
        tm[6] =! tm[6];
      }
    }
} 

/********************************************************************
Description: Shortcut for different functions
********************************************************************/
public void keyPressed()
{
  switch (key)
  {
  case ' ': //play and pause
    s =! s;
    if (s == false)
    {
      //pausets = millis()/4;
      controlP5.getController("play").setLabel("Play");
    } else if (s == true )
    {
      //origint = origint + millis()/4 - pausets;
      controlP5.getController("play").setLabel("Pause");
    }
    break; 

  case TAB: //change of basemap
    if (mapwd == map1)
    {
      mapwd = map3;
      mapwk = map4;  
    } else
    {
      mapwd = map1;
      mapwk = map2;
    }
    break;   

  case ',': //backwards
    runtimes = runtimes - 300;
    break;

  case '<': //backwards
    runtimes = runtimes - 300;
    break;     

  case '.': //forwards
    runtimes = runtimes + 300;
    break;

  case '>': //forwards
    runtimes = runtimes + 300;
    break;

  case 'z': //zoom to origin layer
    mapwk.zoomAndPanTo(BeijingLocation, 12);
    mapwd.zoomAndPanTo(BeijingLocation, 12);
    break;

//  case 'q': //switch mode
//      f.show();
//    break;
  }
}
/********************************************************************
Description: add arrow to the maps
********************************************************************/
public void arrow()
{

PImage img1,img2;
img1=loadImage("compass.png");
image(img1,630,110);
img2=loadImage("compass.png");
image(img2,1490,110);

}
// This defines structure for rawdata
class Movement {
  ArrayList<Float> lat;
  ArrayList<Float> lon;
  ArrayList<Float> alt;
  ArrayList<Float> day1899;
  ArrayList<String> date;
  ArrayList<String> time;
  ArrayList<Location> stay;
  String filedate;
  int record;
  int ID;
  
  //Structure for the movement
  Movement() {
    record=0;
    ID =0 ;
    filedate = "";
    lat= new ArrayList<Float>();
    lon = new ArrayList<Float>();
    alt=new ArrayList<Float>();
    day1899=new ArrayList<Float>();
    date=new ArrayList<String>();
    time=new ArrayList<String>();
    stay = new ArrayList<Location>();
    record = 0;
  }
  
  // Add record from file
  public void addRecord(String lat1, String lon1, String alt1, String day18991, String date1, String time1) {
    lat.add(PApplet.parseFloat(lat1));
    lon.add(PApplet.parseFloat(lon1));
    alt.add(PApplet.parseFloat(alt1));
    day1899.add(PApplet.parseFloat(day18991));
    date.add(date1);
    time.add(time1);
    record++;
  }

 //Transfer the String to Date format
  public Date Transfertime(String timetmp) {
    Date timedatetmp = new Date();
    try {
      timedatetmp = sdftime.parse(timetmp);
    }
    catch (ParseException e) {  
      e.printStackTrace();
    }
    return timedatetmp;
  }

  //Find the staypoint
  public void staypoint()
  { 
    stay = new ArrayList<Location>(); 
      
    Location centre;    
    for (int i=0; i<lat.size (); )
    {
      ArrayList<Location> form_circle = new ArrayList<Location>();
      Location cs = new Location(lat.get(i), lon.get(i)); // start point
      Location ce; // end point
      form_circle.add(cs);
      for (int n=1; i+n<lat.size (); n++)
      {        
        ce = new Location(lat.get(i+n), lon.get(i+n)); 
        if (cs.getDistance(ce) <= disthre*2)
        {          
          form_circle.add(ce);
        } else
        {
          if (form_circle.size()>=4)
          {
            Date timee = Transfertime(time.get(i+n-1));
            Date times = Transfertime(time.get(i));

            if (abs(timee.getTime()-times.getTime())/1000 >=staythre)
            {
              centre = GeoUtils.getEuclideanCentroid(form_circle);
              if (DeleteNotInCircle(form_circle, centre, i, i+n-1))
              {    
                stay.add(centre);
                SimplePointMarker showstay = new SimplePointMarker(centre);
                int type = Integer.parseInt(filedate.substring(6, 8));
                showstay.setColor(color(type*10, type*4,type*7, 180));
                if(zoomlevel>10)
                  showstay.setRadius((zoomlevel-10)*7);
                markerManager.addMarker(showstay);
                i=i+form_circle.size();
              }
            } else {
              i++;
              break;
            }
          } else 
          {
            i++;
            break;
          }
        }
      }
      i++;
    }
  }

  //Delete the points not in the circle or shorter than the time
  public boolean DeleteNotInCircle (ArrayList<Location> form_circle, Location centre, int start, int end)
  {
    for (int i=0; i<form_circle.size (); i++)
    {
      if (centre.getDistance(form_circle.get(i)) > disthre )
      {
        if (i<4) return false;
        else { 
          for (int q = i; q<form_circle.size (); q++)
          {
            form_circle.remove(q);
          }
          Date timee = Transfertime(time.get(start+i-1));
          Date times = Transfertime(time.get(start));
          if (abs(timee.getTime()-times.getTime())/1000 >=staythre)
          {
            centre = GeoUtils.getEuclideanCentroid(form_circle);
            return true;
          } else return false;
        }
      }
    }
    return false;
  }
}

//Read Data from file for movement
public void readFile() {
  ArrayList<Movement> onetime = new ArrayList<Movement>(); 
  Movement newone = new Movement(); 
  String readLine; 

  File folder = new File(filefolder); 
  File[] listOfFiles = folder.listFiles(); 
  for (File file : listOfFiles) {
    if (file.isFile()&& file.getName().contains("200903")) {
      try {
        onetime = new ArrayList<Movement>(); 
        newone = new Movement(); 
        BufferedReader br = new BufferedReader(new FileReader(filefolder+"\\"+file.getName())); 
        readLine = br.readLine (); 
        String[] previouline = readLine.split(","); 
        int previousint = Integer.parseInt(previouline[7]); 
        while ( readLine != null) {
          String[] currentline = readLine.split(","); 
          if (Integer.parseInt(currentline[7]) == previousint)
          {
            newone.addRecord(currentline[0], currentline[1], currentline[2], currentline[4], currentline[5], currentline[6]); 
            newone.ID = Integer.parseInt(currentline[7]); 
            newone.filedate = file.getName();
          } else
          {            
            onetime.add(newone); 
            newone = new Movement(); 
            newone.addRecord(currentline[0], currentline[1], currentline[2], currentline[4], currentline[5], currentline[6]);
          }
          previousint = Integer.parseInt(currentline[7]); 
          readLine = br.readLine ();
        }
      }
      catch (IOException e) {
        e.printStackTrace();
      }
      rawdata.add(onetime);
    }    
  }
  println(rawdata.size());
}

//PFrame f;
//secondApplet sa;
////pop-up frame, add pApplet
//public class PFrame extends JFrame {
//  public PFrame() {
//    setBounds(0, 0, displayWidth, displayHeight-100);
//    setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE);
//    sa = new secondApplet();
//    add(sa);
//    sa.init(); 
//  }
//}
//
////draw in second window
//public class secondApplet extends PApplet {
//  public void setup() {
//    size(displayWidth, displayHeight-100);
//    frameRate(30);    
//    map = new UnfoldingMap(this, new EsriProvider.WorldStreetMap() );  
//    Location defaultlo = new Location (39.921165f, 116.38419f);
//    map.zoomAndPanTo(defaultlo, 12);    
//    smooth();
//    //Listen to map controller
//    eventDispatcher = new EventDispatcher();
//    mouseHandler = new MouseHandler(this, map);
//    eventDispatcher.addBroadcaster(mouseHandler);
//    listen();
//    markerManager = map.getDefaultMarkerManager();
//  }
//
//  public void draw() { 
//    map.draw();   
//    zoomlevel = map.getZoomLevel();
//    //draw barscale and compass
//    barScale = new BarScaleUI(this, map, width/2, height-20);
//    compass= new CompassUI(this, map, compimage, width-33, 33);
//    PFont myFont = createFont("Cambria", 25);
//    barScale.setStyle(color(20, 20, 20), 5, -2, myFont);
//    barScale.draw();
//    compass.draw();
//    barYt=height-40;
//    barYd =height-140;
//    rectMode(RADIUS); 
//    pointerXt = width-180+xOffsett; 
//    pointerXd = width-180+xOffsetd; 
//    pushStyle(); 
//    noStroke(); 
//    fill(228, 198, 220, 180); 
//    rect(width-108, height-92, 123, 86); 
//    stroke(0); 
//    strokeWeight(3); 
//    line(width-180, height-140, width-20, height-140); 
//    line(width-180, height-40, width-20, height-40); 
//    fill(0); 
//    textSize(25); 
//    text("Stay Points", width/2, 30); 
//    textSize(17); 
//    text("Stay_Radius(km)", width-180, height-160); 
//    text("0.5", width-185, height-110); 
//    text("4", width-25, height-110); 
//    text(String.format("%.1f", disthre), width-215, height-135); 
//    text("Stay_Time(hour)", width-180, height-60); 
//    text("0.5", width-185, height-10); 
//    text("24", width-30, height-10); 
//    text(String.format("%.1f", staythre/3600), width-225, height-35); 
//    popStyle(); 
//
//    // Check if mouse is over the time pointer
//    if (mouseX>=pointerXt-3&&mouseX<=pointerXt+3&&
//      mouseY>=barYt-11&&mouseY<=barYt+11) {
//      overPointert=true; 
//      stroke(120); 
//      fill(100);
//    } else {            //if not over, color the pointer in black
//      stroke(0); 
//      fill(0); 
//      overPointert=false;
//    }
//    rect(pointerXt, barYt, 2, 10); 
//    if (mouseX>=pointerXd-3&&mouseX<=pointerXd+3&&
//      mouseY>=barYd-11&&mouseY<=barYd+11) {
//      overPointerd=true; 
//      stroke(120); 
//      fill(100);
//    } else {            //if not over, color the pointer in black
//      stroke(0); 
//      fill(0); 
//      overPointerd=false;
//    }
//    rect(pointerXd, barYd, 2, 10);
//
//    for (int i=0; i<rawdata.size (); i++)
//    {
//      int type = Integer.parseInt(rawdata.get(i).get(1).filedate.substring(6, 8)); 
//      fill(type*10, type*4,type*7, 180);
//      ellipse(20, i*50+10, 15, 15);
//      fill(0);
//      textSize(14);
//      text(rawdata.get(i).get(1).filedate.substring(0, 8), 40, i*50+15);
//    }
//
//    fill(255);  
//    //Will draw stay points if pressing, dragging and releasing the pointer.
//    if (locked == true)
//    {   
//      for (int i=0; i<rawdata.size (); i++)
//      {
//        for (int j=0; j<rawdata.get (i).size(); j++)
//        {
//
//          rawdata.get(i).get(j).staypoint();
//        }
//      }    
//      flag=false;
//    }
//
//    //draw interesting circles
//    for (int i=0; i<interestlo.size (); i++)
//    {
//      SimplePointMarker showstay = new SimplePointMarker(interestlo.get(i));
//      ScreenPosition pos = showstay.getScreenPosition(map);
//      fill(255, 255, 255, 0);
//      strokeWeight(15);
//      stroke(190, 225, 243, 200);
//      ellipse(pos.x, pos.y, 55, 55);
//      fill(255, 255, 255, 0);
//      strokeWeight(15);
//      stroke(165, 225, 243, 200);
//      ellipse(pos.x, pos.y, 80, 80);
//      textSize(zoomlevel*1.4);
//      fill(0);
//      text(interestna.get(i), pos.x- textWidth(interestna.get(i)) / 2, pos.y);
//    } 
//
//    // if using mousescroll, clear all the markers and add new markers with new size
//    if (mousescroll)
//    {
//      markerManager.clearMarkers();
//      for (int i=0; i<rawdata.size (); i++)
//      {
//        for (int j=0; j<rawdata.get (i).size(); j++)
//        {
//          for (int p=0; p<rawdata.get (i).get(j).stay.size(); p++)
//          {
//            Location tmp = rawdata.get(i).get(j).stay.get(p); 
//            int type = Integer.parseInt(rawdata.get(i).get(j).filedate.substring(6, 8)); 
//            SimplePointMarker showstay = new SimplePointMarker(tmp);
//            showstay.setColor(color(type*10, type*4,type*7, 180)); 
//            if (zoomlevel>10)
//              showstay.setRadius((zoomlevel-10)*7); 
//            markerManager.addMarker(showstay);
//          }
//        }
//      }
//      mousescroll=false;
//    } 
//
//    locked=false;
//  }
//   
//  //press on the pointer 
//  void mousePressed()
//  {
//    if (overPointerd) {
//      fill(230); 
//      stroke(200); 
//      mute();
//    }   
//    if (overPointert) {
//      fill(230); 
//      stroke(200); 
//      mute();
//    }
//  }
//  public void mouseWheel()
//  {
//    mousescroll=true;
//  }
//
//  void mouseDragged() {
//    // When the mouse is dragging the pointer, the pointer moves
//    // with the mouse
//    if (overPointert)
//    {
//      mute(); 
//      if (mouseX<=width-180) {
//        xOffsett=0;
//      } else if (mouseX>=width-20) {
//        xOffsett=160;
//      } else {
//        xOffsett=mouseX-(width-180);
//      }
//      staythre = (xOffsett/160*23.5+0.5)*3600; 
//
//      flag=true;
//    }
//    if (overPointerd)
//    {
//      mute(); 
//      if (mouseX<=width-180) {
//        xOffsetd=0;
//      } else if (mouseX>=width-20) {
//        xOffsetd=160;
//      } else {
//        xOffsetd=mouseX-(width-180);
//      }
//      disthre = xOffsetd/160*3.5 +0.5; 
//      flag=true;
//    }
//  }
//
//  void mouseReleased()
//  {  
//    listen(); 
//    if (flag==true)
//    {
//      locked =true; 
//      markerManager.clearMarkers();
//    }
//  }
//} 
//
////Not listen to map controller when drag pointer
//public void mute() {
//  eventDispatcher.unregister(map, PanMapEvent.TYPE_PAN, map.getId()); 
//  eventDispatcher.unregister(map, ZoomMapEvent.TYPE_ZOOM, map.getId());
//}
//
////Will listen to map controller when not drag pointer
//public void listen() {
//  eventDispatcher.register(map, PanMapEvent.TYPE_PAN, map.getId()); 
//  eventDispatcher.register(map, ZoomMapEvent.TYPE_ZOOM, map.getId());
//}






























 

 

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
Location BeijingLocation = new Location(39.9459631f, 116.391248f);


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
public float disthre = 0.5f;  // the threshold for moving circle to pick interest places, in kilometers
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


  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Processing_Interface" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
