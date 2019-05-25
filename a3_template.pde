/**************************************************************
* File: a3_tempate.pde
* Group: <Wilcox Ronguno>
* Date: 26/05/2019
* Course: COSC101 - Software Development Studio 1
* Desc: Astroids is a prototype of the atari game back in the 80's. It has got the basic fundamentals of game development.
*       the game was developed in OOP.
* Usage: Make sure to run in the processing environment and press play to start the game.
*
**************************************************************/

//This class represents the Asteroid objects. It handles the physics, drawing, and behovoir
//of the asteroid objects.
class Asteroid{
  PVector asteroidVelocity;                                //velocity and position vectors used for movement
  PVector asteroidPosition;                                //There is no acceleration vector becasue they have a constant speed.
  float asteroidDirection;                                 //This variable is used when the asteroids split 
  float rotAngle;                                          //This is the delta rotation between the control points
  float[] anchorsX;                                        //Array that holds the x-coords of the control points
  float[] anchorsY;                                        //Array that holds the y-coords of the control points
  float asteroidSize;                                      //The multiplication factor on the asteroid base size
  int numAnchors;                                          //The number of anchor points

  //The main constructor for the asteroid. It sets the default values for the variables above and gives them all random sizes
  Asteroid(int px, int py, float vx, float vy, float inD){
    asteroidVelocity = new PVector(vx, vy);
    asteroidPosition = new PVector(px, py);
    asteroidDirection = inD;
    asteroidSize = random(15,30);
    numAnchors = 6;
    rotAngle = 0;
    anchorsX = new float[numAnchors];
    anchorsY = new float[numAnchors];
  }

  //The secondary contructor that is used when an asteroid splits. It has an extra param which represents the size of the asteroid parent.
  //This is used to calculate the size of the child asteroid.
  Asteroid(int px, int py, float vx, float vy, float inD, float s){
    asteroidVelocity = new PVector(vx, vy);
    asteroidPosition = new PVector(px, py);
    asteroidDirection = inD;
    asteroidSize = random(s/3,s/1.5);
    numAnchors = 6;
    rotAngle = 0;
    anchorsX = new float[numAnchors];
    anchorsY = new float[numAnchors];
  }

  //This method handles the drawing of the asteroid by drawing curved lines between the control points.
  //The curve tightness is set to 0 for the smoothest lines. Increased tightness would result in sharper corners.
  void drawAsteroid(){
    updateAsteroid();
    curveTightness(0);
    beginShape();
    noStroke();
    for (int i=0; i<numAnchors; i++) {
      curveVertex(anchorsX[i], anchorsY[i]);}
    for (int i=0; i<numAnchors; i++) {
      curveVertex(anchorsX[i], anchorsY[i]);}
    endShape(CLOSE);
  }

  //Handles the movement od the asteroid and screen wrapping. It also updates the control vertices using perlin noise
  //Finally, it checks the size of the asteroid and determines if it should die, split or niether. 
  void updateAsteroid(){
    asteroidPosition.add(asteroidVelocity);
    asteroidPosition.x %= width;
    if (asteroidPosition.x < -10)
      {asteroidPosition.x = width;}
    asteroidPosition.y %= height;
    if (asteroidPosition.y < -10)
      {asteroidPosition.y = height;}
    rotAngle = 0;
    for (int i=0; i<numAnchors; i++){
      anchorsX[i] = asteroidPosition.x + cos(radians(rotAngle) + noise(asteroidPosition.x/20+i*4))*asteroidSize ;
      anchorsY[i] = asteroidPosition.y + sin(radians(rotAngle) + noise(asteroidPosition.y/20+i*4))*asteroidSize ;
      rotAngle += 360/numAnchors;
    }
    asteroidSize +=.01; 
    if(asteroidSize < 10)
      die();
    if(asteroidSize > 50)
      split();
  }
  
  //Splits the asteroid into two smaller asteroids by calling the secondary contructor in Asteroid. It then calls die() on the current asteroid to remove it
  void split(){
    asteroids.add(new Asteroid((int)asteroidPosition.x, (int)asteroidPosition.y, asteroidVelocity.x + random(-2,2), asteroidVelocity.y + random(-2,2), asteroidDirection + random(-40,40),asteroidSize));
    asteroids.add(new Asteroid((int)asteroidPosition.x, (int)asteroidPosition.y, asteroidVelocity.x + random(-2,2), asteroidVelocity.y + random(-2,2), asteroidDirection + random(-40,40),asteroidSize));
    die();
  }

  //A method that removes the current asteroid
  void die(){
    asteroids.remove(this);
  }
}

int score = 0;                                            //initiate the scoring
ArrayList<Asteroid> asteroids;                            //global variables including object lists, player, and manager
ArrayList<Bullet> bullets;
Ship player;
GameManager manager;

class GameManager{
  int bulletIndex;                                        //index used in the bullet recycling process

  GameManager(){                                          //contructor for variable instantiation
     bulletIndex = 0;
     asteroids = new ArrayList<Asteroid>();
     bullets = new ArrayList<Bullet>();
     for(int i = 0; i < 20; i++)
       {bullets.add(new Bullet());}                       //create all bullet objects ahead of time
     for(int i = 0; i < 10; i++)                          //create and place all asteroids
       {asteroids.add(new Asteroid((int)random(0,width), (int)random(0,height), random(0,1), random(0,1), random(0,360)));}
     player = new Ship();                                //create the plater ship
  }
  
  void drawGame(){                                       //runs once a frame, calls update and handles drawing
    checkCollisions();                                   
    fill(0,50);
    rect(0,0,width,height);                              //draw over image with opacity for trail effects
    fill(0, 55 ,255);
    player.drawShip();                                   //call the ship's draw
    for(int i = 0; i < asteroids.size(); i++)
      {asteroids.get(i).drawAsteroid();}                 //call draw on all asteroids
    for(int i = 0; i < bullets.size(); i++)
      {bullets.get(i).drawBullet();}                     //call draw on all bullets
  }
  
  void checkCollisions(){
    Asteroid testHolder;                                 //asteroid and bullet objects to minimize creating new objects
    Bullet bulletHolder;
    for(int i = 0; i < asteroids.size(); i++){
      testHolder = asteroids.get(i);                     //pull and store each asteroid from list for testing
      if(dist(testHolder.asteroidPosition.x, testHolder.asteroidPosition.y, player.shipPosition.x, player.shipPosition.y) < testHolder.asteroidSize)
        {player.destroyShip();}                          //test collision with player using the distance and size of the asteroid
      for(int j = 0; j < bullets.size(); j++){
        bulletHolder = bullets.get(j);                   //pull and store each bullet from the list 
        if(bulletHolder.bulletHidden){continue;}         //don't calculate anything if it is hidden
        if(dist(testHolder.asteroidPosition.x, testHolder.asteroidPosition.y, bulletHolder.bulletPosition.x, bulletHolder.bulletPosition.y) < testHolder.asteroidSize){
          testHolder.split();                            //use distance and asteroid size to detect collision and split if collided
          bulletHolder.bulletHidden = true;              //hide the bullet so it won't go 'through' the asteroids
          j++;                                           //minimize chance of the next bullet immediatly hitting an asteroid
          score++;                                       //scoring counter
        }
      }
    }
  }
  
  void fireBullet(PVector pos, PVector spe, float dir){
    bullets.get(bulletIndex).reset(pos, spe, dir);       //set attributes of last used bullet
    bulletIndex++;                                       //update index
    bulletIndex %= bullets.size();                       //keep index in range
  }
}

void setup(){
 //size(1920,1080);
 fullScreen();
 background(0);
 frameRate(24);
 //TODO SHow the main screen until the plater clicks on the play button 
 manager = new GameManager();
}

void draw(){
  manager.drawGame();
  
}


//The bullet object that gets fired from the ship at the asteroids.
//It handles its own movement, drawing, and resets its variables when
//being recycled
class Bullet{
  PVector bulletPosition;                    //position and velocity vectors used in the calculation
  PVector bulletVelocity;                    //of movement. There is no acceleration vector because they have a constant speed
  boolean bulletHidden;                      //determines whether physics should be updated and if it should be drawn or not
  int bulletSize;                            //the diameter of the bullet
  int bulletCreationTime;                    //used in calculating the lifespan of the bullet
  int bulletLifespan;                        //the time in milli seconds that bullets last  
  int bulletSpeed;                           //the speed of the bullet

  //Constructor that sets the default values for the vars above
  Bullet(){
    bulletHidden = true;
    bulletSize = 5;
    bulletPosition = new PVector();
    bulletVelocity = new PVector();
    bulletCreationTime = 0;
    bulletLifespan = 2000;
    bulletSpeed = 3;
  }

  //Handles the bullet movement. It only runs calculations if the bullet is active and checks that the bullet is not past its lifespan.
  //it also handles screen wrapping
  void updateBullet(){
    if (!bulletHidden){
      bulletPosition.add(bulletVelocity);
      if (millis() - bulletCreationTime > bulletLifespan)
        {bulletHidden = true;}
    bulletPosition.x %= width;
    if(bulletPosition.x < -1)
      {bulletPosition.x = width;}
    bulletPosition.y %= height;
    if(bulletPosition.y < -1)
      {bulletPosition.y = height;}
    }
  }

  //Draw the function after ensuring the bullet is active
  void drawBullet(){
    if (!bulletHidden){
      updateBullet();
      ellipse(bulletPosition.x, bulletPosition.y, bulletSize, bulletSize);
    }
  }

  //This function is called when the bullet is 'dead' and is now being recycled. It handles the restting of the 
  //applicabel variables. This method of reusing objects and limiting object instantiation was implemented in an 
  //effort to increase the performance of the game. 
  void reset(PVector pos, PVector spe, float direct){
    bulletPosition = new PVector(pos.x + (20 * cos(radians(direct) - PI/2)), pos.y + (20 * sin(radians(direct) - PI/2)));
    bulletVelocity.x = bulletSpeed * cos(radians(direct) - PI/2) + spe.x;
    bulletVelocity.y = bulletSpeed * sin(radians(direct) - PI/2) + spe.y;
    bulletCreationTime =  millis();
    bulletHidden = false;
  }
}

boolean[] keys;                            //The array that will hold the value for key presses

class Ship{
  PVector shipAcceleration;                //acceleration, velocity, and position vecotrs are used in movement 
  PVector shipVelocity;                    //of the ship. 
  PVector shipPosition;
  PShape shipShape;                        //The shape of the ship
  float shipDirection;                     //holds the rotation of the ship from top dead center
  int shipLastFire;                        //holds the time in millis that the last bullet was fired
  int shipDelayTime;                       //The delay time in milli seconds between bullet firing
  
  
  //The main contructor for the Ship class. It sets the default values for the variables above and creates
  //the shape of the ship
  Ship(){
    shipAcceleration = new PVector();
    shipVelocity = new PVector();
    shipPosition = new PVector(width/2, height/2);
    shipDirection = 0;
    shipLastFire = 0;
    shipDelayTime = 300;
    keys = new boolean[5];
    shipShape = createShape();              //The ship is created with the center at 0,0 and is very small
    shipShape.beginShape();                 //Creating it at 0,0 ensures that the rotation point is in the center
    shipShape.fill(0, 0, 255);                    //Creating it very small just gives a bit more control when scaling
    shipShape.strokeWeight(1);              //the ship up
    shipShape.vertex(0, -4);
    shipShape.vertex(2,0);
    shipShape.vertex(2,2);
    shipShape.vertex(0,1);
    shipShape.vertex(-2,2);
    shipShape.vertex(-2,0);
    shipShape.vertex(0, -4);
    shipShape.endShape();
  }
  
  //Handles the drawing of the ship by first updating the physics, then resetting it back to 0,0 with no rotation or scaling
  //The ship is then rotated based on the rotation variable, and drawn at the position stored in the position vector with 
  //the appropriate scale.
  void drawShip(){
    updateShip();
    shipShape.resetMatrix();
    shipShape.rotate(radians(shipDirection));
    shape(shipShape, shipPosition.x, shipPosition.y, 10,10);
  }
  
  // Stops the drawing loop and prints a simple message to the screen saying that the player has lost.
  void destroyShip(){
    fill(150);
    textAlign(CENTER, CENTER);
    textSize(50);
    noLoop();
    text("Game Over!", width/2, height/2);
    textSize(28);
    
    text("YOU SCORED " +score ,width/2,height/1.8);
    textSize(16);
    
    text("PRESS 'R' TO RESTART " ,width/2,height/1.1);// not implemented
   
    
    
  }
  
  //adds acceleration if up key is pressed based on direction. Updates roation based on key presses and
  //adds drag to velocity. It also handles screen wrapping and calls fireBullet if enough time has passed
  //since the last bullet was fired
  void updateShip(){
    shipAcceleration.x = 0;
    shipAcceleration.y = 0;
    if(keys[0]){
      shipAcceleration.x = 0.5 * cos(radians(shipDirection)  - PI/2);
      shipAcceleration.y = 0.5 * sin(radians(shipDirection) - PI/2);
    }
    if(keys[1] && !keys[2])
      {shipDirection -= 5;}
    if(keys[2] && !keys[1])
      {shipDirection += 5;}
    shipVelocity.add(shipAcceleration);
    shipPosition.add(shipVelocity);
    shipVelocity.mult(.95);
    shipPosition.x %= width;
    if(shipPosition.x < -10)
      {shipPosition.x = width;}
    shipPosition.y %= height;
    if(shipPosition.y < -10)
      {shipPosition.y = height;}
    if(keys[4]){
      if(millis() - shipLastFire > shipDelayTime){
          shipLastFire = millis();
          manager.fireBullet(shipPosition, shipVelocity, shipDirection);
        }
    }
  }
}

void keyPressed(){
   if(key == CODED){
     if(keyCode == UP)
       keys[0] = true;
     if(keyCode == LEFT)
       keys[1] = true;
     if(keyCode == RIGHT)
       keys[2] = true;
     if(keyCode == DOWN)
       keys[3] = true;
   }
   else{
     if(key == 'w')
       keys[0] = true;
     if(key == 'a')
       keys[1] = true;
     if(key == 'd')
       keys[2] = true;
     if(key == 's')
       keys[3] = true;
     if(key == ' ')
       keys[4] = true;
   }
}

void keyReleased(){
   if(key == CODED){
     if(keyCode == UP)
       keys[0] = false;
     if(keyCode == LEFT)
       keys[1] = false;
     if(keyCode == RIGHT)
       keys[2] = false;
     if(keyCode == DOWN)
       keys[3] = false;
   }
   else{
     if(key == 'w')
       keys[0] = false;
     if(key == 'a')
       keys[1] = false;
     if(key == 'd')
       keys[2] = false;
     if(key == 's')
       keys[3] = false;
     if(key == ' ')
       keys[4] = false;
   }
}
