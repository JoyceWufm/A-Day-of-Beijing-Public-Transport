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

