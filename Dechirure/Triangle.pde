class Triangle{

    public Particule particule1;
    public Particule particule2;
    public Particule particule3;

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

        PVector p1P2 = PVector.sub(particule2.position , particule1.position);
        PVector p1P3 = PVector.sub(particule3.position , particule1.position);

        PVector.cross(p1P2,p1P3,normale);
        normale.normalize();
    }
    public void calculerForces(){
      
        calculerNormale();
        
        PVector surf= PVector.mult( PVector.add(particule1.velocite, 
                                      PVector.add(particule2.velocite,particule3.velocite) 
                                      )
                         , (1.f/3.f));
        PVector v = PVector.sub(vent,surf); 
        
        PVector f = PVector.mult( 
            PVector.mult(  normale,  ( v.dot(normale)* amortissementAir)), 
            (1.f/3.f)
        );
        particule1.forceExterne.add(f);
        particule2.forceExterne.add(f);
        particule3.forceExterne.add(f);
      
    }

    public void triParticule(Particule p){
        Particule temp;
        if(p.equals(tri.particule2)){
           temp = particule2;
           particule2 = particule1;
           particule1= temp;
        } else if(p.equals(tri.particule3)){
            temp = particule3;
            particule3 = particule1;
            particule1= temp;
        }  
    }

    public void dessiner(){
        
        particule1.dessiner(2);
        particule2.dessiner(2);
        particule3.dessiner(2);
        
        stroke(0);
        line(particule1.position.x ,particule1.position.y,particule1.position.z,
             particule2.position.x ,particule2.position.y,particule2.position.z);

        line(particule1.position.x ,particule1.position.y,particule1.position.z,
            particule3.position.x ,particule3.position.y,particule3.position.z);

        line(particule2.position.x ,particule2.position.y,particule2.position.z,
             particule3.position.x ,particule3.position.y,particule3.position.z);
        
        fill(127,25,69);
        beginShape(TRIANGLES);
        vertex(particule1.position.x ,particule1.position.y,particule1.position.z);
        vertex(particule2.position.x ,particule2.position.y,particule2.position.z);
        vertex(particule3.position.x ,particule3.position.y,particule3.position.z);
        endShape();
        
    }
    
    

}
