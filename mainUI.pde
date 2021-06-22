ArrayList<Game> games;
int selectedGame;

void selectUI(){
  if(games == null) reloadGames();
  textSize(50);
  fill(0);
  text("Main menu",width/2,50);
  textSize(30);
  text("Select game",width/2,100);
  if(games.size() == 0){
    text("No games available.\nAdd some and press \"reload\"",width/2,height/2);
  }
  else{
    selectedGame = constrain(selectedGame,0,games.size()-1);
    if(selectedGame > 0){
      if(button("<",width/2-130,height/2+20,40,40)){
        selectedGame--;
      }
    }
    fill(0);
    text((selectedGame+1)+"/"+games.size(),width/2,height/2+37);
    if(selectedGame < games.size()-1){
      if(button(">",width/2+90,height/2+20,40,40)){
        selectedGame++;
      }
    }
    if(button("",width/2-150,height/2-200,300,200)){
      appState = 1;
      activeGame = games.get(selectedGame);
      games = null;
      debug.println("[DEBUG]: Selected game "+activeGame.name+".");
    }
    else{
      fill(0);
      text(games.get(selectedGame).name,width/2,height/2-150);
      text(games.get(selectedGame).version,width/2,height/2-100);
    }
  }
  if(button("reload",width/2-100,height-100,200,70)){
    reloadGames();
  }
}

void reloadGames(){
  debug.println("[DEBUG]: Reloading all games...");
  games = new ArrayList<Game>();
  File[] files = listFiles("data/games");
  for (int i = 0; i < files.length; i++) {
    if(!files[i].isDirectory()){
      if(files[i].toString().endsWith(".json")){
        Game g = new Game(files[i].getName());
        if(g.isValid){
          games.add(g);
          debug.println("         Successfully loaded "+g.name+".");
        }
        else{
          debug.println("         Loaded "+g.name+" with errors.");
        }
      }
    }
  }
  debug.println("[DEBUG]: Reloaded all games.");
}
