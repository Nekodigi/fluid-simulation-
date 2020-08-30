class MeshDeform{
  PVector[][] ctrPoss;
  PVector[][] ctrUV;
  PImage img;
  PVector tl, br;
  int resI, resJ;
  
  MeshDeform(PImage img, int resI, int resJ, PVector tl, PVector br){//top left, bottom right
    this.img = img;
    this.tl = tl;
    this.br = br;
    this.resI = resI;
    this.resJ = resJ;
    resetCoord();
  }
  
  void resetCoord(){
    ctrPoss = new PVector[resI][resJ];
    ctrUV = new PVector[resI][resJ];
    for(int i=0; i<resI; i++){
      for(int j=0; j<resJ; j++){
        float x = map(i, 0, resI-1, tl.x, br.x);
        float y = map(j, 0, resJ-1, tl.y, br.y);
        float u = map(i, 0, resI-1, 0, 1);
        float v = map(j, 0, resJ-1, 0, 1);
        ctrPoss[i][j] = new PVector(x, y);
        ctrUV[i][j] = new PVector(u, v);
      }
    }
  }
  
  void show(){
    textureMode(NORMAL);
    for(int i=0; i<ctrPoss.length-1; i++){
      beginShape(TRIANGLE_STRIP);
      texture(img);
      for(int j=0; j<ctrPoss[0].length; j++){
        vertex(ctrPoss[i][j].x, ctrPoss[i][j].y, ctrUV[i][j].x, ctrUV[i][j].y);
        vertex(ctrPoss[i+1][j].x, ctrPoss[i+1][j].y, ctrUV[i+1][j].x, ctrUV[i+1][j].y);
      }
      endShape();
    }
    
  }
}
