class Object {
  PVector position;
  PVector velocity;
  float rectWidth;
  float rectHeight;
  Fluid fluid;
  Grid grid;
  ArrayList<Cell> overlappingCells;
  ArrayList<Particle> collidingParticles;
  float buoyancyCoefficient;
  float buoyancyForce;
  float volume;
  float mass;
  float objectDensity;
  float restitution;
  float timestep;

  Object(float _x, float _y, float _rectWidth, float _rectHeight, Fluid _fluid, float _timestep) {
    position = new PVector(_x, _y);
    velocity = new PVector(0, 0);
    rectWidth = _rectWidth;
    rectHeight = _rectHeight;
    fluid = _fluid;
    grid = fluid.grid;
    overlappingCells = new ArrayList<Cell>();
    collidingParticles = new ArrayList<Particle>();
    volume = rectWidth * rectHeight;
    objectDensity = 7;
    mass = objectDensity * volume;
    restitution = 0;
    timestep = _timestep;
  }

  void Update() {
    ResolveCollision();
    GetCellsAndParticles();

    float submergedDensity = 0;
    float submergedVolume = 0;

    for (Particle p : collidingParticles) {
      submergedDensity += p.density;
      submergedVolume += p.mass;
    }

    if (submergedDensity > 0) {
      buoyancyForce = submergedDensity * submergedVolume * fluid.gravity.y;
      PVector buoyancyAcceleration = PVector.div(PVector.mult(fluid.gravity, -1), mass);
      buoyancyAcceleration.mult(buoyancyForce);
      velocity.add(PVector.mult(buoyancyAcceleration, timestep));
    }

    velocity.add(PVector.mult(fluid.gravity, timestep));
    position.add(PVector.mult(velocity, timestep));
  }



  void Render() {
    fill(125, 125, 125, 20);
    strokeWeight(3);
    stroke(0);
    rect(position.x, position.y, rectWidth, rectHeight);
  }

  void ResolveCollision() {
    for (Particle p : collidingParticles) {
      float distX = abs(p.position.x - position.x - rectWidth/2);
      float distY = abs(p.position.y - position.y - rectHeight/2);

      if (distX > (rectWidth/2 + p.radius) || distY > (rectHeight/2 + p.radius))
        continue;

      float penetrationDepthX = (rectWidth/2 + p.radius) - distX;
      float penetrationDepthY = (rectHeight/2 + p.radius) - distY;
      PVector normal = new PVector();

      if (penetrationDepthX < penetrationDepthY)
        normal.x = -Math.signum(p.position.x - position.x - rectWidth/2);
      else
        normal.y = -Math.signum(p.position.y - position.y - rectHeight/2);

      PVector relativeVelocity = PVector.sub(p.velocity, velocity);
      float normalRelativeVelocity = PVector.dot(relativeVelocity, normal);

      if (normalRelativeVelocity > 0)
        continue;

      float impulseMagnitude = -(1 + restitution) * normalRelativeVelocity;
      impulseMagnitude /= 1 / mass + 1 / p.mass;

      PVector impulse = PVector.mult(normal, impulseMagnitude);
      velocity.sub(PVector.mult(impulse, 1 / mass));
    }

    if (position.x - rectWidth < 0) {
      velocity.x = 0;
      position.x = rectWidth;
    }
    if (position.x + rectWidth > width) {
      velocity.x = 0;
      position.x = width - rectWidth;
    }
    if (position.y + rectHeight > height) {
      velocity.y = 0;
      position.y = height - rectHeight;
    }
  }

  void GetCellsAndParticles() {
    overlappingCells.clear();
    collidingParticles.clear();

    for (Cell c : grid.GetOverlappingCells(position.x, position.y, rectWidth, rectHeight))
      overlappingCells.add(c);

    for (Cell c : overlappingCells) {
      for (Particle p : c.particles) {
        float distX = abs(p.position.x - position.x - rectWidth / 2);
        float distY = abs(p.position.y - position.y - rectHeight / 2);

        if (distX > (rectWidth / 2 + p.radius) || distY > (rectHeight / 2 + p.radius))
          p.isInsideObject = false;
        else if (distX <= (rectWidth / 2) && distY <= (rectHeight / 2))
          p.isInsideObject = true;
        else {
          float cornerDistance = (distX - rectWidth / 2) * (distX - rectWidth / 2) +
            (distY - rectHeight / 2) * (distY - rectHeight / 2);
          p.isInsideObject = (cornerDistance <= (p.radius * p.radius));
        }

        if (p.isInsideObject)
          if (!collidingParticles.contains(p))
            collidingParticles.add(p);
      }
    }
  }
}
