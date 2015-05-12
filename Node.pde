class Node{
  String id;
  float lat, lon;
  PVector coord;
  Node(String iid, float ilat, float ilon){
    id = iid;
    lat = ilat;
    lon = ilon;
    coord = new PVector(lon, lat);
  }
}
