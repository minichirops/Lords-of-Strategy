PImage colorImage; //This is the color map, also (I think) called a normals map. The textures in perfectly even lighting
PImage heightImage; //This is the height map, in which blue is height, red is reflectiveness, and green is transparency
int screenSize=800; //this is the size of the program screen
int lightSize=200; //this is the size of the basic light map, which will determine the resolution of the lighting calculations
int shadowSize=200; //this is the size of the basic shadow map, which will determine the resolution of the shadow calculations
int[] lightMap = new int[lightSize*lightSize]; //this will hold the light map
int[] shadowMap = new int[shadowSize*shadowSize]; //this will hold the shadow map
int[] heightMap;
int[] refMap;
int[] transMap;

void setup() {
  //define the source images
  colorImage = loadImage("TCP.png");//this will be used as a size reference for the image
  heightImage = loadImage("THP.png");
  heightMap = new int[colorImage.width*colorImage.height]; //this will hold height values from heightImage
  refMap = new int[colorImage.width*colorImage.height]; //this will hold reflection values from heightImage
  transMap = new int[colorImage.width*colorImage.height]; //this will hold transparency values from heightImage
  //check for insufficently small screenspace (until the program does things offscreen)
  if (screenSize<colorImage.height) {
    screenSize = colorImage.height;
  }
  if (screenSize<colorImage.width) {
    screenSize = colorImage.width;
  }
  //define the screen space
  size(screenSize, screenSize);
  //populate the lightMap array with an inverted dome shape; the inverse will populate the shadowMap array.
  for (int y = 0; y < lightSize; y++) {
    for (int x = 0; x < lightSize; x++) {
      // calculate the distance from the center of the light map to each pixel.
      // invert it so we have 255 in the center and 0 at the edges. 
      // make sure the numbers are in the range [0-255]
      // this results in something that looks like a ball
      int distance = constrain((int)(255 - 255 * dist((lightSize/2), (lightSize/2), x, y) / (lightSize/2)), 0, 255);
      lightMap[x + y * lightSize] = distance;
    }
  }  
  for (int y = 0; y < shadowSize; y++) {
    for (int x = 0; x < shadowSize; x++) {
      int distance = constrain((int)(255 - 255 * dist((shadowSize/2), (shadowSize/2), x, y) / (shadowSize/2)), 255, 0);
      lightMap[x + y * shadowSize] = distance;
    }
  } 
  // extract the red, green, and blue channels from the bump map - and use those as height, transparency, and reflection values. 
  for (int y = 0; y < colorImage.height; y++) {
    for (int x = 0; x < colorImage.width; x++) {
      colorMode(RGB);
      // blue is in the last 8 bits, which we get with the bitmask 16 & 0xff
      heightMap[x + y * colorImage.height] = heightImage.get(x, y) >> 16 & 0xff;
      // green is in the middle 8 bits, which we get with the bitmask 8 & 0xff
      transMap[x + y * colorImage.height] = heightImage.get(x, y) >> 8 & 0xff;
      // red is in the first 8 bits, which we get with the bitmask 0 & 0xff
      refMap[x + y * colorImage.height] = heightImage.get(x, y) >> 0 & 0xff;
    }
  }
}//end of setup loop

void draw() {
  //this is where lights are declared, for now; better to do them by an object-by-object basis, but that would take thought
  //for now, have a mouse-based light source
  int lightX = int(mouseX+lightSize/2);
  int lightY = int(-mouseY+lightSize/2);
  //prepare pixels array for accessing
  loadPixels();
  //SEEMS to work just fine outside the draw loop; might help fps, but the docs don't seem to agree
  for (int y=1; y<colorImage.height-1; y++) {
    for (int x=1; x<colorImage.width-1; x++) {
      //calculate dx and dy based on the absolute value of the average of the three pixel-comparisons necessary for x and y, respectively
      int dx = abs(((heightMap[(x-1) + y * colorImage.width] - heightMap[(x+1) + y * colorImage.width])+(heightMap[(x-1) + (y-1) * colorImage.width] - heightMap[(x+1) + (y-1) * colorImage.width])+(heightMap[(x-1) + (y+1) * colorImage.width] - heightMap[(x+1) + (y+1) * colorImage.width]))/3);
      int dy = abs(((heightMap[x + (y-1) * colorImage.height] - heightMap[x + (y+1) * colorImage.height])+(heightMap[(x-1) + (y-1) * colorImage.height] - heightMap[(x-1) + (y+1) * colorImage.height])+(heightMap[(x+1) + (y-1) * colorImage.height] - heightMap[(x+1) + (y+1) * colorImage.height]))/3);
      //calculate whether to apply light or shadow mapping, or both
      //calculate where to read the light intensity from the light map
      //start with the current pixel position, offset by light position, further offset based on dx and dy times the mapped value of distance from the light source and the reflection value of the pixel
      //ideally, this will increase gradient the further from the light source we go
      //lastly, values are clamped between lightWidth/Height and 0
      //look up light intensity from the light map and shadow map
      //read pixel color from the color map
      //modify intensity based on height map
      //multiply light intensity by each color component and clamp to 0 to 255 range
      color p = colorImage.get(x, y);
      float intensity = 128.0;
      int r = min(255, (int)((red(p)) * intensity / 256.0));
      int g = min(255, (int)((green(p)) * intensity / 256.0));
      int b = min(255, (int)((blue(p)) * intensity / 256.0));
      // output the calculated pixel
      pixels[x + y * screenSize] = color(r, g, b);
    }
  }
  updatePixels();
}
<<<<<<< HEAD
//int lx = constrain(lightX + x + dx * int(map(lightX-x/(lightsize),-width+1,width-1,-lightsize+1,lightsize-1)), 0, lightsize-1);
//int ly = constrain(lightY + y + dy * int(map(-lightY+y/(lightsize),-height+1,height-1,-lightsize+1,lightsize-1)), 0, lightsize-1);      
//int intensity = lightMap[lx + ly * lightsize];
=======

>>>>>>> origin/master
