class Drapeau{
    
    public ArrayList<Particule> particules = new ArrayList<Particule>();
    public int longueur;
    public int largeur;
    
    public float longueurRepos;
    public PVector position;
    
    public ArrayList<Ressort> ressorts = new ArrayList<Ressort>();
    public ArrayList<Triangle> triangles = new ArrayList<Triangle>();
    
    
    public Drapeau(PVector p, int nbParticules, int l, float masses, float amortissementAirMasses, float longRep, float distance, float amortissementAirTri ) {
        
        // generation des particules
        //============================================
        position = p;//position du coin superieur gauche
        longueur = l;
        largeur = nbParticules / longueur;
        longueurRepos= longRep;

        if(distance > longRep)
            print("une erreur\n");// ("longeur au repos trop petite ");
        
        PVector posParticule;
        for (int i = 0; i < nbParticules; i++) {
        
            float x = (i % longueur) * distance;
            float y = int(i / longueur) * distance;
            
            posParticule = new PVector(x, y, 0).add(position);
            
            particules.add(new Particule(posParticule, new PVector(0, 0, 0), masses, amortissementAirMasses));
        }

        // contraintes statiques 
        particules.get(0).statique = true;
        particules.get(9).statique = true;
        //if (nbParticules > 2)
        //    particules.get((largeur - 1) * longueur).statique = true; 


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
                    ressorts.add(new Ressort(particules.get(i), particules.get(i + 1), rigiditePrincipale, longRep, Type.principaux ));
                if(lar)
                    ressorts.add(new Ressort(particules.get(i), particules.get(i + longueur), rigiditePrincipale, longRep , Type.principaux ));
                if(y > 0 && lon)
                    ressorts.add(new Ressort(particules.get(i), particules.get(i + 1 - longueur), rigiditeDiag, longRep*sqrt(2.f), Type.diagonale ));
                if(lon && lar)
                     ressorts.add(new Ressort(particules.get(i), particules.get(i + longueur + 1), rigiditeDiag, longRep*sqrt(2.f), Type.diagonale ));
                if(x < longueur-2)
                   ressorts.add(new Ressort(particules.get(i), particules.get(i + 2), rigiditeSecond, longRep*2.f,  Type.secondaire ));
                if(y < largeur-2)
                   ressorts.add(new Ressort(particules.get(i), particules.get(i + longueur*2), rigiditeSecond, longRep*2.f, Type.secondaire ));
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
        for (Particule particule : particules) 
            particule.calculerForces();            
        //ressorts
        for (Ressort ressort : ressorts) 
            ressort.calculerForces();     
        //triangles
        for (Triangle tri : triangles) 
            tri.calculerForces();    
    }
    
    public void correctionDesDeformations(float dt) {
        // Procédure dynamique inverse  pour eviter l'élongation des ressorts, à faire après l'intégration.
        
        for (Ressort ressort : ressorts) {
          ressort.corrige(dt);
        }
        // Cette opération déplace les position des vertices et risque de créer d'autre ressorts trop étendu. 
        // Cependant, les deformations étant concentré assez localement, le résultat reste plus acceptable que sans cette opération.
    }
    
    // Scinde un vertex en deux
    public void découpageMasse(Particule p, Ressort r ) { // Le ressort correspond au ressort de la particule
        
        PVector normale = PVector.sub(r.particule1 - r.particule2).normalize();
        // Duplication de la masse
        
        Particule np = new Particule(p.position, p.velocite, p.masse, p.amortissementAir);
        // TODO : Diviser les masses
        
        // Rechercher les triangles qui sont lié au point qui doit être scindé // TODO : faire ca en plus rapide.
        ArrayList<Triangle> triangleRelies= new ArrayList<Triangle>() ;
        for(Triangle tri : triangles) {
            if(p.equals(tri.particule1) || p.equals(tri.particule2) || p.equals(tri.particule3)) {
                triangleRelies.add(tri);
            }
        }

        // réaffectation des triangles // TODO : half-edge
       
        Particule p2 ;
        Particule p3 ;

        // Le plan de découpe est perpendiculaire au ressort
        // On se sert des angles formé entre la normal du plan de découpe (direction du ressort qui lache) et les segments des triangles
          
        ArrayList<Triangle> triangleDessus= new ArrayList<Triangle>() ;
        ArrayList<Triangle> triangleDessous= new ArrayList<Triangle>() ;
        for(Triangle tri : triangleRelies) { 
            if (p.equals(tri.particule1)) {
                p2 = tri.particule2;
                p3 = tri.particule3;
                tri.particule1 = np;
            } else if(p.equals(tri.particule2)){
                p2 = tri.particule1;
                p3 = tri.particule3;
                tri.particule2 = np;
            } else if(p.equals(tri.particule3)){
                p2 = tri.particule2;
                p3 = tri.particule1;
                tri.particule3 = np;
            }

            PVector pP1 = PVector.sub(p1.position, p.position).normalize();
            PVector pP2 = PVector.sub(p2.position, p.position).normalize();
            
          
            // Test si le triangle est considéré comme au dessus ou en dessous du plan de découpe
            float angle1 = pP1.dot(normale);
            float angle2 = pP2.dot(normale);
              
              
            if(angle1 >=0 && angle2>=0)
                triangleDessus.add(tri);
            else if (angle1<0 && angle2<0 )
                triangleDessous.add(tri);
            else {
                
                if(abs(angle1) > abs(angle2) && angle1 > 0 || abs(angle2) > abs(angle2) && angle2>0  )
                     triangleDessus.add(tri);
                
                 if(abs(angle1) > abs(angle2) && angle1 < 0 || abs(angle2) > abs(angle2) && angle2<0  )
                     triangleDessous.add(tri);
                
            }

        }
        ArrayList<Ressorts> ress =new ArrayList<Ressort>();
        for(Ressort res : ressorts) {
            
            if(res.particule1.equals(p) || res.type == Type.secondaire){
               
                ressorts.add(new ressort(np,res.particule2, res.rigidite, res.longRep,res.type) );
            }

            else if(res.particule2.equals(p) || res.type == Type.secondaire){
               ressorts.add(new ressort(res.particule1,np, res.rigidite, res.longRep,res.type) );

            }
            else   


        } 

        // TODO : les ressorts tertiaire doivent être pris en compte
        // On peu se servir du ressort pour connaitre le ressort tertiaire a peter
        // Si un de ses ressorts passe par dessus le plan de découpe, il faut aussi le détruire.
    }
    
    public void mettreAJour(float dt, boolean correct) {
        
        forces(); 
        
        for (Particule particule : particules) { 
            particule.integration(dt);
        } 
        if (correct)
            correctionDesDeformations(dt);
    }
    
    
    public void dessiner(boolean renduTriangle) {
        /*
        for(int i =0 ; i<particules.size(); i++){
        particules.get(i).dessiner(10);
    }
        */
        if (renduTriangle) {
            for (Triangle tri : triangles) { 
                tri.dessiner();
            }
        } else { 
            for (int i = 0; i < ressorts.size(); i++) {
                ressorts.get(i).dessiner();
            }
        } 
    }

}
