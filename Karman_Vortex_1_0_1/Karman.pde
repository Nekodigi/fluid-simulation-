//based on this site https://github.com/eduidl/karman-vortex

class Karman{
  float Re = 70.0;//reynolds number
  float cfl = 0.2;//cfl number
  
  //sor parameters
  float omegap = 1.0;
  int maxitp = 100;
  float errorp = 0.0001;
  
  //int bi1 = 96, bi2 = 106, bj1 = 96, bj2 = 106;//box corner
  int bi1, bi2, bj1, bj2;
  
  //set delta
  float dx, dy, dt;
  
  int nx, ny;
  float[][] p_;
  float[][] u_;
  float[][] v_;

  Karman(){
    nx = int(width/pSize);
    ny = int(height/pSize);
    bi1 = nx/4 - ny/50;
    bi2 = nx/4 + ny/50;
    bj1 = ny/2 - ny/50;
    bj2 = ny/2 + ny/50;
    dx = 1.0/(bi2 - bi1);
    dy = 1.0/(bj2 - bj1);
    dt = cfl*min(dx, dy);
    p_ = new float[nx + 2][ny + 2];
    u_ = new float[nx + 2][ny + 2];
    v_ = new float[nx + 2][ny + 2];
    for(int i = 0; i < nx + 2; i++){
      for(int j = 0; j < ny + 2; j++){
        u_[i][j] = 1;
      }
    }
  }
  
  boolean withInSquare(int x, int y){
    return bi1 < x && x < bi2 && bj1 < y && y < bj2;
  }
  
  void boundaryConditionP(){
    //top bottom
    for(int j = 1; j <= ny; j++){
      p_[1][j] = 0.0;
      p_[nx][j] = 0.0;
    }
    
    //right left
    for(int i = 1; i <= nx; i++){
      p_[i][1] = 0.0;
      p_[i][ny] = 0.0;
    }
    
    //box corner
    p_[bi1][bj1] = p_[bi1-1][bj1-1];
    p_[bi1][bj2] = p_[bi1-1][bj2+1];
    p_[bi2][bj1] = p_[bi2+1][bj1-1];
    p_[bi2][bj2] = p_[bi2+1][bj2+1];
    
    //box top bottom
    for(int j = bj1+1; j < bj2; j++){
      p_[bi1][j] = p_[bi1-1][j];
      p_[bi2][j] = p_[bi2+1][j];
    }
    
    //box left right
    for(int i = bi1+1; i < bi2; i++){
      p_[i][bj1] = p_[i][bj1-1];
      p_[i][bj2] = p_[i][bj2+1];
    }
  }
  
  void boundaryConditionUV(){
    //top bottom
    for(int j = 1; j <= ny; j++){
      u_[1][j] = 1.0;
      u_[0][j] = 1.0;
      
      v_[1][j] = 0.0;
      v_[0][j] = 0.0;
      
      u_[nx][j] = 2.0*u_[nx - 1][j] - u_[nx - 2][j];
      u_[nx + 1][j] = 2.0*u_[nx][j] - u_[nx - 1][j];
      
      v_[nx][j] = 2.0*v_[nx - 1][j] - v_[nx - 2][j];
      v_[nx + 1][j] = 2.0*v_[nx][j] - v_[nx - 1][j];
    }
    
    //left right
    for(int i = 1; i <= nx; i++){
      u_[i][1] = 2.0*u_[i][2] - u_[i][3];
      u_[i][0] = 2.0*u_[i][1] - u_[i][2];
      
      v_[i][1] = 2.0*v_[i][2] - v_[i][3];
      v_[i][0] = 2.0*v_[i][1] - v_[i][2];
      
      u_[i][ny] = 2.0*u_[i][ny - 1] - u_[i][ny - 2];
      u_[i][ny + 1] = 2.0*u_[i][ny] - u_[i][ny - 1];
      
      v_[i][ny] = 2.0*v_[i][ny - 1] - v_[i][ny - 2];
      v_[i][ny + 1] = 2.0*v_[i][ny] - v_[i][ny - 1];
    }
    
    //in the box
    for(int i = bi1; i <= bi2; i++){
      for(int j = bj1; j <= bj2; j++){
        u_[i][j] = 0.0;
        v_[i][j] = 0.0;
      }
    }
  }
  
  void poissonEquation(){
    float[][] rhs = new float[nx + 2][ny + 2];
    for(int i = 2; i < nx; i++){
      for(int j = 2; j < ny; j++){
        if(withInSquare(i, j)) continue;
        
        float ux = (u_[i + 1][j] - u_[i - 1][j])/(2.0*dx);
        float uy = (u_[i][j + 1] - u_[i][j - 1])/(2.0*dy);
        float vx = (v_[i + 1][j] - v_[i - 1][j])/(2.0*dx);
        float vy = (v_[i][j + 1] - v_[i][j - 1])/(2.0*dy);
        rhs[i][j] = (ux + vy)/dt - (ux*ux + 2.0*uy*vx + vy*vy);
      }
    }
    
    for(int iter = 1; iter <= maxitp; iter++){
      float res = 0.0;
      for(int i = 2; i < nx; i++){
        for(int j = 2; j < ny; j++){
          if(withInSquare(i, j)) continue;
          
          float dp = ((p_[i + 1][j] + p_[i - 1][j])/(dx*dx) + 
                      (p_[i][j + 1] + p_[i][j - 1])/(dy*dy) - rhs[i][j])/
                      (2.0/(dx*dx) + 2.0/(dy*dy)) - p_[i][j];
          res += dp * dp;
          p_[i][j] += omegap * dp;
        }
      }
      boundaryConditionP();
      res = sqrt(res/(nx*ny));
      if(res < errorp) break;
    }
  }
  
  float KKSchemeX(float u, float[][] f, int i, int j){
    return (u*(-f[i + 2][j] + 8.0*(f[i + 1][j] - f[i - 1][j]) + f[i - 2][j])/(12.0*dx)
          + abs(u)*(f[i + 2][j] - 4.0*(f[i + 1][j] + f[i - 1][j]) + 6.0*f[i][j] + f[i - 2][j])/(4.0*dx));
  }
  
  float KKSchemeY(float v, float[][] f, int i, int j){
    return (v*(-f[i][j + 2] + 8.0*(f[i][j + 1] - f[i][j - 1]) + f[i][j - 2])/(12.0 * dy)
          + abs(v)*(f[i][j + 2] - 4.0*(f[i][j + 1] + f[i][j - 1]) + 6.0*f[i][j] + f[i][j - 2])/(4.0*dy));
  }
  
  void velocityEquation(){
    float[][] urhs = new float[nx + 2][ny + 2];
    float[][] vrhs = new float[nx + 2][ny + 2];
    
    for(int i = 2; i < nx; i++){
      for(int j = 2; j < ny; j++){
        if(withInSquare(i, j)) continue;
        
        urhs[i][j] = -(p_[i + 1][j] - p_[i - 1][j])/(2.0*dx) + 
                      (u_[i + 1][j] - 2.0*u_[i][j] + u_[i - 1][j])/(Re*dx*dx) +
                      (u_[i][j + 1] - 2.0*u_[i][j] + u_[i][j - 1])/(Re*dy*dy) - 
                      KKSchemeX(u_[i][j], u_, i, j) - KKSchemeY(v_[i][j], u_, i, j);
                      
        vrhs[i][j] = -(p_[i][j + 1] - p_[i][j - 1])/(2.0*dy) + 
                      (v_[i + 1][j] - 2.0*v_[i][j] + v_[i - 1][j])/(Re*dx*dx) + 
                      (v_[i][j + 1] - 2.0*v_[i][j] + v_[i][j - 1])/(Re*dy*dy) - 
                      KKSchemeX(u_[i][j], v_, i, j) - KKSchemeY(v_[i][j], v_, i, j);
      }
    }
    
    for(int i = 2; i < nx; i++){
      for(int j = 2; j < ny; j++){
        if(withInSquare(i, j)) continue;
        
        u_[i][j] += dt*urhs[i][j];
        v_[i][j] += dt*vrhs[i][j];
      }
    }
  }
  
  void show(){
    for(int i = 0; i < nx; i++){
      for(int j = 0; j < ny; j++){
        fill(p_[i][j]*3600, 100, 100);
        rect(i*pSize, j*pSize, pSize, pSize);
      }
    }
    fill(360);
    rect(bi1*pSize, bj1*pSize, (bi2-bi1)*pSize, (bj2-bj1)*pSize);
  }
  
  void lin_solve(int b, float[][] x, float[][] x0, float a, float c) {
    float cRecip = 1.0 / c;
    for (int k = 0; k < iter; k++) {
      for (int i = 1; i <= nx; i++) {
        for (int j = 1; j <= ny; j++) {
          //if(!isWall[IX(i, j)]){
          x[i][j] = (x0[i][j]+ a*(x[i+1][j]+x[i-1][j]+x[i][j+1]+x[i][j-1])) * cRecip;
          //}
        }
      }
      boundaryConditionUV();
    }
  }

  void project (){
    float[][] p = new float[nx + 2][ny + 2]; float[][] div = new float[nx + 2][ny + 2];
    float h = 1.0/ (float)ny;
    for(int i = 1; i <= nx; i++){
      for(int j = 1; j <= ny; j++){
        div[i][j] = -0.5*h*(u_[i+1][j]-u_[i-1][j]+v_[i][j+1]-v_[i][j-1]);
        p[i][j] = 0;
      }
    }
    boundaryConditionUV();
    lin_solve(0, p, div, 1, 4);//which is correct 6 or 4
    for(int i = 1; i < nx - 1; i++){
      for(int j = 1; j < ny - 1; j++){
        //if(!isWall[IX(i, j)]){
        u_[i][j] -= 0.5*(p[i+1][j]-p[i-1][j])/h;
        v_[i][j] -= 0.5*(p[i][j+1]-p[i][j-1])/h;
        //}
      }
    }
    boundaryConditionUV();
  }
}