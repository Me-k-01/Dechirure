
class Ray {
    public PVector pos;
    public PVector dir;
    public Ray(PVector pos, PVector dir) {
        this.pos = pos;
        this.dir = dir;
    }
}

class Accrocheur { 
 
    public float fov;
    public float focalDist; // near Clip
    public float aspect; // aspect ratio 

    //
    private PVector hautGauche; 
    private PVector horiVec;   // viewport u
    private PVector vertiVec;  // viewport v

    public int triangleControle = -1; // Indice du triangle que l'on controle
    private Ray rayonDebug = null;
 
    // Permet de déplacer le triangle séléctionné selon la souris.
    // Lorsque null, pas de triangle séléctionné
    private Ray rayonDepart;
    private float tDepart; // Distance t du point d'intersection du rayon de départ

    // Pour pouvoir créer un rayon, il nous faut les perspective de la camera
    public Accrocheur(float fov, float focalDist, float aspect) {  
        this.fov = fov; // FOV en radian
        this.focalDist = focalDist; 
        this.aspect = aspect; 
        
        updateViewport();
    }
    
    public boolean selectionTriangle(ArrayList<Triangle> triangles, Ray rayon) {
        this.rayonDebug = rayon;

        int i = 0;
        float tNear = Float.POSITIVE_INFINITY;
        int iNear = 0;

        for (Triangle tri : d.triangles) {
            float t = tri.intersect(rayon);
            
            if (t != -1.f) { // On a intersection  
                // On ne garde que le triangle le plus proche
                if (tNear > t) {
                    tNear = t;
                    iNear = i;
                }
            }
            i++;
        }
        System.out.println("tNear" + tNear);
        // Si jamais on a eu une intersection
        if (tNear != Float.POSITIVE_INFINITY) {
            // On démare le déplacement
            rayonDepart = rayon; 
            tDepart = tNear;
            changeControle(triangles, iNear);   
            // TODO : calculer le drag
            return true;
        }
        return false;
    
    }
  

    public void changeControle(ArrayList<Triangle> triangles, int triangleControle) { 
        this.triangleControle = triangleControle;
        triangles.get(triangleControle).colo = true; // Colorie le triangle lorsqu'il est séléctionné
    }

    public void stopSelection(ArrayList<Triangle> triangles) {
        if (rayonDepart == null) return; // Cas ou on n'a pas démarer une selection
        
        triangles.get(this.triangleControle).colo = false; // Décolorie le triangle séléctinné
        rayonDepart = null;
        tDepart = 0;
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

    public void dessinDebug() { // Dessin pour le debugage
        if (rayonDebug == null) return; 
        stroke(0); 

        translate(rayonDebug.pos.x, rayonDebug.pos.y, rayonDebug.pos.z); 
        box(0.1); 
        translate(- rayonDebug.pos.x, -rayonDebug.pos.y, - rayonDebug.pos.z); 
        
        line(
            rayonDebug.pos.x, rayonDebug.pos.y, rayonDebug.pos.z, 
            rayonDebug.pos.x + rayonDebug.dir.x * 100000, rayonDebug.pos.y + rayonDebug.dir.y * 100000, rayonDebug.pos.z + rayonDebug.dir.z * 100000
        );
    }

    public void deplace(ArrayList<Triangle> triangles, float dt) {
        // TODO : On drag selon le plan de la caméra :
 
        if (rayonDepart == null) return; // Rien a déplacer

        Triangle tri = triangles.get(triangleControle);         
        // On a enregistré la direction originel lorsqu'on a attrapé
        // Afin de mesurer la différence avec la direction que point la souris actuellement
        Ray rCurseur = genereRayon(
            (float)mouseX/(float)width, 
            (float)mouseY/(float)height
        );
        // Avec le t de la première intersection, on peut ainsi calculer la position actuel que devrait avoir le triangle
        PVector nouvP = PVector.mult(rCurseur.dir, tDepart);
        PVector anciP = PVector.mult(rayonDepart.dir, tDepart);
        PVector deplacement = PVector.sub(nouvP, anciP);

        // On déplace ainsi chaque particule
        tri.particule1.dynamiqueInv(deplacement, dt); 
        tri.particule2.dynamiqueInv(deplacement, dt);
        tri.particule3.dynamiqueInv(deplacement, dt);
        //PVector f = new PVector(10, 1, 0);
        //tri.particule1.velocite.add(f);
        //tri.particule2.velocite.add(f);
        //tri.particule3.velocite.add(f); 
        
    }  
    
}