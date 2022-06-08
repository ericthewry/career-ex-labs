class Packet {
  
  int ttl;
  Router src;
  Router dst;
  View view;
  boolean isPayload;
  
  Packet(Router srci, Router dsti, boolean _payload, int xi, int yi) {
    ttl = 7;
    src = srci;
    dst = dsti;
    isPayload = _payload;
    PImage img = null;
    if (isPayload) {
      img = loadImage("packet.png");
    } else  {
      img = loadImage("arp_packet.png"); 
    }
    view = new View(img, xi, yi, PACKET_SIZE, PACKET_SIZE);
  }
  
  boolean equals (Object o){
    if (o instanceof Packet){
      Packet other = (Packet) o;
      return ttl == other.ttl && src.equals(other.src) && dst.equals(other.dst) && isPayload == other.isPayload;
    } else {
      return false;  
    }
  }
  
  // Depicts packet image
  void depict() {
    view.depict();
    if (view.mouseAbove()){
      fill(#474747);
      stroke(#474747);
      rect(view.left(), view.top()+10, 50, 30);
      fill(#FFFFFF);
      stroke(#FFFFFF);
      textSize(10);
      text("Rcv = " + dst.getId(), view.left() + 23, view.top() + 18);
      text("Snd = " + src.getId(), view.left() + 23, view.top() + 30); 
    }
  }
}
