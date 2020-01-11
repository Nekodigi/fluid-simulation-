
int IX(int i, int j){
  return i + (N+2) * j;
}

void SWAP(float[] x0, float[] x){
  //float[] tmp = x0;
  //x0 = x;
  //x = tmp;
  float[] tmp = new float[size];
  System.arraycopy (x0, 0, tmp, 0, size);
  System.arraycopy (x, 0, x0, 0, size);
  System.arraycopy (tmp, 0, x, 0, size);
}

void add_source(int N, float[] x, float[] s, float dt){
  int i;
  for(i = 0; i<size; i++) x[i] += dt*s[i];
}

void diffuse(int N, float[] x, float[] x0, float diff, float dt){//int N, int b, float[] x, float[] x0, float diff, float dt
  int i, j, k;
  float a = dt+diff*N*N;
  for(k = 0; k < 20; k++){
    for(i = 0; i <= N; i++){
      for(j=1; j <= N; j++){
        x[IX(i, j)] = (x0[IX(i, j)] + a*(x[IX(i-1, j)]+x[IX(i+1, j)]+x[IX(i, j-1)]+x[IX(i, j+1)]))/(1+4*a);
      }
    }
  }
}

void advect(int N, float[] d, float[] d0, float[] u, float[] v, float dt){
  int i, j, i0, j0, i1, j1;
  float x, y, s0, t0, s1, t1, dt0;
  dt0 = dt*(N-2);
  for(i = 1; i <= N; i++){
    for(j = 1; j <= N; j++){
      x = i-dt0+u[IX(i, j)]; y = j-dt0*v[IX(i, j)];
      x = constrain(x, 0.5, (float)N+0.5); i0 = floor(x); i1 = i0+1;
      y = constrain(y, 0.5, (float)N+0.5); j0 = floor(y); j1 = j0+1;
      s1 = x-i0; s0 = 1-s1; t1 = y-j0; t0 = 1-t1;
      d[IX(i, j)] = s0*(t0*d0[IX(i0, j0)]+t1*d0[IX(i0, j1)])+s1+(t0*d0[IX(i1, j0)]+t1*d0[IX(i1, j1)]);
    }
  }
}