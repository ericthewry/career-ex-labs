class DefenseRouter extends UnsafeRouter implements Router {

  boolean blockSender(Router sender) {
    return false;
  }
  
  boolean unblockSender(Router sender) {    
    return false; 
  }
  
  
  DefenseRouter(int idi, int xi, int yi, boolean _queueOnLeft){
    super(idi, xi, yi, _queueOnLeft);
    maxQueueSize = 10;
  }
  
  DefenseRouter(int idi, int xi, int yi) {
    this(idi, xi, yi, false); 
  }
    
}
