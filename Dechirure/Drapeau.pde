class Drapeau{
    
    public ArrayList<Particule> particules = new ArrayList<Particule>();
    public int longueur;
    public int largeur;
    
    public PVector position;
    
    public ArrayList<Ressort> ressorts = new ArrayList<Ressort>();
    public ArrayList<Triangle> triangles = new ArrayList<Triangle>();
    
    
    public Drapeau(PVector p, int nbParticules, int l, float masses, float amortissementAirMasses, float longRep, float amortissementAirTri ) {
        
        // generation des particules
        //============================================
        position = p;//position du coin superieur gauche
        longueur = l;
        largeur = nbParticules / longueur;
        
        
        PVector posParticule;
        for (int i = 0; i < nbParticules; i++) {
            
            float x = (i % longueur) * longRep;
            float y = int(i / longueur) * longRep;
            posParticule = new PVector(x, y, 0).add(position);
            
            particules.add(new Particule(posParticule, new PVector(0, 0, 0), masses, amortissementAirMasses));
        }

        // contraintes statiques 
        particules.get(0).statique = true;
        if (nbParticules > 2)
            particules.get((largeur - 1) * longueur).statique = true; 


        //============================================
        // generation des ressorts
        //============================================


       boolean lon,lar;
  
        for(int x = 0; x < longueur; x++ ){
            for(int y = 0 ; y < largeur; y++){
                // Pour chaque masses on ajoute les ressorts sur un seul sens

                lon = x <longueur - 1;
                lar = y < largeur - 1;
                
                int i = x + (y*longueur);
                if(lon)
                    ressorts.add(new Ressort(particules.get(i), particules.get(i + 1), rigiditePrincipale, longRep ));
                if(lar)
                    ressorts.add(new Ressort(particules.get(i), particules.get(i + longueur), rigiditePrincipale, longRep ));
                if(y > 0 && lon)
                    ressorts.add(new Ressort(particules.get(i), particules.get(i + 1 - longueur), rigiditeDiag, longRep*sqrt(2.f) ));
                if(lon && lar)
                     ressorts.add(new Ressort(particules.get(i), particules.get(i + longueur + 1), rigiditeDiag, longRep*sqrt(2.f) ));
                if(x < longueur-2)
                   ressorts.add(new Ressort(particules.get(i), particules.get(i + 2), rigiditeSecond, longRep*2.f ));
                if(y < largeur-2)
                   ressorts.add(new Ressort(particules.get(i), particules.get(i + longueur*2), rigiditeSecond, longRep*2.f ));
            }
        }


        //============================================
        // generation des triangle
        //============================================
        if (nbParticules > 2 && largeur > 1 && longueur > 1) {
            int ind;
            if (nbParticules == 3)
                triangles.add(new Triangle(particules.get(0), particules.get(1), particules.get(2), amortissementAirTri));
            else {
                for (int i = 0; i < largeur; i++) {
                    for (int j = 0; j < longueur - 1; j++) {
                        ind = j + (i * longueur);
                        if (i < largeur - 1)
                            triangles.add(new Triangle(particules.get(ind), particules.get(ind + 1), particules.get(ind + longueur + 1), amortissementAirTri));
                        if ( i > 0)
                            triangles.add(new Triangle(particules.get(ind), particules.get(ind - longueur), particules.get(ind + 1), amortissementAirTri));
                    }
                }
            } 
        }  
    }
    
    public void forces() {
        
        // 3 boucles sur chaque tableau
        //particules

        for (int i = 0; i < particules.size();i++) {
            particules.get(i).calculerForces();            
        }

        //ressorts
        for (int i = 0; i < ressorts.size();i++) {
            ressorts.get(i).calculerForces();    
        }

        //triangles
        for (int i = 0; i < triangles.size();i++) {
            triangles.get(i).calculerForces();    
        }
    }
    
    
    
    public void mettreAJour(float t) {
        
        forces();
        for (int i = 0; i < particules.size(); i++) {
            particules.get(i).integration(t);
        }
    }
    
    
    public void dessiner() {
        /*
        for(int i =0 ; i<particules.size();i++){
        particules.get(i).dessiner(10);
    }
        */
        /*
        for (int i = 0; i < ressorts.size();i++) {
            ressorts.get(i).dessiner();
        }
        */    
        
        for (int i = 0; i < triangles.size(); i++) {
            triangles.get(i).dessiner();
        }
        
    }
}
