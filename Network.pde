import java.util.*;

class Network {
  ArrayList<Transit> inTransit;
  
  Router[] routers;
  
  View view;

  Network () {
    inTransit = new ArrayList<Transit>(17);
    
    if (labNumber == 1) {
      routers = new Person[7];
      routers[0] = new Person(0, 240, 95);
      routers[1] = new Person(1, 660, 105, false); // puts queue on right
      routers[2] = new Person(2, 190, 300);
      routers[3] = new Person(3, 445, 225);
      routers[4] = new Person(4, 780, 370, false); // puts queue on right
      routers[5] = new Person(5, 290, 500);
      routers[6] = new Person(6, 610, 500);
      //routers[6] = new DDoSRouter(routers[3], 6, 610, 500);
    } else if (labNumber == 2) {
      routers = new AbstractRouter[7];
      routers[0] = new UnsafeRouter(0, 240, 95);
      routers[1] = new UnsafeRouter(1, 660, 105, false); // puts queue on right
      routers[2] = new UnsafeRouter(2, 190, 300);
      routers[3] = new UnsafeRouter(3, 445, 225);
      routers[4] = new UnsafeRouter(4, 780, 370, false); // puts queue on right
      routers[5] = new UnsafeRouter(5, 290, 500);
      routers[6] = new UnsafeRouter(6, 610, 500); 
    } else if (labNumber == 3) {
      routers = new AbstractRouter[7];
      routers[0] = new DefenseRouter(0, 240, 95);
      routers[1] = new DefenseRouter(1, 660, 105, false); // puts queue on right
      routers[2] = new DefenseRouter(2, 190, 300);
      routers[3] = new DefenseRouter(3, 445, 225);
      routers[4] = new DefenseRouter(4, 780, 370, false); // puts queue on right
      routers[5] = new DefenseRouter(5, 290, 500);
      routers[6] = new DefenseRouter(6, 610, 500);      
    }
    
    addConn(2,0);
    addConn(2,5);
    addConn(0,5);
    addConn(0,3);
    addConn(5,6);
    addConn(3,1);
    addConn(3,4);
    addConn(3,6);
    addConn(4,1);
    addConn(4,6);
  }
  
  void drawNetwork() {
    
    addConn(2,0);
    addConn(2,5);
    addConn(0,5);
    addConn(0,3);
    addConn(5,6);
    addConn(3,1);
    addConn(3,4);
    addConn(3,6);
    addConn(4,1);
    addConn(4,6);
    
    for (Router r : routers) {
      r.depict();
    }
    
    for (Transit t : myNetwork.inTransit) {
      t.depict();
    } 
    
    for (Router r : routers) {
      r.depict_alerts(); 
    }
  }
  
  void sendAllPackets() {
   //a.queuePacket(a, g, new Packet(a, g, false, a.x, a.y));
   //b.queuePacket(b, c, new Packet(b, c, false, b.x, b.y));
   //c.queuePacket(c, a, new Packet(c, b, false, c.x, c.y));
   ////d.queuePacket(d, e, new Packet(d, e, false, d.x, d.y));
   //routers[4].queuePacket(routers[4], routers[2], 
   //  new Packet(routers[4], routers[2], false, routers[4].getX(), routers[4].getY()));
  }
  
  void stepAllRouters(){
    for (Router r : routers) r.step(); 
  }
  
  // replaces router r with router s
  void replaceRouter(Router r, Router s){
    if (r != null && s != null)
      routers[r.getId()] = s;    
  }
  
  void unifyTransit() {
    for (int i = 0; i < inTransit.size(); i++ ){
      Transit outer = inTransit.get(i);
      for (int j =  i + 1; j < inTransit.size();) {
        Transit inner = inTransit.get(j);
        if (outer.equals(inner)) {
          outer.increment();
          inTransit.remove(j);
        } else {
          j++;
        }
      }
    }
  }
  
  Router overRouter() {
    for (Router r : routers) {
      if (r.over()) {
        return r; 
      }
    }
    return null;
  }
  
  void addConn(int rid, int sid){
    addConnect(routers[rid], routers[sid]);
  }
  
} // Network end

// Adds connection
void addConnect(Router r, Router s) {
  s.setFwd(r.getId(), r);
  r.setFwd(s.getId(), s);
  r.drawConnection(s);
}
