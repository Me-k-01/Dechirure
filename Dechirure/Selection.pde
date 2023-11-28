
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

    //
    private PVector hautGauche; 
    private PVector horiVec;   // viewport u
    private PVector vertiVec;  // viewport v

    // Pour pouvoir créer un rayon, il nous faut les perspective de la camera
    public Selection(float fov, float focalDist, float aspect) {  
        this.fov = fov; // FOV en radian
        this.focalDist = focalDist; 
        this.aspect = aspect; 

        updateViewport();
    }
 

    // Génére un rayon en projetant une coordonné de la caméra vers l'espace monde
    public Ray genereRayon(float camX, float camY) { 
        updateViewport();
 
        //System.out.println("camPos : x : "+camPos.x+", y : " + camPos.y + ", z : " + camPos.z);
        System.out.println("hautGauche : x : " + hautGauche.x + ", y : " + hautGauche.y + ", z : " + hautGauche.z);
        System.out.println("horiVec : x : " + horiVec.x + ", y : " + horiVec.y + ", z : " + horiVec.z);
        System.out.println("vertiVec : x : " + vertiVec.x + ", y : " + vertiVec.y + ", z : " + vertiVec.z); 
        System.out.println("camX : " + camX);
        System.out.println("camY : " + camY);
        
        // Position du point du plan dans l'espace monde
        PVector posPoint = PVector.add(
            hautGauche, 
            PVector.sub(
                PVector.mult(horiVec, camX),
                PVector.mult(vertiVec, camY)
            )
        ); // topLeft + vU * x - vV * y
        PVector dir = PVector.sub(posPoint, versVec(cam.getPosition())); // point - camPos
        dir.normalize();

        return new Ray(posPoint, dir);
    }

    private PVector versVec(float[] arg) {
        return new PVector(arg[0], arg[1], arg[2]);
    }
 

    public void updateViewport() { 
        PVector camCible = versVec(cam.getLookAt()); // Cible que pointe la caméra 
        PVector camPos = versVec(cam.getPosition()); // Position de la caméra 
        System.out.println("camCible : x : "+camCible.x+", y : " + camCible.y + ", z : " + camCible.z);
        // Systeme de coordonné local 
        PVector w = PVector.sub(camPos, camCible); // Inverse de la direction : - (lookAt - camPos)
        w.normalize();
        PVector u = new PVector(0.f, 1.f, 0.f).cross(w); // Cross entre un vecteur de l'espace monde et w
        u.normalize();
        PVector v = new PVector(w.x, w.y, w.z).cross(u);
        v.normalize(); 
        float o = ((float)Math.tan(fov) / 2.f) * focalDist; // TOA : fov déjà en radian
        
        vertiVec = PVector.mult(v, - o * 2.f); // viewport v : hauteur TODO : trouver pourquoi mettre en negatif fait fonctionner
        horiVec = PVector.mult(u, aspect * o * 2.f); // Viewport u : largeur
 

        PVector milieu = PVector.add(camPos, PVector.mult(w, -focalDist)); // pos + nearClip * -w
        hautGauche = PVector.add(milieu, PVector.add(
            PVector.mult(vertiVec, 0.5f), // Hauteur/2
            PVector.mult(horiVec, -0.5f)) // -Largeur/2
        ); // mid + vV / 2 + -vU/2 
    }


    // TODO : On drag selon le plan de la caméra :
    // La direction de déplacement par du point d'intersection et se dirige le plus rapidement possible vers le nouveau rayon de la projection
}