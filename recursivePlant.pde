import java.io.File; //<>// //<>//
import java.io.FilenameFilter;
import java.util.Iterator;

String[] words;
String imagesPath;

ArrayList<Plant> plants;

PVector spawnAreaLeftTopClose;
PVector spawnAreaRightBottomFar;

Timer plantSpawnerTimer;
int plantCountLimit;

void setup() {
  size(1920, 1080, P3D);
  frameRate(40);
  //ortho();
  //    hint(ENABLE_DEPTH_MASK);
  hint(ENABLE_DEPTH_SORT); // BILLBOARDS RENDER ALPHA CORRECTLY. MIGHT SLOW DOWN PERFORMANCE.
  imageMode(CENTER);
  rectMode(CENTER);

  words = loadStrings("words.txt");
  imagesPath = "illustrations/";

  plants = new ArrayList<Plant>();

  spawnAreaLeftTopClose = new PVector(0, height * 0.7f, 0);
  spawnAreaRightBottomFar = new PVector(width, height, -1000);

  plantSpawnerTimer = new Timer(5000);
  plantSpawnerTimer.start();
  
  plantCountLimit = 10;
  
}


void draw() {
  background(20);

  if (plantSpawnerTimer.isFinished()) {
    spawnPlantRandom();
    plantSpawnerTimer.start();
  }

    // DRAW PLANTS
    for (Iterator it = plants.iterator(); it.hasNext();) {
      Plant plant = (Plant) it.next();

      plant.update();
      plant.render();

      if (plant.isReadyForDeletion()) {
        it.remove();
      }
    }
}

void spawnPlantRandom() {
     
  // IF OVERCROWDED, KILL A PLANT BEFORE SPAWNING ANOTHER ONE
  if(plants.size() >= plantCountLimit){
     killPlant();
  }
  
  
  String[] plantList = loadFilenames(sketchPath() + "/data/illustrations");
  String chosenFilePath = plantList[floor(random(plantList.length))];
  //println("Plant => " + chosenFilePath);
  PImage illustration = getIllustration(chosenFilePath);

  // POSITION
  // RANDOM PLANT AND RANDOM POSITION IN THE BACKGROUND

  PVector posInit = new PVector();
  if (plants.isEmpty()) {
    float xPos = random(spawnAreaLeftTopClose.x, spawnAreaRightBottomFar.x);
    float yPos = random(spawnAreaLeftTopClose.y, spawnAreaRightBottomFar.y);
    float zPos = random(spawnAreaRightBottomFar.z, spawnAreaLeftTopClose.z);
    posInit.set(xPos, yPos, zPos);
  } else {
    // WAY TO SPACE OUT "EVENLY" AND NOT RANDOMLY
    // DECALLER LA NOUVELLE PLANTE ~75% DU WIDTH, PUIS WRAP AROUND
    float lastPosX = plants.get(plants.size() - 1).pivot.x;
    lastPosX += random(width * 0.5, width * 0.75);

    float xPos = lastPosX % width;
    float yPos = random(spawnAreaLeftTopClose.y, spawnAreaRightBottomFar.y);
    float zPos = random(spawnAreaRightBottomFar.z, spawnAreaLeftTopClose.z);
    posInit.set(xPos, yPos, zPos);
  }


  Plant newPlant = new Plant(chosenFilePath.split("\\.")[0], posInit, illustration, words, true);

  plants.add(newPlant);
}

void killPlant(){
 
      int randomSelect = floor(random(0, plants.size()));
      plants.get(randomSelect).triggerShrinking();
  
}

public PImage getIllustration(String imageFileName) {
  return loadImage("illustrations/" + imageFileName);
}


String[] loadFilenames(String path) {

  File folder = new File(path);
  FilenameFilter filenameFilter = new FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".png");
    }
  };
  return folder.list(filenameFilter);
}

void clearAllPlants() {
  plants.clear();
}

void keyPressed() {
  if (key == ' ') {
    spawnPlantRandom();
  } else if (key == 'c') {
    clearAllPlants();
  }
}