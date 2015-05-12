// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// Box2DProcessing example

// A rectangular box
class CustomShape {

  // We need to keep track of a Body and a width and height
  Body body;
  ArrayList<PVector> myPoints = new ArrayList<PVector>();

  // Constructor
  CustomShape(float x, float y, ArrayList<PVector> ipoints) {
    // Add the box to the box2d world
    myPoints = ipoints;
    makeBody(new Vec2(x, y));
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }
  void collisionOff(){
    body.getFixtureList().setSensor(true);
  }
  void collisionOn(){
    body.getFixtureList().setSensor(false);
  }
  float getAng() {
    return body.getAngle();
  }
  float getMas() {
    return body.getMass();
  }
  Vec2 getPos() {
    return box2d.getBodyPixelCoord(body);
  }
  void applyForce(Vec2 v) {
    body.applyForce(v, body.getWorldCenter());
  }
  Vec2 getVel() {
    return body.getLinearVelocity();
  }
  float getAngVel() {
    return body.getAngularVelocity();
  }
  void setAngVel(float vel) {
    body.setAngularVelocity(vel);
  }
  float getIner() {
    return body.getInertia();
  }
  void applyTor(float torque) {
    body.applyTorque(torque);
  }
  void setVel(Vec2 newVel) {
    body.setLinearVelocity(newVel);
  }

  // Is the particle ready for deletion?
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height) {
      killBody();
      return true;
    }
    return false;
  }
  boolean isClockwise (Vec2[] pol) {
    int total = 0;
    for (int index = 0; index < pol.length - 1; index ++) {
      total += (pol[index + 1].x - pol[index].x) * (pol[index + 1].y + pol[index].y);
    }
    if (total < 0) {
      //println("clockwise");
      return true;
    } else {// if (total > 0){
      //println("counter clockwise");
      return false;
    }
  }
  float getArea(Vec2[] perimeter) {
    float result = 0;
    int imax = perimeter.length - 1;
    for (int i = 0; i < imax; i ++) {
      result += (perimeter[i].x * perimeter[i+1].y) - (perimeter[i+1].x * perimeter[i].y);
    }
    result += (perimeter[imax].x * perimeter[0].y) - (perimeter[0].x * perimeter[imax].y);
    return result /2;
  }
  float[] getSides(Vec2[] perimeter) {

    int imax = perimeter.length - 1;
    float[] sides = new float[imax];
    for (int i = 0; i < imax; i ++) {
      Vec2 tempSide = perimeter[i+1].sub(perimeter[i]);
      sides[i] = tempSide.length();
    }
    return sides;
  }

  // Drawing the box
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    Fixture f = body.getFixtureList();
    PolygonShape ps = (PolygonShape) f.getShape();

    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(175);
    stroke(0);
    beginShape();
    // For every vertex, convert to pixel vector
    for (int i = 0; i < ps.getVertexCount (); i++) {
      Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    popMatrix();
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center) {

    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    int nCorners = myPoints.size();
    Vec2[] vertices = new Vec2[nCorners];
    for (int i = 0; i < nCorners; i++) {
      vertices[i] = box2d.vectorPixelsToWorld(new Vec2(myPoints.get(i).x * toWorld, myPoints.get(i).y * toWorld));
    }
    sd.set(vertices, vertices.length);
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    body = box2d.createBody(bd);
    body.createFixture(sd, 1); 
    body.setLinearVelocity(new Vec2(0, 0));
    body.setAngularVelocity(0);
    body.setGravityScale(0);
  }
}

