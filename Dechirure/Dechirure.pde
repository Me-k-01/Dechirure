import peasy.*;


PeasyCam cam;
Drapeau d;
PVector gravite, vent;
float dt = 0.001f; 

float rigiditePrincipale;
float rigiditeSecond;
float rigiditeDiag;

boolean pause = false;
boolean renduTriangle = true;
boolean correct = true;
   
Accrocheur accrocheur; 

int presetActuel = 0; 
JSONObject config;
JSONArray presets;

void genereVent(float n) {
  vent.x = random(0,5);
  vent.y = 0.0f;
  vent.z = random( - 5,5);
  
  vent.mult(n);
} 
void modifVent() { // modifie légèrement le vent au fils des pas de temps pour éviter le tressautement
  vent.x += random(0.f, 0.1f);
  vent.z += random(-0.1f, 0.1f);
}

void setup() {  
  config = loadJSONObject("preset.json");
  presets = config.getJSONArray("presets"); 

  size(1240, 720, P3D);
  frameRate(30);
  
  cam = new PeasyCam(this, 500);
  //camera.setSuppressRollRotationMode();
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(1000);
  cam.setSuppressRollRotationMode(); 
  // Changement des contrôles de la caméra, pour permettre d'attraper des triangles avec le clique gauche
  cam.setLeftDragHandler(null); 
  cam.setRightDragHandler(cam.getRotateDragHandler());

  float fov = 1.f;
  float aspect = (float)width / (float)height; 
  float nearClip = 1.f;
  float farClip = 100000.f;
  perspective(fov, aspect, nearClip, farClip);  
  accrocheur = new Accrocheur(fov, aspect, nearClip);

  sceneSetup();
}

void sceneSetup() {
  config = presets.getJSONObject(presetActuel);   
  
  rigiditePrincipale = config.getFloat("rigidite_principale");
  rigiditeSecond = config.getFloat("rigidite_secondaire");
  rigiditeDiag = config.getFloat("rigidite_diagonale");
 
  JSONArray posD = config.getJSONArray("position");  
  d = new Drapeau(
    new PVector(posD.getFloat(0), posD.getFloat(1), posD.getFloat(2)), 
    config.getInt("nombre_de_particules"), 
    config.getInt("taille_du_drapeau"),
    config.getFloat("masses"),
    config.getFloat("amortissement_air_masses"),
    config.getFloat("longueur_repos"),
    config.getFloat("espacement"),
    config.getFloat("amortissement_air_tri"),
    config.getJSONArray("masses_statiques")
  );
  vent = new PVector(0, 0, 0); 
  gravite = new PVector(0, 9.8f, 0);  
  genereVent(config.getFloat("puissance_du_vent")); 
}


void mousePressed() {
  if (mouseButton == LEFT) {
    System.out.println("User tried to grab a triangle."); 
    // On genere un rayon à partir du curseur de la souris sur l'écran
    // Pour cela, on transforme les coordonées en scalaire de 0 à 1  

    Ray rayon = accrocheur.genereRayon(
      (float)mouseX/(float)width, 
      (float)mouseY/(float)height
    );
    //System.out.print("x : " + rayon.dir.x);
    //System.out.print(", y : " + rayon.dir.y);
    //System.out.println(", z : " + rayon.dir.z);

    // Selection du triangle qui intersect le rayon
    accrocheur.selectionTriangle(d.triangles, rayon);
  }  
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    accrocheur.stopSelection(d.triangles);
  }
}

void keyPressed(){
  if (key == 'c') {
    correct = !correct;
    println("Configuration : Correction des déformations à " + correct);
  } 
  if (key == 'r') {
    sceneSetup();
  } 
  if (key == 't') {
    renduTriangle = !renduTriangle;
    println("Configuration : Rendu en triangle à " + renduTriangle);
  } 
  if(key == 'p') { // pause
    pause = !pause;
    println("Configuration : Pause à " + pause);
  }
  
  if(key == 's') { //  
    for(int i = 60 ; i < 74 ;i++)
      d.découpageMasse(d.particules.get(i),d.ressorts.get(4));
  }
  //////// preset ////////
  if(key == '1' || key == '&') { // drapeau
    println("Configuration : Changement de scene");
    presetActuel = 0;
    sceneSetup();
  }
  if(key == '2' || key == 'é') { // haut fixé
    println("Configuration : Changement de scene");
    presetActuel = 1;
    sceneSetup();
  }
  if(key == '3' || key == '"') { // drap pendu par les coins
    println("Configuration : Changement de scene");
    presetActuel = 2;
    sceneSetup();
  } 
}

void draw() {
  background(200);
  
  d.dessiner(renduTriangle);
  modifVent();
  
  if (!pause)
    for (float i = 0; i < 0.1f; i+= dt)
      d.mettreAJour(dt, correct);
    accrocheur.deplace(d.triangles, dt);
  // Debugage
  accrocheur.dessinDebug(); 
}
