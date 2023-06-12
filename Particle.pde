class Particle {
  PVector position;
  PVector previousPosition;
  PVector velocity;
  ArrayList<Particle> neighbors;
  float density;
  float densityNear;
  float pressure;
  float pressureNear;
  float radius;
  PVector displacementPosition;
  float mass;
  boolean isInsideObject;

  Particle(float _x, float _y, float _radius) {
    position = new PVector(_x, _y);
    velocity = new PVector();
    neighbors = new ArrayList<Particle>();
    density = 0;
    densityNear = 0;
    radius = _radius;
    displacementPosition = new PVector(0, 0);
    mass = PI * radius * radius;
  }

  void Render() {
    if (!visualizeInteractions)
      stroke(145, 255, 255);
    else {
      float hue = map(pressure, -0.05, 0.05, 175, 100);
      stroke(hue, 75, 255);
    }

    strokeWeight(radius * 2);

    if (isInsideObject && visualizeInteractions)
      stroke(100 - pressure * 2000, 255, 125);

    point(position.x, position.y);
  }

  void FindNeighborsInList(ArrayList<Particle> _particles, float _kernalRadius) {
    neighbors.clear();

    for (int j = 0; j < _particles.size(); j++) {
      Particle p2 = _particles.get(j);
      if ((abs(position.x - p2.position.x) < _kernalRadius) && (abs(position.y - p2.position.y) < _kernalRadius))
        neighbors.add(p2);
    }
  }

  void FindNeighborsInGrid(Grid _grid) {
    Cell c = _grid.GetCell(position.x, position.y);
    if (c != null)
      neighbors = c.particles;
  }
}
