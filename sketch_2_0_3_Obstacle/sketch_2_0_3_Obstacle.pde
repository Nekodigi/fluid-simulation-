int Nx = 384;
int Ny = 216;
int cell_size = 10;
int b = 0;//still undecidet
float dt = 0.2f;
float diff = 0;//density diffusion
float visc = 0.00001;//speed diffusion
int iter = 20;//diffusion sampling
//Brush config
float B_dense = 100;
float B_dense_size = 300;
float B_velocity = 10;
float B_velocity_size = 30;


float t = 0;
float angle = 0;
int size = (Nx+2)*(Ny+2);
float[] dens = new float[size];
float[] s = new float[size];
float[] Vx = new float[size];
float[] Vy = new float[size];
float[] Vx0 = new float[size];
float[] Vy0 = new float[size];



public void setup(){
  fullScreen();
  colorMode(HSB, 360, 100, 100, 100);
}

void draw(){
  background(0);
  //draw and user input
  noStroke();      
  for(int i = 0; i <= Nx; i++){
    for(int j=0; j <= Ny; j++){
      float cx = i*width/Nx;//grid address to position
      float cy = j*height/Ny;
      if(mousePressed){
        dens[IX(i, j)] += constrain(1-dist(mouseX, mouseY, cx, cy)/B_dense_size, 0, 1)*B_dense;
        Vx[IX(i, j)] += constrain(1-dist(mouseX, mouseY, cx, cy)/B_velocity_size, 0, 1)*cos(angle)*B_velocity;
        Vy[IX(i, j)] += constrain(1-dist(mouseX, mouseY, cx, cy)/B_velocity_size, 0, 1)*sin(angle)*B_velocity;
      }
      fill((dens[IX(i, j)]/10)%360, 100, dens[IX(i, j)]/5);
      rect(cx, cy, width/Nx, -height/Ny);
    }
  }
  //draw Cursor
  stroke(360);
  strokeWeight(10);
  line(mouseX, mouseY, mouseX+cos(angle)*100.0, mouseY+sin(angle)*100.0);
  //update Fluid
  fluid_step();
}

void mouseWheel(MouseEvent e ){
  angle += e.getAmount()*0.1;
}

void keyPressed(){
  if(key=='r'){
    for(int i = 0; i<size; i++) dens[i] = 0;
  }
}