import controlP5.*; //<>// //<>//
import processing.core.PApplet;

enum MODE { //<Remover esse enum do código e mudar para uma solução mais clara>//
  EDITOR, PLAYER, NONE, MANAGER
};

class Rect {
  float x, y, w, h;

  Rect(float _x, float _y, float _w, float _h) {
    this.x = _x;
    this.y = _y;
    this.w = _w;
    this.h = _h;
  }
}

boolean checkClickInRectArea( float cx, float cy, float rpx, float rpy, float rw, float rh) {
  boolean colX = ( cx > rpx && cx < ( rpx + rw ) );
  boolean colY = ( cy > rpy && cy < ( rpy + rh ) );

  return ( colX && colY );
}

// ------------------------------------------------------------------------------

/*
  Classe base para toda a lógica da aplicação
 Responsavel por gerenciar os frames da aplicação
 Também possui as funções e métodos para controlar as imagens ( escalar de acordo com o tamanho da tela )
 Apresenta a imagem da cena e verifica a colisão com os hotspots, também redirecionando para a próxima tela
 Contudo, não implementa nenhuma manipulação (adição/edição/remoção) de dados, apenas lê os dados do arquivo json recebido e os interpreta para a aplicação.
 */

class Player {

  public ArrayList<Frame> frames = new ArrayList<Frame>();
  public int currentFrame;/// change to 'currentFrameIndex'
  private int mainFrameIndex = -1;

  private Callable caller = null;

  protected Rect frameLimits = new Rect(0, 0, width, height);
  private Rect imageLimits = new Rect(0, 0, 0, 0);

  protected MODE mode = MODE.PLAYER;

  private float widthPercentage;  // core
  private float heightPercentage; // core

  // save state of mouse, used in frames collision system
  protected boolean mouseIsPressed = false;
  protected boolean mouseIsReleased = false;

  private boolean reloadFrameView = false; //
  private int cursorState = ARROW; // use ARROW and HAND
  private boolean showHotSpotsInPlayer = false;

  protected String fileOpened = ""; // for save path of current file loaded

  //private final String imageFolderPath =  (String)sketchPath("room");

  private Rect buttonArea;

  // TODO : Criar metodo para quando sair do player garantir que o mouse esteja no estado ARROW

  // Constructor method ----------------------------------------------------

  public Player() {
    this.setWidthPercentage(width/100);
    this.setHeightPercentage(height/100);

    this.mode = MODE.PLAYER;
    this.setFrameLimitsToPlayer();

    this.buttonArea = new Rect( 0, 0, 6 * width/100, 6 * height/100);
    textAlign(CENTER, CENTER);
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
    if ( checkClickInRectArea( mouseX, mouseY, 0, 0, this.buttonArea.w, this.buttonArea.h) ) {
      this.backToLastScreen();
    }
  }

  // Method to return -- Button
  public void backToLastScreen() {

    if ( caller == null ) return;

    if ( this.caller instanceof Callable ) {
      this.caller.backToInitScreen();
    }
  }

  public void backToInitScreen() {
  }; //empty method

  public void setCaller(Callable call) {
    this.caller = call;
    //println("call -> ", call);
  }

  // Methods for controll game properties ----------------------------------

  public float getWidthPercentage() {
    return widthPercentage;
  }

  public float getHeightPercentage() {
    return heightPercentage;
  }

  public void setWidthPercentage(float _width) {
    // without any validation...
    this.widthPercentage = _width;
  }

  public void setHeightPercentage(float _height) {
    // without any validation...
    this.heightPercentage = _height;
  }

  public MODE getMode() {
    return this.mode;
  }

  public void setCurrentFrame( int frameIndex ) {
    if ( this.isFrameIndexValid( frameIndex ) ) {
      this.currentFrame = frameIndex;
    }
  }

  public Frame getCurrentFrame() {
    if ( this.frames.size() > 0 ) {
      return this.frames.get(this.currentFrame);
    } else {
      return new Frame(null);
    }
  }

  public void setMainFrameIndex( int mainFrame ) {
    if ( this.isFrameIndexValid( mainFrame ) ) {
      this.mainFrameIndex = mainFrame;
    }
  }

  public int getMainFrameIndex() {
    return this.mainFrameIndex;
  }

  public boolean isFrameIndexValid( int frameIndexToValidate ) {
    return ( frameIndexToValidate >= 0 && frameIndexToValidate < this.frames.size() );
  }

  protected void setFrameLimits( float _x, float _y, float _w, float _h ) {
    this.frameLimits = new Rect( _x, _y, _w, _h );
  }

  public Rect getFrameLimits() {
    return this.frameLimits;
  }

  public void setFrameLimitsToPlayer() {
    // this method adjust limits to player screen
    this.setFrameLimits( 0.0, 0.0, width, height);
    //this.setFrameLimits( 0, 0, int(100 * this.getWidthPercentage()), int(100 * this.getHeightPercentage()));
  }

  public String getImageFolderPath() {
    //return this.imageFolderPath;
    return this.fileOpened + "//Assets";
  }

  public String getFolderPath() {
    return this.fileOpened;
  }
  
  protected void setFolderPath( String folderPath ){
    this.fileOpened = folderPath;
  }

  // -----------------------------------------------------------------------

  // Start game ------------------------------------------------------------

  // call after read json file ::
  public void play() {
    if ( this.frames.size() < 0 ) return;

    if ( this.isFrameIndexValid( this.mainFrameIndex ) == false) {
      this.mainFrameIndex = 0;
    }

    this.reloadFrameView( this.mainFrameIndex );
  }

  private void reloadFrameView( int frameIndex ) {
    this.setCurrentFrame( frameIndex );
    this.reloadFrameView = true;
    this.cursorState = ARROW;
  }

  public void setVisibleHotSpotsInPlayer( boolean state) {
    this.showHotSpotsInPlayer = state;
  }

  public void changeVisibilityHotSpotsInPlayer() {
    this.setVisibleHotSpotsInPlayer( !this.showHotSpotsInPlayer );
    this.reloadFrameView = true;
  }

  // Render and manage frames in game loop ---------------------------------
  public void renderPlayer() {
    if ( this.isFrameIndexValid(this.currentFrame) == false ) return;

    // TODO : Fazer a imagem só ser carregada uma vez
    if ( reloadFrameView ) {
      this.renderResizedImage(this.frameLimits.x, this.frameLimits.y, this.frameLimits.w, this.frameLimits.h);
      this.showHotSpotsInFrame(); // just render if VAR::showHotSpotsInPlayer is true
      this.reloadFrameView = false;
    }

    // Mouse cursor logic in player screen
    int i = this.getCurrentFrame().hotspots.size() - 1;
    while ( i >= 0  ) {
      Rect hsRect = this.getCurrentFrame().hotspots.get(i).getRectColliderShape( this.frameLimits );

      // FEEDBACK SE O PLAYER ESTIVER || N SOBRE UM HOTSPOT ----------
      if ( checkClickInRectArea( mouseX, mouseY, hsRect.x, hsRect.y, hsRect.w, hsRect.h ) ) {
        cursorState = HAND;
        i = -1; //escape loop
      } else {
        cursorState = ARROW;
      }
      i--;
      // ----------------------------------------------------------------
    }

    cursor( cursorState );

    this.drawButton();
  }

  private void showHotSpotsInFrame() {
    if ( showHotSpotsInPlayer == false ) return;

    for ( Hotspot hs : this.getCurrentFrame().hotspots ) {
      Rect hsRect = hs.getRectColliderShape( this.frameLimits );

      fill(185, 185, 255, 100);
      rect(hsRect.x, hsRect.y, hsRect.w, hsRect.h);
    }
  }

  public void renderResizedImage(float minX, float minY, float sizeW, float sizeH) {
    // Centraliza a imagem na tela e ajusta a resolução para que fique dentro da tela, mantendo a proporção da imagem original
    // | - esses parametros representam a área em que desejo colocar a imagem ( basicamente um rect insvisivel );
    // | - dentro desse rect eu gero novas variaveis, estas representam as dimensoes da imagem apresentada na tela (this.imageLimits)

    background(125);

    String imageAbslotuePath = this.getImageFolderPath() +  "\\" + this.getCurrentFrame().getImageRef();
    PImage img = loadImage( imageAbslotuePath );

    this.imageLimits = this.calculatCurrentFrameImageRect( minX, minY, sizeW, sizeH );

    image( img, this.imageLimits.x, this.imageLimits.y, this.imageLimits.w, this.imageLimits.h);
  }

  public Rect calculatCurrentFrameImageRect(float minX, float minY, float sizeW, float sizeH) {

    if ( this.getCurrentFrame().getImageRef() == null ) {
      println("Error in load image");
      return new Rect( 0, 0, width, height);
    }

    String imageAbslotuePath = this.getImageFolderPath() +  "\\" + this.getCurrentFrame().getImageRef();
    PImage img = loadImage( imageAbslotuePath );

    Rect iL = new Rect(0, 0, 0, 0); // imageLimits
    float imageRatio = ( img.width / (float)img.height );

    iL.h = imageRatio < 1 ? (imageRatio * sizeH) : sizeH;
    iL.w = imageRatio * iL.h;

    iL.x = minX + ( abs(sizeW - iL.w)/2 );
    iL.y = minY + ( abs(sizeH - iL.h)/2 );

    return iL;
  }

  public void mouseHasPressed() {
    this.mouseIsPressed = true;

    this.inputDetector();
    this.checkClickinButton();
  }

  public void mouseHasReleased() {
    this.mouseIsPressed = false;
  }

  protected void inputDetector() {
    if ( this.mouseIsPressed ) {
      // code for validate collisions btw mouse ( click ) inside of one frame
      this.checkPointPressed();
    }
  }

  private void checkPointPressed() {
    // loop for all HotSpots in frame and check if mouse inside one -> go to next frame
    for ( Hotspot hs : this.getCurrentFrame().hotspots ) {

      Rect hsRect = hs.getRectColliderShape( this.frameLimits );

      if ( checkClickInRectArea( mouseX, mouseY, hsRect.x, hsRect.y, hsRect.w, hsRect.h )) {
        int nextFrame = hs.getTargetIndex();

        if ( this.isFrameIndexValid( nextFrame ) ) {
          this.reloadFrameView( nextFrame );
          return;
        }
      }
    }
  }
  // -----------------------------------------------------------------------


  // Save game properies in a named file -----------------------------------
  public void importJSONFile( String importFileName ) { // nova versão do código

    if ( importFileName.contains(".json") == false ) {
      println("ERROR : the file - " + importFileName + " - not is a json.");
      return;
    }

    // Clear data of frames
    this.frames.clear();

    // save file path
    if ( fileOpened != importFileName ) {
      this.fileOpened = importFileName;
    }

    JSONObject json = loadJSONObject(importFileName);

    //println(json); // Para caso seja necessario ver os json bruto

    if ( json.hasKey("mainFrameIndex") ) {
      this.mainFrameIndex = json.getInt("mainFrameIndex"); // fazer um setter [FIX-THIS]
    } else {
      this.mainFrameIndex = -1;
    }

    JSONArray getFrames = json.getJSONArray("frames");

    for ( int i = 0; i < getFrames.size(); i++ ) {
      JSONObject loadFrameData = getFrames.getJSONObject(i);

      Frame newFrame = new Frame( loadFrameData.getString("frameImg") );

      if ( loadFrameData.hasKey("frameName") ) { // para permitir que funcione com versões antigas
        newFrame.setFrameName( loadFrameData.getString("frameName") );
      }

      JSONArray loadHotSpotsData = loadFrameData.getJSONArray("hotspots");

      for ( int h = 0; h < loadHotSpotsData.size(); h++ ) {
        // IMPLEMENAR codigo de leitura dos hotspots

        JSONObject hotSpotData = loadHotSpotsData.getJSONObject(h);

        int _target = hotSpotData.getInt("target");

        JSONArray vertices = hotSpotData.getJSONArray("vertices");

        float[][] verticesList = new float[4][2];

        for (int v = 0; v < vertices.size(); v++) {
          JSONObject vertex = vertices.getJSONObject(v);

          verticesList[v][0] = vertex.getFloat("x");
          verticesList[v][1] = vertex.getFloat("y");
        }

        newFrame.addHotspot(
          verticesList[0][0],
          verticesList[0][1],
          verticesList[2][0],
          verticesList[2][1],
          _target
          );
      }

      this.frames.add(newFrame);
    }
  }


  // -----------------------------------------------------------------------
}

public interface Callable {
  // Used to change 'scene' in PlayerScreen e/or InitScreen
  public void backToInitScreen();
}
