class Button{
  String name;
  float posx, posy, wid, heig;
  boolean pressed = false;
  int[] stroke = new int [3];
  color on_color = color(255, 255, 255, 200);
  color text_color = color(150, 150, 150);
  float w = 1;
  int id;
  boolean option;
  
  Button (int iid, String iname, float iposx, float iposy, float iwid, float iheig, boolean ipressed){
    id = iid;
    name = iname;     
    posx = iposx;
    posy = iposy;
    wid = iwid;
    heig = iheig;
    pressed = ipressed;
    option = false;
    
  }
  boolean just_click(float x, float y){
    if ((x >= posx) && ( x <= posx + wid) && (y >= posy) && ( y <= posy + heig)){return true;}
    else{return false;}
  }
  void content(String newText){
    name = newText;
  }
  void setPos(float x, float y){
    posx = x - wid/2;
    posy = y - heig/2;
  }
  void on(){
    text_color = color(255, 0, 0);
  }
  void off(){
    text_color = color(150, 150, 150);
  }
  
  void update(){
    fill(on_color);
    noStroke();
    rect(posx, posy, wid, heig);
    fill(text_color);
    text(name, posx + 10, posy + heig/2 + 5);
    fill(0);
  }
}
