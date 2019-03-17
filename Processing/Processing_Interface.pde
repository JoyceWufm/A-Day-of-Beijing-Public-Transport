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
void setup() 
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
  Arrays.asList(new Location(39.99, 116.26), new Location(40.01, 116.30), new Location(39.989, 116.306), 
  new Location(40.00, 116.32), new Location(40.064, 116.582), new Location(40.068, 116.129), 
  new Location(40.0261, 116.388), new Location(39.915, 116.316 ), new Location(39.927, 116.383)));
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
void draw() 
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
void infoDisplay()
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
void transport() 
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
void timer()
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
void shadeTra(int n)
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

void shadePoint()
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
void play() 
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
void time(int value) 
{
  runtimes = value;
}

void forwards()
{
  runtimes = runtimes + 300;
}

void backwards()
{
  runtimes = runtimes - 300;
}

void speedup()
{
  if (speed <= 300 && speed >=100)
  {
    speed = speed+100;
  } else if (speed <100)
  {
    speed = speed + 25;
  }
}

void speeddown()
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
void drawslider()
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
void gweekend()
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
void gweekday()
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
void frame()
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

void star(float x, float y, float radius1, float radius2, int npoints) //********
{
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
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
void piechart()
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
void graduation()
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
String[][] loadData(String fileName)
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
void mousePressed() //transport mode selected
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
void keyPressed()
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
void arrow()
{

PImage img1,img2;
img1=loadImage("compass.png");
image(img1,630,110);
img2=loadImage("compass.png");
image(img2,1490,110);

}
