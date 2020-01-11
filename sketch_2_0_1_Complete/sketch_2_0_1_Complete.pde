int N = 128;
int b = 0;//still undecidet
float dt = 0.2;
float diff = 0;
float visc = 0;
int iter = 20;

float t = 0;
float angle = 0;
int size = (N+2)*(N+2);
float[] dens = new float[size];
float[] s = new float[size];
float[] Vx = new float[size];
float[] Vy = new float[size];
float[] Vx0 = new float[size];
float[] Vy0 = new float[size];



void setup(){
  size(2000, 2000);
  colorMode(HSB, 360, 100, 100, 100);
}

void draw(){
  background(0);
  noStroke();      
  for(int i = 0; i <= N; i++){
    for(int j=0; j <= N; j++){
      float cx = i*width/N;//grid address to position
      float cy = j*height/N;
      if(mousePressed){
        dens[IX(i, j)] = constrain(100-dist(mouseX, mouseY, cx, cy)*1, 0, 100)*100;
        Vx[IX(i, j)] = constrain(Vx[IX(i, j)]+constrain(5-dist(mouseX, mouseY, cx, cy)*0.3, 0, 5)*cos(angle), -10, 10);
        Vy[IX(i, j)] = constrain(Vy[IX(i, j)]+constrain(5-dist(mouseX, mouseY, cx, cy)*0.3, 0, 5)*sin(angle), -10, 10);
      }
      fill((dens[IX(i, j)]/10)%360, 100, dens[IX(i, j)]/5);
      rect(cx, cy, width/N, -height/N);
    }
  }
  stroke(360);
  strokeWeight(10);
  line(mouseX, mouseY, mouseX+cos(angle)*100.0, mouseY+sin(angle)*100.0);

  int cx = int(N*0.5);
  int cy = int(N*0.5);
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      //addDensity(cx+i, cy+j, random(50, 150));
    }
  }
  for (int i = 0; i < 2; i++) {
    float angle = noise(t) * TWO_PI * 2;
    PVector v = PVector.fromAngle(angle);
    v.mult(0.2);
    t += 0.01;
    //addVelocity(cx, cy, v.x, v.y );
  }
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