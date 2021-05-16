class ParticleSystem 
{
  ArrayList<Particle> _particles;
  int _n;
    
  // Kd : Rozamiento entre bolas y superficie mesa
  //      Linealmente proporcional a la velocidad de las bolas
  // Cr1: Entre 0 y 1
  //      Pérdida de energía por cada colisión de cada bola con las bandas de la mesa
  // Cr2: Entre 0 y 1
  //      Pérdida de eneergía entre colisión de bolas
  
  float Kd = 0.09;
  float Cr1 = 0.95;
  float Cr2 = 0.95;
  
  //Argumentos añadidos por nosotras
  ParticleSystem()  
  {
    _particles = new ArrayList<Particle>();
    _n = 0;
    Kd = 0.09;
  }

  void addParticle(int id, PVector initPos, PVector initVel, float mass, float radius) 
  { 
    Particle p = new Particle(this, id, initPos, initVel, mass, radius);
    _particles.add(p);
    _n++;
  }
  
  void restart()
  {
    restartSimulation();
  }

  
  int getNumParticles()
  {
    return _n;
  }
  
  ArrayList<Particle> getParticleArray()
  {
    return _particles;
  }

  void run() 
  {
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);
      p.update();
    }
  }
  
  void computeCollisions(ArrayList<PlaneSection> planes, boolean computeParticleCollision) 
  { 
    if (computeParticleCollision)
      for(int i = 0; i < getNumParticles(); i++)
      {
        _particles.get(i).planeCollision(planes);
        for(int j = 0; j < getNumParticles(); j++)
          if (_particles.get(i).getId() != _particles.get(j).getId())
            _particles.get(i).particleCollisionVelocityModel(_particles.get(j));
      }   
  }
    
  void display() 
  {
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);      
      p.display();
    }    
  }
  
  void randomVelocity()
  {
    PVector velocity;
    float velocityX, velocityY;

    for (int i = 0; i < getNumParticles(); i++)
    {
      Particle p = _particles.get(i);
      velocityX = random (-1000, 1000);
      velocityY = random (-1000, 1000);
      velocity = new PVector(velocityX, velocityY);
      p._v = velocity;
    }
  }
  void clickBall(PVector ballMouse)
  {
    // Comprobamos si el usuario clicka una bola o quiere crear una
    boolean createBall = true;
    
    for (int i = 0; i < getNumParticles(); i++)
    {
      Particle p = _particles.get(i);
      PVector position = p.getPosition();
      
      // Comprobamos no solo el centro de la bola sino sus 4 partes
      PVector positionAndRadio1 = new PVector(position.x + p.getRadius(), position.y + p.getRadius());
      PVector positionAndRadio2 = new PVector(position.x + p.getRadius(), position.y - p.getRadius());
      PVector positionAndRadio3 = new PVector(position.x - p.getRadius(), position.y - p.getRadius());
      PVector positionAndRadio4 = new PVector(position.x - p.getRadius(), position.y + p.getRadius());

      if ((ballMouse.x >= position.x && ballMouse.x <= positionAndRadio1.x && ballMouse.y >= position.y && ballMouse.y <= positionAndRadio1.y) ||
      (ballMouse.x >= position.x && ballMouse.x <= positionAndRadio2.x && ballMouse.y <= position.y && ballMouse.y >= positionAndRadio2.y) ||
      (ballMouse.x <= position.x && ballMouse.x >= positionAndRadio3.x && ballMouse.y <= position.y && ballMouse.y >= positionAndRadio3.y) ||
      (ballMouse.x <= position.x && ballMouse.x >= positionAndRadio4.x && ballMouse.y >= position.y && ballMouse.y <= positionAndRadio4.y))
      {
        PVector velocity;
        float velocityX, velocityY;
        velocityX = random (-1000, 1000);
        velocityY = random (-1000, 1000);

        velocity = new PVector (velocityX, velocityY);
        
        p._v = velocity;
        createBall = false;
      }
    }
    // Si el usuario no ha clickado una bola, creamos una nueva
    if (createBall)
    {
        float velocityX = random (-1000, 1000);
        float velocityY = random (-1000, 1000);
        PVector velocity = new PVector (velocityX, velocityY);
        
        float radio = 0.03075;
        radio = worldToPixels(radio);
        float masa = 0.210;
  
        addParticle(getNumParticles()+1, ballMouse, velocity, masa, radio);
    }
  }
  void goToCorner()
  {
    PVector velocity;
    float velocityX, velocityY;
    
    // Recorremos todas las bolas para cambiar su velocidad hacia la esquina de abajo izquierda
    for (int i = 0; i < getNumParticles(); i++)
    {
      Particle p = _particles.get(i);
      velocityX = mesaX - p._s.x;
      velocityY = alto+mesaY - p._s.y; 
      velocity = new PVector(velocityX, velocityY);
      p._v.set(velocity);
    }
  }
}
