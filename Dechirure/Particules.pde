
class Particule{
    
    public PVector position;
    public PVector velocite;
    public PVector forceExterne = new PVector(0,0,0);
    
    public float  masse;
    public float amortissementAir;
    
    public boolean  statique = false;
    
    
    public Particule(PVector p0, PVector v0, float m, float aa) {
        position = p0;
        velocite = v0;
        masse = m;
        amortissementAir = aa;
        
    }
    
    public Particule(PVector p0, PVector v0, float m, float aa, boolean fixe) {
        position = p0;
        velocite = v0;
        masse = m;
        amortissementAir = aa;
        statique = fixe;
    }
    
    public void integration(float t) {
        if (!statique) {
            PVector acceleration = PVector.div(forceExterne,masse);
            
            PVector velociteSuivante = PVector.add(velocite, PVector.mult(acceleration,t));
            PVector positionSuivante = PVector.add(position, PVector.mult(velociteSuivante,t));
            
            position = positionSuivante.copy();
            velocite = velociteSuivante.copy();
        }
    }
    
    public void calculerForces() {
        
        PVector vn = new PVector(0,0,0);
        PVector v = PVector.sub(velocite, vent);
        v.normalize(vn);
        
        PVector f = PVector.mult(vn, -amortissementAir * v.dot(v));
        PVector.add(PVector.mult(gravite,masse),f, forceExterne);
    }
    
    public void dessiner(float radius) {
        translate(position.x,position.y,position.z);
        
        if (statique)
            fill(255,0,0);
        else 
            fill(59,157,32);
        
        noStroke();   
        sphere(radius);
        
        translate( - position.x, - position.y, - position.z);
    } 
}
