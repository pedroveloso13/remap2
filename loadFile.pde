void loadFile(String fileName){
  XML xml;
  xml = loadXML(fileName);
  loadNodes(xml);
  loadWays(xml);
  loadRelations(xml);
  findMinMax(buildingsI);
  loadBuildings(buildingsI, 0);
  //saveIncomes();
  //saveElevations();
  //loadNewValue(filename+"elevation.txt");
  //loadNewValue(filename+"income.txt");
}

void loadNodes(XML xml){
  //load object nodes
  XML[] childrenNodes = xml.getChildren("node");
  for (int i = 0; i<childrenNodes.length; i++){
    String id = childrenNodes[i].getString("id");
    float lat = childrenNodes[i].getFloat("lat");
    float lon = childrenNodes[i].getFloat("lon");
    Node tempNode = new Node(id, lat, lon);
    nodes.add(tempNode);
    nodesI.set(id,i);//this is the dict to translate from string id to the index of arraylist
  }
}

void loadWays(XML xml){
  //load objects ways and some of the object buildings
  XML[] childrenWay = xml.getChildren("way");
  for (int i = 0; i<childrenWay.length; i++){
    String id = childrenWay[i].getString("id");
    StringDict tags = new StringDict();
    boolean isBuilding = false;
    //store all the tags and evaluate if it is a building
    XML[] tagRef = childrenWay[i].getChildren("tag");
    for (int j = 0; j < tagRef.length; j++){
      String k =  tagRef[j].getString("k");
      String v =  tagRef[j].getString("v");
      tags.set(k, v);
      if ((k != null) && (k.equals("building"))){
        isBuilding = true;
      }
    }
    //evaluate all points in the way and store them in a arraylist  
    ArrayList<PVector> coords = new ArrayList<PVector>(); 
    XML[] nodeRef = childrenWay[i].getChildren("nd");
    for (int j = 0; j < nodeRef.length; j++){
      String ref =  nodeRef[j].getString("ref");
      if (ref != null){
        PVector curCoords = nodes.get(nodesI.get(ref)).coord;
        coords.add(curCoords);
      }
    }
    //create the new way object and put it inside an arraylist
    //it is necessary because the relations may trackback to the ways without appropriate tags
    Way tempWay = new Way(id, coords, tags);
    ways.add(tempWay);
    waysI.set(id,i);//this is the dict to translate from string id to the index of arraylist
    //keep track of the ways that are buildings
    if (isBuilding == true) {
      buildingsI.set(id,i);
    }
  }
}

void loadRelations(XML xml){
  //load objects ways and some of the object buildings
  XML[] childrenRelation = xml.getChildren("relation");
  for (int i = 0; i<childrenRelation.length; i++){
    StringDict tags = new StringDict();
    boolean isBuilding = false;
    //store all the tags and evaluate if it is a building
    XML[] tagRef = childrenRelation[i].getChildren("tag");
    for (int j = 0; j < tagRef.length; j++){
      String k =  tagRef[j].getString("k");
      String v =  tagRef[j].getString("v");
      tags.set(k, v);
      if ((k != null) && (k.toLowerCase().contains("building"))){
        isBuilding = true;
      }
    }
    if (isBuilding == true){
      XML[] childrenMember = childrenRelation[i].getChildren("member");
      //evaluate all points in the way and store them in a arraylist
      for (int j = 0; j < childrenMember.length; j++){
        //not considering holes
        if (childrenMember[j].getString("type").equals("way") && childrenMember[j].getString("role").equals("outer")){
          String id = childrenMember[j].getString("ref");
          ways.get(waysI.get(id)).addDict(tags);
          if (buildingsI.hasKey(id) == false){
            buildingsI.set(id,waysI.get(id));
          }
        }
      }
    }
  }
}
void findMinMax(IntDict dictI){
  int[] allIndex = dictI.valueArray();
  for (int i = 0; i< allIndex.length; i++){
    ArrayList<PVector> tempCoords = ways.get(allIndex[i]).coords;
    //update range of coordinates
    for (int j = 0; j < tempCoords.size(); j++){
      maxLat = max(maxLat, tempCoords.get(j).y);
      minLat = min(minLat, tempCoords.get(j).y);
      maxLon = max(maxLon, tempCoords.get(j).x);
      minLon = min(minLon, tempCoords.get(j).x);
    }
  }
  //convert max geocoord to cartesian
  maxPoint.x = haversine(minLat, minLon, minLat, maxLon);
  maxPoint.y = haversine(minLat, minLon, maxLat, minLon);
  scale = min(.8*screenSize.x/maxPoint.x, .8*screenSize.y/maxPoint.y);
  maxPoint.x *= scale;
  maxPoint.y *= scale;
}

void loadBuildings(IntDict dictI, int colour){
  String[] allId = dictI.keyArray();
  int[] allIndex = dictI.valueArray();
  for (int i = 0; i< (allIndex.length); i++){
    ArrayList<PVector> tempCoords = ways.get(allIndex[i]).coords;
    StringDict tempTags = ways.get(allIndex[i]).tags;
    if (tempCoords.size() > 2){
      Building tempBuilding = new Building(allId[i], i, tempCoords, tempTags, colour);
      buildings.add(tempBuilding);
    }
  }

  for (int i = 0; i< buildings.size(); i++){
    buildings.get(i).initPoints(maxPoint, minLon, maxLon, minLat, maxLat, scale);
    buildings.get(i).initAttributes();
    buildings.get(i).initAnalysis();
  }
  
}

float haversine(float minLat, float minLon, float inputLat, float inputLon){
  float earthR = 6371000; //mean radius of earth
  float dLat = radians(inputLat - minLat);
  float dLon = radians(inputLon - minLon);
  float lat1 = radians(minLat);
  float lat2 = radians(inputLat);
  float a = sq(sin(dLat/2)) + cos(lat1) * cos(lat2) * sq(sin(dLon/2));
  float c = 2 * asin(sqrt(a));
  return c*earthR;
}
