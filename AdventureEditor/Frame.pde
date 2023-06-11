class Frame {
  PImage frameImg = createImage(0, 0, RGB);
  String frameImgRef;
  Hotspot selectedHotspot; // ?
  ArrayList<Hotspot> hotspots = new ArrayList<Hotspot>();

  private String frameName = "";

  Frame(String imageRef) {
    this.frameImgRef = imageRef;
    this.setFrameName( imageRef );
  }

  public void setFrameName( String framename ) {
    this.frameName = framename;
  }

  public String getFrameName() {
    return this.frameName;
  }

  public String getImageRef() {
    return this.frameImgRef;
  }

  void addHotspot(float x1, float y1, float x2, float y2, int targetIndex) {
    Hotspot tmp = new Hotspot(x1, y1, x2, y2, targetIndex);
    hotspots.add(tmp);
  }

  public int getNextFrameIndex(Hotspot hotspot) {
    return hotspot.getTargetIndex();
  }

  public int getNumberOfHotSpots() {
    return this.hotspots.size();
  }


  public void renderHotSpotsInFrame() {

    for (int i = 0; i < hotspots.size(); i++) {
      try {
        hotspots.get(i).drawHotspot();
      }
      catch(NullPointerException e) {
        println("[ERROR] -> FRAME:renderHotSpotsInFrame = ", e);
      }
    }
  }

  public void hotspotDrawHandler() {
    for (int i = 0; i < hotspots.size(); i++) {
      try {
        hotspots.get(i).drawHotspot();
      }
      catch(NullPointerException e) {
        e.printStackTrace();
      }
    }
  }
}
