

/*Pour résoudre le problème d'hyperélasticité il faut rajouter un taux de deformement a chaque pas de temps.
cela permet de réduire l'élongation sur les endroit a forte contrainte en un temps donné, ce qui force la réparticion de l'élongation sur le reste du maillage
*/
enum Type{
  principaux,//struct
  diagonale, // shear
  secondaire //flex
};
    
class Ressort{ 
    public float rigidite;
    public float longueurRepos;
    public float longueurCarréDechirure; // Longueur critique au dela du quelle le ressort peut casser
    
    public Particule particule1;
    public Particule particule2;
    
    private float tc; // Taux de déformation critique (entre 0 et 1)
    private float distPrecedent;
    
    public boolean colo = true;
    
    private Type type;
    
    Ressort(Particule p1, Particule p2, float k, float l, Type t) {
        rigidite = k;
        longueurRepos = l;
        particule1 = p1;
        particule2 = p2;
        type = t;
        tc = 0.0001f; // Taux de deformation critique 
        distPrecedent = l;
        longueurCarréDechirure = longueurRepos * longueurRepos + 40000 ;
    }

    public float longueurCarré() {
      return PVector.sub(particule2.position, particule1.position).magSq();
    }

    public Particule plusLourds( ) {
      if (particule1.masse == particule2.masse) {
        return Math.random()<0.5f? particule1 : particule2;
      } else if (particule1.masse > particule2.masse) 
        return particule1;
      else 
        return particule2;
    }

    public boolean estStatique() {
      return particule1.statique || particule2.statique;
    }
    
    public void corrige(float dt) { // Corrige sur un pas de temps donné les élongations //<>// //<>// //<>//
        if (type == Type.secondaire)
          return;
          
        PVector p1P2 = PVector.sub(particule2.position, particule1.position);
        float dist = p1P2.mag();
        
        // Calculer le taux de deformation
        float deformation = dist - distPrecedent;
        
        // Si la deformation d'un ressort ne dépasse pas le taux de déformation critique, il n'y a rien a faire
        if (abs(deformation) <= tc*longueurRepos) return; 
        
        // Il faut les replacer les position et recalculer les velocités en conséquence, 
        // de tel sorte a ce que la deformation actuel corresponde à la deformation max        
        PVector dep = p1P2.normalize().mult(deformation);
        
        // On replace les masses, en ne prenant pas en compte l'intégration précedente.
        // C'est une procédure dynamique inverse car on place les positions avant de recalculer la vélocité
          
        // La réduction doit se faire selon si le ressort est libre ou fixe  
        // Si l'un des deux est fixe, il faut rapprocher le libre vers le fixe de sorte a respecter la contrainte statique de masses
        if (particule1.statique) {
          particule2.dynamiqueInv(dep, dt); 
        } else if (particule2.statique) { 
          particule1.dynamiqueInv(PVector.mult(dep, -1.f), dt); 
        // Si les deux sont libre, on les rapproche vers leurs centre
        } else {   
          dep = PVector.mult(dep, 0.5f); // Déplacement vers le centre
          particule2.dynamiqueInv(dep, dt); 
          particule1.dynamiqueInv(PVector.mult(dep, -1.f), dt);  
        }
        
        
        // La deformation du ressort ne doit pas dépasser tc * longueurRepos
        
        //System.out.println(dist);
        // Alors on applique la procédure dynamique inverse sur les deux masses du ressorts de tel sorte a ce qu'on soit égal a la déformation critique 
    }
    
    public void calculerForces() {
        
        PVector p1P2 = PVector.sub(particule2.position, particule1.position);
        
        float dist = p1P2.mag();
        distPrecedent = dist; // On sauvegarde les distances pour pouvoir calculer le taux de deformation de ce pas de temps, dans la procédure dynamique inverse
        
        PVector f = PVector.mult(p1P2,(longueurRepos - dist) * - rigidite );
        //print(dist+"\n");
        particule1.forceExterne.add(f);
        particule2.forceExterne.sub(f);
        
        /*
        // Si la masses est statiques, on déplace deux fois plus l'autre
        if (particule1.statique) {
          particule2.forceExterne.sub(f);
        } else if (particule2.statique) {
          particule1.forceExterne.add(f);
        }*/
    }

    public boolean relie(Particule p1, Particule p2){
      return (particule1.equals(p1) && particule2.equals(p2))  || (particule2.equals(p1) && particule1.equals(p2));
    }
    
    public void dessiner() {
        
        particule1.dessiner(2);
        particule2.dessiner(2);
        
        if(colo)
          stroke(0);
        else
          stroke(0,0,255);
        
        PVector p1P2 = PVector.sub(particule2.position, particule1.position);
        float dist = p1P2.mag();
        float deformation = dist - distPrecedent;
        
       
        if (abs(deformation) > tc*longueurRepos) 
          stroke(255,0,0);
          
          
       line(particule1.position.x, particule1.position.y, particule1.position.z,
             particule2.position.x, particule2.position.y, particule2.position.z);
        
    }
}
