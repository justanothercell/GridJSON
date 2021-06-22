int page;

void optionsUI(){
  if(activeGame == null) appState=0;
  boolean error = false;
  try{
    textSize(50);
    fill(0);
    text(activeGame.name,width/2,50);
    textSize(30);
    text("Options",width/2,100);
    String[] optionKeys = (String[])activeGame.options.keys().toArray(new String[]{});
    int maxY = 0;
    for(int i = 0;i < optionKeys.length;i++){
      int y = activeGame.options.getJSONObject(optionKeys[i]).getInt("index",0);
      if(y > maxY) maxY = y;
      y -= page*8;
      if(y >= 0 && y < 8){
        if(activeGame.options.getJSONObject(optionKeys[i]).getString("type").toLowerCase().equals("number")){
          String range[] = activeGame.options.getJSONObject(optionKeys[i]).getString("range","0 1").split(" ");
          if(range.length == 2){
            int min = int(range[0]);
            int max = int(range[1]);
            int num = activeGame.options.getJSONObject(optionKeys[i]).getInt("value");
            num = constrain(num,min,max);
            num = (int)(slider((num-min)/(float)(max-min),width/2-100,150+y*50+5,200)*(max-min)+min);
            activeGame.options.getJSONObject(optionKeys[i]).setInt("value",num);
            fill(0);
            text(activeGame.options.getJSONObject(optionKeys[i]).getString("name","null"),width/2-200,150+y*50+10);
            text(num,width/2+200,150+y*50+10);
          }
        }
        if(activeGame.options.getJSONObject(optionKeys[i]).getString("type").toLowerCase().equals("flag")){
          boolean flag = activeGame.options.getJSONObject(optionKeys[i]).getBoolean("value");
          if(button(activeGame.options.getJSONObject(optionKeys[i]).getString("name","null"),width/2-100,150+y*50,200,30)) flag = !flag;
          activeGame.options.getJSONObject(optionKeys[i]).setBoolean("value",flag);
          fill(0);
          text(flag+"",width/2+200,150+y*50+10);
        }
      }
    }
    
    maxY++;
    if(maxY-page*8 >= 0 && maxY-page*8 < 8){
      fill(0);
      text("Presets:",width/2,150+(maxY-page*8)*50+10);
    }
    
    for(int i = 0;i < activeGame.presets.size();i++){
      int y = activeGame.presets.getJSONObject(i).getInt("index",0)+1;
      if(y > maxY) maxY = y;
      y -= page*8;
      if(y >= 0 && y < 8){
        if(button(activeGame.presets.getJSONObject(i).getString("name","null"),width/2-100,150+y*50,200,30)){
          String[] presentKeys = (String[])activeGame.presets.getJSONObject(i).getJSONObject("values").keys().toArray(new String[]{});
          for(int k = 0;k < presentKeys.length;k++){
            if(activeGame.options.get(presentKeys[k]) != null){
              if(activeGame.options.getJSONObject(presentKeys[k]).getString("type").equals("NUMBER")) activeGame.options.getJSONObject(presentKeys[k]).setInt("value",activeGame.presets.getJSONObject(i).getJSONObject("values").getInt(presentKeys[k]));
              if(activeGame.options.getJSONObject(presentKeys[k]).getString("type").equals("FLAG")) activeGame.options.getJSONObject(presentKeys[k]).setBoolean("value",activeGame.presets.getJSONObject(i).getJSONObject("values").getBoolean(presentKeys[k]));
            }
          }
        }
      }
    }
    
    if(page > 0){
      if(button("<",width/2-90,height-250,40,40)){
        page--;
      }
    }
    fill(0);
    text((page+1)+"/"+(maxY/8+1),width/2,height-235);
    if(page < maxY/8){
      if(button(">",width/2+50,height-250,40,40)){
        page++;
      }
    }
  }
  catch(Exception e){
    fill(255,0,0);
    stroke(0);
    rect(width/2-270,height/2-100,540,200,10);
    fill(0);
    text("Game settings could not\nbe displayed properly\ndue to an error:\n"+e.toString(),width/2,height/2);
    debug.println("[ERROR]: Game settings could not be displayed properly due to an error: "+e.toString());
    error = true;
  }
  if(!error){
    if(button("start game",width/2-100,height - 180,200,70)){
      appState = 2;
      restartGame();
      debug.println("[DEBUG]: Started game "+activeGame.name+".");
    }
  }
  if(button("main menu",width/2-100,height - 100,200,70)){
    appState = 0;
    debug.println("[DEBUG]: Exited to main menu.");
  }
}
