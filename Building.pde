class Building {
  String id; 
  int index;
  float perimeter = 0;
  float radius = 1;
  float area = 1;
  float screenScale;
  float unitScale;
  StringDict tags;
  boolean collision = true;
  ArrayList<PVector> points = new ArrayList<PVector>();
  ArrayList<Float> angles = new ArrayList<Float>();
  ArrayList<Float> lengths = new ArrayList<Float>();
  ArrayList<PVector> coords = new ArrayList<PVector>();
  PVector center = new PVector(0, 0);
  PVector centroid = new PVector(0, 0);
  PVector originalCenter = new PVector(0, 0);
  PVector geoCenter = new PVector(0, 0);
  PVector geoCentroid = new PVector(0, 0);
  ArrayList<PVector> bbox = new ArrayList<PVector>();
  ArrayList<PVector> absBox = new ArrayList<PVector>();
  PVector bboxCenter = new PVector(0, 0);
  PVector bboxOrigin;
  float bboxAngle;
  float bboxArea;
  float G = 1;
  CustomShape myShape;
  ArrayList<PVector> hole = new ArrayList<PVector>();
  int colour;
  float maxSpeed = 2;
  float repulsion = 1000;
  float mySpeed = random(0.2,5);
  float bouncing = 1;
  float curAngle;
  color curColor = color(0);
  float addAngle;
  //float startAng = random(2*PI);
  float curScale = 1;
  float curRadius;
  boolean normalized = false;
  int mode = 0;
  int lastmode = 0;
  FloatDict data = new FloatDict();
  Vec2 force = new Vec2(0, 0);
  float torque = 0;
  Vec2 goal = new Vec2(center.x, center.y);
  int nPoints; 
  float xs[];
  float ys[]; 

  Building(String iid, int iindex, ArrayList<PVector> icoords, StringDict itags, int icolour) {
    id = iid;
    index = iindex;
    coords = icoords;
    tags = itags;
    colour = icolour;
  }
  void initPoints(PVector maxPoint, float minLon, float maxLon, float minLat, float maxLat, float iscreenScale) {
    screenScale = iscreenScale;
    ArrayList<PVector> tempPoints = new ArrayList<PVector>();
    for (int i = 0; i< coords.size (); i ++) {
      float tempX = haversine(minLat, minLon, minLat, coords.get(i).x) * screenScale; //convert from geographical to cartesian coordinates
      float tempY = maxPoint.y - haversine(minLat, minLon, coords.get(i).y, minLon)* screenScale;
      PVector tempPoint = new PVector(tempX, tempY);
      tempPoints.add(tempPoint);
    }
    int i = tempPoints.size()-1;
    PVector a = tempPoints.get(i);
    PVector b = tempPoints.get(i-1);
    PVector c = tempPoints.get(i-2);
    points.add(a);
    float angAB = atan2(b.y-a.y, b.x - a.x);
    float angBC = atan2(c.y-b.y, c.x - b.x);
    while(i >2){
      if (abs(angAB - angBC) > radians(5)){
        points.add(b);
        a = b;
      }
      i -= 1;
      b = c;// or PVector b = tempPoints.get(i-1);
      c = tempPoints.get(i-2);
      angAB = atan2(b.y-a.y, b.x - a.x);
      angBC = atan2(c.y-b.y, c.x - b.x);
    }
    points.add(tempPoints.get(1));
    points.add(tempPoints.get(0));     
    if (isClockwise(points) == true){
      points = reversePoints(points);
    }
    nPoints = points.size();
  }
  void initAttributes() {    
    geoCenter = loadCenter(coords);
    area = getArea(points);
    center = loadCentroid(points);
    //center = loadCenter(points);
    originalCenter = center.get();
    area = abs(area);
    unitScale = 1/sqrt(area);
    loadPerimeter();
    centralizePoints();
    loadRadius();
    curRadius = radius;
    loadMinBBox(50);
    absBox = getAbsBox(bbox);
  }
  void loadCustomShape() {
    myShape = new CustomShape(center.x * toWorld, center.y * toWorld, absBox);
    polygons.add(myShape);
  }
  void centralizePoints() {
    for (int i = 0; i< points.size (); i ++) {
      points.get(i).x -= center.x;
      points.get(i).y -= center.y; 
      angles.add(atan2(points.get(i).y, points.get(i).x));
      lengths.add(sqrt(sq(points.get(i).x)+sq(points.get(i).y)));
    }
  }
  ArrayList<PVector> reversePoints(ArrayList<PVector> pts) {
    ArrayList<PVector> tempPts = new ArrayList<PVector>(); 
    for (int i = points.size ()-1; i >= 0; i --) {
      tempPts.add(points.get(i));
    }
    
    return tempPts;
  }
  boolean isClockwise (ArrayList<PVector> pol) {
    int total = 0;
    for (int index = 0; index < pol.size () - 1; index ++) {
      total += (pol.get(index + 1).x - pol.get(index).x) * (pol.get(index + 1).y + pol.get(index).y);
    }
    if (total < 0) {
      return true;
    } else {// if (total > 0){
      return false;
    }
  }
  PVector loadCenter(ArrayList<PVector> perimeter) {
    PVector c = new PVector(0, 0);
    for (int i = 0; i< perimeter.size (); i ++) {
      c.x += perimeter.get(i).x;
      c.y += perimeter.get(i).y;
    }
    c.x /= perimeter.size();
    c.y /= perimeter.size();
    return c;
  }
  PVector loadCentroid(ArrayList<PVector> perimeter) {
    int imax = perimeter.size() - 1;
    PVector c = new PVector(0.0, 0.0);
    for (int i = 0; i < imax; i ++) {
      c.x += (perimeter.get(i).x + perimeter.get(i+1).x) * ((perimeter.get(i).x * perimeter.get(i+1).y) - (perimeter.get(i+1).x * perimeter.get(i).y));
      c.y += (perimeter.get(i).y + perimeter.get(i+1).y) * ((perimeter.get(i).x * perimeter.get(i+1).y) - (perimeter.get(i+1).x * perimeter.get(i).y));
    }
    c.x += (perimeter.get(imax).x + perimeter.get(0).x) * ((perimeter.get(imax).x * perimeter.get(0).y) - (perimeter.get(0).x * perimeter.get(imax).y));
    c.y += (perimeter.get(imax).y + perimeter.get(0).y) * ((perimeter.get(imax).x * perimeter.get(0).y) - (perimeter.get(0).x * perimeter.get(imax).y));
    c.x /= (area * 6.0);
    c.y /= (area * 6.0);
    return c;
  }
  void loadRadius() {
    float avgDist = 0;
    for (int i=0; i<lengths.size (); i ++) {
      avgDist += lengths.get(i);
    }
    avgDist /= lengths.size();
    radius = avgDist/2;
  }
  void loadPerimeter() {
    perimeter = 0;
    int npoints = points.size();
    for (int i = 0; i< npoints; i ++) {
      perimeter += distance(points.get(i), points.get((i+1)%npoints));
    }
  }
  ArrayList<PVector> BBox(float ang) {
    ArrayList<PVector> tempBox = new ArrayList<PVector>();
    PVector corner0 = new PVector(inf, inf);
    PVector corner2 = new PVector(-inf, -inf);
    ArrayList<PVector> rotPoints = new ArrayList<PVector>();
    for (int i = 0; i < points.size (); i++) {
      float testAngle = angles.get(i) + ang;
      rotPoints.add(new PVector(cos(testAngle)*lengths.get(i), sin(testAngle)*lengths.get(i)));
    }
    for (int i = 0; i < rotPoints.size (); i++) {
      float tempX = rotPoints.get(i).x;
      float tempY = rotPoints.get(i).y;
      corner0.x = min(tempX, corner0.x);
      corner0.y = min(tempY, corner0.y); 
      corner2.x = max(tempX, corner2.x);
      corner2.y = max(tempY, corner2.y);
    }
    tempBox.add(corner0);
    tempBox.add(new PVector(corner2.x, corner0.y));
    tempBox.add(corner2);
    tempBox.add(new PVector(corner0.x, corner2.y));
    return tempBox;
  }
  void loadMinBBox(int trials) {
    bboxArea = inf;
    for (int i=0; i<trials; i++) {
      float ang = (TWO_PI/trials) * i;
      ArrayList<PVector>tempBox = BBox(ang);
      float curArea = getArea(tempBox);
      if (curArea < bboxArea) {
        bboxArea = curArea;
        bbox = tempBox;
        bboxAngle = -ang;
      }
    }  
  }
  
  ArrayList<PVector> getAbsBox(ArrayList<PVector> bbox){
    ArrayList<PVector> rotBox = new ArrayList<PVector>();
    for (int i = 0; i < bbox.size (); i++) {
      
      float angle = atan2(bbox.get(i).y, bbox.get(i).x);
      float len = sqrt(sq(bbox.get(i).x)+sq(bbox.get(i).y));
      float newAngle = angle + bboxAngle;
      rotBox.add(new PVector(cos(newAngle)*len, sin(newAngle)*len));
    }
    return rotBox;
  }
  float getArea(ArrayList<PVector> testpoints) {
    float result = 0;
    int imax = testpoints.size() - 1;
    for (int i = 0; i < imax; i ++) {
      result += (testpoints.get(i).x * testpoints.get(i+1).y) - (testpoints.get(i+1).x * testpoints.get(i).y);
    }
    result += (testpoints.get(imax).x * testpoints.get(0).y) - (testpoints.get(0).x * testpoints.get(imax).y);
    return result /2;
  }
  //THIS FUNCTION WON'T WORK NOW... because i am using relative coordinates for the outline
  boolean isInside(float x, float y) {
    int i, j;
    boolean inside = false;
    for (i = 0, j = points.size () - 1; i < points.size(); j = i++) {
      if ((((points.get(i).y <= y) && (y < points.get(j).y)) || ((points.get(j).y <= y) && (y < points.get(i).y))) && (x < (points.get(j).x - points.get(i).x) * (y - points.get(i).y) / (points.get(j).y - points.get(i).y) + points.get(i).x)) {
        inside =! inside;
      }
    }
    return inside;
  }
  

  void initAnalysis() {
    dataDispersion();
    dataRectangularity();
    dataPerimeter();
    dataArea();
    //loadOrtogonality();
    //loadSimilarity();
  }
  void collisionOff(){
    collision = false;
    myShape.collisionOff();
  }
  void collisionOn(){
    collision = true;
    myShape.collisionOn();
  }

  void dataDispersion() {
    addData("dispersion", perimeter*unitScale);
  }
  void dataRectangularity() {
    addData("rectangularity", area/bboxArea);
  }  
  void dataPerimeter() {
    addData("perimeter", perimeter/screenScale);
  }
  void dataArea() {
    addData("area", area);
  }

  void addData(String aKey, Float aValue) {
    //these global function keep track of the boundary values to define the graphs space
    updateGlobalData(aKey, aValue);
    data.set(aKey, aValue);
  }
  void updateVector() {
    if (mode == 1) {//go back to position without orbiting 
      G = .01 * speedFactor/2 * toWorld; // Strength of force
      Vec2 cen = box2d.coordPixelsToWorld(center.x, center.y); 
      Vec2 goTo = box2d.coordPixelsToWorld(goal.x, goal.y);
      force = goTo.sub(cen);
      float distance = force.length();
      distance = constrain(distance, .01, 3);
      force.normalize();
      float strength = G * sq(distance) * myShape.body.m_mass;
      force.mulLocal(strength);
      float nextAngle = myShape.getAng() + myShape.getAngVel() / 60.0;
      float totalRotation = -nextAngle;
      while ( totalRotation < radians (-180) ) {
        totalRotation += radians(360);
      }
      while ( totalRotation >  radians (180) ) {
        totalRotation -= radians(360);
      }
      float desiredAngularVelocity = totalRotation;
      torque = myShape.getIner() * desiredAngularVelocity * 60;
      myShape.applyTor(torque);
      myShape.setVel(force);
      
    } else if(mode == 2){ // this is the real attraction
      G = speedFactor * mySpeed * toWorld; // Strength of force
      Vec2 cen = box2d.coordPixelsToWorld(center.x, center.y);//myShape.body.getWorldCenter(); 
      Vec2 goTo = box2d.coordPixelsToWorld(goal.x+random(-2, 2), goal.y+random(-2, 2)); 
      force = goTo.sub(cen);
      float distance = force.length();
      force.normalize();
      float strength = G* sq(distance) * myShape.body.m_mass;
      force.mulLocal(strength);
      Vec2 pos = myShape.body.getWorldCenter();
      myShape.body.applyForce(force, pos);
    }
  }
  void vec2Constraint(Vec2 inVector){
    if (inVector.x > width - menuWidth - margin){inVector.x = width - menuWidth - margin;}
    else if (inVector.x < margin){inVector.x = margin;}
    if (inVector.y > height - margin){inVector.y = height - margin;}
    else if (inVector.y < margin){inVector.y = margin;}
  }
  
  void vectorGoal(float x, float y) {
    mode = 2;
    goal = new Vec2 (x, y);
    vec2Constraint(goal); 
  }
  void vectorAttract(float x, float y) {
    mode = 2;
    float dist = distance(new PVector(x, y), center);
    if (dist <= height*mouseInfluence){
      float vecSize = map(dist, 0, height*mouseInfluence, 0, height*mouseInfluence/2);
      println(map(dist, 0, height, 0, height/2), 10*sqrt(dist));
      goal  = new Vec2 ((x - center.x), (y - center.y));
      goal.normalize();
      goal = goal.mul(vecSize);
      goal.x += center.x;
      goal.y += center.y;
    }
  }
  void vectorRepel(float x, float y) {
    mode = 2;
    float dist = distance(new PVector(x, y), center);
    if (dist <= height*mouseInfluence){
      float vecSize = map(dist, 0, height*mouseInfluence, height*mouseInfluence/2, 3*height*mouseInfluence/2);
      goal  = new Vec2 ((center.x - x), (center.y - y));
      goal.normalize();
      goal = goal.mul(vecSize);
      goal.x += center.x;
      goal.y += center.y;
      vec2Constraint(goal);
    }
  }
  void vectorOrigin() {
    mode = 1;
    goal = new Vec2 (originalCenter.x, originalCenter.y);
  }
  void vectorStop() {
    lastmode = mode;
    goal = new Vec2(center.x, center.y);
    mode = 1;
  }
  void vectorRestart() {
    mode = lastmode;
  }

  void changeSize() {
    normalized = !normalized;
    if (normalized == true) {
      curScale = unitScale;
      curRadius = radius*unitScale;
    } else {
      curScale = 1;   
      curRadius = radius;
      //finalVector = new PVector(cos(random(2*PI)) * mySpeed, sin(random(2*PI)) * mySpeed);
    }
  }
  void update() {
    mySpeed = max(goal.length() / 100, 1);
    if (mode != 0) {
      updateVector();
    }
    Vec2 myPosition = myShape.getPos();
    center.x = myPosition.x * toPixels;
    center.y = myPosition.y * toPixels;
    curAngle = -myShape.getAng();
  }
  

  void drawOutline() {
    fill(curColor);
    pushMatrix();
    translate(center.x, center.y);
    // scale (curScale);
    rotate(curAngle);

    beginShape();
    for (int i = 0; i <nPoints; i ++) {
      //vertex (xs[i], ys[i]);
      PVector aPoint = points.get(i);
      vertex(aPoint.x, aPoint.y);
    }
    endShape(CLOSE);
    popMatrix();
//    stroke(255,0,0);
//    line(center.x, center.y, goal.x, goal.y);
//    noStroke();
  }
  }
  



