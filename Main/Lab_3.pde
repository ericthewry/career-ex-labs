class DefenseRouter extends UnsafeRouter implements Router {
  DefenseRouter(int idi, int xi, int yi, boolean _queueOnLeft){
    super(idi, xi, yi, _queueOnLeft);
    maxQueueSize = 10;
  }
  
  DefenseRouter(int idi, int xi, int yi) {
    this(idi, xi, yi, false); 
  }
  
  boolean blockSender(Router sender) {
    // To Do (Step 2) : Implement this command
    return false;
  }
  
  boolean unblockSender(Router sender) {
    // To Do (Step 3) : Implement this command    
    return false; 
  }
  
}
