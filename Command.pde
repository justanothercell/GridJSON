class Command{
  String funcName;
  int line;
  Game game;
  String cmd;
  String operator;
  String part0;
  String part1;
  
  Function cmplxThen;
  Function cmplxElse;
  Function cmplxFor;
  
  Command(Game _game,Function f,String _cmd,String _funcName,int _line,JSONObject cmplx){
    funcName = _funcName;
    line = _line;
    game = _game;
    cmd = _cmd;
    if(cmplx != null){
      String if_ = cmplx.getString("IF");
      JSONArray then = cmplx.getJSONArray("THEN");
      JSONArray else_ = cmplx.getJSONArray("ELSE");
      
      String for_ = cmplx.getString("FOR");
      JSONArray do_ = cmplx.getJSONArray("DO");
      if(if_==null && for_ == null){
        debug.println("[ERROR]: IF clause in line "+line+" in function "+funcName+" does not specify IF condition.");
        return;
      }
      if(if_ != null){
        if(then == null && else_ == null){
          debug.println("[ERROR]: IF clause "+if_+" in line "+line+" in function "+funcName+" does not specify THEN and/or ELSE behaviour.");
          return;
        }
        operator = "IF";
        part0 = if_;
        if(then != null) cmplxThen = new Function(game,funcName+"."+line+".IF.THEN",f.header,then);
        if(else_ != null) cmplxElse = new Function(game,funcName+"."+line+".IF.ELSE",f.header,else_);
      }
      if(for_ != null){
        if(do_ == null){
          debug.println("[ERROR]: FOR loop "+for_+" in line "+line+" in function "+funcName+" does not specify DO behaviour.");
          return;
        }
        operator = "FOR";
        String p[] = for_.split(" FROM ");
        if(p.length == 2){
          part0 = p[0];
          part1 = p[1];
          cmplxFor = new Function(game,funcName+"."+line+".FOR",f.header,do_);
        }
        else{
          debug.println("[ERROR]: FOR loop "+for_+" in line "+line+" in function "+funcName+" does not follow 'variable FROM a TO b'.");
        }
      }
    }
    //Operators
    else if(cmd.contains(" ADD ")){ //destination ADD source
      String args[] = cmd.split(" ADD ");
      operator = "ADD";
      if(args.length != 2){
        debug.println("[ERROR]: Invalid number of args for ADD for command '"+cmd+"' in line "+line+" in function "+funcName+".");
        return;
      }
      part0 = args[0]; //destination
      part1 = args[1]; //source
    }
    else if(cmd.contains(" SUB ")){ //destination SUB source
      String args[] = cmd.split(" SUB ");
      operator = "SUB";
      if(args.length != 2){
        debug.println("[ERROR]: Invalid number of args for SUB for command '"+cmd+"' in line "+line+" in function "+funcName+".");
        return;
      }
      part0 = args[0]; //destination
      part1 = args[1]; //source
    }
    else if(cmd.contains(" MULT ")){ //destination MULT source
      String args[] = cmd.split(" MULT ");
      operator = "MULT";
      if(args.length != 2){
        debug.println("[ERROR]: Invalid number of args for MULT for command '"+cmd+"' in line "+line+" in function "+funcName+".");
        return;
      }
      part0 = args[0]; //destination
      part1 = args[1]; //source
    }
    else if(cmd.contains(" DIV ")){ //destination DIV source
      String args[] = cmd.split(" DIV ");
      operator = "DIV";
      if(args.length != 2){
        debug.println("[ERROR]: Invalid number of args for DIV for command '"+cmd+"' in line "+line+" in function "+funcName+".");
        return;
      }
      part0 = args[0]; //destination
      part1 = args[1]; //source
    }
    else if(cmd.contains(" SET ")){ //destination SET source
      String args[] = cmd.split(" SET ");
      operator = "SET";
      if(args.length != 2){
        debug.println("[ERROR]: Invalid number of args for SET for command '"+cmd+"' in line "+line+" in function "+funcName+".");
        return;
      }
      part0 = args[0]; //destination
      part1 = args[1]; //source
    }
    else if(cmd.contains(" TOGGLE ")){ //destination TOGGLE source (bool)
      String args[] = cmd.split(" TOGGLE ");
      operator = "TOGGLE";
      if(args.length != 2){
        debug.println("[ERROR]: Invalid number of args for TOGGLE for command '"+cmd+"' in line "+line+" in function "+funcName+".");
        return;
      }
      part0 = args[0]; //destination
      part1 = args[1]; //source
    }
    //execute
    else if(cmd.startsWith("DO ")){ //DO Function WITH args AND args
      String args[] = cmd.substring(3).split(" WITH ");
      operator = "DO";
      if(args.length < 1 || args.length > 2){
        debug.println("[ERROR]: Invalid number of args for DO for command '"+cmd+"' in line "+line+" in function "+funcName+".");
        return;
      }
      part0 = args[0]; //Function
      if(args.length == 2) part1 = args[1]; //args
    }
    //log
    else if(cmd.startsWith("LOG ")){  //LOG variable
      operator = "LOG";
      part0 = cmd.substring(4); //source
    }
    //nothing
    else{
      debug.println("[ERROR]: Invalid command '"+cmd+"' in line "+line+" in function "+funcName+".");
    }
  }
  
  void execute(){
    if(operator.equals("ADD")){ //destination ADD source
      JSONObject dest = getVariable(part0);
      JSONObject source = getVariableOrValue(part1);
      if(dest.getString("type").equals("NUMBER")){
        if(dest.getString("type").equals(source.getString("type"))){
          dest.setInt("value",dest.getInt("value")+source.getInt("value"));
        }
        else{
          debug.println("[ERROR]: Types '"+dest.getString("type").equals("INTEGER")+"' and '"+source.getString("type").equals("INTEGER")+"' for operation ADD in command '"+cmd+"' in line "+line+" in function "+funcName+" do not match.");
        }
      }
      else{
        debug.println("[ERROR]: Invalid type '"+dest.getString("type").equals("INTEGER")+"' for operation ADD in command '"+cmd+"' in line "+line+" in function "+funcName+".");
      }
    }
    if(operator.equals("SUB")){ //destination SUB source
      JSONObject dest = getVariable(part0);
      JSONObject source = getVariableOrValue(part1);
      if(dest.getString("type").equals("NUMBER")){
        if(dest.getString("type").equals(source.getString("type"))){
          dest.setInt("value",dest.getInt("value")-source.getInt("value"));
        }
        else{
          debug.println("[ERROR]: Types '"+dest.getString("type").equals("INTEGER")+"' and '"+source.getString("type").equals("INTEGER")+"' for operation ADD in command '"+cmd+"' in line "+line+" in function "+funcName+" do not match.");
        }
      }
      else{
        debug.println("[ERROR]: Invalid type '"+dest.getString("type").equals("INTEGER")+"' for operation SUB in command '"+cmd+"' in line "+line+" in function "+funcName+".");
      }
    }
    if(operator.equals("MULT")){ //destination MULT source
      JSONObject dest = getVariable(part0);
      JSONObject source = getVariableOrValue(part1);
      if(dest.getString("type").equals("NUMBER")){
        if(dest.getString("type").equals(source.getString("type"))){
          dest.setInt("value",dest.getInt("value")*source.getInt("value"));
        }
        else{
          debug.println("[ERROR]: Types '"+dest.getString("type").equals("INTEGER")+"' and '"+source.getString("type").equals("INTEGER")+"' for operation ADD in command '"+cmd+"' in line "+line+" in function "+funcName+" do not match.");
        }
      }
      else{
        debug.println("[ERROR]: Invalid type '"+dest.getString("type").equals("INTEGER")+"' for operation MULT in command '"+cmd+"' in line "+line+" in function "+funcName+".");
      }
    }
    if(operator.equals("DIV")){ //destination DIV source
      JSONObject dest = getVariable(part0);
      JSONObject source = getVariableOrValue(part1);
      if(dest.getString("type").equals("NUMBER")){
        if(dest.getString("type").equals(source.getString("type"))){
          dest.setInt("value",dest.getInt("value")/source.getInt("value"));
        }
        else{
          debug.println("[ERROR]: Types '"+dest.getString("type")+"' and '"+source.getString("type")+"' for operation ADD in command '"+cmd+"' in line "+line+" in function "+funcName+" do not match.");
        }
      }
      else{
        debug.println("[ERROR]: Invalid type '"+dest.getString("type")+"' for operation DIV in command '"+cmd+"' in line "+line+" in function "+funcName+".");
      }
    }
    if(operator.equals("TOGGLE")){ //destination TOGGLE source
      JSONObject dest = getVariable(part0);
      JSONObject source = getVariableOrValue(part1);
      if(dest.getString("type").equals("FLAG")){
        if(dest.getString("type").equals(source.getString("type"))){
          dest.setBoolean("value",!source.getBoolean("value"));
        }
        else{
          debug.println("[ERROR]: Types '"+dest.getString("type")+"' and '"+source.getString("type")+"' for operation TOGGLE in command '"+cmd+"' in line "+line+" in function "+funcName+" do not match.");
        }
      }
      else{
        debug.println("[ERROR]: Invalid type '"+dest.getString("type")+"' for operation TOGGLE in command '"+cmd+"' in line "+line+" in function "+funcName+".");
      }
    }
    if(operator.equals("SET")){ //destination SET source
      JSONObject dest = getVariable(part0);
      JSONObject source = getVariableOrValue(part1);
      if(dest != null && source != null){
        if(dest.getString("type").equals(source.getString("type"))){
          dest.put("value",source.get("value"));
        }
        else{
          debug.println("[ERROR]: Types '"+dest.getString("type").equals("INTEGER")+"' and '"+source.getString("type").equals("INTEGER")+"' for operation SET in command '"+cmd+"' in line "+line+" in function "+funcName+" do not match.");
        }
      }
    }
    if(operator.equals("FOR")){ //variable FROM a TO b
      String m[] = part1.split(" TO ");
      if(m.length == 2){
        String m_m[] = m[1].split(" COUNTING ");
        int counting = 1;
        if(m_m.length == 2){
          m[1] = m_m[0];
          JSONObject c = getVariableOrValue(m_m[1]);
          if(c == null){
            debug.println("[ERROR]: In FOR loop "+part0+" FROM "+part1+" in line "+line+" in function "+funcName+" the optional COUNTING arg is not a valid number or variable.");
          }
          else{
            if(!c.getString("type").equals("NUMBER")){
              debug.println("[ERROR]: In FOR loop "+part0+" FROM "+part1+" in line "+line+" in function "+funcName+" the optional COUNTING arg is not of type NUMBER.");
            }
            else{
              if(c.getInt("value") == 0){
                debug.println("[ERROR]: In FOR loop "+part0+" FROM "+part1+" in line "+line+" in function "+funcName+" the optional COUNTING arg is not a valid number or variable.");
              }
              else{
                counting = c.getInt("value");
              }
            }
          }
        }
        JSONObject min = getVariableOrValue(m[0]);
        JSONObject max = getVariableOrValue(m[1]);
        JSONObject counter = getVariable(part0);
        
        if(min == null){
          debug.println("[ERROR]: In FOR loop "+part0+" FROM "+part1+" in line "+line+" in function "+funcName+" the variable or value 'a' could not be resolved 'variable FROM a TO b'.");
          return;
        }
        if(!min.getString("type").equals("NUMBER")){
          debug.println("[ERROR]: In FOR loop "+part0+" FROM "+part1+" in line "+line+" in function "+funcName+" the variable or value 'a' 'variable FROM a TO b' is not of type NUMBER.");
          return;
        }
        if(max == null){
          debug.println("[ERROR]: In FOR loop "+part0+" FROM "+part1+" in line "+line+" in function "+funcName+" the variable or value 'b' could not be resolved 'variable FROM a TO b'.");
          return;
        }
        if(!max.getString("type").equals("NUMBER")){
          debug.println("[ERROR]: In FOR loop "+part0+" FROM "+part1+" in line "+line+" in function "+funcName+" the variable or value 'b' 'variable FROM a TO b' is not of type NUMBER.");
          return;
        }
        int MIN = min.getInt("value");
        int MAX = max.getInt("value");
        
        if(counter == null){
          debug.println("[ERROR]: In FOR loop "+part0+" FROM "+part1+" in line "+line+" in function "+funcName+" the variable 'variable' could not be resolved 'variable FROM a TO b'.");
          return;
        }
        if((MAX-MIN)/(float)counting < 0){
          debug.println("[ERROR]: In FOR loop "+part0+" FROM "+part1+" in line "+line+" in function "+funcName+" the counter seems to count in the wrong direction (from "+MIN+" to "+MAX+" incrementing by "+counting+").");
          return;
        }
        if(counting > 0){
          for(int i = MAX-1;i >= MIN;i-=counting){
            Scope locals = game.localVariables.get(game.localVariables.size()-1);
            
            Scope t = new Scope(game,cmplxFor);
            t.locals = locals.locals;
            game.localVariables.add(t);
            
            Scope setCounter = new Scope(game,new Function(game,"FOR.SETCOUNTER",new JSONObject(),JSONArray.parse("[\""+part0+" SET "+i+"\"]")));
            setCounter.locals = locals.locals;
            game.localVariables.add(setCounter);
          }
        }
        if(counting < 0){
          for(int i = MAX+1;i <= MIN;i-=counting){
            Scope locals = game.localVariables.get(game.localVariables.size()-1);
            
            Scope t = new Scope(game,cmplxFor);
            t.locals = locals.locals;
            game.localVariables.add(t);
            
            Scope setCounter = new Scope(game,new Function(game,"FOR.SETCOUNTER",new JSONObject(),JSONArray.parse("[\""+part0+" SET "+i+"\"]")));
            setCounter.locals = locals.locals;
            game.localVariables.add(setCounter);
          }
        }
      }
      else{
        debug.println("[ERROR]: FOR loop "+part0+" FROM "+part1+" in line "+line+" in function "+funcName+" does not follow 'variable FROM a TO b'.");
      }
    }
    if(operator.equals("IF")){ //a IS b
      if(part0.contains(" IS ")){
        String a[] = part0.split(" IS ");
        JSONObject left = getVariableOrValue(a[0]);
        JSONObject right = getVariableOrValue(a[1]);
        if(left == null) return;
        if(right == null) return;
        
        if(left.getString("type").equals(right.getString("type")) && left.get("value").toString().equals(right.get("value").toString())){
          if(cmplxThen != null){
            Scope t = new Scope(game,cmplxThen);
            Scope locals = game.localVariables.get(game.localVariables.size()-1);
            t.locals = locals.locals;
            game.localVariables.add(t);
          }
        }
        else if(cmplxElse != null){
          Scope t = new Scope(game,cmplxElse);
          Scope locals = game.localVariables.get(game.localVariables.size()-1);
          t.locals = locals.locals;
          game.localVariables.add(t);
        }
      }
      else if(part0.contains(" GTR ")){
        String a[] = part0.split(" GTR ");
        JSONObject left = getVariableOrValue(a[0]);
        JSONObject right = getVariableOrValue(a[1]);
        if(left == null) return;
        if(right == null) return;
        
        if(!left.getString("type").equals("NUMBER")){
          debug.println("[ERROR]: Invalid type '"+left.getString("type").equals("INTEGER")+"' for comaprison GTR in command '"+cmd+"' in line "+line+" in function "+funcName+".");
          return;
        }
        if(!right.getString("type").equals("NUMBER")){
          debug.println("[ERROR]: Invalid type '"+right.getString("type").equals("INTEGER")+"' for comaprison GTR in command '"+cmd+"' in line "+line+" in function "+funcName+".");
          return;
        }
        if(left.getInt("value") > right.getInt("value")){
          if(cmplxThen != null){
            Scope t = new Scope(game,cmplxThen);
            Scope locals = game.localVariables.get(game.localVariables.size()-1);
            t.locals = locals.locals;
            game.localVariables.add(t);
          }
        }
        else if(cmplxElse != null){
          Scope t = new Scope(game,cmplxElse);
          Scope locals = game.localVariables.get(game.localVariables.size()-1);
          t.locals = locals.locals;
          game.localVariables.add(t);
        }
      }
      else if(part0.contains(" LSS ")){
        String a[] = part0.split(" LSS ");
        JSONObject left = getVariableOrValue(a[0]);
        JSONObject right = getVariableOrValue(a[1]);
        if(left == null) return;
        if(right == null) return;
        
        if(!left.getString("type").equals("NUMBER")){
          debug.println("[ERROR]: Invalid type '"+left.getString("type").equals("INTEGER")+"' for comaprison LSS in command '"+cmd+"' in line "+line+" in function "+funcName+".");
          return;
        }
        if(!right.getString("type").equals("NUMBER")){
          debug.println("[ERROR]: Invalid type '"+right.getString("type").equals("INTEGER")+"' for comaprison LSS in command '"+cmd+"' in line "+line+" in function "+funcName+".");
          return;
        }
        if(left.getInt("value") < right.getInt("value")){
          if(cmplxThen != null){
            Scope t = new Scope(game,cmplxThen);
            Scope locals = game.localVariables.get(game.localVariables.size()-1);
            t.locals = locals.locals;
            game.localVariables.add(t);
          }
        }
        else if(cmplxElse != null){
          Scope t = new Scope(game,cmplxElse);
          Scope locals = game.localVariables.get(game.localVariables.size()-1);
          t.locals = locals.locals;
          game.localVariables.add(t);
        }
      }
    }
    //execute
    if(operator.equals("DO")){ //DO Function WITH args AND args
      if(game.functions.get(part0) != null){
        Scope scope = new Scope(game,game.functions.get(part0));
        if(part1 != null){
          String argsStr[] = part1.split(" AND ");
          JSONObject args[] = new JSONObject[argsStr.length];
          String argKeys[] = new String[argsStr.length];
          for(int i = 0;i < argsStr.length;i++){
            String a[] = argsStr[i].split(" AS ");
            if(a.length != 2){
              debug.println("[ERROR]: Argument '"+argsStr[i]+"' for function "+part0+" in line "+line+" does not match syntax 'value/variable AS key'.");
              return;
            }
            args[i] = getVariableOrValue(a[0]);
            argKeys[i] = a[1];
            if(args[i] == null){
              return;
            }
          }
          if(argKeys.length >= args.length){
            for(int i = 0;i < argKeys.length;i++){
              if(!scope.locals.getJSONObject(argKeys[i]).getString("type").equals(args[i].getString("type"))){
                debug.println("[ERROR]: Argument "+argKeys[i]+" for function "+part0+" is not of type "+scope.locals.getJSONObject(argKeys[i]).getString("type")+" ("+args[i].getString("type")+").");
              }
              else{
                scope.locals.getJSONObject(argKeys[i]).put("value",args[i].get("value"));
              }
            }
          }
          else{
            debug.println("[ERROR]: Need at least 2 arguments for function "+part0+" (got "+argKeys.length+").");
          }
        }
        game.localVariables.add(scope);
      }
      else{
        debug.println("[ERROR]: Function '"+part0+"' as function call in command '"+cmd+"' in line "+line+" in function "+funcName+" does not exist.");
      }
    }
    if(operator.equals("LOG")){ //LOG variable
      debug.println("[LOG]: "+part0+": "+getVariableOrValue(part0));
    }
  }
  
  JSONObject getVariableOrValue(String path){
    int col = Colors.byName(path);
    if(col != 0){
      JSONObject var = new JSONObject();
      var.setString("type","COLOR");
      var.setString("value",path);
      return var;
    }
    int integer = int(path);
    if((integer+"").equals(path)){
      JSONObject var = new JSONObject();
      var.setString("type","NUMBER");
      var.setInt("value",integer);
      return var;
    }
    if(path.equals("TRUE")){
      JSONObject var = new JSONObject();
      var.setString("type","FLAG");
      var.setBoolean("value",true);
      return var;
    }
    if(path.equals("FALSE")){
      JSONObject var = new JSONObject();
      var.setString("type","FLAG");
      var.setBoolean("value",false);
      return var;
    }
    JSONObject var = getVariable(path);
    if(var != null){
      return var;
    }
    return null;
  }
  
  JSONObject getVariable(String path){
    if(path.startsWith("BOARD ")){
      path = path.substring(6);
      String xy[] = path.split(" ");
      if(xy.length == 2){
        JSONObject x = getVariableOrValue(xy[0]);
        JSONObject y = getVariableOrValue(xy[1]);
        if(x == null){
          return null;
        }
        if(y == null){
          return null;
        }
        if(!x.getString("type").equals("NUMBER")) {
          debug.println("[ERROR]: Variable '"+xy[0]+"' in command '"+cmd+"' in line "+line+" in function "+funcName+" is not of type NUMBER.");
        }
        if(!y.getString("type").equals("NUMBER")) {
          debug.println("[ERROR]: Variable '"+xy[1]+"' in command '"+cmd+"' in line "+line+" in function "+funcName+" is not of type NUMBER.");
        }
        int X = x.getInt("value");
        int Y = y.getInt("value");
        if(X < 0 || X > board.length-1 || Y < 0 || Y > board[X].length-1) return JSONObject.parse("{\"type\":\"color\",\"value\":\"BLACK\"}");
        return board[X][Y];
      }
      else{
        debug.println("[ERROR]: Not 2 coordinates were defined '"+path+"' for BOARD in command '"+cmd+"' in line "+line+" in function "+funcName+".");
        return null;
      }
    }
    else if(path.equals("BACKGROUND")){
      return backgroundColor;
    }
    else{
      Scope locals = game.localVariables.get(game.localVariables.size()-1);
      JSONObject res = getVariableScoped(locals.locals,path);
      if(res != null) return res;
      res = getVariableScoped(game.globalVariables,path);
      if(res != null) return res;
      debug.println("[ERROR]: Variable '"+path+"' could not be resolved in command '"+cmd+"' in line "+line+" in function "+funcName+".");
    }
    return null;
  }
  
  JSONObject getVariableScoped(JSONObject vars,String path){
    String args[] = path.split(" OF ");
    JSONObject var = vars.getJSONObject(args[args.length-1]);
    if(var != null){
      if(args.length == 1) return var;
      for(int i = args.length-2;i>=0;i--){
        String type = var.getString("type");
        if(type.equals("LIST")){
          JSONObject value = var.getJSONObject("value");
          JSONArray list = value.getJSONArray("values");
          JSONObject child = value.getJSONObject("child");
          if(args[i].equals("SIZE")){
            var = new JSONObject();
            var.setString("type","NUMBER");
            var.setInt("value",list.size());
          }
          else{
            int index = int(args[i]);
            if(!(index+"").equals(args[i])){
              JSONObject I = getVariableScoped(game.localVariables.get(game.localVariables.size()-1).locals,args[i]);
              if(I == null) I = getVariableScoped(game.globalVariables,args[i]);
              if(I != null){
                if(I.getString("type").equals("NUMBER")){
                  index = I.getInt("value");
                }
                else{
                  debug.println("[ERROR]: No valid variable type ("+I.getString("type")+") variable "+args[i]+" of list "+args[i+1]+" in command '"+cmd+"' in line "+line+" in function "+funcName+".");
                  return null;
                }
              }
              else{
                debug.println("[ERROR]: No valid index or variable("+index+") of list "+args[i+1]+" in command '"+cmd+"' in line "+line+" in function "+funcName+".");
                return null;
              }
            }
            if(index < 0) {
              index = 0;
              debug.println("[ERROR]: Accessing invalid index("+index+") of "+args[i+1]+" in command '"+cmd+"' in line "+line+" in function "+funcName+".");
            }
            while(list.size() < index+1){
              list.append(JSONObject.parse(child.toString()));
            }
            var = list.getJSONObject(index);
          }
        }
        else{
          var = var.getJSONObject("value").getJSONObject(args[i]);
        }
      }
      return var;
    }
    return null;
  }
}
