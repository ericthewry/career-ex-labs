class Person extends AbstractPerson implements Router {
  
  void itsForMe(Letter l) {
    // To Do : implement this command (Step 3)
  }
  
  void dontKnow(Person neighbor, Letter l) {
    // To Do : Implement this command (Step 4)
  }
  
  void doKnow(Person neighbor, Letter l) {
    Person nextPerson = rememberHowToGetTo(getRecipient(l));
    forwardTo(nextPerson, l);
  }
  
  void discover(Person neighbor, Letter l) {
    // To Do : Implement this command (Step 5)
  }  
  
/*
 * -------------------------IGNORE CODE BELOW THIS LINE-------------------------
 */
  
  Person(int idi, int xi, int yi, boolean _queueOnLeft) {
    super(idi, xi, yi, _queueOnLeft);
  }
  
  Person(int idi, int xi, int yi) {
    this(idi, xi, yi, false); 
  }
  
}
