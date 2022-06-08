class Transit {
  int tta;
  Packet p;
  Router from;
  Router to;
  int count;
  
  Transit(int ttai, Packet pi, Router fromi, Router toi) {
    tta = ttai;
    p = new Packet(pi.src, pi.dst, pi.isPayload, pi.view.x, pi.view.y);
    p.ttl = pi.ttl - 1;
    from = fromi;
    to = toi;
    count = 1;
  }
  
  void depict() {
    p.depict();
    if (count > 1) depictLabel();
  }
  
  void depictLabel() {
    if (p.isPayload){
      fill(#000000);
    } else {
      fill(#1F9CFF);
    }
    textSize(24);
    text(count, p.view.x, p.view.y); 
  }

  void increment(){
    count++; 
  }
  
  boolean equals(Object o){
    if (o instanceof Transit) {
      Transit other = (Transit) o;
      return tta == other.tta && p.equals(other.p) && from.equals(other.from) && to.equals(other.to); 
    } else {
      return false;
    }
  }

  int interpolate(int n1, int n2) {
    return p.view.interpolate(n1, n2, tta, MAX_TTA);
  }
  
  void jiggle ()  {
    View start, end;
    if (from.getId() > to.getId()) {
      //p.view.x += 15;
      //p.view.y -= 15;
      //p.view.x = p.view.x + slopeSign * 15;
      //p.view.y = p.view.y - slopeSign * 15;
      start = from.getView();
      end = to.getView();
      if (start.x > end.x) { 
        if (start.y > end.y) { // start low right end up left
          p.view.x += 15;
          p.view.y -= 15;
        } else { // start high right end low left
          p.view.x -= 15;
          p.view.y -= 15;
        }
      } else {
        if (start.y > end.y) { // start low left end  high right
          p.view.x -= 15;
          p.view.y -= 15;
        } else { // start high left end low right
          p.view.x += 15;
          p.view.y -= 15;
        }
      }
    } else {
      //p.view.x -= 15;
      ////p.view.y += 15;
      //p.view.x = p.view.x - slopeSign * 15;
      //p.view.y = p.view.y + slopeSign * 15;
      start = from.getView();
      end = to.getView();
      if (start.x > end.x) { 
        if (start.y > end.y) { // start low right end up left
          p.view.x -= 15;
          p.view.y += 15;
        } else { // start high right end low left
          p.view.x += 15;
          p.view.y += 15;
        }
      } else {
        if (start.y > end.y) { // start low left end  high right
          p.view.x += 15;
          p.view.y += 15;
        } else { // start high left end low right
          p.view.x -= 15;
          p.view.y += 15;
        }
      }
    }    
  }
  
  // Updates position of packet and tta
  boolean step() {
    p.view.x = interpolate(from.getX(), to.getX());
    p.view.y = interpolate(from.getY(), to.getY());
    jiggle();

    p.view.rotateView(from.getX(), from.getY(), to.getX(), to.getY());
    
    if (tta == 0) {
      for (int i = 0; i < count; i++){ 
        to.receivePacket(from, new Packet(p.src, p.dst, p.isPayload, p.view.x, p.view.y));
      }
      return true;
    } else {
      tta = tta - 1;
      return false;
    }
  }
}
