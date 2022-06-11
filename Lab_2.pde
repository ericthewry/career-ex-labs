class EvilRouter extends DDoSRouter implements Router {
  
  void evilDoEveryStep(Router target) {
    // ToDo : Implement this command!
  }
 
  void evilItsForMe(Packet p) {
    if (getSender(p) == target) {
      dontSendPacket();
    } else {
      replyTo(p);
    }
  }
  
  void evilDontKnow(Router neighbor, Packet p) {
    forwardToAllExcept(neighbor, p);
  }
  
  void evilDoKnow(Router neighbor, Packet p) {
      forwardTo(rememberHowToGetTo(neighbor), p);
  }  
  
  /** 
   * Don't worry about these lines of code below here -----
   **/
  
  EvilRouter (Router _target, int _id, int _x, int _y) {
    super(_target, _id, _x, _y);
  }
  
  EvilRouter (int _id, int _x, int _y) {
    this(null, _id, _x, _y);
  }
  
  /** Don't worry about about code above this line ---- **/
  
}

class UnsafeRouter extends AbstractRouter implements Router {
  
  void itsForMe(Packet p) {
    replyTo(p);
  }
  
  void dontKnow(Router neighbor, Packet p) {
    forwardToAllExcept(neighbor, p); 
  }
  
  void doKnow(Router neighbor, Packet p) {
    forwardTo(rememberHowToGetTo(getRecipient(p)), p);
  }
  
  void discover(Router neighbor, Packet p) {
    if (!haveGottenPacketFrom(p.src)) {
      memorizeHowToGetTo(getSender(p), neighbor);
    }
  }
  
/*
 * -------------------------IGNORE CODE BELOW THIS LINE-------------------------
 */

  UnsafeRouter(int idi, int xi, int yi, boolean _queueOnLeft) {
    super(idi, xi, yi, _queueOnLeft);
  }
  
  UnsafeRouter(int idi, int xi, int yi) {
    this(idi, xi, yi, false); 
  }

}
