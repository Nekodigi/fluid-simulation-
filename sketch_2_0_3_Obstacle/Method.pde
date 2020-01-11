
int IX(int i, int j){
  i = constrain(i, 0, Nx-1);
  j = constrain(j, 0, Ny-1);
  return i + (j * Nx);
}

void add_source(float[] x, float[] s, float dt){
  for(int i = 0; i<size; i++) x[i] += dt*s[i];
}

void diffuse (int b, float[] x, float[] x0, float diff, float dt) {
  float a = dt * diff * Nx * Ny;
  lin_solve(b, x, x0, a, 1 + 4 * a);//Which is correct 4 or 6
}

void lin_solve(int b, float[] x, float[] x0, float a, float c) {
  float cRecip = 1.0 / c;
  for (int k = 0; k < iter; k++) {
    for (int i = 1; i <= Nx; i++) {
      for (int j = 1; j <= Ny; j++) {
        x[IX(i, j)] = (x0[IX(i, j)]+ a*(x[IX(i+1, j)]+x[IX(i-1, j)]+x[IX(i, j+1)]+x[IX(i, j-1)])) * cRecip;
      }
    }
    set_bnd(b, x);
  }
}

void project (float[] Vx, float[] Vy, float[] Vx0, float[] Vy0){
  float h = 1.0/ (float)Ny;
  for(int i = 1; i <= Nx; i++){
    for(int j = 1; j <= Ny; j++){
      Vy0[IX(i, j)] = -0.5*h*(Vx[IX(i+1, j)]-Vx[IX(i-1, j)]+Vy[IX(i, j+1)]-Vy[IX(i, j-1)]);
      Vx0[IX(i, j)] = 0;
    }
  }
  set_bnd(0, Vy0); set_bnd(0, Vx0);
  lin_solve(0, Vx0, Vy0, 1, 4);//which is correct 6 or 4
  for(int i = 1; i < Nx - 1; i++){
    for(int j = 1; j < Ny - 1; j++){
      Vx[IX(i, j)] -= 0.5*(Vx0[IX(i+1, j)]-Vx0[IX(i-1, j)])/h;
      Vy[IX(i, j)] -= 0.5*(Vx0[IX(i, j+1)]-Vx0[IX(i, j-1)])/h;
    }
  }
  set_bnd(1, Vx); set_bnd(2, Vy);
}

void advect(int b, float[] d, float[] d0, float[] Vx, float[] Vy, float dt){
  int i, j, i0, j0, i1, j1;
  float x, y, s0, t0, s1, t1;
  for(i = 1; i <= Nx; i++){
    for(j = 1; j <= Ny; j++){
      x = (float)i-dt*Nx*Vx[IX(i, j)]; y = (float)j-dt*Ny*Vy[IX(i, j)];
      x = constrain(x, 0.5, (float)Nx+0.5); i0 = floor(x); i1 = i0+1;
      y = constrain(y, 0.5, (float)Ny+0.5); j0 = floor(y); j1 = j0+1;
      s1 = x-(float)i0; s0 = 1.0-s1; t1 = y-(float)j0; t0 = 1-t1;
      d[IX(i, j)] = s0*(t0*d0[IX(i0, j0)]+t1*d0[IX(i0, j1)])+s1*(t0*d0[IX(i1, j0)]+t1*d0[IX(i1, j1)]);
    }
  }
  set_bnd(b, d);
}

void set_bnd(int b, float[] x) {
  for (int i = 1; i < Nx - 1; i++) {
    x[IX(i, 0  )] = b == 2 ? -x[IX(i, 1  )] : x[IX(i, 1 )];
    x[IX(i, Ny-1)] = b == 2 ? -x[IX(i, Ny-2)] : x[IX(i, Ny-2)];
  }
  for (int j = 1; j < Ny - 1; j++) {
    x[IX(0, j)] = b == 1 ? -x[IX(1, j)] : x[IX(1, j)];
    x[IX(Nx-1, j)] = b == 1 ? -x[IX(Nx-2, j)] : x[IX(Nx-2, j)];
  }

  x[IX(0, 0)] = 0.5f * (x[IX(1, 0)] + x[IX(0, 1)]);
  x[IX(0, Ny-1)] = 0.5f * (x[IX(1, Ny-1)] + x[IX(0, Ny-2)]);
  x[IX(Nx-1, 0)] = 0.5f * (x[IX(Nx-2, 0)] + x[IX(Nx-1, 1)]);
  x[IX(Nx-1, Ny-1)] = 0.5f * (x[IX(Nx-2, Ny-1)] + x[IX(Nx-1, Ny-2)]);
}