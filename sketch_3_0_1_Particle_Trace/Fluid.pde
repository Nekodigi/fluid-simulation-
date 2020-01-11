void fluid_step(){
  vel_step(Vx, Vy, Vx0, Vy0, visc, dt);
  diffuse(0, s, dens, diff, dt);
  advect(0, dens, s, Vx, Vy, dt);
}

void vel_step(float[] Vx, float []Vy, float[] Vx0, float[] Vy0, float visc, float dt){//visc is diffusion in speed
  diffuse(1, Vx0, Vx, visc, dt);//omit SWAP
  diffuse(2, Vy0, Vy, visc, dt);//Two times omit SWAP is the same as doing Nothing
  project(Vx0, Vy0, Vx, Vy);//However, each time SWAP is omitted, the previous and current are reversed
  advect(1, Vx, Vx0, Vx0, Vy0, dt);//omit SWAP
  advect(2, Vy, Vy0, Vx0, Vy0, dt);
  project(Vx, Vy, Vx0, Vy0);
}