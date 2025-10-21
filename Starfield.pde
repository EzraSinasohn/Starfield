int num = 50, numDucks = 10, direction = 1, startSide = -70, startTime = 60, timer = startTime, score = 0, relativeTime = 0, laserTime = 0, laserReq = 10;
float g = 0.5, floorY = 100;
boolean keys[], laserOn;

PImage wingsUp, wingsDown, flap, dead;

Particle[] particle = new Particle[num];
Particle[] tempList;
OddballParticle[] duck = new OddballParticle[numDucks];
Crosshair ch = new Crosshair(width/2, height/2);


void setup() {
  background(50, 150, 255);
  //fullScreen();
  size(1000, 1000);
  noCursor();
  textAlign(CENTER, CENTER);
  keys = new boolean[5];
  keys[0] = false;
  keys[1] = false;
  wingsUp = loadImage("DuckHuntWingsUp.png");
  wingsDown = loadImage("DuckHuntWingsDown.png");
  flap = loadImage("DuckHuntFlapping.png");
  dead = loadImage("Raw_Chicken_JE3_BE3.png");
  for(int i = 0; i < particle.length; i++) {particle[i] = new Particle(width/2, height/2, 0, 0, 0);}
  for(int i = 0; i < duck.length; i++) {
    if(Math.random() >= 0.5) {
      direction = 1;
    } else {
      direction = -1;
    }
    duck[i] = new OddballParticle(startSide+Math.random()*100, Math.random()*(height-200)+50, (2.9/2)*((int) (Math.random()*2)+1)*direction, 0, 0, 3, 255);
  }
}
void draw() {
  background(100, 150, 255);
  makeFloor();
  if(timer >= 0) {
    for(int i = 0; i < duck.length; i++) {
      if(duck[i].hit > 0) {
        duck[i].fly();
      } else {
        duck[i].gotShot();
      }
      duck[i].show();
    }
      for(int i = 0; i < particle.length; i++) {
        if(particle[i].op != 0) {
          particle[i].hitFloor();
          particle[i].move();
          particle[i].show();
        }
      }
    ch.move();
    ch.show();
    fill(0);
    textSize(64);
    text(score, 64, 64);
    timer = relativeTime + startTime - (int) (millis()/1000);
    text(timer, width-64, 64);
    if(laserOn) {laserBeam();}
  } else {
    fill(0);
    textSize(128);
    text(score, width/2, height/2+64);
    text("Your score:", width/2, height/2-64);
  }
  if(score == laserReq && !laserOn) {
    laserOn = true;
    laserTime = timer;
    laserReq += 10;
  }
  if(laserOn) {
    stroke(0);
    fill(255, 0, 0);
    textSize(50);
    text("LASER EQUIPPED", width/2, height-50);
  } else {
    stroke(0);
    fill(255, 0, 0);
    textSize(50);
    text("Laser in " + (laserReq-score) + " kills.", width/2, height-50);
  }
}
class Particle {
  double x, y, vx, vy;
  int op;
  public Particle(double x, double y, double vx, double vy, int op) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.op = op;
  }
  void move() {
    this.vy += g;
    this.x += this.vx;
    this.y += this.vy;
    this.vx *= 0.99;
  }
  void show() {
    stroke(120, 0, 0, this.op);
    fill(120, 0, 0, this.op);
    ellipse((float) this.x, (float) this.y, 3, 6);
  }
  void hitFloor() {
    if(this.y >= height-floorY/2) {
      this.vy = 0;
      this.y = height-floorY/2;
      this.vx *= 0.3;
      if(Math.abs(this.vx) <= 0.01) {this.vx = 0;}
      this.op *= 0.9;
      if(this.op <= 0.01) {this.op = 0;}
    }
  }
}

class OddballParticle {
  double x, y, vx, vy;
  int sprite, hit, op, hurt = 255;
  public OddballParticle(double x, double y, double vx, double vy, int sprite, int hit, int op) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.sprite = sprite;
    this.hit = hit;
    this.op = op;
  }
  void show() {
    pushMatrix();
    if(this.vx <= 0) {
    translate(width, 0);
    scale(-1, 1);
    }
    if(this.sprite == 0) {
      tint(255, hurt, hurt, this.op);
      image(wingsUp, (float) this.x, (float) this.y, 100, 100);
    } else if(this.sprite == 1) {
      tint(255, hurt, hurt, this.op);
      image(flap, (float) this.x, (float) this.y, 100, 100);
    } else if(this.sprite == 2) {
      tint(255, hurt, hurt, this.op);
      image(wingsDown, (float) this.x, (float) this.y, 100, 100);
    } else if(this.sprite == 3) {
      tint(255, hurt, hurt, this.op);
    } else if(this.sprite == 4) {
      tint(255, this.op);
      image(dead, (float) this.x, (float) this.y, 50, 50);
    }
    popMatrix();
  }
  
  void fly() {
    this.x += Math.abs(vx);
    this.sprite = (int) (Math.round(this.x*2)%3);
    if(this.x < -75 || this.x > width+75) {reset();}
  }
  
  void gotShot() {
    this.sprite = 4;
    this.vy += g;
    this.y += vy;
    this.x += Math.abs(vx);
    if(this.y >= height-floorY/2-50) {
      this.vy = 0;
      this.y = height-floorY/2-50;
      this.vx *= 0.3;
      this.op *= 0.9;
      if(this.op <= 0.01) {
      reset();
      score++;
    }
    }
    }
    
    void reset() {
      if(Math.random() >= 0.5) {
        direction = 1;
      } else {
        direction = -1;
      }
      this.op = 255;
      hurt = 255;
      this.vx = (2.9/2)*((int) (Math.random()*4)+1)*direction;
      this.x = startSide;
      this.y = Math.random()*(height-200)+50;
      this.vy = 0;
      this.sprite = 0;
      this.hit = 3;
      
    }
  }
class Crosshair {
  double x, y;
  public Crosshair(double x, double y) {
    this.x = x;
    this.y = y;
  }
    void move() {
        if(keys[0] && !(this.y <= 0)) {
          this.y -= 5;
        } if(keys[1] && !(this.y >= height)) {
          this.y += 5;
        } if(keys[2] && !(this.x <= 0)) {
          this.x -= 5;
        } if(keys[3] && !(this.x >= width)) {
          this.x += 5;
        }
    }
    
    void show() {
      fill(255, 0, 0, 90);
      stroke(255, 0, 0);
      ellipse((float) this.x, (float) this.y, 10, 10);
    }
}

void makeFloor() {
  fill(0, 120, 0);
  stroke(0, 120, 0);
  rect(0, height-floorY, width, height); 
}

void shot() {
  tempList = particle;
  num += 50;
  particle = new Particle[num];
  for(int i = 0; i < particle.length; i++) {
    if(i < tempList.length) {
      particle[i] = tempList[i];
    } else {
      particle[i] = new Particle(ch.x, ch.y, Math.random()*2-1, Math.random()*2-3, 255);
    }
  }
}

void laserBeam() {
  if(laserTime-timer < 5) {
    stroke(255, 0, 0);
    line((float) ch.x, (float) ch.y, width, height);
    fill(100);
    stroke(0);
    pushMatrix();
    translate(width, height);
    rotate((float) (Math.atan2(width-ch.x, -height+ch.y)));
    rect(-50, 0, 100, 400);
    fill(0);
    rotate(PI);
    text(5-(laserTime-timer), 0, -200);
    popMatrix();
    for(int i = 0; i < duck.length; i++) {          
      if(duck[i].vx > 0) {            
        if(Math.abs(ch.x-(duck[i].x+50)) <= 55 && Math.abs(ch.y-(duck[i].y+50)) <= 30) {
          duck[i].hurt -= 100;
          shot();
          duck[i].hit -= 1;
          if(duck[i].hit == 0) {
            duck[i].vy = Math.random()*5-7;
          }
        }
      } else {
          if(Math.abs(ch.x-(width-(duck[i].x+50))) <= 55 && Math.abs(ch.y-(duck[i].y+50)) <= 30) {
            duck[i].hurt -= 100;
            shot();
            duck[i].hit -= 1;
            if(duck[i].hit == 0) {
              duck[i].vy = Math.random()*5-7;
            }
          }
      }
    }
  } else {
    laserOn = false;
  }
}

void keyPressed() {
      if(keyCode == UP) {
        keys[0] = true;
      } if(keyCode == DOWN) {
        keys[1] = true;
      } if(keyCode == LEFT) {
        keys[2] = true;
      } if(keyCode == RIGHT) {
        keys[3] = true;
      } if(key == ' ') {
        keys[4] = true;
      }
}

void keyReleased() {
      if(keyCode == UP) {
        keys[0] = false;
      } if(keyCode == DOWN) {
        keys[1] = false;
      } if(keyCode == LEFT) {
        keys[2] = false;
      } if(keyCode == RIGHT) {
        keys[3] = false;
      } if(key == ' ') {
        keys[4] = false;
        for(int i = 0; i < duck.length; i++) {          
          if(duck[i].vx > 0) {            
            if(Math.abs(ch.x-(duck[i].x+50)) <= 55 && Math.abs(ch.y-(duck[i].y+50)) <= 30) {
              duck[i].hurt -= 100;
              shot();
              duck[i].hit -= 1;
              if(duck[i].hit == 0) {
                duck[i].vy = Math.random()*5-7;
              }
            }
          } else {
              if(Math.abs(ch.x-(width-(duck[i].x+50))) <= 55 && Math.abs(ch.y-(duck[i].y+50)) <= 30) {
                duck[i].hurt -= 100;
                shot();
                duck[i].hit -= 1;
                if(duck[i].hit == 0) {
                  duck[i].vy = Math.random()*5-7;
            }
          }
          }
        }
      }
}

void mousePressed() {
  if(timer < 0) {
    relativeTime = (int) (millis()/1000);
    timer = startTime;
    laserTime = 0;
    laserReq = 10;
    laserOn = false;
    score = 0;
  }
}
