void keyPressed(){
  if(keyCode == ESC){
    switch(appState){ 
    case 0: 
      break;
    case 1: 
      appState = 0;
      break;
    case 2:
      appState = 3;
      debug.println("[DEBUG]: Paused game "+activeGame.name+".");
      break;
    case 3:
      appState = 2;
      debug.println("[DEBUG]: Resumed game "+activeGame.name+".");
      break;
    }
    key = 0; 
  }
}
