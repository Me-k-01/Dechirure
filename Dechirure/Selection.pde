
class Ray {
    public PVector pos;
    public PVector dir;
    public Ray(PVector pos, PVector dir) {
        this.pos = pos;
        this.dir = dir;
    }
}

class Selection { 
 
    public float fov;
    public float focalDist; // near Clip
    public float aspect; // aspect ratio
    float o; // TOA

    //
    private PVector hautGauche; 
    private PVector horiVec;   // viewport u
    private PVector vertiVec;  // viewport v

    // Pour pouvoir selectionner correctement, il nous faut les perspective de la camera
    public Selection(float fov, float focalDist, float aspect) { // FOV en radian
        this.fov = fov;
        this.focalDist = focalDist; 
        this.aspect = aspect; 

        updateViewport();
    }
 

    // Génére un rayon depuis une coordonné de la caméra
    public Ray genereRayon(float camX, float camY) { 
        updateViewport();

        // Position du point du plan dans l'espace monde
        PVector posPoint = PVector.add(
            hautGauche, 
            PVector.sub(
                PVector.mult(horiVec, camX),
                PVector.mult(vertiVec, camY)
            )
        ); 
        PVector dir = PVector.sub(posPoint, versVec(cam.getPosition()));
        dir.normalize();

        return new Ray(posPoint, dir);
    }

    private PVector versVec(float[] arg) {
        return new PVector(arg[0], arg[1], arg[2]);
    }
 

    public void updateViewport() { 
        PVector camCible = versVec(cam.getLookAt()); // Cible que pointe la caméra 
        PVector camPos = versVec(cam.getPosition()); // Position de la caméra 

        // Systeme de coordonné local 
        PVector w = PVector.sub(camPos, camCible); // Inverse de la direction
        w.normalize();
        PVector u = new PVector(0, 1, 0).cross(w); // Cross entre un vecteur de l'espace monde et w
        u.normalize();
        PVector v = new PVector(w.x, w.y, w.z).cross(u);
        v.normalize();

        o = ((float)Math.tan(fov) / 2.f) * focalDist; 
        
        vertiVec = PVector.mult(v, o * 2.f); // viewport v
        horiVec = PVector.mult(u, -aspect * o * 2.f); // Viewport u

        PVector milieu = PVector.add(camPos, PVector.mult(w, -focalDist)); // pos + nearClip * -w
        hautGauche = milieu.add(PVector.add(
            PVector.mult(vertiVec, 0.5f),
            PVector.mult(horiVec, -0.5f))
        ); // mid + vV / 2 + -vU/2
    }
}