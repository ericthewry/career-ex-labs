class Letter extends Packet {

  
  Letter(Router srci, Router dsti, boolean _payload, int xi, int yi){
    super(srci, dsti, _payload, xi, yi);
  }
  
  Letter(Packet p){
    this(p.src, p.dst, p.isPayload, p.view.x, p.view.y); 
  }
  
}
