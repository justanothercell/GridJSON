PImage pauseBackground;

void pauseMenu(){
  if(pauseBackground != null) image(pauseBackground,0,0,width,height);
  if(activeGame != null){
    textSize(50);
    fill(0);
    text(activeGame.name,width/2,50);
    textSize(30);
    text("Pause",width/2,100);
  }
  if(button("return to game",width/2-100,height - 340,200,70)){
    appState = 2;
    debug.println("[DEBUG]: Resumed game "+activeGame.name+".");
  }
  if(button("exit game",width/2-100,height - 260,200,70)){
    appState = 1;
    debug.println("[DEBUG]: Exited game "+activeGame.name+".");
  }
  if(button("restart game",width/2-100,height - 180,200,70)){
    appState = 2;
    restartGame();
    debug.println("[DEBUG]: Restarted game "+activeGame.name+".");
    
  }
  if(button("main menu",width/2-100,height - 100,200,70)){
    appState = 0;
    debug.println("[DEBUG]: Exited game "+activeGame.name+" to main menu.");
  }
}
