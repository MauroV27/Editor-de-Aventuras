public class GraphScreen {
  public Graph graph = null;
  private Editor editor = null;

  // Cores usadas de https://lospec.com/palette-list/spook-12 - removi o branco
  private final color[] NODES_COLOR = {color(193, 163, 255), color(145, 80, 233), color(84, 53, 147), color(255, 218, 84), color(203, 139, 77),
    color(128, 190, 59), color(88, 104, 48), color(255, 143, 71), color(160, 71, 50), color(121, 73, 62), color(0, 0, 0)
  };

  // Radius of cicrle graph
  private final int GRAPH_RADIUS = 240; // 280 // 320
  private float cx, cy; // circular graph center point x, y
  private float nodeRadius = 20; // size of radius of nodes in graph

  private Rect buttonArea; // BUTTON in TOP-LEFT // copy from Player class

  public GraphScreen( Editor e ) {
    this.editor = e;
    cx = width/2;   //center in x
    cy = height/2;  //center in y
    this.buttonArea = new Rect( 0, 0, 6 * width/100, 6 * height/100);
  }

  public void createGraph( ) {
    this.graph = new Graph( this.editor.frames );
    this.graph.setNodesPositionsInCircle( this.GRAPH_RADIUS );
    this.graph.printGraphData();
  }

  public void renderGraph() {
    background(255);//128);

    stroke(4);
    fill(255);//128);
    circle(cx, cy, 2*GRAPH_RADIUS);

    int ni = 0; // node index used for change arrow color

    this.drawArcs( cx, cy, GRAPH_RADIUS);
    // draw nodes circles ( before draw connections )
    for ( Node n : this.graph.getNodes() ) {
      fill( NODES_COLOR[ ni % NODES_COLOR.length ] );
      float pX = cx + n.x;
      float pY = cy + n.y;
      ni++;
      circle(pX, pY, 2 * nodeRadius);
    }

    ni = 0; //reset node index

    for ( Node n : this.graph.getNodes() ) {

      // posiciona os pontos na tela com base no centro (cx, cy)
      color nc = NODES_COLOR[ ni % NODES_COLOR.length ];
      //fill( nc );
      float pX = cx + n.x;
      float pY = cy + n.y;
      //circle(pX, pY, 2 * nodeRadius);

      // Apresenta o nome do node na tela
      push();
      noStroke();
      fill(0);
      translate(pX, pY);
      textSize(18); // size of text in nodes
      float rotateAngle = n.getNodeAngle() + (PI/2);
      if ( rotateAngle < 0 || rotateAngle > PI) {
        //rotate( rotateAngle + PI/2);
        textAlign(RIGHT, CENTER);
        text(  n.nodeName, -24, 0);
      } else {
        //rotate( rotateAngle + (1.5*PI) );
        textAlign(LEFT, CENTER);
        text( n.nodeName, 24, 0);
      }
      pop();

      push();
      noFill();
      strokeWeight(3);
      for ( int t : n.getTargets() ) {
        float tx = (cx + this.graph.getNode(t).x);
        float ty = (cy + this.graph.getNode(t).y);
        //this.drawLineArrowBtw2Nodes(pX, pY, tx, ty, nodeRadius, nc);
        stroke(nc);
        this.drawBezierArrowBtw2Nodes( pX, pY, cx, cy, tx, ty, nodeRadius, nc);
      }
      pop();

      ni++;
    }

    this.drawButton();
    this.checkClickinButton();
  }

  // Draw button in screen : ---------------------------------

  public void drawButton() {

    int sizeScale = int( width/ 100);

    fill(0, 45, 90);
    rect( this.buttonArea.x, this.buttonArea.y, this.buttonArea.w, this.buttonArea.h );
    fill( 250 );
    textSize( 2 * sizeScale );
    text("Voltar", this.buttonArea.x, this.buttonArea.y, this.buttonArea.w, this.buttonArea.h);
  }

  private void checkClickinButton() {
    if ( checkClickInRectArea( mouseX, mouseY, 0, 0, this.buttonArea.w, this.buttonArea.h) && mousePressed ) {
      this.editor.DEBUG_changeEditState( EDITOR_SUB_STATES.MENU );
    }
  }

  public void mouseHasPressed() {
  }

  public void mouseHasReleased() {
  }

  private void drawLineArrowBtw2Nodes(float x, float y, float x1, float y1, float r, color c) {
    // calculate the angle of the line between the start and end points
    float angle = atan2(y1 - y, x1 - x);

    // draw the line
    float distance = ( sqrt(pow(x - x1, 2) + pow(y - y1, 2)) ) - (r);

    float fx = x + ( cos(angle) * distance );
    float fy = y + ( sin(angle) * distance );

    // draw the arrowhead
    //pushMatrix();
    push();
    stroke(2);
    line(x, y, fx, fy);
    fill( c );

    translate(fx, fy);
    rotate(angle);
    triangle(-15, -10, 0, 0, -15, 10);
    //popMatrix();
    pop();
  }

  void drawBezierArrowBtw2Nodes( float px, float py, float cx, float cy, float tx, float ty, float r, color c ) {

    float mpx = abs(7*px + 1*tx)/8.0; // ponto medio entre pX e tx ( media ponderada )
    float mpy = abs(7*py + 1*ty)/8.0; // ponto medio entre pY e ty ( media ponderada )

    float limitRadius = this.GRAPH_RADIUS - r;

    mpx = clamp( mpx, cx - limitRadius, cx + limitRadius); // correcao do valor de mpx para garantir que esteja dentro do circulo
    mpy = clamp( mpy, cy - limitRadius, cy + limitRadius); // correcao do valor de mpy para garantir que esteja dentro do circulo

    //println("points: ", px, py, " |-med:", mpx, mpy, " |-targ:", tx, ty);
    bezier(px, py, cx, cy, mpx, mpy, tx, ty); // desenha bezier

    // --- Parte para desenhar o triangulo da seta
    float angle = atan2(ty - mpy, tx - mpx);
    float ts = r/2; // triangle size
    float distance = ( sqrt(pow(tx - mpx, 2) + pow(ty - mpy, 2)) ) - (r + ts);

    float fx = mpx + ( cos(angle) * distance );
    float fy = mpy + ( sin(angle) * distance );

    stroke( 1 );
    fill(c);
    beginShape();
    vertex(fx + ts * cos(angle), fy + ts * sin(angle));
    vertex(fx + ts * cos(angle + TWO_PI / 3 ), fy + ts * sin(angle + TWO_PI / 3));
    vertex(fx + ts * cos(angle + 2 * TWO_PI / 3), fy + ts * sin(angle + 2 * TWO_PI / 3));
    endShape(CLOSE);
    noFill();
  }

  void drawArcs( float cx, float cy, float radius ) {
    int NUM_CONN = this.graph.getNodes().size();
    float ANGLE_MIN = 2*PI/NUM_CONN;
    float baseAngle = PI + ANGLE_MIN/2;

    float arc_by_node = (2*PI) / NUM_CONN;
    //float ta = 0; // total angle

    push();
    strokeWeight(10);
    noFill();

    float ta = PI + (this.graph.getNode(0).getNodeAngle()) - ANGLE_MIN;//total angle

    for ( int i = 0; i < this.graph.getNodes().size(); i++) {
      color nc = NODES_COLOR[ i % NODES_COLOR.length ];

      stroke(nc);

      float arcSize = arc_by_node * 1;//this.graph.getNode(i).getValue();
      float startAngle = ta + baseAngle ;
      float endAngle = baseAngle + ta + arcSize;

      arc(cx, cy, radius * 2, radius * 2, startAngle, endAngle);

      ta += arcSize;
    }

    pop();
  }
}


// ----------------------------------------------------------------------

public class Graph {
  // class to manager all logic in graph view

  private ArrayList<Node> nodes = new ArrayList<Node>();

  public Graph(ArrayList<Frame> framesData) {
    this.nodes = this.convertFramesToNodes( framesData );
  }

  private ArrayList<Node> convertFramesToNodes( ArrayList<Frame> framesData ) {

    ArrayList<Node> _nodes = new ArrayList<Node>();
    int _numberFrames = framesData.size();

    // create nodes to -> Number of Nodes == Number of Frames ( index equivalent )
    for ( int i = 0; i < _numberFrames; i++) {
      _nodes.add( new Node( framesData.get(i).getFrameName() ) );
    }

    // create relations btw nodes
    for (int i = 0; i < _numberFrames; i++ ) {
      for ( Hotspot h : framesData.get(i).hotspots ) {
        _nodes.get(i).addTarget( h.getTargetIndex() );
      }
    }

    return _nodes;
  }

  public void setNodesPositionsInCircle(float radius) {

    int NUM_NODES = this.nodes.size();

    float ANGLE_MIN = 2*PI/NUM_NODES;

    // render nodes
    for ( int i = 0; i < NUM_NODES; i++) {
      float angle = (i * ANGLE_MIN) - PI ;

      float x = ( radius * cos( angle ));
      float y = ( radius * sin( angle ));

      //println("pos: ", x, y);

      this.nodes.get(i).setPositionNode(x, y);
      this.nodes.get(i).setNodeAngle( angle );
    }
  }

  public ArrayList<Node> getNodes() {
    return this.nodes;
  }

  public Node getNode(int index) {
    return this.nodes.get(index);
  }

  public void printGraphData() {
    // for debug
    println("Nodes in graph : ----------------------" ); // print das informações no console
    int nodeIndex = 0;
    for ( Node n : this.nodes ) {
      println( String.format("%02d", nodeIndex) + " | " + n.getNodeName() + " - Targets - " + this.getTargetsNodesFromIndex( n.targets ) );
      nodeIndex += 1;
    }
    println(" -------------------------------------- ");
  }

  private String getTargetsNodesFromIndex( IntList targetIndex ) {
    // for debug
    String result = "{ ";

    for ( int target : targetIndex ) {
      if ( target >= 0 && target < this.nodes.size() ) {
        result += this.nodes.get(target).getNodeName() + " ,";
      }
    }

    return result + " }";
  }
}

// ----------------------------------------------------------------------

public class Node {

  private float x, y; // position in screen
  private float angle; // angle of node in circular graph
  private String nodeName;

  public IntList targets = new IntList(); // aponta para outros nodes <index deles na lista>

  public Node( String frameName) {
    this.nodeName = frameName;
  }

  public void addTarget(int targetIndex) {
    if ( this.targets.hasValue( targetIndex ) ) return; // not duplicated values
    this.targets.append( targetIndex );
  }

  public int[] getTargets() {
    return this.targets.toArray();
  }

  public String getNodeName() {
    return this.nodeName;
  }

  public String toString() {
    return "NODE : - Name : " + this.nodeName + " - Targets - " + this.targets.toString();
  }

  public void setPositionNode( float x, float y) {
    this.x = x;
    this.y = y;
  }

  public void setNodeAngle(float a) {
    this.angle = a;
  }

  public float getNodeAngle() {
    return this.angle;
  }
}
