int ticks;
JSONObject board[][];
float offX;
float offY;
float scale;
JSONObject backgroundColor;

void runGame(){
  for(int i = 0;i < 32;i++){
    activeGame.run();
    ticks++;
  }
}

void renderGame(){
  background(Colors.byName(backgroundColor.getString("value")));
  for(int x = 0;x < board.length;x++){
    for(int y = 0;y < board[x].length;y++){
      fill(Colors.byName(board[x][y].getString("value")));
      stroke(0);
      rect(x*scale+offX,y*scale+offY,scale,scale);
    }
  }
  pauseBackground = g.copy();
}

void restartGame(){
  ticks = 0;
  backgroundColor = new JSONObject();
  backgroundColor.setString("type","COLOR");
  backgroundColor.setString("value","WHITE");
  JSONObject boardContext = activeGame.context.getJSONObject("board");
  int x = 1;
  int y = 1;
  if(boardContext != null){
    String X = boardContext.getString("width");
    String Y = boardContext.getString("height");
    if(X==null) {
      x = boardContext.getInt("width");
    }
    else{
      JSONObject w = activeGame.options.getJSONObject(X);
      if(w == null) {
        debug.println("[ERROR]: value for width '"+X+"' is no number and not defined in options of "+activeGame.name+".");
        x = 1;
      }
      else{
        if(!w.getString("type").equals("NUMBER")){
          debug.println("[ERROR]: Option '"+X+"' for width for board in context is no NUMBER.");
          x = 1;
        }
        else{
          x = w.getInt("value");
        }
      }
    }
    if(Y==null){
      y = activeGame.context.getInt("height");
    }
    else{
      JSONObject h = activeGame.options.getJSONObject(Y);
      if(h == null) {
        debug.println("[ERROR]: Value for height '"+Y+"' is no number and not defined in options of "+activeGame.name+".");
        y = 1;
      }
      else{
        if(!h.getString("type").equals("NUMBER")){
          debug.println("[ERROR]: Option '"+Y+"' for height for board in cotext is no NUMBER.");
          y = 1;
        }
        else{
          y = h.getInt("value");
        }
      }
    }
  }
  else{
    debug.println("[ERROR]: Board in cotext is not defined.");
  }

  if(x < 1 || x > 128){
    debug.println("[ERROR]: Width ("+x+") is not in range 1-128.");
    x = constrain(x,1,128);
  }
  if(y < 1 || y > 128){
    debug.println("[ERROR]: Height ("+y+") is not in range 1-128.");
    y = constrain(y,1,128);
  }
  board = new JSONObject[x][y];
  float sx = (width-1)/(float)board.length;
  float sy = (height-1)/(float)board[0].length;
  scale = min(sx,sy);
  offX = (width-board.length*scale)/2.0;
  offY = (height-board[0].length*scale)/2.0;
  for(int xx = 0;xx < board.length;xx++){
    for(int yy = 0;yy < board[xx].length;yy++){
      board[xx][yy] = new JSONObject();
      board[xx][yy].setString("type","COLOR");
      board[xx][yy].setString("value","WHITE");
    }
  }
  activeGame.startGame();
  debug.println("[DEBUG]: Restarted + reset game "+activeGame.name+".");
}
