import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;

import uibooster.*;

enum EDITOR_SUB_STATES {
  MENU, EDIT, PLAY, GRAPH
};

/*
  Classe que possibilita a adição,edição e remoção dos dados dos frames, além disso o editor gerencia a inserção de imagens e o export do
 dados em formato json ( sendo este lido pelo player ).
 O player conta com 3 telas :
 - tela incial: possibilita a adição/edição/remoção de Frames, bem como outras configurações dos dados ( cena inicial ) e as funções de import/export/player
 - tela de edição: possibilita criar/remover hotspots de um determinado Frame, definindo tamanho(área) e qual o frame para onde o hotspot aponta
 - tela do grafo: exibe a estrutura de frmaes/hotspots de uma forma visual, assim facilitando a debugação do projeto
 */

class Editor extends Player implements Callable {

  private EDITOR_SUB_STATES editingMode = EDITOR_SUB_STATES.MENU;

  private InitScreen initScreen; // Component for show init screen
  private EditorScreen edScreen; // Component for show edit screen
  private GraphScreen gpScreen; // Component for show graph

  private ControlP5 reference, ref2; // every screen need a ControlP5 reference

  // OBS : Nao consegui impedir que a aplicação fechase, mas para previnir algumas infelicidades vou criar um sistema para permitir salvar os dados caso a aplicação seja fechada
  private boolean saveProgressIfExitApp = false;

  Editor(ControlP5 ref, ControlP5 ref2) {

    this.mode = MODE.EDITOR;
    this.reference = ref;
    this.ref2 = ref2;

    this.setWidthPercentage( width/100.0 );
    this.setHeightPercentage( height/100.0 );

    //println("screen size: ", int(100 * this.getWidthPercentage()), int(100 * this.getHeightPercentage()));

    this.initScreen = new InitScreen(this, this.reference);
    this.edScreen = new EditorScreen(this, this.ref2);
    this.gpScreen = new GraphScreen(this);

    this.changeEditState( EDITOR_SUB_STATES.MENU );

    this.setCaller( this );
  }

  void render() {
    if ( editingMode == EDITOR_SUB_STATES.EDIT ) {
      this.renderEditorScreen();
    } else if ( editingMode == EDITOR_SUB_STATES.MENU ) {
      this.renderMenu();
    } else if ( editingMode == EDITOR_SUB_STATES.GRAPH ) {
      this.renderGraph();
    } else {
      this.renderPlayer();
    }
  }

  void renderMenu() {
    this.initScreen.render();
  }

  void renderEditorScreen() {
    this.edScreen.render();
  }

  void renderGraph() {
    this.gpScreen.renderGraph();
  }

  private void changeEditState( EDITOR_SUB_STATES newState ) {
    this.editingMode = newState;

    switch  ( newState ) {
    case EDIT :
      this.initScreen.hideScreen();
      this.setFrameLimitsToEditor();
      this.edScreen.showScreen();
      break;
    case MENU :
      this.initScreen.getFramesFromEditor();
      this.edScreen.hideScreen();
      this.initScreen.showScreen();
      break;
    case PLAY :
      this.edScreen.hideScreen();
      this.initScreen.hideScreen();
      this.setFrameLimitsToPlayer();
      this.play(); // start play in main frame
      break;
    case GRAPH : // adicionei para testar o grafo ------------------------
      this.edScreen.hideScreen();
      this.initScreen.hideScreen();
      this.gpScreen.createGraph();
      //new Graph( this.frames );  // cria a 'matrix' do grafo e printa os dados no console, mas apenas isso - n desenha nada
      break; // ----------------------------------------------------------
    default :
      return;
    }
  }

  private void setFrameLimitsToEditor() {
    // this method adjust limits to editor screen
    // normal is 100% x 100% -> resized to keep proportion
    // edit screen -> 82% x 82%
    this.setFrameLimits(
      9 * this.getWidthPercentage(),
      15 * this.getHeightPercentage(),
      82 * this.getWidthPercentage(),
      82 * this.getHeightPercentage()
      );
  }

  public void DEBUG_changeEditState( EDITOR_SUB_STATES newState ) { // [REMOVE]
    this.changeEditState(newState);
  }

  public void backToInitScreen() {
    this.changeEditState( EDITOR_SUB_STATES.MENU );
  }

  public void openEditorScreenInFrame( int frameIndex ) {
    //println("EDITOR -> openEditorScreenInFrame: ", frameIndex);
    if ( this.isFrameIndexValid( frameIndex ) ) {
      this.currentFrame = frameIndex;
      this.changeEditState( EDITOR_SUB_STATES.EDIT );
    }
  }

  public void changeForPlayMode() {
    this.changeEditState( EDITOR_SUB_STATES.PLAY );
    //this.play(); // start play in main framege
  }

  public void printGraphData() {
    // [REMENBER] : Remove this method when graph screen is working
    // print graph data in console
    Graph g = new Graph( this.frames );  // cria a 'matrix' do grafo e printa os dados no console, mas apenas isso - n desenha nada
    g.printGraphData();
  }

  // METHODS FOR MANAGER SAVE ---------------------------------------

  public void saveCurrentState() {
    if ( fileOpened != "" ) {
      this.exportJSONFile( fileOpened );
      println("O arquivo - " + fileOpened + " - foi atualizado"); // apresentar na tela para informar o player
    } else {
      this.backToInitScreen();

      this.initScreen.dialogExport();
    }
  }


  // METHODS TO MANAGE FRAMES DATA ----------------------------------

  public void addFrame(File imageFile) {

    //String destination = (String)sketchPath("room") + "\\" + imageFile.getName();
    String destination = this.getImageFolderPath() + "\\" + imageFile.getName();
    File imageSave = new File(destination);

    if ( imageSave.exists() == false ) {

      try {
        this.copyFileUsingStream(imageFile, imageSave);
      }
      catch ( IOException err) {
        println("[EEROR]: Editor:addFrame - filed to copy image. err: ", err);
      }
    }
    //println("Frame created : ", imageFile.getName() );


    Frame newFrame = new Frame( imageFile.getName() ); //only gets name for image
    this.frames.add(newFrame);

    this.initScreen.getFramesFromEditor();
  }

  public void removeFrame( int frameIndexToRemove ) {
    if ( this.isFrameIndexValid( frameIndexToRemove ) ) {
      this.frames.remove( frameIndexToRemove );
    }

    this.initScreen.getFramesFromEditor();
  }

  public void renameFrame( int frameIndexToRename, String newFrameName ) {
    if ( this.isFrameIndexValid( frameIndexToRename ) ) {
      this.frames.get( frameIndexToRename ).setFrameName( newFrameName );
    }

    //this.initScreen.getFramesFromEditor();
    //this.backToInitScreen();
  }

  private void copyFileUsingStream(File source, File dest) throws IOException {
    // used to copy image form a file to room directory ( see addFrame function );
    // find in -> https://stackoverflow.com/questions/16433915/how-to-copy-file-from-one-location-to-another-location/32652909#32652909

    InputStream is = null;
    OutputStream os = null;

    try {
      is = new FileInputStream(source);
      os = new FileOutputStream(dest);
      byte[] buffer = new byte[1024];
      int length;
      while ((length = is.read(buffer)) > 0) {
        os.write(buffer, 0, length);
      }
    }
    catch ( NullPointerException err ) {
      println("Error in save image in destination folder. ", err);
    }
    finally {
      if ( is != null ) is.close();
      if ( os != null ) os.close();
    }
  }


  public boolean imageIsVallide(File file) {
    String fileName = file.getName().toUpperCase();
    return fileName.endsWith(".JPG") || fileName.endsWith(".JPEG") || fileName.endsWith(".PNG");
  }

  // ----------------------------------------------------------------

  // METHODS TO MANAGE MOUSE INPUT IN EDITOR SCREEN -----------------

  public void mouseHasPressed() {
    this.mouseIsPressed = true;
    this.mouseIsReleased = false;

    if ( editingMode == EDITOR_SUB_STATES.EDIT ) {
      this.edScreen.mouseHasPressed();
    }

    if ( editingMode == EDITOR_SUB_STATES.PLAY ) {
      super.mouseHasPressed();
    }
  }

  public void mouseHasReleased() {
    this.mouseIsPressed = false;
    this.mouseIsReleased = true;

    if ( editingMode == EDITOR_SUB_STATES.EDIT ) {
      this.edScreen.mouseHasReleased();
    }

    if ( editingMode == EDITOR_SUB_STATES.PLAY ) {
      super.mouseHasReleased();
    }
  }

  // ----------------------------------------------------------------

  // METHODS TO MANAGE HOTSPOT IN EDITOR SCREEN ---------------------

  public void addHotSpotInFrame( float p1x, float p1y, float p2x, float p2y, int nextFrame ) {
    if ( this.isFrameIndexValid( nextFrame ) && this.isFrameIndexValid(this.currentFrame) ) {
      //println("EDITOR --> Adicionionou o frmae");
      this.frames.get(this.currentFrame).addHotspot(  p1x, p1y, p2x, p2y, nextFrame );
    }
  }

  public void remvoeHotSpotInCurrentFrame( int hotSpotIndex ) {
    //println("hotspotindex in frame not is used: ", hotSpotIndex);

    if ( this.isFrameIndexValid(this.currentFrame) ) {
      this.getCurrentFrame().hotspots.remove(hotSpotIndex);
    }
  }

  public void removeAllHotSpotsInCurretFrame() {
    this.getCurrentFrame().hotspots.clear();
  }

  // ----------------------------------------------------------------

  private void _saveAndExit( boolean v ) {
    this.saveProgressIfExitApp = v;
  }

  public void exitWindow() {

    if ( this.frames.size() == 0 ) return; // not show every time when app was close

    // confirm exit
    new UiBooster().showConfirmDialog(
      "O aplicativo vai ser fechado, deseja salvar o que foi feito?",
      "Sair do programa?",
      () -> _saveAndExit( true ),
      () -> _saveAndExit( false ));

    if ( this.saveProgressIfExitApp == false ) return;

    this.saveCurrentState();
  }


  // METHODS TO MANAGE DATA FILES -----------------------------------

  public void createProjectFolder( String absolutPath ) {

    File projectRoot = new File( absolutPath );
    
    // Create Assets folder
    File assetsDir = new File( projectRoot.getAbsolutePath() + "//Assets" );
    assetsDir.mkdir();

    // Create jsonFile
    this.exportJSONFile( projectRoot.getAbsolutePath() );
  }

  public void exportJSONFile( String directoryFolder ) {

    // Loop in frames :
    // |- Dados sobre a imagem do frame
    // |- Loop nos hotspots do frame :
    //    |- Dados sobre os hotspots do frame
    
    String exportFileName = "adventure-project.json";

    if ( directoryFolder == "" || directoryFolder == null || directoryFolder == "null" ) {
      println("Algo deu errado com o save do arquivo, por favor tente de novo");
      return;
    }

    JSONObject data = new JSONObject();
    JSONArray state = new JSONArray();

    for (int i = 0; i < frames.size(); i++) {
      JSONArray hotspots = new JSONArray();
      JSONObject frame = new JSONObject();

      frame.setInt("id", i);
      frame.setString("frameImg", frames.get(i).getImageRef() ); //save name of image file
      frame.setString("frameName", frames.get(i).getFrameName() ); // save name of frame

      for (int h = 0; h < frames.get(i).hotspots.size(); h++) {
        JSONObject hotspot = new JSONObject();
        JSONArray vertices = new JSONArray();

        Hotspot current = frames.get(i).hotspots.get(h);

        hotspot.setInt("id", h);
        hotspot.setInt("target", current.targetFrameIndex);

        for (int v = 0; v < current.vertices.length; v++) {
          JSONObject vertex = new JSONObject();

          vertex.setFloat("x", current.vertices[v].x);
          vertex.setFloat("y", current.vertices[v].y);

          vertices.setJSONObject(v, vertex);
        }

        hotspot.setJSONArray("vertices", vertices);
        hotspots.setJSONObject(h, hotspot);
      }

      frame.setJSONArray("hotspots", hotspots);
      state.setJSONObject(i, frame);
    }

    //saveJSONObject(state, "data/"+ exportFileName);
    data.setInt("mainFrameIndex", this.getMainFrameIndex());

    data.setJSONArray("frames", state);

    if ( exportFileName.endsWith(".json") ) {
      exportFileName = exportFileName.substring(0, exportFileName.length() - 5);
    }

    saveJSONObject(data, directoryFolder + "//" + exportFileName, "indent=5");

    // save file path, now app can save just pressed letter "s" in keybord
    if ( fileOpened != exportFileName ) {
      this.fileOpened = directoryFolder;
    }
  }


  // ----------------------------------------------------------------
}
