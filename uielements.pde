int uiElementID;
int currentID;
boolean pmousePressed;

boolean button(String title, float x, float y, float w, float h){
  currentID++;
  strokeWeight(3);
  fill(200);
  stroke(0);
  rect(x,y,w,h,10);
  fill(0);
  textAlign(CENTER,CENTER);
  textSize(25);
  text(title,x+w/2,y+h/2-5);
  if(mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h){
    if(uiElementID == 0 || uiElementID == currentID){
      fill(100,50);
      rect(x,y,w,h,10);
      if(mousePressed && mouseButton == LEFT){
        if(uiElementID == 0 && !pmousePressed) uiElementID = currentID;
        rect(x,y,w,h,10);
      }
      if(!mousePressed && uiElementID == currentID){
        return true;
      }
    }
  }
  else if(uiElementID == currentID){
    fill(100,50);
    rect(x,y,w,h,10);
  }
  return false;
}

float slider(float value, float x, float y, float w){
  currentID++;
  strokeWeight(3);
  fill(200);
  stroke(0);
  rect(x,y,w,20,10);
  if(mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+20){
    if(uiElementID == 0 || uiElementID == currentID){
      fill(100,50);
      rect(x,y,w,20,10);
      if(mousePressed && mouseButton == LEFT){
        rect(x,y,w,20,10);
        if(uiElementID == 0 && !pmousePressed) uiElementID = currentID;
      }
    }
  }
  else if(uiElementID == currentID){
    fill(100,50);
    rect(x,y,w,20,10);
  }
  if(mousePressed && uiElementID == currentID){
    value = constrain((mouseX-x)/w,0,1);
  }
  fill(100);
  rect(x+w*value-5,y-5,10,30,5);
  return value;
}

void preRun(){
  if(appState != 2) background(255);
  currentID = 0;
  if(appState != 1) page = 0; //reset options page
}

void postRun(){
  if(!mousePressed){
    uiElementID = 0;
  }
  pmousePressed = mousePressed;
}
