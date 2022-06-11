class Person extends AbstractPerson implements Router {
  
  void itsForMe(Letter l) {
    // To Do : implement this command (Step 3)
    replyTo(l);
  }
  
  void dontKnow(Person neighbor, Letter l) {
    // To Do : Implement this command (Step 4)
    forwardToAllExcept(neighbor, l);
  }
  
  void doKnow(Person neighbor, Letter l) {
    Person nextPerson = rememberHowToGetTo(getRecipient(l));
    forwardTo(nextPerson, l);
  }
  
  void discover(Person neighbor, Letter l) {
    // To Do : Implement this command (Step 5)
    if (!haveGottenPacketFrom(getSender(l))){
      memorizeHowToGetTo(getSender(l), neighbor);
    }
  }  
  
  /****
   * ---------------IGNORE CODE BELOW THIS LINE ---------------------------
   */
  
  Person(int idi, int xi, int yi, boolean _queueOnLeft){
    super(idi, xi, yi, _queueOnLeft);
  }
  
  Person(int idi, int xi, int yi) {
    this(idi, xi, yi, false); 
  }
  
}
