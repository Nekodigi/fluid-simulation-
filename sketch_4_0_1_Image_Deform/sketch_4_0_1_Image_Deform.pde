int Nx = 192;
int Ny = 108;
int cell_size = 10;
int b = 0;//still undecidet
float dt = 0.2f;
float diff = 0;//density diffusion
float visc = 0.00001;//speed diffusion
int iter = 20;//diffusion sampling
//Brush config
float B_dense = 100;
float B_dense_size = 300;
float B_velocity = 1;
float B_velocity_size = 50;
int resI = Nx, resJ = Ny;
float moveP = 20;

PImage img;
MeshDeform meshDeform;


float t = 0;
float angle = 0;
int size = (Nx+2)*(Ny+2);
float[] dens = new float[size];
float[] s = new float[size];
float[] Vx = new float[size];
float[] Vy = new float[size];
float[] Vx0 = new float[size];
float[] Vy0 = new float[size];

ArrayList<Particle> particles = new ArrayList<Particle>();

public void setup(){
  fullScreen(P3D);
  img = loadImage("FevCat.png");
  //img.resize(200, 200);//reduce resolution for high speed processing
  meshDeform = new MeshDeform(img, resI, resJ, new PVector(0, 0), new PVector(width, height));
  colorMode(HSB, 360, 100, 100, 100);
  background(0);
}

void draw(){
  fill(0, 1);
  noStroke();  
  rect(0, 0, width, height);
  //background(0);
  //draw and user input    
  for(int i = 0; i <= Nx; i++){
    for(int j=0; j <= Ny; j++){
      float cx = i*width/Nx;//grid address to position
      float cy = j*height/Ny;
      if(mousePressed){
        dens[IX(i, j)] += constrain(1-dist(mouseX, mouseY, cx, cy)/B_dense_size, 0, 1)*B_dense;
        Vx[IX(i, j)] += constrain(1-dist(mouseX, mouseY, cx, cy)/B_velocity_size, 0, 0.1)*cos(angle)*B_velocity;
        Vy[IX(i, j)] += constrain(1-dist(mouseX, mouseY, cx, cy)/B_velocity_size, 0, 0.1)*sin(angle)*B_velocity;
      }
      //fill((dens[IX(i, j)]/10)%360, 100, dens[IX(i, j)]/5);
      //rect(cx, cy, width/Nx, -height/Ny);
    }
  }
  //draw Cursor
  stroke(360, 50);
  strokeWeight(3);
  line(mouseX, mouseY, mouseX+cos(angle)*50.0, mouseY+sin(angle)*50.0);
  //update Fluid
  if(mousePressed){
    for(int i = 0; i < 100; i++){
      particles.add(new Particle(new PVector(mouseX+random(-B_velocity_size, B_velocity_size), mouseY+random(-B_velocity_size, B_velocity_size))));
    }
  }
  //noStroke();
  //for(Particle particle : particles){
  //  int index = IX(int(particle.pos.x*Nx/width),int(particle.pos.y*Ny/height));
  //  float tVx = Vx[index];
  //  float tVy = Vy[index];
  //  particle.pos.add(tVx*300, tVy*300);
  //  fill(sqrt(tVx*tVx+tVy*tVy)*2000, 100, 100, 50);
  //  rect(particle.pos.x, particle.pos.y, 5, 5);
  //}
  fluid_step();
  PVector[][] target = meshDeform.ctrPoss;
  for(int i=0; i<target.length; i++){
    for(int j=0; j<target[0].length; j++){
      PVector tg = target[i][j];
      int fi = constrain((int)map(tg.x, 0, width, 0, Nx), 0, Nx-1);
      int fj = constrain((int)map(tg.y, 0, height, 0, Ny), 0, Ny-1);
      int index = IX(fi, fj);
      tg.add(Vx[index]*moveP, Vy[index]*moveP);
    }
  }
  noStroke();
  meshDeform.show();
}

void mouseWheel(MouseEvent e ){
  angle += e.getAmount()*0.1;
}

void keyPressed(){
  if(key=='r'){
    for(int i = 0; i<size; i++) dens[i] = 0;
    particles = new ArrayList<Particle>();
    background(0);
  }
}
