import peasy.*;


PeasyCam cam;
Drapeau d;
PVector gravite, vent;
float dt = 0.001f;


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
 
  d = new Drapeau(new PVector(0,0,0), 70 , 10 , 10 ,0.01, 100, 5.5);
  vent = new PVector(0,0,0); 
  gravite = new PVector(0,9.8,0); 
  
}


void draw() {
  background(200);
  
  d.dessiner();
  genereVent(20);
  
  for(float i = 0; i < 0.1f; i+= dt){
    d.mettreAJour(dt);
  }
    
}
