class Fluid {
  ArrayList<Particle> particles;
  PVector gravity;
  float timestep;
  float kernalRadius;
  float stiffness;
  float stiffnessNear;
  float referenceDensity;
  float linearDependence;
  float quadraticDependence;
  Grid grid;

  Fluid(float _timestep, float _kernalRadius) {
    particles = new ArrayList<Particle>();
    gravity = new PVector(0, 0.01);
    gravity.mult(_timestep);
    this.timestep = _timestep;
    this.kernalRadius = _kernalRadius;
    stiffness = 0.008;
    stiffnessNear = 0.01;
    referenceDensity = 10;
    linearDependence = 0;
    quadraticDependence = 0;
    grid = new Grid(width, height, _kernalRadius);
  }

  void Update() {
    for (Particle p : particles) {
      p.velocity.add(gravity);
    }

    for (int i = 0; i < particles.size(); i++) {
      for (int j = i + 1; j < particles.get(i).neighbors.size(); j++) {
        Particle p = particles.get(i);
        Particle pNeighbor = particles.get(i).neighbors.get(j);

        if (pNeighbor == p)
          continue;

        PVector pToPNeighbor = PVector.sub(pNeighbor.position, p.position);
        float pToPNeighborLength = pToPNeighbor.mag();
        float smoothingRadiusRatio = pToPNeighborLength / kernalRadius;

        if (smoothingRadiusRatio < 1) {
          PVector normalizedVector = pToPNeighbor.copy().normalize();
          float inwardRadialVelocity = PVector.dot(PVector.sub(p.velocity, pNeighbor.velocity), normalizedVector);

          if (inwardRadialVelocity > 0) {
            float strengthOfImpulse = timestep * (1 - smoothingRadiusRatio) * (linearDependence * inwardRadialVelocity + quadraticDependence * inwardRadialVelocity * inwardRadialVelocity);
            PVector impulse = pToPNeighbor.mult(strengthOfImpulse / 2);
            p.velocity.sub(impulse);
            pNeighbor.velocity.add(impulse);
          }
        }
      }
    }

    for (Particle p : particles) {
      p.previousPosition = p.position.copy();
      p.position.add(PVector.mult(p.velocity, timestep));
    }

    grid.ClearGrid();
    for (Particle p : particles) {
      grid.AddParticle(p);
    }

    if (visualizeInteractions)
      grid.Render();

    for (Particle p : particles) {
      p.FindNeighborsInGrid(grid);
      p.density = 0;
      p.densityNear = 0;

      for (Particle pNeighbor : p.neighbors) {
        if ((pNeighbor != p) ) {
          PVector pToPNeighbor = PVector.sub(pNeighbor.position, p.position);
          float pToPNeighborLength = pToPNeighbor.mag();
          float smoothingRadiusRatio = pToPNeighborLength / kernalRadius;

          if (smoothingRadiusRatio < 1) {
            float pNeighborToKernalRatio = 1 - smoothingRadiusRatio;
            float powerOfPNeighborToKernalRatio = pNeighborToKernalRatio * pNeighborToKernalRatio;
            p.density += powerOfPNeighborToKernalRatio;
            powerOfPNeighborToKernalRatio *= pNeighborToKernalRatio;
            p.densityNear += powerOfPNeighborToKernalRatio;
          }
        }
      }

      p.pressure = stiffness * (p.density - referenceDensity);
      p.pressureNear = stiffnessNear * p.densityNear;

      p.displacementPosition.mult(0);
      for (Particle pNeighbor : p.neighbors) {
        PVector pToPNeighbor = PVector.sub(pNeighbor.position, p.position);
        float pToPNeighborLength = pToPNeighbor.mag();
        float smoothingRadiusRatio = pToPNeighborLength / kernalRadius;

        if (smoothingRadiusRatio < 1) {
          PVector displacement = pToPNeighbor.normalize();
          displacement.mult(timestep * timestep * (p.pressure * (1 - smoothingRadiusRatio) + p.pressureNear * (1 - smoothingRadiusRatio) * (1 - smoothingRadiusRatio)));
          displacement.div(2);
          pNeighbor.position.add(displacement);
          p.displacementPosition.sub(displacement);
        }
      }
      p.position.add(p.displacementPosition);
    }

    for (Particle p : particles) {
      if (p.position.x < 0) p.position.x = 1;
      if (p.position.x > width) p.position.x = width-1;
      if (p.position.y > height) p.position.y = height-1;
    }

    for (Particle p : particles) {
      p.velocity = PVector.sub(p.position, p.previousPosition);
      p.velocity.div(timestep);
    }
  }

  void Render() {
    for (Particle p : particles) {
      p.Render();
    }
  }
}
