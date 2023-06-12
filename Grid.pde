class Grid {
  Cell[] cells;
  int cellWidth;
  int cellHeight;
  float kernalRadius;
  float rectX;
  float rectY;
  float rectWidth;
  float rectHeight;

  Grid(float _width, float _height, float _kernalRadius) {
    this.kernalRadius = _kernalRadius;
    cellWidth = ceil(_width / _kernalRadius);
    cellHeight = ceil(_height / _kernalRadius);
    cells = new Cell[cellWidth * cellHeight];

    for (int i = 0; i < cells.length; i++) {
      cells[i] = new Cell();
    }
  }

  int GetCellIndex(int _x, int _y) {
    return _x + _y * cellWidth;
  }

  void Render() {
    for (int i = 0; i < cellWidth; i++) {
      for (int j = 0; j < cellHeight; j++) {
        int index = GetCellIndex(i, j);
        Cell c = cells[index];
        int numParticles = c.particles.size();
        float cellX = i * kernalRadius;
        float cellY = j * kernalRadius;

        strokeWeight(0);
        fill(map(numParticles, 0, 255, 255, 0));
        rect(cellX, cellY, kernalRadius, kernalRadius);

        if (rectX != 0 && rectY != 0 && rectWidth != 0 && rectHeight != 0) {
          if (rectX <= cellX + kernalRadius && cellX <= rectX + rectWidth &&
            rectY <= cellY + kernalRadius && cellY <= rectY + rectHeight) {
            strokeWeight(0);
            fill(0, 300, 100, 50);
            rect(cellX, cellY, kernalRadius, kernalRadius);
          }
        }
      }
    }
  }

  Cell GetCell(float _x, float _y) {
    int cellPosX = floor(_x / kernalRadius);
    int cellPosY = floor(_y / kernalRadius);
    if ((cellPosX >= 0) && (cellPosX < cellWidth) && (cellPosY >= 0) && (cellPosY < cellHeight)) {
      int index = GetCellIndex(cellPosX, cellPosY);
      return cells[index];
    } else
      return null;
  }

  ArrayList<Cell> GetOverlappingCells(float _rectX, float _rectY, float _rectWidth, float _rectHeight) {
    rectX = _rectX;
    rectY = _rectY;
    rectWidth = _rectWidth;
    rectHeight = _rectHeight;

    int startX = floor(_rectX / kernalRadius);
    int endX = ceil((_rectX + _rectWidth) / kernalRadius);
    int startY = floor(_rectY / kernalRadius);
    int endY = ceil((_rectY + _rectHeight) / kernalRadius);

    ArrayList<Cell> overlappingCells = new ArrayList<Cell>();
    for (int i = startX; i < endX; i++) {
      for (int j = startY; j < endY; j++) {
        if (i >= 0 && i < cellWidth && j >= 0 && j < cellHeight) {
          int index = GetCellIndex(i, j);
          overlappingCells.add(cells[index]);
        }
      }
    }
    return overlappingCells;
  }

  void AddParticle(Particle _p) {
    for (int i = -1; i < 2; i++) {
      for (int j = -1; j < 2; j++) {
        float x = _p.position.x + kernalRadius * float(i);
        float y = _p.position.y + kernalRadius * float(j);
        Cell c = GetCell(x, y);
        if (c != null)
          c.particles.add(_p);
      }
    }
  }

  void ClearGrid() {
    for (Cell c : cells) {
      c.particles.clear();
    }
  }
}

class Cell {
  ArrayList<Particle> particles;

  Cell() {
    particles = new ArrayList<Particle>();
  }
}
