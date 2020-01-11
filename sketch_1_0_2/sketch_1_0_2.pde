int N = 50;
int b = 0;//still undecidet
float dt = 0.01;
float diff = 0.0001;

float angle = 0;
int size = (N+2)*(N+2);
float[] dens = new float[size];
float[] s = new float[size];
float[] u = new float[size];
float[] v = new float[size];



void setup(){
  size(2000, 2000);
}

void draw(){
  background(255);
  //add_source(N, x, x0, dt);
  noStroke();      
  for(int i = 0; i <= N; i++){
    for(int j=1; j <= N; j++){
      float cx = i*width/N;//grid address to position
      float cy = j*height/N;
      if(mousePressed){
        dens[IX(i, j)] = constrain(dens[IX(i, j)]+constrain(100-dist(mouseX, mouseY, cx, cy), 0, 100)*2.55, 0, 255);
      }
      fill(dens[IX(i, j)]);
      rect(cx, cy, width/N, -height/N);
    }
  }
  for(int i = 0; i <= N; i++){
    for(int j=1; j <= N; j++){
      float cx = (i+0.5)*width/N;//grid address to position
      float cy = (j+0.5)*height/N;
      if(mousePressed){
        u[IX(i, j)] = constrain(u[IX(i, j)]+constrain(1-dist(mouseX, mouseY, cx, cy)*0.01, 0, 1)*cos(angle), -1, 1);
        v[IX(i, j)] = constrain(v[IX(i, j)]+constrain(1-dist(mouseX, mouseY, cx, cy)*0.01, 0, 1)*sin(angle), -1, 1);
      }
      stroke(255);
      strokeWeight(1);
      line(cx, cy, cx+u[IX(i, j)]*width/N, cy+v[IX(i, j)]*width/N);
      strokeWeight(10);
      
      line(mouseX, mouseY, mouseX+cos(angle)*100, mouseY+sin(angle)*100);
    }
  }
  diffuse(N, s, dens, diff, dt);
  SWAP(s, dens);
  //advect(N, dens, s, u, v, dt);
}

void mouseWheel(MouseEvent e ){
  angle += e.getAmount()*0.1;
}

void keyPressed(){
  if(key=='r'){
    for(int i = 0; i<size; i++) dens[i] = 0;
  }
}