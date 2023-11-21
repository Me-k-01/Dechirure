

/*Pour résoudre le problème d'hyperélasticité il faut rajouter un taux de deformement a chaque pas de temps.
cela permet de réduire l'élongation sur les endroit a forte contrainte en un temps donné, ce qui force la réparticion de l'élongation sur le reste du maillage
*/


class Ressort{
    
    public float rigidite;
    public float longueurRepos;
    
    public Particule particule1;
    public Particule particule2;
    
    private float tc; // Taux de déformation critique (entre 0 et 1)
    private float distPrecedant;
    
    Ressort(Particule p1, Particule p2, float k, float l0) {
        rigidite = k;
        longueurRepos = l0;
        particule1 = p1;
        particule2 = p2;
        tc = 0.001f; // Taux de deformation critique 
    }
    
    public void corrige(float dt) { // Corrige sur un pas de temps donné les élongations
    
        PVector p1P2 = PVector.sub(particule2.position, particule1.position);
        float dist = p1P2.mag();
        
        // Calculer le taux de deformation
        float deformation = dist - distPrecedant;
        
        // Si la deformation d'un ressort ne dépasse pas le taux de déformation critique, il n'y a rien a faire
        if (abs(deformation) <= tc*longueurRepos) return; 
        
        // Il faut les replacer les position et recalculer les velocités en conséquence, 
        // de tel sorte a ce que la deformation actuel corresponde à la deformation max
         
        
        PVector dep = p1P2.normalize().mult(deformation);
        // On replace les masses, en ne prenant pas en compte l'intégration précedente.
        // Dynamique inverse car on place les positions avant de recalculer la vélocité
          
        // La réduction doit etre opérer selon si le rossort est libre ou fixe  
        // Si l'un des deux est fixe, il faut rapprocher le libre vers le fixe de sorte a respecter la contrainte
        if (particule1.statique) {
          particule2.position.sub(dep);
        } else if (particule2.statique) {
          particule1.position.add(dep); 
          
        // Si les deux sont libre, on les rapproche vers leurs centre 
        } else { 
          dep = PVector.mult(dep, 0.5f); // Déplacement vers le centre
          particule2.position.sub(dep);
          particule1.position.add(dep);
        }
        
        
        // La deformation du ressort ne doit pas dépasser tc * longueurRepos
        
        //System.out.println(dist);
        // Alors on applique la procédure dynamique inverse sur les deux masses du ressorts de tel sorte a ce qu'on soit égal a la déformation critique 
        
         
         
    }
    
    public void calculerForces() {
        
        PVector p1P2 = PVector.sub(particule2.position, particule1.position);
        
        float dist = p1P2.mag();
        distPrecedant = dist; // On sauvegarde les distances pour pouvoir calculer le taux de deformation de ce pas de temps, dans la procédure dynamique inverse
        
        PVector f = PVector.mult(p1P2,(longueurRepos - dist) * - rigidite );
        //print(dist+"\n");
        particule1.forceExterne.add(f);
        particule2.forceExterne.sub(f);
        /*if (particule1.statique) {
          particule2.forceExterne.sub(f);
        }
        if (particule2.statique) {
          particule1.forceExterne.add(f);
        }*/
    }
    
    public void dessiner() {
        
        particule1.dessiner(10);
        particule2.dessiner(10);
        stroke(0);
        line(particule1.position.x ,particule1.position.y,particule1.position.z,
             particule2.position.x ,particule2.position.y,particule2.position.z);
        
    }
}
