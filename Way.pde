class Way{
  String id;
  ArrayList<PVector> coords = new ArrayList<PVector>();
  StringDict tags; 
  Way(String iid, ArrayList<PVector> icoords, StringDict itags){
    id = iid;
    coords = icoords;
    tags = itags;
  }
  void addDict(StringDict newDict){
    String[] keys = newDict.keyArray();
    String[] values = newDict.valueArray();
    for (int i = 0; i<keys.length; i++){
      tags.set(keys[i], values[i]);
    } 
  }
}
