// Authors: 
// Lucía Medina Gómez
// Maria Assumpció Campos Martínez 

// Problem description:
// Billar francés

final float SIM_STEP = 0.01;   // Simulation time-step (s)
float _simTime = 0.0;   // Simulated time (s)

ParticleSystem _system;   // Particle system
ArrayList<PlaneSection> _planes;    // Planes representing the limits
boolean _computePlaneCollisions = true;

// Billar
float alto = 1.42; // metros
float ancho = 2.82; // metros

float mesaX = 300.0;
float mesaY = 300.0;

final boolean FULL_SCREEN = false;
int DISPLAY_SIZE_X = 1800;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1000;   // Display height (pixels)
final int [] BACKGROUND_COLOR = {10, 10, 25};

final float PIXELS_PER_METER = 400.0;   // Display length that corresponds with 1 meter (pixels)
final PVector DISPLAY_CENTER = new PVector(0.0, 0.0);   // World position that corresponds with the center of the display (m)

final int numBolas = 5; // number of balls

void settings()
{
  if (FULL_SCREEN)
  {
    fullScreen();
    DISPLAY_SIZE_X = displayWidth;
    DISPLAY_SIZE_Y = displayHeight;
  } 
  else
    size(DISPLAY_SIZE_X, DISPLAY_SIZE_Y);
}

void setup()
{
  initSimulation();
}

void initSimulation()
{
  // Creamos un sistema y un plano
  _system = new ParticleSystem();
  _planes = new ArrayList<PlaneSection>();
  
  ancho = worldToPixels(ancho);
  alto = worldToPixels(alto); 
  
  float radio = 0.03075;
  radio = worldToPixels(radio);
  float masa = 0.210;
  
  float velocidadX, velocidadY;
     
  for (int i = 0; i < numBolas; i++)
  {    
    // Creamos las bolas en posiciones aleatorias
    float posicionX = random(mesaX+10.0, ancho+mesaX-10.0);
    float posicionY = random(mesaY+10.0, alto+mesaY-10.0);
    
    // La velocidad inicial es 0
    velocidadX = 0;
    velocidadY = 0; 
    
    PVector initpos = new PVector(posicionX, posicionY);
    PVector initvel = new PVector(velocidadX, velocidadY);
   
   // Añadimos las partículas al sistema correspondiente
    _system.addParticle(i, initpos, initvel, masa, radio);
  }
  
  // Creamos el tablero de la mesa
  //arriba
  PlaneSection ps = new PlaneSection(mesaX, mesaY, ancho+mesaX, mesaY, true);
  //abajo
  PlaneSection ps2 = new PlaneSection(mesaX, alto+mesaY, ancho+mesaX, alto+mesaY, false);
  //izquierda
  PlaneSection ps3 = new PlaneSection(mesaX, mesaY, mesaX, alto+mesaY, false);
  //derecha
  PlaneSection ps4 = new PlaneSection(ancho+mesaX, mesaY, ancho+mesaX, alto+mesaY, true);
  
  _planes.add(ps);
  _planes.add(ps2);
  _planes.add(ps3);
  _planes.add(ps4);
}

void restartSimulation()
{
  _system = new ParticleSystem();
  _planes = new ArrayList<PlaneSection>();
    
  float radio = 0.03075;
  radio = worldToPixels(radio);
  float masa = 0.210;
  
  float velocidadX, velocidadY;
     
  for (int i = 0; i < numBolas; i++)
  {    
    float posicionX = random(mesaX+10.0, ancho+mesaX-10.0);
    float posicionY = random(mesaY+10.0, alto+mesaY-10.0);
    
    velocidadX = 0;
    velocidadY = 0; 
    
    PVector initpos = new PVector(posicionX, posicionY);
    PVector initvel = new PVector(velocidadX, velocidadY);
   
    _system.addParticle(i, initpos, initvel, masa, radio);
  }
  
  //arriba
  PlaneSection ps = new PlaneSection(mesaX, mesaY, ancho+mesaX, mesaY, true);
  //abajo
  PlaneSection ps2 = new PlaneSection(mesaX, alto+mesaY, ancho+mesaX, alto+mesaY, false);
  //izquierda
  PlaneSection ps3 = new PlaneSection(mesaX, mesaY, mesaX, alto+mesaY, false);
  //derecha
  PlaneSection ps4 = new PlaneSection(ancho+mesaX, mesaY, ancho+mesaX, alto+mesaY, true);
  
  _planes.add(ps);
  _planes.add(ps2);
  _planes.add(ps3);
  _planes.add(ps4);
}
void drawStaticEnvironment()
{
  fill(34,139,34);
  rect(mesaX, mesaY, ancho, alto);
  
  _planes.get(0).draw();
  _planes.get(1).draw();
  _planes.get(2).draw();
  _planes.get(3).draw();
}

void draw() 
{  
  drawStaticEnvironment();
    
  _system.run();
  _system.computeCollisions(_planes, _computePlaneCollisions);  
  _system.display();  

  _simTime += SIM_STEP;
  
}
// Converts distances from world length to pixel length
float worldToPixels(float dist)
{
  return dist*PIXELS_PER_METER;
}

// Converts distances from pixel length to world length
float pixelsToWorld(float dist)
{
  return dist/PIXELS_PER_METER;
}

// Converts a point from world coordinates to screen coordinates
void worldToScreen(PVector worldPos, PVector screenPos)
{
  screenPos.x = 0.5*DISPLAY_SIZE_X + (worldPos.x - DISPLAY_CENTER.x)*PIXELS_PER_METER;
  screenPos.y = 0.5*DISPLAY_SIZE_Y - (worldPos.y - DISPLAY_CENTER.y)*PIXELS_PER_METER;
}

// Converts a point from screen coordinates to world coordinates
void screenToWorld(PVector screenPos, PVector worldPos)
{
  worldPos.x = ((screenPos.x - 0.5*DISPLAY_SIZE_X)/PIXELS_PER_METER) + DISPLAY_CENTER.x;
  worldPos.y = ((0.5*DISPLAY_SIZE_Y - screenPos.y)/PIXELS_PER_METER) + DISPLAY_CENTER.y;
}

void mouseClicked() 
{
  PVector mouse = new PVector(mouseX, mouseY, 0.0);
  if(mouse.y <= (alto + mesaY) && mouse.y >= mesaY && mouse.x <= (ancho + mesaX) && mouse.x >= mesaX)
    _system.clickBall(mouse);
}

void keyPressed()
{
  // random velocity
  if (key == 'a' || key == 'A')
    _system.randomVelocity();
  // Colisiones
  if (key == 'c' || key == 'C')
  {
    if(_computePlaneCollisions)
      _computePlaneCollisions = false;
    else
      _computePlaneCollisions = true;
  }
  // Mover todas las bolas a una esquina
  else if (key == 'p' || key == 'P')
    _system.goToCorner();
  else if (key == 'r' || key == 'R')
    _system.restart();
  // stop the simulation
  else if (key == 's' || key == 'S')
    stop();

}
  
void stop()
{
  exit();
}
