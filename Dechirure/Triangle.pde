class Triangle{

    public Particule particule1;
    public Particule particule2;
    public Particule particule3;
    
    public boolean colo = false;
    public float amortissementAir;
    public PVector normale = new PVector(0,0,0);

    public Triangle(Particule p1, Particule p2, Particule p3, float aa) {
        particule1 = p1;
        particule2 = p2;
        particule3 = p3; 
        amortissementAir = aa;

        calculerNormale(); 
    }

    public void calculerNormale(){

        PVector p1P2 = PVector.sub(particule2.position, particule1.position);
        PVector p1P3 = PVector.sub(particule3.position, particule1.position);

        PVector.cross(p1P2,p1P3,normale);  
        normale.normalize();
    }

    public void calculerForces(){
      
        calculerNormale();
        
        PVector surf= PVector.mult( 
            PVector.add(
                particule1.velocite, 
                PVector.add(particule2.velocite, particule3.velocite)),
            (1.f/3.f)
        );

        PVector v = PVector.sub(vent,surf); 
        
        PVector f = PVector.mult(
            PVector.mult( normale, (v.dot(normale) * amortissementAir)), 
            (1.f/3.f)
        );
        particule1.forceExterne.add(f);
        particule2.forceExterne.add(f);
        particule3.forceExterne.add(f); 
    }

    public void triParticule(Particule p){
        Particule temp;
        if(p.equals(particule2)){
           temp = particule2;
           particule2 = particule1;
           particule1= temp;
        } else if(p.equals(particule3)){
            temp = particule3;
            particule3 = particule1;
            particule1= temp;
        }  
    }

    public boolean appartient(Particule p){
        return particule1.equals(p)|| particule2.equals(p)||particule3.equals(p);
    }

    public boolean appartient(Particule p1 , Particule p2){
        
        boolean ap1 = particule1.equals(p1)|| particule2.equals(p1)||particule3.equals(p1);
        boolean ap2 = particule1.equals(p2)|| particule2.equals(p2)||particule3.equals(p2);

        return ap1 && ap2;
    }


    public void dessiner(){
        
        particule1.dessiner(2);
        particule2.dessiner(2);
        particule3.dessiner(2);
        
        stroke(0);
       
        
        if(colo)
          fill(32,185,83); 
        else
          fill(127,25,69);
          
        beginShape(TRIANGLES);
            vertex(particule1.position.x ,particule1.position.y,particule1.position.z);
            vertex(particule2.position.x ,particule2.position.y,particule2.position.z);
            vertex(particule3.position.x ,particule3.position.y,particule3.position.z);
        endShape();
        
    }
    
    // Retourne le point d'intersection avec le triangle
    // renvoie null s'il n'y a pas d'intersection
    public float intersect(Ray rayon) {
        final float EPS = 0.0000001f;
        PVector p1P2 = PVector.sub(particule2.position, particule1.position);
        PVector p1P3 = PVector.sub(particule3.position, particule1.position);
        
        PVector h, s, q;
        h = rayon.dir.cross(p1P3);

        final float a = PVector.dot(p1P2, h);
        if (Math.abs(a) < EPS)
            return -1.f; // Parallèle au triangle

        final float f = 1.0f/a;
        s = PVector.sub(rayon.pos, particule1.position);
        float u = f * PVector.dot(s, h);
        if (u < 0.f || u > 1.f) 
            return -1.f;
         
        q = s.cross(p1P2);
        float v = f * PVector.dot(rayon.dir, q);
        if (v < 0.f || u+v > 1.f) 
            return -1.f;
 

        // On calcul t l'endroit d'intersection au rayon
        final float t = f * PVector.dot(p1P3, q);
        if (t > EPS) // Il y a une intersection 
            return t;
        else  // Pas d'intersection.
            return -1.f;
        
    }

}
