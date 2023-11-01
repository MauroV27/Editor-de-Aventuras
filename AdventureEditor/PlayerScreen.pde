import controlP5.*;
import uibooster.*;

class PlayerScreen implements Callable {

  private Player player; // component

  private ControlP5 cp5;
  private UiBooster booster;

  private boolean isPlaying = false;

  PFont font1;
  String nomeCaminho = "...";
  String pergunta1 = "Escolha uma arquivo: ";

  PlayerScreen(ControlP5 ref) {
    this.cp5 = ref;
    this.booster = new UiBooster();

    this.player = new Player();

    loadScreenElements();

    this.player.setCaller( this );
  }

  public void loadScreenElements() {

    //float _w_percenet = this.player.getWidthPercentage();   // width / 100
    //float _h_percenet = this.player.getHeightPercentage();  // height / 100
    ControlFont font = new ControlFont(createFont("Arial", 14));

    Button b = this.cp5.addButton("Jogar")
      .setValue(0)
      .setPosition(width/9 * 4, height/9 * 5)
      .setSize( int(width/8), 50)
      .plugTo(this, "startGame")
      ;

    b.getCaptionLabel().setFont(font);

    Button b1 = this.cp5.addButton("Ler/Importar Fase")
      .setValue(0)
      .setPosition(width/9 * 4, height/9 * 4)
      .setSize(int(width/8), 50)
      .plugTo(this, "dialogImport")
      ;

    b1.getCaptionLabel().setFont(font);

    //this.cp5.addButton("Menu Principal")
    //  .setValue(0)
    //  .setPosition(width/9 * 7, height/20 * 1)
    //  .setSize(width/9 * 1, 50)
    //  .plugTo(this, "telaMenu")
    //  ;

    noStroke();
    //frameRate(60);
    //Estado inicial do player ---------------------
    //currentFrame = 1;
    this.telaMenu();
  }

  private void telaMenu() {
    //FUNDO
    background(255);
    noFill();
    stroke(0);
    //line(width/2, 0, width/2, height);
    rect(width/9 * 3, height/9 * 2, (width/9) * 3, (width/9) * 3);
    rect(width/3 * 1 + 30, height/30 * 11, width/3 * 1 - 60, (width/30) * 1);

    //FONTE
    //font1 = loadFont("MiriamMonoCLM-Book-48.vlw");
    fill(0);
    //textFont(font1, 24);
    textSize(width/40);
    text("Menu Principal", width/10 * 4.2, 120);
    textSize(width/60);
    //text(pergunta1, width/10 * 5 - (pergunta1.length() * 5) - 10, 250);
    fill(150);
    text(nomeCaminho, width/10 * 5 - ((nomeCaminho.length() * 5) - 5), height * 0.4);//290/720 -> 29/72 ~ 0.4
  }

  public void startGame() {
    if ( this.player.frames.size() <= 0 ) {
      this.dialogError("Você precisa Importar uma fase", "Error");
      this.showPlayerStartScreen();

      this.telaMenu();
      this.isPlaying = false;
    } else {
      this.closeGame();
    }
  }

  public void closeGame() {
    this.hidePlayerStartScreen();
    this.isPlaying = true;

    this.player.play();
  }

  public void dialogImport() {

    booster = new UiBooster();

    //File filePath = booster.showFileSelectionFromPath( sketchPath("data"), "Selecione um arquivo json", "json");
    File folderPath = booster.showDirectorySelection();
    //println("Nome do arquivo de import: " + filePath.getName());

    //if ( filePath.getName().endsWith(".json") == false ) {
    //  String message = "Falha ao importar o arquivo - " + filePath.getName() + " - este não é um arquivo JSON valido. Tente com um arquivo valido.";
    //  this.dialogError(message, "error");
    //  this.nomeCaminho = "...";
    //  return;
    //}

    this.player.importJSONFile( folderPath.getAbsolutePath() );

    if ( this.player.frames.size() <= 0 ) {
      String message = "Falha ao importar o arquivo - " + folderPath.getName() + " - . Tente com um arquivo valido.";
      this.dialogError(message, "error");
      this.nomeCaminho = "...";
    } else {
      String message = "O arquivo - " + folderPath.getName() + " - foi lido com sucesso.";
      this.dialogSuccess(message);

      this.nomeCaminho = folderPath.getName();
    }
  }

  // methods for comunicate player with external input -------

  public void render() {
    if ( this.isPlaying ) {
      this.player.renderPlayer();
    } else {
      this.telaMenu();
    }
  }

  public void mouseHasPressed() {
    this.player.mouseHasPressed();
  }

  public void mouseHasReleased() {
    this.player.mouseHasReleased();
  }

  public void backToMenuScreen() {
    this.showPlayerStartScreen();
    this.isPlaying = false;

    this.player.setCurrentFrame( this.player.getMainFrameIndex() ); // restar current frame to main frame in game
  }

  // ---------------------------------------------------------

  public void backToInitScreen() {
    backToMenuScreen();
  }

  // methods for auxialiate ui elements ----------------------

  private void showPlayerStartScreen() { // show all elements of cp5
    for ( ControllerInterface elem : this.cp5.getAll() ) {
      elem.show();
    }
  }

  private void hidePlayerStartScreen() { // hide all elements of cp5
    for ( ControllerInterface elem : this.cp5.getAll() ) {
      elem.hide();
    }
  }

  private void dialogError(String text, String title) {
    booster = new UiBooster();
    booster.showErrorDialog(text, title);
  }

  private void dialogSuccess(String text) {
    booster = new UiBooster();
    booster.showInfoDialog(text);
  }

  //private void
}
