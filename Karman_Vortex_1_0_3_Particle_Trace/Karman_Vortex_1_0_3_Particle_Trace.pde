float pSize = 5;
int iter = 1;
Karman karman;

void setup(){
  size(1000, 500);
  //fullScreen();
  colorMode(HSB, 360, 100, 100);
  karman = new Karman();
  karman.boundaryConditionP();
  karman.boundaryConditionUV();
  noStroke();
  background(360);
}

void draw(){
  for(int i = 0; i < iter; i++){
    karman.poissonEquation();
    karman.project();//don't have to
    karman.velocityEquation();
    karman.boundaryConditionUV();
    karman.project();//don't have to
  }
  karman.show();
}