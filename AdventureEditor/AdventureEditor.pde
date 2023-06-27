// Adventure editor - v0.1

import controlP5.*;

ControlP5 _cp5, _cp5_2;
Editor e;

void setup() {
  size(1280, 720);
  surface.setTitle("Editor de Aventuras - v1.0");

  _cp5 = new ControlP5(this);
  _cp5_2 = new ControlP5(this);

  // Gambiarra que tive que fazer para criar 2 ControlP5 diferentes....
  // um pra tela initScreen e outro para a tela EditorScreen
  e = new Editor(_cp5, _cp5_2);

  colorMode(RGB);

  // ----------- FEITO PARA TESTES ------------------------
  
  // ----------- FEITO PARA TESTES ------------------ [ FIM ]
}

void draw() {
  e.render();
}

void mousePressed() {
  e.mouseHasPressed();
}

void mouseReleased() {
  e.mouseHasReleased();
}

void keyPressed() {
  //println(keyCode);

  if ( keyCode == 37 ) e.DEBUG_changeEditState( EDITOR_SUB_STATES.EDIT ); // ARROW LEFT -> Tela de edição do frame ( controle dos hotspots )
  if ( keyCode == 38 ) e.DEBUG_changeEditState( EDITOR_SUB_STATES.MENU ); // ARROW UP -> Tela inicial ( menu )
  if ( keyCode == 39 ) e.DEBUG_changeEditState( EDITOR_SUB_STATES.PLAY ); // ARROW RIGHT -> Tela do player ( teste )
  if ( keyCode == 71 ) e.DEBUG_changeEditState( EDITOR_SUB_STATES.GRAPH ); // "G" -> Graph Screen [DEBUG]

  if ( keyCode == 72 ) e.changeVisibilityHotSpotsInPlayer(); // in player screen -> show/hide hotspots -> key "H"
  if ( keyCode == 83 ) e.saveCurrentState(); // save state -> key "S" ( quiky save )
}

void exit() {
  e.exitWindow();
}

/* Código para apresentar a tela do player<PlayerScreen> ( em vez do editor )*/
/*PlayerScreen pScreen;
 
 void setup() {
 size(1280, 720);
 
 pScreen = new PlayerScreen( new ControlP5(this) );
 
 colorMode(RGB);
 }
 
 void draw() {
 pScreen.render();
 }
 
 void mousePressed() {
 pScreen.mouseHasPressed();
 }
 
 void mouseReleased() {
 pScreen.mouseHasReleased();
 }
 
 void keyPressed() {
 if ( keyCode == 40 ) pScreen.backToMenuScreen(); // Arrow Down
 }*/
