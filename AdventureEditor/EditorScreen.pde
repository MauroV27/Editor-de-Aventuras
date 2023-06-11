/*  //<>// //<>//
 Feito para conter todo o código da interface do editor
 Possui botões para :
 1. adicionar novo hotspot;
 2. remover hotspot ( remove todos de uma vez, por enquanto );
 3. voltar a tela do menu;
 */

import uibooster.*;
import uibooster.components.*;
import uibooster.model.*;
import uibooster.model.formelements.*;
import uibooster.model.options.*;
import uibooster.utils.*;

float clamp( float value, float min, float max ) {
  if ( value < min ) return min;
  if ( value > max ) return max;

  return value;
}

class EditorScreen {

  private ControlP5 cp5;

  private Editor editorConnection = null;

  private boolean isDrawingHotSpot = false;
  private boolean canDrawAnHotSpot = false;
  private float pmPressedX, pmPressedY, pmReleasedX, pmReleasedY;

  //private Rect imageLimits;

  public EditorScreen( Editor e, ControlP5 c ) {

    this.editorConnection = e;
    this.cp5 = c;

    initializeInterfaceElements();
    this.pmPressedX = this.pmPressedY = this.pmReleasedX = this.pmReleasedY = -1.0;
  }

  private void initializeInterfaceElements() {

    float _w_percenet = this.editorConnection.getWidthPercentage();   // width / 100
    float _h_percenet = this.editorConnection.getHeightPercentage();  // height / 100

    // Configs to control size of elements in interface
    int[] SIZE_BUTTON = {200, 40}; // antes era 100, 30

    // Fonte
    ControlFont font = new ControlFont(createFont("Arial", 14));

    this.createControlButton( "Adicionar área clicável", _w_percenet * 2, _h_percenet * 3, SIZE_BUTTON, font, "addHotSpotInFrame");
    this.createControlButton( "Remover área clicável", _w_percenet * 43, _h_percenet * 3, SIZE_BUTTON, font, "removeHotSpotInFrame");

    int[] BUTTON_MID_SIZE = {(int)SIZE_BUTTON[0]/2, (int)SIZE_BUTTON[1]};
    this.createControlButton( "voltar", _w_percenet * 91, _h_percenet * 3, BUTTON_MID_SIZE, font, "backToInitScreen");
  }

  public Button createControlButton(String theName, float posX, float posY, int[] size, ControlFont theFont, String callBackMethod) {
    // função REPETIDA da classe InitScreen...Resolver isso criando uma classe base para todas as telas
    Button b = this.cp5.addButton(theName)
      .setValue(0)
      .setPosition(posX, posY )
      .setSize(size[0], size[1])
      .plugTo( this, callBackMethod)
      ;

    b.getCaptionLabel().setFont(theFont);

    return b;
  }

  public void hideScreen() {

    for ( ControllerInterface elem : this.cp5.getAll() ) {
      //println(elem);
      elem.hide();
    }
  }

  public void showScreen() {
    for ( ControllerInterface elem : this.cp5.getAll() ) {
      //println(elem);
      elem.show();
    }

    //this.reloadImageData();
  }

  //public void reloadImageData() { // comentado para testar problemas com o processign detecntando funções
  //  Rect fL = this.editorConnection.getFrameLimits();
  //  Rect iL = this.editorConnection.calculatCurrentFrameImageRect( fL.x, fL.y, fL.w, fL.h);

  //  this.imageLimits = new Rect(iL.x, iL.y, iL.w, iL.h);
  //}

  public void render() {
    background(125);
    // render current frame
    if ( this.editorConnection.frames.size() != 0 ) {

      Rect fL = this.editorConnection.getFrameLimits();

      this.editorConnection.renderResizedImage(fL.x, fL.y, fL.w, fL.h);

      for ( Hotspot hs : this.editorConnection.getCurrentFrame().hotspots ) {

        //if (selected) {
        //  editor.showNodes();
        //  fill(125, 0, 0, 100);
        //}
        Rect hsShape = hs.getRectColliderShape( fL );

        fill(185, 185, 255, 100);
        rect( hsShape.x, hsShape.y, hsShape.w, hsShape.h );
      }

      this.drawHotSpotRect();
    }
  }


  // ----------------------------------------------------------------

  public void backToInitScreen() {
    this.editorConnection.backToInitScreen();
    this.canDrawAnHotSpot = false;
    this.isDrawingHotSpot = false;
    this.setMousePressedPoint( -1, -1);
  }

  public void addHotSpotInFrame() {
    //println("Addd hotspot");
    this.canDrawAnHotSpot = true;
    this.isDrawingHotSpot = false;
    this.setMousePressedPoint( -1, -1);
  }

  public void removeHotSpotInFrame() {
    // por enquanto remove todos os hotspots de uma vez....

    if ( this.editorConnection == null ) return;

    // criar código para selecionar um hotspot aq...

    // TODO : Show list of all hotspots in screnn ( like to target a frame )
    int NUMBER_OF_HOTSPOTS = this.editorConnection.getCurrentFrame().hotspots.size();
    String[] listOfValidHotSpots = new String[ NUMBER_OF_HOTSPOTS + 1]; // +1 for all hotspots

    int i = 0;
    for ( Hotspot h : this.editorConnection.getCurrentFrame().hotspots ) {
      listOfValidHotSpots[i] = this.editorConnection.frames.get(h.getTargetIndex()).getFrameName();
      i++;
    }

    listOfValidHotSpots[NUMBER_OF_HOTSPOTS] = "Remover todas as áreas clicaveis!"; // last index in list

    String select = new UiBooster().showSelectionDialog(
      "Remover área clicavel",
      "Selecione uma área clicavel para remover",
      listOfValidHotSpots);

    //if (select == null) {
    //  UiBooster booster = new UiBooster();
    //  booster.showErrorDialog("Falha ao remover HotSpot, por favor tente novamente.", "Error ao remover hotspot");
    //  return;
    //}

    if ( select == listOfValidHotSpots[NUMBER_OF_HOTSPOTS] ) {
      // TODO : add confirm in this option
      this.editorConnection.removeAllHotSpotsInCurretFrame();
      return;
    }

    int selectedHotSpot = -1;

    for ( int s = 0; s < NUMBER_OF_HOTSPOTS; s++ ) {
      if ( select == listOfValidHotSpots[s] ) { // search the first string value == destiny text -> get first index
        selectedHotSpot = s;
      }
    }

    // TODO : Highlight selected hotspot (
    // TODO : show UIbooster confirm prompt

    this.editorConnection.remvoeHotSpotInCurrentFrame( selectedHotSpot );
  }

  // ----------------------------------------------------------------

  public void mouseHasPressed() {
    if ( this.canDrawAnHotSpot == false ) return;

    if ( this.isDrawingHotSpot == false ) {
      this.setMousePressedPoint( mouseX, mouseY );
    }
  }

  public void mouseHasReleased() {
    if ( this.canDrawAnHotSpot == false ) return;

    if ( this.isDrawingHotSpot == true ) {
      this.setMouseReleasedPoint( mouseX, mouseY );
    }
  }

  /* nao ta funcionando direito isso de verificar se um hotspot esta ou nao dentro de outro */
  public void setMousePressedPoint( float mPressedX, float mPressedY ) {

    if ( this.canDrawAnHotSpot == false ) return;

    // verifica se o ponto já pertence a um hotspot
    for ( Hotspot hs : this.editorConnection.getCurrentFrame().hotspots ) {
      if ( hs.verifyIfAPointHasInHotSpotArea( mPressedX, mPressedY ) ) {
        println("Nao pode criar um hotspot nesse ponto...");
        return;
      }
    }

    this.pmPressedX = mPressedX;
    this.pmPressedY = mPressedY;

    this.isDrawingHotSpot = true;
  }

  public void setMouseReleasedPoint( float mReleasedX, float mReleasedY ) {
    if ( this.isDrawingHotSpot == false ) return;

    this.pmReleasedX = mReleasedX;
    this.pmReleasedY = mReleasedY;

    this.createAHotSpot();
    this.isDrawingHotSpot = false;
  }

  private void createAHotSpot() {
    // enviar dados de todos os pontos
    if ( this.canDrawAnHotSpot == false ) return;
    if ( this.isDrawingHotSpot == false ) return;

    if ( this.pmPressedX == -1 || this.pmPressedY == -1 || this.pmReleasedX == -1 || this.pmReleasedY == -1 ) return;

    int NUMBER_OF_FRAMES = this.editorConnection.frames.size();

    String[] listOfValidFrames = new String[NUMBER_OF_FRAMES];

    for ( int i = 0; i < listOfValidFrames.length; i++) {
      //listOfValidFrames[i] = "Frame - " + str(i);
      listOfValidFrames[i] = this.editorConnection.frames.get(i).getFrameName();
    }

    String destiny = new UiBooster().showSelectionDialog(
      "Frames",
      "Selecione um frame Destino",
      listOfValidFrames);

    if (destiny != null) {
      int indexDestinyString = -1;

      for ( int s = 0; s < NUMBER_OF_FRAMES; s++ ) {
        if ( destiny == listOfValidFrames[s] ) { // search the first string value == destiny text -> get first index
          indexDestinyString = s;
        }
      }

      if ( indexDestinyString != -1 ) {
        this.calculateDataFromCreateHotSpot(indexDestinyString);
      } else {
        // emit error in screen ::
        UiBooster booster = new UiBooster();
        booster.showErrorDialog("Falha ao criar HotSpot, por favor tente novamente.", "Error em criar hotspot");
      }
    }
  }

  private void calculateDataFromCreateHotSpot(int nextFrameIndex) {

    // WARNING : Muita matematica confusa abaixo...... cuidado quando mexer

    Rect fL = this.editorConnection.getFrameLimits();

    float minPointX = clamp(this.pmPressedX - fL.x, 0.0, fL.w);
    float minPointY = clamp(this.pmPressedY - fL.y, 0.0, fL.h);
    float maxPointX = clamp(this.pmReleasedX - fL.x, 0.0, fL.w);
    float maxPointY = clamp(this.pmReleasedY - fL.y, 0.0, fL.h);

    // Pega os pontos extremos do HotSpot desenhado na tela e divide pelo tamanho do frame, mantendo na proporção tanto imagem quanto hotspot

    float pointX = ( min(maxPointX, minPointX) ) / fL.w;
    float pointY = ( min(maxPointY, minPointY) ) / fL.h;

    float sizeW = abs( maxPointX - minPointX ) / fL.w;
    float sizeH = abs( maxPointY - minPointY ) / fL.h;

    this.editorConnection.addHotSpotInFrame(pointX, pointY, (pointX + sizeW), (pointY + sizeH), nextFrameIndex);
  }

  private void drawHotSpotRect() {
    if ( this.isDrawingHotSpot == false ) return;

    if ( isDrawingHotSpot && this.pmPressedX >= -1 && this.pmPressedY > -1) {
      //println("drawHotSpotRect -> Ta desnehajoo");
      //fill(185, 185, 185, 100);
      //fill( 255, 120, 120);
      fill(125, 0, 0, 100);
      rect(this.pmPressedX, this.pmPressedY, mouseX-this.pmPressedX, mouseY-this.pmPressedY);
    }
  }



  // ----------------------------------------------------------------
}
