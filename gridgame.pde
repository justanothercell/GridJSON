import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.util.Arrays;

int appState;
Game activeGame;
PrintWriter debug;
PrintWriter functionStack;

void setup(){
  size(1200,800);
  try {
    saveStrings("data\\debug.log",new String[]{});
    debug = new PrintWriter(new FileOutputStream(sketchPath()+"\\data\\debug.log", true));
    saveStrings("data\\functionStack.log",new String[]{});
    functionStack = new PrintWriter(new FileOutputStream(sketchPath()+"\\data\\functionStack.log", true));
  }
  catch(FileNotFoundException e){
    e.printStackTrace();
  }
  debug.println("[DEBUG]: Started.");
}

void draw(){
  try{
    preRun();
    //literally the only time ill use switch in my entire life
    switch(appState){ 
      case 0: 
        selectUI();
        break;
      case 1: 
        optionsUI();
        break;
      case 2:
        runGame();
        break;
      case 3:
        pauseMenu();
        break;
    }
    postRun();
    if(frameCount%60==0) {
      debug.flush();
      functionStack.flush();
    }
  }
  catch(Exception e){
    e.printStackTrace();
    debug.println(e);
    debug.close();
    functionStack.close();
    exit();
  }
}

void exit(){
  debug.println("[DEBUG]: Exited.");
  debug.close();
  functionStack.close();
  super.exit();
}
