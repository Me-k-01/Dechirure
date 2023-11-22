import peasy.*;


PeasyCam cam;
Drapeau d;
PVector gravite, vent;
float dt = 0.001f;
boolean pause = false;
boolean renduTriangle = true;
boolean correct = true;

float rigiditePrincipale=1;
float rigiditeSecond=0.1;
float rigiditeDiag=0.1;

void genereVent(float n) {
  vent.x = random(0,5);
  vent.y = 0.0;
  vent.z = random( - 5,5);
  
  vent.mult(n);
}
 

void setup() { 
    
  size(1240,720,P3D);
  frameRate(30);
  
  cam = new PeasyCam(this,500);
  
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(1000);
  cam.setSuppressRollRotationMode(); 
 
  d = new Drapeau(new PVector(0,0,0), 100 , 10 , 100, 0.01, 200, 100, 5.5); //70 , 10 , 10
  vent = new PVector(0,0,0); 
  gravite = new PVector(0,9.8,0); 
  
}

void keyPressed(){
  if (key == 'c') {
    correct = !correct;
    println("Configuration : Correction des déformations à " + correct);
  } 
  if (key == 'r') {
    renduTriangle = !renduTriangle;
    println("Configuration : rendu en triangle à " + renduTriangle);
  } 
  if(key == 'p'){//pause
    pause = !pause;
    println("Configuration : Pause à " + pause);
  }
  
}

void draw() {
  background(200);
  
  d.dessiner(renduTriangle);
  genereVent(10);
  
  if(!pause)
    for(float i = 0; i < 0.1f; i+= dt){
      d.mettreAJour(dt, correct);
    }
    
}
