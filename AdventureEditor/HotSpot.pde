class Hotspot {
  //HotspotEditor editor; // Hotspot e o HotspotEditor e o possuem referência ciclica.
  int targetFrameIndex = 0;

  public int getTargetIndex() {
    return targetFrameIndex;
  }

  public void setTargetIndex(int value) {
    // [ISSUE] : Limit index that targetFrameIndex can assume ( 0 - frame.lenght)
    targetFrameIndex = value;
  }


  Vertice[] vertices = new Vertice[4];

  int index = 0;

  boolean drawing = false;
  boolean editing = false;
  boolean selected = false;

  Hotspot( float x1, float y1, float x2, float y2, int targetIndex ){
    // constroi com base no Rect ( x, y, w, h )
    
    vertices[0] = new Vertice(x1, y1);
    vertices[2] = new Vertice(x2, y2);
    this.setTargetIndex( targetIndex );
    
    this.updateVertices();
  }

  Hotspot(float primaryCornerX, float primaryCornerY) {
    vertices[0] = new Vertice(primaryCornerX, primaryCornerY);
    drawing = true;
  }

  public Rect getRectShape() {
    // get absolute values of vertices ( used for transcription data for json );
    // a rect ( [0,1], [0,1], [0,1], [0,1]); 
    return new Rect( this.vertices[0].x, this.vertices[0].y, this.vertices[2].x - this.vertices[0].x, this.vertices[2].y - this.vertices[0].y ); 
  }
  
  public Rect getRectColliderShape( Rect r ) {
    // escala os valores do rect original do hotspot ( imutavel ) para um rect redimensionado com base em um outro rect
    Rect p = this.getRectShape();
    
    return new Rect( (p.x * r.w) + r.x, (p.y * r.h) + r.y, (p.w * r.w), (p.h * r.h) ); 
  }

  public void drawHotspotRect(){
    fill(185, 185, 185, 100);
    Rect hsRect = this.getRectShape();
    
    rect( hsRect.x, hsRect.y, hsRect.w, hsRect.h );
  }

  void drawHotspot() {

    fill(185, 185, 185, 100);
    if (selected) {
      //editor.showNodes();
      fill(125, 0, 0, 100);
    }
    rect(vertices[0].x, vertices[0].y, vertices[2].x - vertices[0].x, vertices[2].y - vertices[0].y);
  }

  void updateShape(float secondaryCornerX, float secondaryCornerY, boolean isFinished) {
    vertices[2] = new Vertice(secondaryCornerX, secondaryCornerY);

    if (isFinished) {
      drawing = false;

      if (abs(secondaryCornerX - vertices[0].x) * abs(secondaryCornerY - vertices[0].y) < 625) {
        vertices[2].x = vertices[0].x + 25;
        vertices[2].y = vertices[0].y + 25;
      }

      updateVertices();
      //editor = new HotspotEditor(this);
    }
  }

  public boolean verifyIfAPointHasInHotSpotArea(float px, float py) { 
    // !DEPRECATED -> valores dos vertices nao consideram o escalonamento da tela ( sao apens valores entre 0 e 1 )

    boolean colX = ( px > this.vertices[0].x && px < (this.vertices[2].x - vertices[0].x) );
    boolean colY = ( py > this.vertices[0].y && py < (this.vertices[2].y - vertices[0].y) );
    
    return ( colX && colY );
  }


  void updateVertices() {
    if (vertices[2].x < vertices[0].x) {
      float tmp;

      tmp = vertices[2].x;
      vertices[2].x = vertices[0].x;
      vertices[0].x = tmp;
    }

    if (vertices[2].y < vertices[0].y) {
      float tmp;

      tmp = vertices[2].y;
      vertices[2].y = vertices[0].y;
      vertices[0].y = tmp;
    }

    vertices[1] = new Vertice(vertices[0].x + (vertices[2].x - vertices[0].x), vertices[0].y);
    vertices[3] = new Vertice(vertices[0].x, vertices[0].y + (vertices[2].y - vertices[0].y));
  }
}

class Vertice {
  float x;
  float y;
  float radius = 20;

  Vertice(float xPos, float yPos) {
    x = xPos;
    y = yPos;
  }

  boolean wasClicked(float clickX, float clickY) {
    if (abs(dist(x, y, clickX, clickY)) < radius)
      return true;

    return false;
  }
}
