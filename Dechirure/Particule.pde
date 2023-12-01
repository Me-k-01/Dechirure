
class Particule{
    
    public PVector position;
    public PVector velocite;
    public PVector forceExterne = new PVector(0,0,0);
    
    public float  masse;
    public float amortissementAir;
    
    public boolean  statique = false;
    public boolean colo = false;
    
    
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
    
    public void integration(float dt) {
        if (!statique) {
          // intégration d'euler 2.3 du papier de Xavier Provot. 
          PVector acceleration = PVector.div(forceExterne, masse); // a(t + dt) = F/m   
          PVector velociteSuivante = PVector.add(velocite, PVector.mult(acceleration, dt)); // v(t+dt) = v(t) + dt * a(t+dt)
          PVector positionSuivante = PVector.add(position, PVector.mult(velociteSuivante, dt)); // P(t + dt) = P(t) + dt * v(t + dt)
          
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
        
        if (statique || colo)
            fill(255,0,0);
        else 
            fill(59,157,32);
        
        noStroke();   
        sphere(radius);
        
        translate( - position.x, - position.y, - position.z);
    } 

    public void dynamiqueInv(PVector dep, float dt) {
        // On deplacement en faisant une routine dynamique inverse
        PVector nouvPosition = PVector.sub(position, dep); // P(t+dt)
        velocite.add(PVector.sub(nouvPosition, position).div(dt)); // v(t+dt) = (P(t+dt) - P(t)) /dt
        position = nouvPosition;
    }
}
