import controlP5.*;
import uibooster.*;
import uibooster.components.*;
import uibooster.model.*;
import uibooster.model.formelements.*;
import uibooster.model.options.*;
import uibooster.utils.*;

// imports to select image files
import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;
import javax.swing.*;

//import uibooster.model.UiBoosterOptions;
//import uibooster.utils.WindowIconHelper;

class InitScreen {

  private int min_number_of_itens_in_lbox; // existe para resolver o bug do erro no index da listbox.

  private ControlP5 cp5;
  private UiBooster booster = new UiBooster();

  private String textSelectedInDropDownList; //
  private ScrollableList lbox; // ListBox is deprecated in ControlP5, so i change for ScrollableList

  private ArrayList<Frame> renderFrames;
  private ArrayList<String> nameFrames;
  private Editor editorConnection = null;

  ControlFont itemFont = new ControlFont(createFont("Arial", 14));

  InitScreen(Editor e, ControlP5 ref) {

    cp5 = ref;
    this.editorConnection = e;

    // Configs to control size of elements in interface
    int[] SIZE_BUTTON = {200, 40}; // antes era 100, 30
    float[] POS_BASE_BUTTON = {width/1.65, height/10};
    int POS_Y_DIFERENCE_BUTTON = (int) width/20; // antes era 40

    // Fonte
    ControlFont font = new ControlFont(createFont("Arial", 16));
    ControlFont font2 = new ControlFont(createFont("Arial", 14));


    // Button part 1
    createControlButton( "Adicionar Cena", POS_BASE_BUTTON[0], POS_BASE_BUTTON[1], SIZE_BUTTON, font, "addFrame");
    createControlButton( "Remover Cena", POS_BASE_BUTTON[0], POS_BASE_BUTTON[1] + ( POS_Y_DIFERENCE_BUTTON ), SIZE_BUTTON, font, "deleteScene");
    createControlButton( "Editar Cena", POS_BASE_BUTTON[0], POS_BASE_BUTTON[1] + ( 2 * POS_Y_DIFERENCE_BUTTON ), SIZE_BUTTON, font, "editFrame");
    createControlButton( "Renomear Cena", POS_BASE_BUTTON[0], POS_BASE_BUTTON[1] + ( 3 * POS_Y_DIFERENCE_BUTTON ), SIZE_BUTTON, font, "renameFrame");
    createControlButton( "Ver grafo", POS_BASE_BUTTON[0], POS_BASE_BUTTON[1] + ( 4 * POS_Y_DIFERENCE_BUTTON ), SIZE_BUTTON, font, "showGraphScreen");

    float POS_Y_MID_BUTTON = height * 2/3;

    // Button part 2
    createControlButton( "Jogar/Executar", POS_BASE_BUTTON[0], POS_Y_MID_BUTTON, SIZE_BUTTON, font, "play");
    createControlButton( "Salvar/Exportar", POS_BASE_BUTTON[0], POS_Y_MID_BUTTON + (POS_Y_DIFERENCE_BUTTON), SIZE_BUTTON, font, "dialogExport");
    createControlButton( "Ler/Importar", POS_BASE_BUTTON[0], POS_Y_MID_BUTTON + (2* POS_Y_DIFERENCE_BUTTON), SIZE_BUTTON, font, "dialogImport");


    int h_base = (int) height/15;

    // Item List --------------------
    //lbox = this.cp5.addListBox("myList")
    lbox= this.cp5.addScrollableList("myList")
      .setPosition(width/4, height/10)
      .setSize(width/3, h_base * 7)
      .setItemHeight(h_base)
      .setBarHeight(h_base)
      .setColorBackground(color(60))
      .setColorActive(color(60))
      .setColorForeground(color(100))
      .setType(ScrollableList.LIST)
      .plugTo(this, "myList")
      ;

    lbox.getCaptionLabel().setFont(font);
    lbox.getCaptionLabel().toUpperCase(true);
    lbox.getCaptionLabel().set("Lista de cenas");


    this.cp5.addTextlabel("Frame-inicial")
      .setValue("Cena inicial não definida.")
      //.setPosition(width/4, height/2 + 70)
      .setPosition( width/4, POS_Y_MID_BUTTON - 30 )
      .setSize(SIZE_BUTTON[0], SIZE_BUTTON[1])
      //.setColorValue(0xffffff00)
      .setFont(font2)
      ;

    createControlButton( "Selecionar cena inicial", width/4, POS_Y_MID_BUTTON, SIZE_BUTTON, font2, "selectMainFrame");

    min_number_of_itens_in_lbox = ceil((PApplet.abs( lbox.getHeight() ) - ( lbox.getBarHeight() )) / h_base);// h_base = lbox.setItemHeight(h_base)
    for ( int i = 0; i < min_number_of_itens_in_lbox; i++) {
      lbox.addItem("", i);
      lbox.getItem(i).put("state", false);
    }

    this.getFramesFromEditor();
    this.printFrameNameInScreen();
  }

  public Button createControlButton(String theName, float posX, float posY, int[] size, ControlFont theFont, String callBackMethod) {
    Button b = this.cp5.addButton(theName)
      .setValue(0)
      .setPosition(posX, posY )
      .setSize(size[0], size[1])
      .plugTo( this, callBackMethod)
      //.setAddress("tela")
      ;

    b.getCaptionLabel().setFont(theFont);

    return b;
  }

  public void showGraphScreen() {
    if (this.editorConnection != null ) {
      if ( this.editorConnection.frames.size() == 0 ) {
        booster = new UiBooster();
        booster.showErrorDialog("Nenhum frame disponivel para visualizar na tela do grafo", "ERROR");
      } else {
        this.editorConnection.DEBUG_changeEditState( EDITOR_SUB_STATES.GRAPH );
      }
    }
  }


  public void getFramesFromEditor() {
    if (this.editorConnection != null ) {

      //if ( this.renderFrames != null ) this.renderFrames.clear();

      this.renderFrames = this.editorConnection.frames;

      int mainFrameIndex = this.editorConnection.getMainFrameIndex();

      String mainFrameName = "";
      if ( mainFrameIndex > -1 ) mainFrameName = this.editorConnection.frames.get( mainFrameIndex ).getFrameName();

      this.mainFrameTextShowInScreen( mainFrameName, mainFrameIndex);

      this.printFrameNameInScreen();
    }
  }

  public void hideScreen() {
    for ( ControllerInterface elem : this.cp5.getAll() ) {
      //if ( elem.getAddress() == "tela" ) {
      elem.hide();
      //}
    }
  }

  public void showScreen() {
    for ( ControllerInterface elem : this.cp5.getAll() ) {
      elem.show();
    }
  }

  private void printFrameNameInScreen() {
    lbox.clear();
    this.nameFrames = this.listFramesNames();

    int lboxSize = min_number_of_itens_in_lbox > this.nameFrames.size() ? min_number_of_itens_in_lbox : this.nameFrames.size();

    for ( int i = 0; i < lboxSize; i++) {
      lbox.addItem("", i);
      lbox.getItem(i).put("state", false);
    }

    for ( int i = 0; i < this.nameFrames.size(); i++) {
      String name = this.nameFrames.get(i);
      lbox.getItem(i).put("text", name);
      lbox.getItem(i).put("name", name);
    }
  }


  public void render() {

    noStroke();
    background(128); //#777777
    //texto "Cenas"
    //textSize(25);
    //fill(0);
    //text("Cenas", width/4, height/10 -10);
    //texto cena inicial
    //fill(0);
    //text("Cena inicial", width/4, height*2/3 -10);

    this.loadListBoxItens();
  }

  private void loadListBoxItens() {

    //lbox.getCaptionLabel().toUpperCase(true);
    //lbox.getCaptionLabel().set("Lista de cenas");
    //lbox.getCaptionLabel().setColor(0xffff0000);


    for (int i=0; i < lbox.getItems().size(); i++) {

      if ( i < this.renderFrames.size() ) {

        if ( this.renderFrames.get(i).getNumberOfHotSpots() == 0 ) {
          // change item background to grey if no hotspots in this frame
          lbox.getItem(i).put("color", new CColor().setBackground(0xffff0000).setBackground(0x64646400));
        } else {
          lbox.getItem(i).put("color", new CColor().setBackground(0xffff0000).setBackground(0xffff8800));
        }

        //lbox.getItem(i).getValueLabel().setFont(itemFont); //.setFont(itemFont);

        String frameName = this.renderFrames.get(i).getFrameName();
        lbox.getItem(i).put("text", frameName);
        lbox.getItem(i).put("name", frameName);
      } else {
        lbox.getItem(i).put("state", false);
        lbox.getItem(i).put("color", new CColor().setBackground(0xff777777).setBackground(0xff777777));
      }
    }
  }

  boolean isMouseOver(float x, float y, float w, float h) {
    if (mouseX>= x && mouseX <= x + w && mouseY>= y && mouseY<= y + h) {
      return true;
    }
    return false;
  }

  //metodo adicionar cena
  void addFrame() {
    //File file = this.booster.showFileSelectionFromPath( sketchPath("room"), "Selecione uma imagem", "png", "jpg", "jpeg" );
    File[] files = ImageFileRetriever.selelctDirectory( sketchPath("room"), "Selecione uma imagem", "png", "jpg", "jpeg");

    if ( files == null || files.length == 0 ) return;

    for ( File file : files ) {
      if ( this.editorConnection.imageIsVallide(file) ) {
        this.editorConnection.addFrame(file);
      }
    }

    this.getFramesFromEditor(); //update frames data in screen
  }

  void editFrame() {
    // Function to open frame in editor screen

    try {
      int selectedFrame = this.selectedFrameInEditor();

      if ( selectedFrame != -1 ) {
        this.editorConnection.openEditorScreenInFrame( selectedFrame );
      }
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }

  private int selectedFrameInEditor() {
    if ( cp5.get(ScrollableList.class, "myList").getItem(textSelectedInDropDownList).get("value") == null ) return -1;

    int selectedFrame = (int) cp5.get(ScrollableList.class, "myList").getItem(textSelectedInDropDownList).get("value");
    if ( selectedFrame >= 0 && selectedFrame < this.renderFrames.size() ) {
      return selectedFrame;
    }

    return -1;
  }

  public void renameFrame() {
    int selectedFrameIndex = this.selectedFrameInEditor();

    if ( selectedFrameIndex != -1 ) {
      String currentFrameName = this.renderFrames.get( selectedFrameIndex ).getFrameName() ;

      String newFrameName = new UiBooster().showTextInputDialog("Renomeie o frame - " + currentFrameName + " para:");

      if ( newFrameName == null ) return;

      println("Novo nome do frame: ", newFrameName);

      this.editorConnection.renameFrame( selectedFrameIndex, newFrameName );
      this.printFrameNameInScreen();
    }
  }

  //metodo exportar
  void dialogExport() {
    //UiBooster booster = new UiBooster();
    //File file = this.booster.showFileSelection();
    //println("fileName = " + file.getName());
    UiBooster booster = new UiBooster();

    String exportName = booster.showTextInputDialog("Nome do arquivo export: ");
    println("Nome do arquivo export: ", exportName);
    this.editorConnection.exportJSONFile(exportName);
  }

  //metodo importar
  void dialogImport() {
    UiBooster booster = new UiBooster();
    //File directory = booster.showDirectorySelection();
    //File filePath = booster.showFileOrDirectorySelection();
    File filePath = booster.showFileSelectionFromPath( sketchPath("data"), "Selecione um arquivo json", "json");
    println("Nome do arquivo de import: " + filePath.getName());

    this.editorConnection.importJSONFile( filePath.getName() );
    this.getFramesFromEditor();
  }

  void play() {
    if ( this.editorConnection.frames.size() > 0 ) {
      this.editorConnection.changeForPlayMode();
    } else {
      booster = new UiBooster();
      booster.showErrorDialog("Nenhum frame disponivel para inicializar o jogo", "ERROR");
    }
  }

  //metodo dialog Sim ou não excluir cena
  void deleteScene() {
    new UiBooster().showConfirmDialog(
      "Você quer mesmo remover essa cena?",
      "Remover cena",
      () -> removeElementInListBox(),
      () -> System.out.println("Action declined"));
    //println("menos 1");
  }

  public void selectMainFrame() {

    int number_frames = this.editorConnection.frames.size();

    if ( number_frames <= 0 ) {
      new UiBooster().showWarningDialog("Nenhum frame para escolher....", "WARN");
      return;
    }

    String[] listOfValidFrames = new String[number_frames];

    for ( int i = 0; i < listOfValidFrames.length; i++) {
      listOfValidFrames[i] = this.editorConnection.frames.get(i).getFrameName();
    }

    String selectMainFrame = new UiBooster().showSelectionDialog(
      "Frames",
      "Selecione o Frame inicial",
      listOfValidFrames);

    if ( selectMainFrame != null ) {
      //String mainFrameIndex = selectMainFrame.substring(8).trim(); // corta a string pegando apenas o numero do index

      //this.editorConnection.setMainFrameIndex( int(mainFrameIndex) );

      //this.mainFrameTextShowInScreen( selectMainFrame.trim(), int(mainFrameIndex));

      int indexDestinyString = -1;

      for ( int s = 0; s < listOfValidFrames.length; s++ ) {
        if ( selectMainFrame == listOfValidFrames[s] ) { // search the first string value == destiny text -> get first index
          indexDestinyString = s;
        }
      }

      if ( indexDestinyString != -1 ) {
        this.editorConnection.setMainFrameIndex(indexDestinyString);
        this.mainFrameTextShowInScreen( selectMainFrame, indexDestinyString);
      } else {
        // emit error in screen ::
        UiBooster booster = new UiBooster();
        booster.showErrorDialog("Falha ao criar HotSpot, por favor tente novamente.", "Error em criar hotspot");
      }
    }
  }

  private void mainFrameTextShowInScreen( String text, int num ) {
    if ( num >= 0 ) {
      cp5.get(Textlabel.class, "Frame-inicial").setValue("Cena inicial - " + text.trim());
    } else {
      cp5.get(Textlabel.class, "Frame-inicial").setValue("Cena inicial não definida.");
    }
  }

  public void myList(int selected_element) {
    // Recebe o 'sinal' (evento) de que o objeto <ScrollableList> de identificado como "myList" ( variavel lbox ) foi modificado.

    if ( selected_element < lbox.getItems().size() ) {
      textSelectedInDropDownList = lbox.getItem(selected_element).get("name").toString();
    }
  }

  public void removeElementInListBox() {
    println("removeElement foi chamado");
    try {
      if ( cp5.get(ScrollableList.class, "myList").getItem(textSelectedInDropDownList).get("value") == null ) return;
      int remove_value = (int) cp5.get(ScrollableList.class, "myList").getItem(textSelectedInDropDownList).get("value");

      this.editorConnection.removeFrame( remove_value );
      this.getFramesFromEditor(); //update frames data in screen
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }

  public ArrayList<String> listFramesNames() {
    ArrayList<String> frameList = new ArrayList<String>();

    for ( Frame frame : this.editorConnection.frames ) {
      frameList.add( frame.getFrameName() );
    }

    return frameList;
  }
}

public static class ImageFileRetriever {
  // class for get many files from directory
  //código para selecionar varios arquivos de uma vez
  public static File[] selelctDirectory( String dirName, String description, String... extensions) {

    // Uibooster elements
    JFrame frameWithIcon = new JFrame();
    frameWithIcon.setIconImage(WindowIconHelper.getIcon(UiBoosterOptions.defaultIconPath).getImage());

    // JFileChooser class
    JFileChooser chooser = new JFileChooser();
    chooser.setFileSelectionMode(JFileChooser.FILES_ONLY);

    chooser.setMultiSelectionEnabled(true);
    chooser.setCurrentDirectory( new File( dirName ));

    FileNameExtensionFilter fileFilter = new FileNameExtensionFilter(description, extensions);
    chooser.setFileFilter(fileFilter);

    int result = chooser.showOpenDialog(frameWithIcon); // connect interface JFileChooser with UiBooster

    if (result == JFileChooser.APPROVE_OPTION) {
      return chooser.getSelectedFiles(); // many files
    }
    return null;
  }
}
