class Drapeau{
    
    public ArrayList<Particule> particules = new ArrayList<Particule>();
    public int longueur;
    public int largeur;
    
    public float longueurRepos;
    public PVector position;
    
    public ArrayList<Ressort> ressorts = new ArrayList<Ressort>();
    public ArrayList<Triangle> triangles = new ArrayList<Triangle>();
    
    
    public Drapeau(PVector p, int nbParticules, int l, float masses, float amortissementAirMasses, float longRep, float distance, float amortissementAirTri, JSONArray particules_statiques) {
        
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
        for(int i =0 ; i < particules_statiques.size(); i++)
            particules.get(particules_statiques.getInt(i)).statique = true;


        //============================================
        // generation des ressorts
        //============================================


       boolean lon,lar;
  
 
      for(int y = 0 ; y < largeur; y++){
          for(int x = 0; x < longueur; x++ ){
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
    
    
    private ArrayList<Triangle> rechercheTriangle(Particule p){
      
        ArrayList<Triangle> triangleRelies= new ArrayList<Triangle>() ;
         
        for(Triangle tri : triangles) {
            if(tri.appartient(p)) {
                triangleRelies.add(tri);
                tri.triParticule(p);
            }
        }

        return triangleRelies;
      
    }

    private boolean ParticuleDedans(Particule p ,ArrayList<Triangle> list ){
        
        
        for(Triangle t : list){

            if(t.appartient(p))
                return true;
        }

        return false;
    }
    
    private boolean DejaRelie(Particule p1,Particule p2 ,ArrayList<Ressort> resList){
        for(Ressort re : resList){   //<>//

            if(re.relie(p1,p2))
                return true;
        }

        return false;
    }


    private Triangle chercheAutreMoiterDeCarre(ArrayList<Triangle> list1, ArrayList<Triangle> list2){

        for(Triangle t1 : list1){

            for(Triangle t2 : list2){

                if(t2.appartient(t1.particule2, t1.particule3))
                    return t2;
            }
        }
        return null;

    }


    private ArrayList<Ressort> ChercheRessortAuDessus(Particule p , ArrayList<Ressort> resList){
        ArrayList<Ressort> ress = new   ArrayList<Ressort>(); 
        ArrayList<Particule> parts = new   ArrayList<Particule>();

        boolean isParticule1;
        boolean isParticule2; 
        for(Ressort res : resList){
            isParticule1 = res.particule1.equals(p) ; 
            isParticule2 = res.particule2.equals(p) ;

            if(isParticule1 & res.type == Type.principaux)
                parts.add(res.particule2);
            else if(isParticule2 & res.type == Type.principaux)
                parts.add(res.particule1);
        
        }
        print(parts.size());
        for(int i =0 ; i<parts.size() ; i++){
            for(int j =i+1 ; j<parts.size() ; j++){

                for(Ressort res : ressorts){

                    if(res.relie(parts.get(i),  parts.get(j) )){
                        ress.add(res);
                        break ;
                    }
                }   
            }
        }

        return ress;
    }
    // Scinde un vertex en deux
    public void découpageMasse(Particule p, Ressort r ) { // Le ressort correspond au ressort de la particule
        
        r.colo =false;
        PVector normale = PVector.sub(r.particule1.position , r.particule2.position).normalize();
        // Duplication de la masse
    
        Particule np = new Particule(p.position.copy(), p.velocite.copy(), p.masse/2, p.amortissementAir);
        particules.add(np);
        np.position.sub(normale);
        
        p.masse = p.masse/2;
        //<>// //<>//
        // Rechercher les triangles qui sont lié au point qui doit être scindé // TODO : faire ca en plus rapide. //<>//
        ArrayList<Triangle> triangleRelies =rechercheTriangle(p);  //<>//
        // réaffectation des triangles // TODO : half-edge
        

        // Le plan de découpe est perpendiculaire au ressort
        // On se sert des angles formé entre la normal du plan de découpe (direction du ressort qui lache) et les segments des triangles
          
        // recupera la liste des ressort attacher a notre particule
        ArrayList<Ressort> ress =new ArrayList<Ressort>();
       
        boolean isParticule1;
        boolean isParticule2; 
        int size = ressorts.size();
        for(int i=0; i<size;i++){
            Ressort res = ressorts.get(i);
            isParticule1 = res.particule1.equals(p) ; 
            isParticule2 = res.particule2.equals(p) ; 
            
            if(isParticule1 ){
                ress.add(res); //on ajoute le ressort

                if(! ParticuleDedans(res.particule2, triangleRelies)){ // si ce ressort a relie la particule avec une particule n'apparenant a aucun triangle deja recupere
                    if(res.type !=Type.secondaire){
                        Triangle autre = chercheAutreMoiterDeCarre(triangleRelies, rechercheTriangle(res.particule2));//on cherche le triangle manquant
                        if(autre != null)
                            triangleRelies.add(autre);
                    }
                    else{
                      Ressort rr = new Ressort(np,res.particule2,res.rigidite,res.longueurRepos,res.type);
                       ressorts.add(rr);
                        ress.add(rr);
                    }
                }
            }

            if(isParticule2 ){
                ress.add(res);
                
                if(! ParticuleDedans(res.particule1, triangleRelies)){ 

                    if(res.type !=Type.secondaire){
                        Triangle autre = chercheAutreMoiterDeCarre(triangleRelies, rechercheTriangle(res.particule1));
                        if(autre != null)
                            triangleRelies.add(autre);
                    }
                    else{
                        Ressort rr = new Ressort(res.particule1,np,res.rigidite,res.longueurRepos,res.type);
                        ressorts.add(rr);
                        ress.add(rr);
                    }
                }   
            }    
                
            
        } 
        ress.addAll(ChercheRessortAuDessus(p,ress));

        //Trie les triangle en fonction de leur position par rapport au paln de decoupe
        ArrayList<Triangle> triangleDessus= new ArrayList<Triangle>() ; 
        ArrayList<Triangle> triangleDessous= new ArrayList<Triangle>() ;

        for(Triangle tri : triangleRelies) { 
            
            if(tri.appartient(p)){ // si le triangle est directemnt relier a la particule 
                PVector pP2 = PVector.sub(tri.particule2.position, p.position).normalize();
                PVector pP3 = PVector.sub(tri.particule3.position, p.position).normalize();
                
                
                // Test si le triangle est considéré comme au dessus ou en dessous du plan de découpe
                float angle1 = pP2.dot(normale);
                float angle2 = pP3.dot(normale);
                    
                    
                if(angle1 >=0 && angle2>=0)
                    triangleDessus.add(tri);
                else if (angle1<0 && angle2<0 )
                    triangleDessous.add(tri);
                    
                else {
                    
                    if(abs(angle1) >= abs(angle2) && angle1 >= 0 || abs(angle2) >= abs(angle2) && angle2>=0  )
                        triangleDessus.add(tri);
                    
                    else if(abs(angle1) >= abs(angle2) && angle1 < 0 || abs(angle2) >= abs(angle2) && angle2<0  ){
                        triangleDessous.add(tri);
                        
                    }
                    
                }
            }
            else{
                PVector pP1 = PVector.sub(tri.particule1.position, p.position).normalize();
                if(pP1.dot(normale)>=0 )
                    triangleDessus.add(tri);
                else    
                    triangleDessous.add(tri);
            }
        }

        //Reaffecte les ressorts a la nouvelle particule 
        for(Triangle tri : triangleDessous) {

            for(Ressort res : ress) { 
                isParticule1 = res.particule1.equals(p) ;
                isParticule2 = res.particule2.equals(p) ;
                
                if(isParticule1 && tri.appartient(res.particule2)){
                    res.particule1 = np;
                }
                else if(isParticule2 && tri.appartient(res.particule1)){
                    res.particule2 = np;
                }
                
            } 
           if(tri.appartient(p))
                tri.particule1=np;
            tri.colo = false;
        }
        
        // on recreer les ressorts neccesaire pour la particule
        for(Triangle tri : triangleDessus) {

            for(Ressort res : ress) { 
                isParticule1 = res.particule1.equals(np) ;
                isParticule2 = res.particule2.equals(np) ;
                
                
                if(isParticule1 && tri.appartient(res.particule2) ){
                    if(! DejaRelie(p,res.particule2,ress))
                        ressorts.add(new Ressort(p,res.particule2, res.rigidite, res.longueurRepos,res.type));


                }
                if(isParticule2 && tri.appartient(res.particule1)){
                    if(! DejaRelie(p,res.particule1,ress))
                        ressorts.add(new Ressort(res.particule1,p, res.rigidite, res.longueurRepos,res.type));
                }
            
            } 
            
        }
       
      //cut les ressort secondaire en trop
       
       PVector PointPlan = p.position.copy();
        p.position.add(normale);
        np.colo =true;
       
        for(Ressort res : ress){

            isParticule1 = res.particule1.equals(p) || res.particule1.equals(np)  ; 
            isParticule2 = res.particule2.equals(p) || res.particule2.equals(np)  ;

            int signe1 = PVector.sub(res.particule1.position,PointPlan).normalize().dot(normale)>0 ? -1 :1;
            int signe2 = PVector.sub(res.particule2.position,PointPlan).normalize().dot(normale)>0 ? -1:1;
            
            if( ( res.type == Type.secondaire && signe1 != signe2 ) ||(res.type == Type.secondaire && !isParticule1 && !isParticule1)  )
                ressorts.remove(res);
        }


   
        p.position.sub(normale);
        np.position.add(normale);
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
