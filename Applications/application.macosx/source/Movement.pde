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
  void addRecord(String lat1, String lon1, String alt1, String day18991, String date1, String time1) {
    lat.add(float(lat1));
    lon.add(float(lon1));
    alt.add(float(alt1));
    day1899.add(float(day18991));
    date.add(date1);
    time.add(time1);
    record++;
  }

 //Transfer the String to Date format
  Date Transfertime(String timetmp) {
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
  void staypoint()
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
  boolean DeleteNotInCircle (ArrayList<Location> form_circle, Location centre, int start, int end)
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

