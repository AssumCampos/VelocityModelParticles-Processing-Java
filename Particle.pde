class Particle  //<>//
{
  ParticleSystem _ps;
  int _id;

  PVector _s;
  PVector _v;
  PVector _a;
  PVector _f;

  float _m = 0.210; // kg
  float _radius = 0.03075; // metros
  color _color;
    
  Particle(ParticleSystem ps, int id, PVector initPos, PVector initVel, float mass, float radius) 
  {
    _ps = ps;
    _id = id;

    _s = initPos.copy();
    _v = initVel.copy();
    _a = new PVector(0.0, 0.0);
    _f = new PVector(0.0, 0.0);

    _m = mass;
    _radius = radius;
    _color = color(random(255),random(255),random(255));
  }
  
  PVector getPosition(){
    return _s;
  }
  float getRadius()
  {
    return _radius;
  }
  
  int getId()
  {
    return _id;
  }
  void update() 
  {  
    updateForce();
    _a = PVector.div(_f,_m);
   
    _s.add(PVector.mult(_v,SIM_STEP));
    _v.add(PVector.mult(_a,SIM_STEP));
  }

  void updateForce()
  {     
    // Rozamiento bola / mesa
    PVector Fbt = new PVector();
    Fbt = PVector.mult(_v, -_ps.Kd);
    _f.set(Fbt);
  }
  
  void display() 
  {
    noStroke();
    fill(_color);
    circle(_s.x, _s.y, 2.0*_radius);
  }
  
  void planeCollision(ArrayList<PlaneSection> planes)
  { 
    Boolean colision = false;
    int i = 0;
    
    // arriba
    if(planes.get(0).getPoint1().y + this.getRadius() >= this.getPosition().y)
    {
      colision = true;
      i = 0;
    }
     
    // abajo
    else if (planes.get(1).getPoint1().y - this.getRadius() <= this.getPosition().y)
    {
      colision = true;
      i = 1;
    }
    // izquierda
    else if (planes.get(2).getPoint1().x + this.getRadius() >= this.getPosition().x)
    {
      colision = true;
      i = 2;
    }
    // derecha
    else if (planes.get(3).getPoint1().x - this.getRadius() <= this.getPosition().x)
    {
      colision = true;
      i = 3;
    }
    
    if (colision)
    {
      collisionBallPlanes(planes, i);
    }    
  } 

  void particleCollisionVelocityModel(Particle p)
  {
    // DETECCION
    PVector d = PVector.sub(this.getPosition(), p.getPosition());
    float dist = d.mag();
    
    // dist = (p2 - p1).magnitude() < r1 + r2
    if (dist < (this.getRadius() + p.getRadius()))
    {
      colisionBallBall(p, d, dist);
    }
  }
   // forces elastiques
  void particleCollisionSpringModel()
  { 
  }
  
  void collisionBallPlanes(ArrayList<PlaneSection> planes, int i)
  {
    PVector pp = PVector.sub(planes.get(i).getPoint1(), this.getPosition());
    float dcol = pp.dot(planes.get(i).getNormal());
    
    if (abs(dcol) <= this.getRadius())
    {
      // Reposicionamiento
      float drestitucion = this.getRadius() - abs(dcol);
      PVector delta_pos = planes.get(i).getNormal().copy().mult(drestitucion);
      _s.add(delta_pos);
    
      // Velocidad
      float vn = _v.dot(planes.get(i).getNormal());
      PVector Vn = planes.get(i).getNormal().copy().mult(vn);
      PVector Vt = PVector.sub(_v, Vn);
      _v = PVector.sub(Vt, Vn.mult(_ps.Cr1));
    }
  }
  
  void colisionBallBall(Particle p, PVector d, float dist){
    PVector unitD = new PVector();
    unitD.set(d);
    unitD.normalize();
    
    // DESCOMPOSICIÓN DE LA VELOCIDAD INICIAL EN NORMAL Y TANGENCIAL AL VECTOR DE COLISION
    // velocidad.project(dist);
    PVector norm1 = PVector.mult(unitD, (_v.dot(d) / dist));
    // tangencial = velocidad - normal;
    PVector tan1 = PVector.sub(_v, norm1);
    
    // velocidad.project(dist);
    PVector norm2 = PVector.mult(unitD, (p._v.dot(d)  / dist));
    // tangencial = velocidad - normal;
    PVector tan2 = PVector.sub(p._v, norm2);
    
    // RESTITUCIÓN
    //L = r1 + r2 - dist.magnitude()
    float L = this.getRadius() + p.getRadius() - dist;
    
    //vrel = (normalp1 ?-normalp2).magnitude()
    PVector res = PVector.sub(norm1, norm2);
    float vrel = res.mag();
    
    //p1 = p1.addScaled(norm1,-L/vrel)
    PVector multN1 = PVector.mult(norm1, -L / vrel);
    _s.add(multN1);
    //p2 = p2.addScaled(norm2,-L/vrel)
    PVector multN2 = PVector.mult(norm2, -L / vrel);
    p._s.add(multN2);
    
    // VELOCIDADES DE SALIDA
    float m1 = _m;
    float m2 = _m;
    
    // u1 = normal.projection(dist)
    float u1 = norm1.dot(d) / dist; 
    float u2 = norm2.dot(d) / dist;
    
    //v1 = ((m1-m2)*u1 + 2*m2*u2) / (m1+m2);
    float v1 = ((m1-m2)*u1 + 2*m2*u2) / (m1+m2);
    // dist.para(v1);
    norm1 = PVector.mult(unitD, v1);
    
    //v2 = ((m1-m2)*u1 + 2*m2*u2) / (m1+m2);
    float v2 = ((m2-m1)*u2 + 1*m1*u1) / (m1+m2);
    // dist.para(v2);
    norm2 = PVector.mult(unitD, v2);
    
    //v'= normal' + tangencial
    _v = PVector.mult(PVector.add(norm1, tan1), _ps.Cr2);
    p._v = PVector.mult(PVector.add(norm2, tan2), _ps.Cr2);
  }
}
