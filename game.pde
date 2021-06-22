class Game{
  String name;
  String version;
  boolean isValid;
  JSONObject options;
  JSONObject context;
  JSONArray presets;
  
  JSONObject structures;
  JSONObject globalVariables;
  ArrayList<Scope> localVariables;
  HashMap<String,Function> functions;
  
  boolean mouseCallEventActive;
  
  Game(String fileName){
    String error = "";
    try{
      JSONObject data = loadJSONObject("data/games/"+fileName);
      name = data.getString("name");
      if(name == null) error += "name not defined\n";
      version = data.getString("version");
      if(version == null) error += "version not defined\n";
      JSONObject settings = data.getJSONObject("settings");
      if(settings == null) error += "settings not defined\n";
      options = settings.getJSONObject("options");
      if(options == null) error += "options not defined\n";
      String[] optionKeys = (String[])options.keys().toArray(new String[]{});
      for(int i = 0;i < optionKeys.length;i++){
        JSONObject option = options.getJSONObject(optionKeys[i]);
        String type = option.getString("type");
        if(type == null) error += "no type defined for option "+optionKeys[i]+"\n";
        if(type.equals("NUMBER")){if(!option.hasKey("value")) option.setInt("value",0);}
        else if(type.equals("FLAG")){if(!option.hasKey("value")) option.setBoolean("value",false);}
        else error += "invalid type for option "+optionKeys[i]+"\n";
      }
      presets = settings.getJSONArray("presets");
      if(presets == null) error += "presents not defined\n";
      
      JSONObject code = data.getJSONObject("code");
      structures = code.getJSONObject("structures");
      
      context = code.getJSONObject("context");
      if(context == null) error += "context not defined\n";
      
      globalVariables = new JSONObject();
      String[] globals = (String[])code.getJSONObject("globals").keys().toArray(new String[]{});
      for(int i = 0;i < globals.length;i++){
        String type = code.getJSONObject("globals").getString(globals[i]);
        if(type == null) error += "no type defined for global "+globals[i]+"\n";
        JSONObject var = createVariable(this,type);
        if(var == null) error += "invalid type for global "+globals[i]+" or one of its children\n";
        globalVariables.setJSONObject(globals[i],var);
      }
      for(int i = 0;i < optionKeys.length;i++){
        globalVariables.setJSONObject(optionKeys[i],options.getJSONObject(optionKeys[i]));
      }
      
      functions = new HashMap<String,Function>();
      localVariables = new ArrayList<Scope>();
      
      String[] funcs = (String[])code.getJSONObject("functions").keys().toArray(new String[]{});
      for(int i = 0;i < funcs.length;i++){
        JSONObject func = code.getJSONObject("functions").getJSONObject(funcs[i]);
        if(func.getJSONObject("header") == null) error += "header for function "+funcs[i]+" not defined\n";
        if(func.getJSONArray("body") == null) error += "body for function "+funcs[i]+" not defined\n";
        functions.put(funcs[i],new Function(this,funcs[i],func.getJSONObject("header"),func.getJSONArray("body")));
      }
      
      if(!functions.containsKey("Start")) error += "Function Start is not defined\n";
      if(!functions.containsKey("Run")) error += "Function Run is not defined\n";
    }
    catch(RuntimeException e){
      println("Exception for: "+fileName);
      e.printStackTrace();
      error += e.toString()+"\n";
    }
    isValid = error.length() == 0;
    File f = new File(sketchPath()+"/data/games/"+fileName+" - error log.txt");
    if (f.exists()) {
      f.delete();
    }
    if(!isValid){
      saveStrings("data/games/"+fileName+" - error log.txt",error.split("\n"));
      println("Logged error for "+fileName+" to file.");
    }
  }
  
  void startGame(){
    localVariables = new ArrayList<Scope>();
    localVariables.add(new Scope(this,functions.get("Run"))); //Run first, so Start is on top of the stack and run remains
    localVariables.add(new Scope(this,functions.get("Start")));
  }
  
  void run(){
    if(mousePressed && !pmousePressed && functions.get("MousePressed") != null && !mouseCallEventActive){
      int X = (int)((mouseX-offX)/scale);
      int Y = (int)((mouseY-offY)/scale);
      if(X >= 0 && Y >= 0 && X < board.length && Y < board[0].length) {
        mouseCallEventActive = true;
        Scope scope = new Scope(this,functions.get("MousePressed"));
        if(scope.locals.hasKey("mouseX") && scope.locals.hasKey("mouseY")){
          boolean ok = true;
          if(!scope.locals.getJSONObject("mouseX").getString("type").equals("NUMBER")){
            debug.println("[ERROR]: Argument mouseX for function MousePressed is not of type NUMBER ("+scope.locals.getJSONObject("mouseX").getString("type")+").");
            ok = false;
          }
          if(!scope.locals.getJSONObject("mouseX").getString("type").equals("NUMBER")){
            debug.println("[ERROR]: Argument mouseY for function MousePressed is not of type NUMBER ("+scope.locals.getJSONObject("mouseY").getString("type")+").");
            ok = false;
          }
          if(ok){
            scope.locals.getJSONObject("mouseX").setInt("value",X);
            scope.locals.getJSONObject("mouseY").setInt("value",Y);
          }
        }
        else{
          debug.println("[ERROR]: Need arguments mouseX and mouseY for function MousePressed.");
        }
        localVariables.add(scope);
      }
    }
    Scope local = localVariables.get(localVariables.size()-1);
    local.execute();
  }
}

class Function{
  String name;
  Game game;
  JSONObject header;
  Command commands[];
  
  Function(Game _game,String _name,JSONObject _header,JSONArray body){
    name = _name;
    game = _game;
    header = _header;
    commands = new Command[body.size()];
    for(int i = 0;i < commands.length;i++){
      if(body.get(i) instanceof String) commands[i] = new Command(game,this,body.getString(i),name,i,null);
      else{
        JSONObject cmd = body.getJSONObject(i);
        commands[i] = new Command(game,this,"",name,i,cmd);
      }
    }
  }
}

class Scope{
  Function function;
  Game game;
  JSONObject locals;
  int line;
  
  Scope(Game _game,Function _function){
    game = _game;
    function = _function;
    locals = createLocals();
  }
  
  void execute(){
    if(line < function.commands.length) {
      function.commands[line].execute();
      line++;
    }
    else{
      if(function.name.equals("Run")){
        line = 0;
        renderGame();
      }
      else if(game.localVariables.size() > 0){
        if(function.name.equals("MousePressed")) game.mouseCallEventActive = false;
        game.localVariables.remove(this);
        functionStack.println(function.name);
      }
    }
  }
  
  JSONObject createLocals(){
    JSONObject locals = new JSONObject();
    if(function.header == null) return locals;
    String[] vars = (String[])function.header.keys().toArray(new String[]{});
    for(int i = 0;i < vars.length;i++){
      JSONObject child = createVariable(game,function.header.getString(vars[i]));
      locals.setJSONObject(vars[i],child);
    }
    return locals;
  }
}

JSONObject createVariable(Game game, String type){
  if(type.equals("NUMBER")){
    JSONObject var = new JSONObject();
    var.setString("type","NUMBER");
    var.setInt("value",0);
    return var;
  }
  else if(type.equals("FLAG")){
    JSONObject var = new JSONObject();
    var.setString("type","FLAG");
    var.setBoolean("value",false);
    return var;
  }
  else if(type.equals("COLOR")){
    JSONObject var = new JSONObject();
    var.setString("type","COLOR");
    var.setString("value","RED");
    return var;
  }
  else if(type.startsWith("LIST OF ")){
    JSONObject var = new JSONObject();
    var.setString("type","LIST");
    JSONObject child = createVariable(game,type.substring(8));
    if(child == null) return null;
    JSONObject subVar = new JSONObject();
    subVar.setJSONArray("values",new JSONArray());
    subVar.setJSONObject("child",child);
    var.setJSONObject("value",subVar);
    return var;
  }
  else if(game.structures.keys().contains(type)){
    JSONObject var = new JSONObject();
    var.setString("type",type);
    JSONObject value = new JSONObject();
    var.setJSONObject("value",value);
    String[] vars = (String[])game.structures.getJSONObject(type).keys().toArray(new String[]{});
    for(int i = 0;i < vars.length;i++){
      JSONObject child = createVariable(game,game.structures.getJSONObject(type).getString(vars[i]));
      if(child == null) return null;
      value.setJSONObject(vars[i],child);
    }
    return var;
  }
  return null;
}

static class Colors{
  static int 
  RED    = #FF0000,
  PURPLE = #FF00FF,
  BLUE   = #0000FF,
  CYAN   = #00FFFF,
  GREEN  = #00FF00,
  YELLOW = #FFFF00,
  ORANGE = #FF8800,
  BLACK = #000000,
  WHITE = #FFFFFF;
  
  static int byName(String name){
    switch(name){
      case "RED":
        return RED;
      case "PURPLE":
        return PURPLE;
      case "BLUE":
        return BLUE;
      case "CYAN":
        return CYAN;
      case "GREEN":
        return GREEN;
      case "YELLOW":
        return YELLOW;
      case "ORANGE":
        return ORANGE;
      case "BLACK":
        return BLACK;
      case "WHITE":
        return WHITE;
    }
    return 0;
  }
  
  static String toName(int col){
    switch(col){
      case #FF0000:
        return "RED";
      case #FF00FF:
        return "PURPLE";
      case #0000FF:
        return "BLUE";
      case #00FFFF:
        return "CYAN";
      case #00FF00:
        return "GREEN";
      case #FFFF00:
        return "YELLOW";
      case #FF8800:
        return "ORANGE";
      case #000000:
        return "BLACK";
      case #FFFFFF:
        return "WHITE";
    }
    return null;
  }
}
