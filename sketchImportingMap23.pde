//INTERFACE
import controlP5.*;

//PDF
import processing.pdf.*;

//COLLISION //<>//
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

//data scrap library
import com.temboo.core.*;
import com.temboo.Library.DataGov.*;
import com.temboo.Library.Google.Elevation.*;

//COLLISION
// A reference to our box2d world
Box2DProcessing box2d;


ControlP5 cp5;
CheckBox checkbox;
RadioButton radioX, radioY, radioM; 

boolean record;

ArrayList<Button> buttons = new ArrayList<Button>();
float but_height = 20;
float but_width = 150;
int margin = 20;
float speedFactor = 1;
float mouseInfluence = 1;

// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;
// A list for all of our rectangles
ArrayList<CustomShape> polygons;
ArrayList<Node> nodes = new ArrayList<Node>();
IntDict nodesI = new IntDict();
ArrayList<Way> ways = new ArrayList<Way>();
FloatDict maxData = new FloatDict();
FloatDict minData = new FloatDict();
ArrayList<String> dataKeys = new ArrayList<String>();
int yIndex = 0;
int xIndex = 0;
int mouseIndex = 0;
IntDict waysI = new IntDict();
ArrayList<Building> buildings = new ArrayList<Building>();
IntDict buildingsI = new IntDict();
float inf = 999999;
PVector maxPoint = new PVector(0, 0); 
float minLat = inf;
float maxLat = -inf;
float minLon = inf;
float maxLon = -inf;
PVector screenSize = new PVector(1400, 900); //there will be an extra width for the buttons and sliders
int menuWidth = 200;
float scale = .6;
int test = 10; 
int select = 5;
int[] scales= {30, 10, 10,10,10, 10, 10}; 
String[] cities= {"finalSiena" , "finalBarcelona", "finalBrasilia", "finalNY" , "finalParis", "finalViena", "chandigarh" };
String filename = cities[select];
boolean normalized = false;
float toWorld = scales[select];
float toPixels = 1/toWorld;
String[] menu = {"(re)map", "x", "y", "change red bars to define", "the area for organization"};
float menuStartX = screenSize.x - menuWidth;
float[] menuX = {screenSize.x + menuWidth/2, screenSize.x + margin/2, screenSize.x + margin/2 + 120, screenSize.x + margin/2, screenSize.x + margin/2};
float[] menuY = {screenSize.y - 2*margin, 1.8*margin, 1.8*margin, 10*margin, 11*margin};



void setup() {
  size(int((screenSize.x) + menuWidth),int(screenSize.y));
  background(255); 
  
  loadFile(filename + ".osm");
  
  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  //toWorld = toWorld;
  //toPixels = toWorld;
  // Create ArrayLists  
  polygons = new ArrayList<CustomShape>();
  boundaries = new ArrayList<Boundary>();

  // Add a bunch of fixed boundaries
  boundaries.add(new Boundary(0, 0, 2*width, margin, 0));
  boundaries.add(new Boundary(width-menuWidth, 0, margin, 2*height, 0));
  boundaries.add(new Boundary(0, height, 2*width, margin, 0));
  boundaries.add(new Boundary(0, 0, margin, 2*height, 0));

  //load all customshapes inside buildings
  for (int i = 0; i <buildings.size (); i++) {
    buildings.get(i).loadCustomShape();
  }
  
  //load interface
  buttons.add(new Button(0, dataKeys.get(0), 0, 0, but_width, but_height, false));
  buttons.add(new Button(0, dataKeys.get(0), 0, 0, but_width, but_height, false));
  PFont pfont = createFont("Arial",20,true); // use true/false for smooth/no-smooth
  ControlFont font = new ControlFont(pfont,241);
  textFont(pfont, 12);
  cp5 = new ControlP5(this);
  cp5.addSlider("slider1")
     .setPosition(0,0)
     .setSize((width-menuWidth)/2,margin/2)
     .setRange(0,(width-menuWidth)/2)
     .setValue((width-menuWidth)/4)
     .setColorForeground(color(255, 255, 255))
     .setColorActive(color(255, 255, 255)) 
     .setColorBackground(color(100, 0, 0))
     .setLabelVisible(false) 
     ;
  
  cp5.addSlider("slider2")
     .setPosition((width-menuWidth)/2,0)
     .setSize((width-menuWidth)/2,margin/2)
     .setRange((width-menuWidth)/2,width-menuWidth)
     .setValue(3*(width-menuWidth)/4)
     .setColorForeground(color(100, 0, 0))
     .setColorActive(color(100, 0, 0)) 
     .setColorBackground(color(255, 255, 255))
     .setLabelVisible(false) 
     ;
  cp5.addSlider("slider3")
     .setPosition(0,10)
     .setSize(10,height/2)
     .setRange(height/2, 0)
     .setValue(height/4)
     .setColorForeground(color(0,0,100))
     .setColorActive(color(0,0,100)) 
     .setColorBackground(color(255, 255, 255))
     .setLabelVisible(false) 
     ;
  cp5.addSlider("slider4")
     .setPosition(0,height/2)
     .setSize(10,height/2)
     .setRange(height, height/2)
     .setValue(3*height/4)
     .setColorForeground(color(255, 255, 255))
     .setColorActive(color(255, 255, 255)) 
     .setColorBackground(color(0,0,100))
     .setLabelVisible(false) 
     ;
  cp5.addSlider("speed factor")
   .setPosition(width - menuWidth + margin/2, 26* margin)
   .setSize(menuWidth/2,margin) //menuWidth - margin/2
   .setRange(0, 2)
   .setValue(.1)
   .setColorForeground(color(100, 0, 0))
   .setColorActive(color(100, 0, 0)) 
   .setColorBackground(color(255,255,255))
   .setColorCaptionLabel(color(0))
   ;
  cp5.addSlider("mouse influence")
   .setPosition(width - menuWidth + margin/2, 24* margin)
   .setSize(menuWidth/2,margin) //menuWidth - margin/2
   .setRange(0, 2)
   .setValue(1)
   .setColorForeground(color(100, 0, 0))
   .setColorActive(color(100, 0, 0)) 
   .setColorBackground(color(255,255,255))
   .setColorCaptionLabel(color(0))
   ;
  checkbox = cp5.addCheckBox("checkBox")
              .setPosition(width - menuWidth + margin/2, 28* margin)
              .setColorForeground(color(200))
              .setColorForeground(color(200))
              .setColorActive(color(100, 0, 0))
              .setColorLabel(color(0))
              .setSize(margin, margin)
              .setItemsPerRow(1)
              .setSpacingColumn(30)
              .setSpacingRow(margin/2)
              .addItem("collision", 0)
              .activate(0)
              ;  
 
  radioX = cp5.addRadioButton("radioX")
         .setPosition(width - menuWidth + margin/2, 2 * margin)
         .setSize(margin,margin)
         .setColorForeground(color(120))
         .setColorActive(color(100, 0, 0))
         .setColorLabel(color(0))
         .setItemsPerRow(1)
         .setSpacingColumn(50)
         ;
  for (int i = 0 ; i < dataKeys.size(); i ++){
    radioX.addItem("axis " + dataKeys.get(i), i);
  }
  radioX.activate(0);
  
  radioY = cp5.addRadioButton("radioY")
         .setPosition(width - menuWidth + margin/2 + 120, 2 * margin)
         .setSize(margin,margin)
         .setColorForeground(color(120))
         .setColorActive(color(100, 0, 0))
         .setColorLabel(color(255))
         .setItemsPerRow(1)
         .setSpacingColumn(50)
         ;
  for (int i = 0 ; i < dataKeys.size(); i ++){
    radioY.addItem("y" + dataKeys.get(i), i);
  }
  radioY.activate(0);
  
  cp5.addButton("organize by axis")
     .setPosition(width - menuWidth + margin/2, 8 * margin)
     .setColorActive(color(100, 0, 0))
     .setColorForeground(color(120))
     .setSize(140,margin)
     ;
     
     
  radioM = cp5.addRadioButton("radioM")
         .setPosition(width - menuWidth + margin/2, 14 * margin)
         .setSize(margin,margin)
         .setColorForeground(color(120))
         .setColorActive(color(100, 0, 0))
         .setColorLabel(color(0))
         .setItemsPerRow(1)
         .setSpacingColumn(50)
         ;
  for (int i = 0 ; i < dataKeys.size(); i ++){
    radioM.addItem("mouse " + dataKeys.get(i), i);
  }
  radioM.addItem("mouse attraction", dataKeys.size());
  radioM.addItem("mouse repulsion", dataKeys.size()+1);
  radioM.addItem("mouse stop", dataKeys.size()+2);
  radioM.addItem("back to original pos", dataKeys.size() + 3);
  radioM.activate(5);
  
  


}

//=====================================================
void draw() {
  if (record) {
    // Note that #### will be replaced with the frame number. Fancy!
    beginRecord(PDF, cities[select] + "frame-####.pdf"); 
  }
  background(255);
  box2d.step();
  
//  for (Boundary wall : boundaries) {
//    wall.display();
//  }
  
  
  fill(0);
  noStroke();
  
  
  int nBuildings = buildings.size();
  for (int i = 0; i <nBuildings; i++) {
    Building aBuilding = buildings.get(i);
    aBuilding.update();
    aBuilding.drawOutline();
  }
  buttons.get(0).update();
  pushMatrix();
  translate(margin/2, cp5.getValue("slider4"));
  rotate(-PI/2);
  buttons.get(1).update();
  popMatrix();
  if (record) {
    endRecord();
  record = false;
  }
  for (int i = 0; i < menu.length; i ++){
    stroke(0);
    fill(0);
    text(menu[i], menuX[i], menuY[i]);
  }
}

//=====================================================
float distance(PVector p1, PVector p2) {
  return sqrt(sq(p2.x - p1.x) + sq(p2.y - p1.y));
}
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(checkbox)) {
    if (checkbox.getItem(0).getValue() == 0){
      for (int i = 0; i <buildings.size (); i++) {
        buildings.get(i).collisionOff();
        
      }
    }
    else{
      for (int i = 0; i <buildings.size (); i++) {
        buildings.get(i).collisionOn();
      }
    }
  }
  else if (theEvent.isFrom(radioX)) {
    xIndex = int(radioX.getValue());
    buttons.get(0).content("x-axis: largest " + dataKeys.get(xIndex));
  }
  else if (theEvent.isFrom(radioY)) {
    yIndex = int(radioY.getValue());
    buttons.get(1).content("y-axis: largest " + dataKeys.get(yIndex));
  }
  else if (theEvent.isFrom(radioM)) {
    mouseIndex = int(radioM.getValue());
    println("mouseIndex is", mouseIndex);
  }
  ////CHECK WHY IS INITIALIZING WITHOUT CLICK
  else if (theEvent.isFrom(cp5.getController("speed factor"))){
    speedFactor = cp5.getController("speed factor").getValue();
    println("speedfactor", speedFactor);
  }
  else if (theEvent.isFrom(cp5.getController("mouse influence"))){
    mouseInfluence = cp5.getController("mouse influence").getValue();
    println("mouse influence", mouseInfluence);
  }

  else if (theEvent.isFrom(cp5.getController("organize by axis"))){
    println("organizing");
    buttons.get(0).on();
    buttons.get(1).on();
    for (int i = 0; i <buildings.size (); i++) {
      String xCriteria = dataKeys.get(xIndex);
      String yCriteria = dataKeys.get(yIndex);
      float tempx = map(buildings.get(i).data.get(xCriteria), minData.get(xCriteria), maxData.get(xCriteria), cp5.getValue("slider1"), cp5.getValue("slider2"));
      float tempy = map(buildings.get(i).data.get(yCriteria), minData.get(yCriteria), maxData.get(yCriteria), cp5.getValue("slider3"), cp5.getValue("slider4"));
      buildings.get(i).vectorGoal(int(tempx), int(tempy));
      buildings.get(i).curColor = color(200 - ((tempx)/(width + height)) * 200, 0, 200 - ((tempy)/(width + height)) * 200);
    }
  }
  else if (theEvent.isFrom(cp5.getController("slider2"))){
    buttons.get(0).setPos(cp5.getValue("slider2") - but_width/2, but_height);
  }
}
void keyPressed() {
  if (key == ENTER) {
    record = true;
  }
}
void mousePressed() {

  if (mouseX > margin && mouseX < width-menuWidth && mouseY>margin && mouseY < height-margin){
    if (mouseIndex > -1 && mouseIndex < dataKeys.size()){
      for (int i = 0; i <buildings.size (); i++) {
        String mouseCriteria = dataKeys.get(mouseIndex);
        float rad = map(buildings.get(i).data.get(mouseCriteria), maxData.get(mouseCriteria), minData.get(mouseCriteria), 10, height*mouseInfluence/2);
        float ang = random(0, TWO_PI);
        buildings.get(i).vectorGoal(mouseX + cos(ang)*rad, mouseY + sin(ang)*rad);
        buildings.get(i).curColor = color(200 - (rad/(height*mouseInfluence/2)) * 200, 0, 0);
      }
    }
    else if (mouseIndex == dataKeys.size()){
      for (int i = 0; i <buildings.size (); i++) {
        buildings.get(i).vectorAttract(mouseX, mouseY);
        buildings.get(i).curColor = color(0);
      }
    }
    else if (mouseIndex == dataKeys.size() + 1){
      for (int i = 0; i <buildings.size (); i++) {
        buildings.get(i).vectorRepel(mouseX, mouseY);
        buildings.get(i).curColor = color(0);
      }
    }
    else if (mouseIndex == dataKeys.size() + 2){
      for (int i = 0; i <buildings.size (); i++) {
        buildings.get(i).vectorStop();
        buildings.get(i).curColor = color(0);
      }
    }
    else if (mouseIndex == dataKeys.size() + 3){
      for (int i = 0; i <buildings.size (); i++) {
        buildings.get(i).vectorOrigin();
        buildings.get(i).curColor = color(0);
      }
    }
    for (int i = 0; i< buttons.size(); i++){
      buttons.get(i).off(); 
    }
  }
}
