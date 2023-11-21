class Ressort{
    
    public float rigidite;
    public float longueurRepos;
    
    public Particule particule1;
    public Particule particule2;
    
    Ressort(Particule p1, Particule p2, float k, float l0) {
        rigidite = k;
        longueurRepos = l0;
        particule1 = p1;
        particule2 = p2;
        
    }
    public void calculerForces() {
        
        PVector p1P2 = PVector.sub(particule2.position, particule1.position);
        
        float dist = p1P2.mag();
        
        PVector f = PVector.mult(p1P2,(longueurRepos - dist) * - rigidite );
        //print(dist+"\n");
        particule1.forceExterne.add(f);
        particule2.forceExterne.sub(f);
            
    }
    
    public void dessiner() {
        
        particule1.dessiner(10);
        particule2.dessiner(10);
        stroke(0);
        line(particule1.position.x ,particule1.position.y,particule1.position.z,
             particule2.position.x ,particule2.position.y,particule2.position.z);
        
    }
}
