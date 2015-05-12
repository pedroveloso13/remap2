void updateGlobalData(String aKey, Float aValue){
  if (minData.hasKey(aKey)){
    minData.set(aKey, min(minData.get(aKey), aValue));
    maxData.set(aKey, max(maxData.get(aKey), aValue));
  }
  else{
    minData.set(aKey, aValue);
    maxData.set(aKey, aValue);
    dataKeys.add(aKey);
  }
}

void loadNewValue(String sourcefile) {
  String []source = loadStrings(sourcefile);
  String theKey = source[0];
  for (int i=1; i <buildings.size() + 1; i++){
    buildings.get(i-1).addData(theKey, float(source[i]));
  }
}

void saveElevations(){
  PVector geoCoord = buildings.get(0).geoCenter;
  String content = "elevation";
  for (int i=0; i <buildings.size(); i++){
    geoCoord = buildings.get(i).geoCenter;
    float elevation = saveElevation(geoCoord.y, geoCoord.x);
    content += "\n" + elevation;
    println("elevation", i, buildings.size());
  }
  String[] listContent = split(content, '\n');
  saveStrings(filename + "elevation.txt", listContent);  
}

float saveElevation(float lat, float lon){
  // Create a session using your Temboo account application details
  TembooSession session = new TembooSession("yourname", "yourapp", "key");
  // Create the Choreo object using your Temboo session
  GetLocationElevation getLocationElevationChoreo = new GetLocationElevation(session);
  // Set inputs
  getLocationElevationChoreo.setLocations(str(lat) + ", " + str(lon));
  // Run the Choreo and store the results
  GetLocationElevationResultSet getLocationElevationResults = getLocationElevationChoreo.run();
  String output = getLocationElevationResults.getResponse();
  JSONObject json = JSONObject.parse(output);
  JSONArray test = json.getJSONArray("results");
  JSONObject results = test.getJSONObject(0);
  float elevation = results.getFloat("elevation");
  return elevation;
}

void saveIncomes() {
  PVector geoCoord = buildings.get(0).geoCenter;
  String content = "income";
  for (int i=0; i <buildings.size(); i++){ 
    geoCoord = buildings.get(i).geoCenter;
    float income = saveIncome(geoCoord.y, geoCoord.x);
    content += "\n" + income; 
    println("income", i, buildings.size());
  }
  String[] listContent = split(content, '\n');
  saveStrings(filename + "income.txt", listContent);
}
float saveIncome(float lat, float lon) { 
  // Run the GetDemographicsByCoordinates Choreo function
  TembooSession session = new TembooSession("yourname", "yourapp", "key");
  // Create the Choreo object using your Temboo session
  GetDemographicsByCoordinates getDemographicsByCoordinatesChoreo = new GetDemographicsByCoordinates(session);
  // Set inputs
  getDemographicsByCoordinatesChoreo.setLatitude(str(lat));
  getDemographicsByCoordinatesChoreo.setLongitude(str(lon));
  // Run the Choreo and store the results
  GetDemographicsByCoordinatesResultSet getDemographicsByCoordinatesResults = getDemographicsByCoordinatesChoreo.run();
  // Print results
  String result = getDemographicsByCoordinatesResults.getResponse();
  XML xml;
  xml = parseXML(result);
  XML[] childrenNodes = xml.getChildren("Results");
  XML[] grandChildren = childrenNodes[0].getChildren("medianIncome");
  float income = float(grandChildren[0].getContent());
  return income;
}
