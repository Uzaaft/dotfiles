#include <CoreGraphics/CoreGraphics.h>
#include <stdio.h>

int main(void) {
  // Buffer for a reasonable number of active displays, reduce buffer size
  CGDirectDisplayID displayIDs[4]; // Most systems have fewer than 4 displays
  CGDisplayCount displayCount;

  // Get the active displays (returns count of active displays)
  if (CGGetActiveDisplayList(4, displayIDs, &displayCount) != kCGErrorSuccess) {
    fprintf(stderr, "Error: Unable to retrieve display list.\n");
    return 1;
  }

  // Check for the built-in display in the active list
  for (CGDisplayCount i = 0; i < displayCount; i++) {
    if (CGDisplayIsBuiltin(displayIDs[i])) {
      /* printf("Internal display is available.\n"); */
      return 0; // Exit early if internal display found
    }
  }

  // No internal display found
  /* printf("Internal display is not available.\n"); */
  return 1;
}
