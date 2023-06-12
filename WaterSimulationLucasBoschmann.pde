Fluid fluid;
ArrayList<Object> objects;
boolean spawnParticles = false;
boolean keyCurrentlyPressed = false;
boolean visualizeInteractions = false;
float kernalRadius = 25;
float timestep = 2;
int example = 1;
float stepsPerFrame = 1;
float particleRadius = 5;

void setup() {
  size(500, 500);
  colorMode(HSB);

  fluid = new Fluid(timestep, kernalRadius);
  objects = new ArrayList<Object>();

  if (example == 1) {
    stepsPerFrame = 1;
    float amountParticlesToSpawn = (width + height) * 3;
    for (int i = 0; i < amountParticlesToSpawn; i++) {
      float spawnPosX = width * random(0.05, 0.95);
      float spawnPosY = height * random(0.45, 0.95);
      fluid.particles.add(new Particle(spawnPosX + random(kernalRadius), spawnPosY + random(kernalRadius), particleRadius));
    }
  }

  if (example == 2) {
    stepsPerFrame = 3;
    fluid.gravity = new PVector(0, 0);
    float amountParticlesToSpawn = (width + height) * 1.5;
    for (int i = 0; i < amountParticlesToSpawn; i++) {
      float spawnPosX = width * random(0.25, 0.65);
      float spawnPosY = height * random(0.45, 0.85);
      fluid.particles.add(new Particle(spawnPosX + random(kernalRadius), spawnPosY + random(kernalRadius), particleRadius));
    }
  }
}

void draw() {
  background(255);

  int fps = (int)frameRate;

  fill(0);
  textSize(20);

  if (mousePressed) {
    for (int i = 1; i < 5; i++)
      fluid.particles.add(new Particle(mouseX + random(kernalRadius), mouseY + random(kernalRadius), particleRadius));
  }

  if (keyPressed && example == 1) {
    if (key == 'o' && keyCurrentlyPressed == false) {
      keyCurrentlyPressed = true;

      objects.add(new Object(random(width * 0.3, width * 0.6), random(height / 5, height / 3), random(30, 50), random(30, 50), fluid, timestep));
    }
  }

  if (keyPressed && key == 'p' && keyCurrentlyPressed == false) {
    keyCurrentlyPressed = true;
    spawnParticles = !spawnParticles;
  }

  if (spawnParticles) {
    if (frameRate < 30) {
      spawnParticles = false;
      return;
    }
    if (frameCount % 2 == 0) {
      for (int i = 1; i < 5; i++)
        fluid.particles.add(new Particle(width / 2 + random(kernalRadius), height / 4 + random(kernalRadius), particleRadius));
    }
  }

  if (keyPressed && key == 'i' && keyCurrentlyPressed == false) {
    keyCurrentlyPressed = true;
    visualizeInteractions = !visualizeInteractions;
  }

  // clear objects
  if (keyPressed && key == 'l' && keyCurrentlyPressed == false) {
    keyCurrentlyPressed = true;
    for (Particle p : fluid.particles)
      p.isInsideObject = false;
    objects.clear();
  }

  for (int i = 0; i < stepsPerFrame; i++) {
    fluid.Update();
  }

  fluid.Render();

  for (Object o : objects) {
    if (o != null) {
      o.Update();
      o.Render();
    }
  }

  DrawBorder();

  if (visualizeInteractions) {
    text("Particles: " + fluid.particles.size(), 10, 25);
    text("Objects: " + objects.size(), 10, 50);
    text("Cells: " + fluid.grid.cells.length, 10, 75);
    text("FPS: " + fps, 10, 100);
  }
}

void keyReleased() {
  if (key == 'o' || key == 'p' || key == 'i' || key == 'o')
    keyCurrentlyPressed = false;
}

void DrawBorder() {
  fill(0);
  stroke(3);
  line(0, 0, 0, height);
  line(0, height, width, height);
  line(width, height, width, 0);
}
