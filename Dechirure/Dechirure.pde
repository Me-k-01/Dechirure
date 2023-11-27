import peasy.*;


PeasyCam cam;
Drapeau d;
PVector gravite, vent;
float dt = 0.001f;

PVector positionHautGauche= new PVector(0,0,0);

int nbParticules =150;
int nbParticulesLargeur=15;
float masseParticules=5;
float fricAirParticules=0.01f;

float longueurRepos=50;
float espacement=50;

float fricAirTraingle = 5.5f;


float rigiditePrincipale=1;
float rigiditeSecond=0.1;
float rigiditeDiag=0.1;

boolean pause = false;
boolean renduTriangle = true;
boolean correct = true;


int preset=0;

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
 
  d = new Drapeau(positionHautGauche, nbParticules, nbParticulesLargeur, masseParticules, fricAirParticules, longueurRepos, espacement, fricAirTraingle ); //70 , 10 , 10
  vent = new PVector(0,0,0); 
  gravite = new PVector(0,9.8,0); 
  
}

void keyPressed(){
  if (key == 'c') {
    correct = !correct;
    println("Configuration : Correction des déformations à " + correct);
  } 
  if (key == 'r') {
    d = new Drapeau(positionHautGauche, nbParticules, nbParticulesLargeur, masseParticules, fricAirParticules, longueurRepos, espacement, fricAirTraingle ); //70 , 10 , 10
  } 
  if (key == 't') {
    renduTriangle = !renduTriangle;
    println("Configuration : rendu en triangle à " + renduTriangle);
  } 
  if(key == 'p'){//pause
    pause = !pause;
    println("Configuration : Pause à " + pause);
  }
  
  if(key == 's'){//pause
  
  for(int i = 60 ; i<74 ;i++)
      d.découpageMasse(d.particules.get(i),d.ressorts.get(4));//
     
   
  }
  
}

void draw() {
  background(200);
  
  d.dessiner(renduTriangle);
  genereVent(5);
  
  if(!pause)
    for(float i = 0; i < 0.1f; i+= dt){
      d.mettreAJour(dt, correct);
    }
    
}
