import java.util.*;

interface Router {
  
  int getId();
  int getX();
  int getY();
  View getView();
  
  void moveTo(int x, int y);
  
  void setId(int i);
  //void setX(int x);
  //void setY(int y);
  void setView(View v);
  
  void depict();
  void depict_alerts();
  
  void step();
  void queuePacket(Router r, Router s, Packet p);
  
  boolean over();
  
  void setFwd(int destId, Router nextHop);
  void drawConnection(Router router);
  
  void mark();
  void unmark();
  boolean marked();
  
  void sendAPacketTo(Router dst);
  void receivePacket(Router from, Packet p);
  
}

class Process {
  Router from;
  Router dst;
  Packet p;
  
  Process(Router _from, Router _dst, Packet _p){
    from = _from;
    dst = _dst;
    p = _p;
  }
    
  void depict (float x, float y, float w, float h){
     p.view.x = int(x);
     p.view.y = int(y);
     p.view.w = int(w);
     p.view.h = int(h);
     p.depict();
   }
} // Process end

abstract class AbstractRouter implements Router {
  
  final int ROUTER_SIZE = 70;
  final float QUEUE_SPACING = 3;
  final float PACKET_WIDTH = PACKET_SIZE;
  final float PACKET_HEIGHT = PACKET_SIZE;
 
  final String DEFEND = "firewall.jpeg",
               ACCEPT = "check.png",
               REJECT = "oh.png",
               TIMEOUT = "ttl.png"; 
               
  final int ALERT_SIZE = 35,
            ALERT_TTA = 1,
            ALERT_MAX_TTA = 13;
  
  String imgString;
  
  int id;
  int x;
  int y;
  View view;
  List<View> accViews;
  Router[] fwd;
  Queue<Process> queue;
  Set<Integer> blacklist;
  Set<Integer> sentTo;
  
  
  int moveLadderX; 
  int moveLadderY;
  int moveSpaceY; 
  int movePacketY;
  float packetScaleFactor;
  
  boolean queueOnLeft = false;
  boolean drawOutline = false;
   
  int maxQueueSize = labNumber == 1? 10000 : 10; // the largest number of elements that can be in a queue at a time.
  
  AbstractRouter(int idi, int xi, int yi, String _imgString, boolean _queueOnLeft) {
    id = idi;
    x = xi;
    y = yi;
    queueOnLeft = _queueOnLeft;
    imgString = _imgString;
    PImage imgRouter = loadImage(imgString);

    view = new View(imgRouter, x, y, 70, 70);
    accViews = new ArrayList<View>();
    
    fwd = new Router[256];
    queue = new LinkedList<Process>();

    blacklist = new HashSet<Integer>();
    sentTo = new HashSet<Integer>();
    packetScaleFactor = 0.5; // can change in theory
  }
  
  AbstractRouter(int idi, int xi, int yi){
    this(idi, xi, yi, true); 
  }
  
  AbstractRouter(int idi, int xi, int yi, boolean _queueOnLeft){
     this(idi, xi, yi, "router.png", _queueOnLeft);
  }
  
  AbstractRouter(int idi, int xi, int yi, String _routerString){
     this(idi, xi, yi, _routerString, true);
  }
  
  void drawConnection(Router a) {
    view.connectTo(a.getView());
  }
  
  boolean isMyNumber(int _id) {
    return id == _id;
  }
  
  void moveTo(int _x, int _y) {
    x = _x;
    y = _y;
    view.x = _x;
    view.y = _y;
  }
  
  // Depicts router images
  void depict() {
    
    if (drawOutline) {
      strokeWeight(4);
      stroke(#FFDB76);
      fill(#FFFFFF);
      int offset = 3;
      rect(x - 0.5 * ROUTER_SIZE - offset, 
           y - 0.5 * ROUTER_SIZE - offset, 
           ROUTER_SIZE + 2*offset, 
           ROUTER_SIZE + 2*offset); 
      strokeWeight(2);
    }
    if (hasFailed()) {
      //print("Depict failed router", id, "\n");
      view = new View(loadImage("failed_router.png"), x, y, ROUTER_SIZE, ROUTER_SIZE);
    } 
    if (SHOW_QUEUE){
      drawQueue(); 
    }
    view.depict();
    showLabel();
  }
  
  void showLabel(){
    fill(#FFFFFF);
    textSize(24);
    text(id, x+8, y+18);
  }
  
  void depict_alerts(){
    for (View v : accViews){
      v.depict(); 
    }
 
  }
  
  float getQueueHorizOffset() {
    if (queueOnLeft) {
      return -1*(0.6 * ROUTER_SIZE + queueWidth());
    } else {
      return 0.6*ROUTER_SIZE;
    }
  }
  
  float getQueueVertOffset() {
    return -0.4 * queueHeight(); 
  }
  
  int amountInQueueFrom(Router sender) {
    Map<Integer, Integer> heavyHitters = new HashMap<Integer, Integer>();
    
    // populate the heavy hitters map by observing every element in the queue
    for (Process proc : queue) {
      Integer oldVal = heavyHitters.getOrDefault(proc.p.src.getId(), 0);
      heavyHitters.put(proc.p.src.getId(), oldVal + 1);
    }
    return heavyHitters.getOrDefault(sender.getId(), 0);
  }
  
  float portionOfQueueFrom(Router sender) {
    return float(amountInQueueFrom(sender)) / float(maxQueueSize); 
  }

  boolean blockSender(Router r) {
    return false;
  }
  
  boolean unblockSender(Router r){
    return false; 
  }
  
  
  boolean defend(Packet p) {
    if (p == null || p.src == null) return true;
    if (unblockSender(p.src)){
      blacklist.remove(p.src.getId()); 
    }
    
    if (blacklist.contains(p.src.getId())) return true;
    
    // if packetCount is too high, blacklist it
    // otherwise, return false
    if (blockSender(p.src)){
      blacklist.add(p.src.getId());
      return true;
    } else {
      return false; 
    }
  }
  
 boolean equals(Object o){
   if (o instanceof AbstractRouter){
     return id == ((AbstractRouter) o).getId();
   } else {
     return false;
   }  
 }
  
 // Avoids sending packet to self
 void receivePacket(Router from, Packet p) {
   if (p == null || from == null || p.src == null) return;
   if (hasFailed()) return;
   if (defend(p)) {
     addAlertView(DEFEND,from);
     return;
   }
   if (p.ttl == 0){
     addAlertView(TIMEOUT, from);
   }
   
   discover(from, p);
   
   if (id == p.dst.getId() ) {
     print("For", id, ", ");
     if (p.isPayload) {
       print("a payload packet ");
       sentTo.add(p.src.getId());
       queuePacket(from, p.dst, p); 
       addAlertView(ACCEPT, from);
     } else if (contactEstablished(p.src)) {
       
       print("with contact established to", p.src.getId(), " ");
       if (sentTo.contains(p.src.getId())){
         print("and we've already send a letter there", p.src.getId(), " ");
         addAlertView(REJECT, from);
         println(" --- REJECT");
       } else {
         print("and we've never sent a letter there", p.src.getId(), " ");
         sentTo.add(p.src.getId());
         queuePacket(from, p.dst, p); 
         println(" --- ACCEPT AND QUEUE PACKET");
         addAlertView(ACCEPT, from);
       }
     }  else {
       print("without contact established to", p.src.getId(), " ");
       if (sentTo.contains(p.src.getId())){
         print("And we've already sent to ", p.src.getId());
         addAlertView(REJECT, from);
         println(" --- REJECT");
       } else {
         print("and we've never sent a letter there", p.src.getId(), " ");
         addAlertView(ACCEPT, from);
         sentTo.add(p.src.getId());
         queuePacket(from, p.dst, p);
         println(" --- ACCEPT AND QUEUE PACKET FOR FLOODING");
       }
     }
   } else {
     
     println("the packet's for ", p.dst.getId(), ", not me [", id,"] so queue it.");
     queuePacket(from, p.dst, p);
   }
 }
 
 void addAlertView(String imgStr, Router from) {
   View v = new View(loadImage(imgStr), view.x, view.y, ALERT_SIZE, ALERT_SIZE);
   v.interpolateAndMove(from.getX(), from.getY(), ALERT_TTA, ALERT_MAX_TTA);
   accViews.add(v);
 }
 
 
 void queuePacket(Router from, Router dst, Packet p){
   if (hasFailed()) return; 
   queue.add(new Process(from, dst, p));
 }  
 
 
   // performs a step of egress processing
 void step(){
   accViews.clear();
   if (hasFailed()) return;
   
   // remove one from queue
   Process toSend = queue.poll(); 
   if (toSend != null && toSend.p.ttl != 0 && toSend.p.dst != null) {
     if (toSend.p.dst.getId() == id) {
       // Respond
       sentTo.add(toSend.p.src.getId());
       itsForMe(toSend.p);
     } else {
      sendPacket(toSend.from, toSend.dst, toSend.p);
     } 
   }
 }
   
 void sendAPacketTo(Router dst) {
   //sentTo.add(dst.getId());
   queuePacket(this, dst, new Packet(this, dst, contactEstablished(dst), x, y)); 
 }
 
 boolean hasFailed(){
   //print(id, "queue size = ", queue.size(), "max size =", maxQueueSize,"\n");
   if (queue.size() > maxQueueSize){
     //print(id, "has failed\n");
     return true;
   } else return false;
 }
 
  
  // Sends packet to next unless it's null; if it's null and it's not at next
  // that means the packet isn't there, so flood
  void sendPacket(Router from, Router dst, Packet p) {
    if (hasFailed() || dst == null || p.dst == null) return;
    Router next = fwd[dst.getId()];
      
    if (next != null) {
      doKnow(next, p);
    } else { // Flood
      dontKnow(from, p);
    }
  }
  
    

  float queueWidth() {
    return 2 * QUEUE_SPACING + packetScaleFactor * PACKET_WIDTH;
  }
  
  float queueHeight() {
    return QUEUE_SPACING + maxQueueSize * (QUEUE_SPACING + packetScaleFactor * PACKET_HEIGHT);
  }
  
  float queueLeft() {    
    return x + getQueueHorizOffset();
  }
    
  float queueTop() { 
    return y + getQueueVertOffset();
  }
    
  void drawQueue() {
      
    // Outside space
    stroke(#B4B4B4);
    fill(#B4B4B4);
    rect(queueLeft(), queueTop(), queueWidth(), queueHeight());
      
    // Inside space
    //float dY = 0;
    for (int k = 0; k < maxQueueSize; k++) {
      stroke(#B4B4B4);
      fill(#B4B4B4);
      //println(k, moveSpaceY);
      moveSpaceY = int(k * (packetScaleFactor * PACKET_HEIGHT + QUEUE_SPACING));
      float x = queueLeft() + QUEUE_SPACING;
      float y = queueTop() + QUEUE_SPACING + moveSpaceY;
      float w = packetScaleFactor * PACKET_WIDTH;
      float h = packetScaleFactor * PACKET_HEIGHT;
      fill(#C9C9C9);  
      rect(x, y, w, h);

    }
    
    for(int k = queue.size() - 1; k >= 0; k--){
      if (queue.toArray()[k] == null) continue;
      moveSpaceY = int(k * (packetScaleFactor * PACKET_HEIGHT + QUEUE_SPACING));
      float x = queueLeft() + QUEUE_SPACING;
      float y = queueTop() + QUEUE_SPACING + moveSpaceY;
      float w = packetScaleFactor * PACKET_WIDTH;
      float h = packetScaleFactor * PACKET_HEIGHT;
      Process process = (Process) queue.toArray()[k];
      process.depict(x+w*0.5, y + h*0.5, w, h);
    }
  }
  void mark() {
     drawOutline = true;  
  }
  
  void unmark() {
    drawOutline = false; 
  }
  
  boolean marked() {
    return drawOutline; 
  }
  
  boolean over() {
    return view.mouseAbove(); 
  }
    
  // *********** Implemented  by students
  
  abstract void itsForMe(Packet p);  
  abstract void dontKnow(Router from, Packet p);
  abstract void doKnow(Router from, Packet p);
  abstract void discover(Router neighbor, Packet p);
  
  // **** End implemented by students
  
  // *** Helper methods for students 
  void replyTo(Packet p) {
    boolean conn = contactEstablished(p.src);
    Packet msg = new Packet(this, p.src, conn, x, y);
    sendPacket(this, p.src, msg);
  }
  
  void forwardToAll(Packet p){
    Set<Router> mySet = (Set<Router>) new HashSet<Router>(Arrays.asList(fwd));
        
    for (Router nextHop : mySet) {
       if (nextHop != null) {
          //print("forwarding", this.id, nextHop.id, dst.id, "\n");
          myNetwork.inTransit.add(new Transit(MAX_TTA-1, p, this, nextHop));
        }
    } 
  }
  
  void forwardToAllExcept(Router from, Packet p){
    Set<Router> mySet = (Set<Router>) new HashSet<Router>(Arrays.asList(fwd));
        
    for (Router nextHop : mySet) {
       if (nextHop != from && nextHop != null) {
          //print("forwarding", this.id, nextHop.id, dst.id, "\n");
          myNetwork.inTransit.add(new Transit(MAX_TTA-1, p, this, nextHop));
        }
    } 
  }
  
  Router getRandomNeighbor(){
    int idx = 0;
    do {
      idx = int(Math.round(Math.random() * 100)) % fwd.length;
    } while (fwd[idx] == null);
    return fwd[idx];
    
  }
  
  Router getRandomNeighborExcept(Router r){
     Router randR = getRandomNeighbor();
     while (r == randR) {
       randR = getRandomNeighbor(); 
     }
     return randR;
  }
  
  Router getNextHop(Packet p) {
    return fwd[p.dst.getId()];    
  }
  
  Router rememberHowToGetTo(Router r) {
    return fwd[r.getId()];
  }
  
  void forwardTo(Router next, Packet p) {
    if((new HashSet<Router>(Arrays.asList(fwd))).contains(next)) {
     myNetwork.inTransit.add(new Transit(MAX_TTA-1, p, this, next));
    } else {
      throw new Error("ForwardTo Exception: Cannot Forward to " + next.getId() + " from " + this.getId());
    }
  }
  
  
  Router getSender(Packet p) {
    return p.src; 
  }
    
  Router getRecipient(Packet l) {
    return l.dst;
  }
  
  void learnNextHop(Router recipient, Router nextHop){
    fwd[recipient.getId()] = nextHop;
  }
  
  boolean contactEstablished(Router r) {
    return fwd[r.getId()] != null;
  }
  
    
  boolean haveGottenLetterFrom(Router p) {
    return contactEstablished(p);
  }
  
  boolean haveGottenPacketFrom(Router p) {
    return contactEstablished(p);
  }
  
  void memorizeHowToGetTo(Router dst, Router nh) {
    learnNextHop(dst, nh); 
  }
  
  // *** Accessor Methods
  
  int getId() { return id; }
  int getX() { return x; }
  int getY() { return y; }
  View getView() { return view; }
  
  void setId(int _id) { id = _id; }
  void setX(int _x) { x = _x; }
  void setY(int _y) { y = _y; }
  void setView(View _view) { view = _view; }
  
  void setFwd(int destId, Router nextHop) {
      fwd[destId] = nextHop;  
  }
    
} // Router end


abstract class AbstractPerson extends AbstractRouter implements Router {
  
  AbstractPerson(int idi, int xi, int yi, boolean _queueOnLeft){
    super(idi, xi, yi, "person.png", _queueOnLeft);
  }
  
  AbstractPerson(int idi, int xi, int yi) {
    this(idi, xi, yi, false); 
  }
  
  void itsForMe(Packet p){
    if (p instanceof Letter){
      itsForMe((Letter) p);
    } else {
      itsForMe(new Letter(p)); 
    }
  }
  
  void dontKnow(Router from, Packet p){
    if (from instanceof Person){
      if (p instanceof Letter){
        dontKnow((Person) from, (Letter) p); 
      } else {
        dontKnow((Person) from, new Letter(p));
      }
    }
  }
  
  void doKnow(Router from, Packet p) {
    if (from instanceof Person) {
      if (p instanceof Letter) {
        doKnow((Person) from, (Letter) p);
      } else {
        doKnow((Person) from, new Letter(p));
      }
    }
  }
  
  void discover(Router from, Packet p) {
    if (from instanceof Person) {
      if (p instanceof Letter){
       discover((Person) from, (Letter) p); 
      } else {
       discover((Person) from, new Letter(p.src, p.dst, p.isPayload, p.view.x, p.view.y));
      }
    }
  }

  abstract void itsForMe(Letter p);
  abstract void dontKnow(Person from, Letter p);  
  abstract void doKnow(Person from, Letter p);
  abstract void discover(Person neighbor, Letter p);
  
  @Override 
  void showLabel(){
    fill(#000000);
    textSize(24);
    text(id, x, y-50); // for people 
  }
  
  Person getRandomNeighbor(){
    return (Person) super.getRandomNeighbor();
  }
  
  Person getRandomNeighborExcept(Router r){
    return (Person) super.getRandomNeighborExcept(r);
  }
  
  Person getSender(Letter l) {
    return (Person) l.src; 
  }
  
  Person getRecipient(Letter l) {
    return (Person) l.dst;
  }
  
  Person rememberHowToGetTo(Person p) {
     return (Person) super.rememberHowToGetTo(p);
  }

  
}



abstract class DDoSRouter extends AbstractRouter implements Router {
  
  Router target;
  int numberAtkPackets = 0;
  int numberSteps = 0;
  
  DDoSRouter (Router _target, int _id, int _x, int _y){
    super(_id, _x, _y);
    target = _target;
    view = new View(loadImage("bad_router.png"), x, y, 70, 70);
    maxQueueSize = 10;
  }
 
  @Override
  void step() {
    println("stepping ddos router", id);
    if (hasFailed()) return;
    if (target != null) {
      evilDoEveryStep(target);
    }
    fill_queue();
    for (int i = 0; i < numberAtkPackets + numberSteps; i++){
      super.step();
    }
    numberAtkPackets = 0;
    numberSteps = 0;
  }
  
  void fill_queue(){
    println("Calling fill_queue for", id, "with ", numberAtkPackets, " packets");
    if (target == null)  return;
    println("\tTarget is not null for", id);
    for (int i = 0; i < numberAtkPackets; i++){
      queuePacket(this, target, targetPacket());
    }
  }
  
  void setTarget(Router t){
    target = t; 
  }
  
  Packet targetPacket(){
    return new Packet(this, target, contactEstablished(target), x, y); 
  }
  
  @Override
  void sendPacket(Router from, Router dst, Packet p){
    if (target == null || from == null || dst == null) return;
    if (p.dst.getId() == target.getId()){
      println("Sending packet to target", dst.getId());
      super.sendPacket(from, dst, p);
    }
  }
  
  @Override
  void receivePacket(Router from, Packet p) {
    numberSteps++;
    super.receivePacket(from,p);
  }
  
  @Override 
  void sendAPacketTo(Router r){
    setTarget(r);
    numberAtkPackets++;
    //super.sendAPacketTo(r);
  }
  
  void discover(Router neighbor, Packet l){
    learnNextHop(getSender(l), neighbor);
  }
  
  @Override
  boolean hasFailed() { return false; }
 
  //@Override
  //void drawQueue() { return; }
  
   
  @Override 
  void doKnow(Router neighbor, Packet p) {
    evilDoKnow(neighbor, p);
  }
  
  @Override 
  void dontKnow(Router neighbor, Packet p) {
    evilDontKnow(neighbor, p); 
  }
  
  @Override 
  void itsForMe(Packet p) {
    evilItsForMe(p); 
  }
  
  abstract void evilDontKnow(Router neighbor, Packet p);
  abstract void evilDoKnow(Router neighbor, Packet p);
  abstract void evilItsForMe(Packet p);
  abstract void evilDoEveryStep(Router p);
} 
 
