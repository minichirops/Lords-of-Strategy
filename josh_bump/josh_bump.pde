/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/42758*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
/**
 * 2D Bump Mapping of the OSAA logo
 *
 * Original created by Rene Hangstrup Møller
 *
 * Tweaked by Jonathan Adams and Joshua Hard
 */
 
PImage colorImg; // color map for the logo
PImage heightImg; // height map for the logo

// will hold extracted height values from the height image.
int[] heightMap = new int[380*380];

// a spot-light light map will be calculated into this array
int[] lightMap = new int[380*380];

int LOD_FADE = 10;

void setup() {
  // same size as the images
  size(380, 380);
  
  // load the color and height maps
  colorImg = loadImage("OSAA_LOGO.png"); 
  heightImg = loadImage("OSAA_BUMP.png");
 
  // calculate the light map
  for (int y = 0; y < 380; y++) {
    for (int x = 0; x < 380; x++) {
      // calculate the distance from the center of the lightmap to each pixel.
      // invert it so we have 255 in the center and 0 at the edges. 
      // make sure the numbers are in the range [0-255]
      // this results in something that looks like a ball
      int d = constrain((int)(255 - 255 * dist(190, 190, x, y) / 190), 0, 255);
      lightMap[x + y * 380] = d;
    }
  }

  // extract the blue channel from the bump map - and use that as height value  
  for (int y = 0; y < 380; y++) {
    for (int x = 0; x < 380; x++) {
      // blue is in the last 8 bits, which we get with the bitmask 0xff
      heightMap[x + y * 380] = heightImg.get(x, y) & 0xff;
    }
  }
  
}

void draw() {
  // move the light in harmonic curves
  //int lightX = (int)(200 * cos(millis()/1000.0));
  //int lightY = (int)(200 * sin(millis()/3000.0));
  int lightX = int(190 - mouseX);
  int lightY = int(190 - mouseY);
  
  // prepare the pixels array for the screen
  // we dont need the current pixel data, but the documentation seems to hint
  // that we should do it anyway before accessing the pixels[] array.
  loadPixels();

  // we skip a 1 pixel border of the screen to accomodate for the gradient calculation
  for (int y = 1; y < 379; y++) {
    for (int x = 1; x < 379; x++) {
      // calculate the gradient at each pixel, by comparing the height of neighbouring pixels
      int dx = ((heightMap[(x-1) + y * 380] - heightMap[(x+1) + y * 380])+(heightMap[(x-1) + (y-1) * 380] - heightMap[(x+1) + (y-1) * 380])+(heightMap[(x-1) + (y+1) * 380] - heightMap[(x+1) + (y+1) * 380]))/3;
      int dy = ((heightMap[x + (y-1) * 380] - heightMap[x + (y+1) * 380])+(heightMap[(x-1) + (y-1) * 380] - heightMap[(x-1) + (y+1) * 380])+(heightMap[(x+1) + (y-1) * 380] - heightMap[(x+1) + (y+1) * 380]))/3;
      // int dx = heightMap[(x-1) + y * 380] - heightMap[(x+1) + y * 380];
      // int dy = heightMap[x + (y-1) * 380] - heightMap[x + (y+1) * 380];
      // calculate where to read the light intensity from the light map
      // start with current pixel position
      // offset by the light position
      // and offset it further based on the gradient values (dx, dy)
      // we double the gradient to make edges more visible. 
      // try multiplying with four instead for more dramatic bumps :-)
      // finally make sure to clamp values to within light map range [0-379]
      float mult = map(dist(x, y, mouseX, mouseY), 0, 460, 2, LOD_FADE);
      int lx = int(constrain(lightX + x + dx * mult, 0, 379));
      int ly = int(constrain(lightY + y + dy * mult, 0, 379));      
      // lookup light intensity from the light map and add a small amount of ambient light
      int intensity = lightMap[lx + ly * 380] + 16;
      
      // read the pixel color form the color map
      color p = colorImg.get(x, y);      
      
      // multiply light intensity with each color component and clamp to range [0-255]
      int r = min(255, (int)((red(p)) * intensity / 256.0));
      int g = min(255, (int)((green(p)) * intensity / 256.0));
      int b = min(255, (int)((blue(p)) * intensity / 256.0));
      
      // output the calculated pixel
      pixels[x + y *380] = color(r, g, b);
    }
  }   
  
  // copy pixel[] to screen buffer
  updatePixels();
}
//scroll in and out to change the gradient value variance relative to the mouse
void mouseWheel(MouseEvent event) {
  LOD_FADE += int(event.getAmount());
  LOD_FADE = max(LOD_FADE, 3);
}

