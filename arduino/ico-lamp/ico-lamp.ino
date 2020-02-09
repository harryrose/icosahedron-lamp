#include <FastLED.h>
#define FASTLED_ALLOW_INTERRUPTS 0

// LED_PIN is the pin on which the LED data line is attached
#define LED_PIN     2
// NUM_LEDS is the number of LEDs in the string.  19 for the icosahedron lamp (minus one due to the base)
#define NUM_LEDS    19

// LED colours
CRGB leds[NUM_LEDS];

// Target colours for each LED.  We'll get closer to these colours with each iteration of the `loop()`
// tr, tg, tb: target red, green, blue respectively
int tr[NUM_LEDS], tg[NUM_LEDS], tb[NUM_LEDS];

// Current colours for each LED.
// cr, cg, cb: current red, green, blue respectively
int cr[NUM_LEDS], cg[NUM_LEDS], cb[NUM_LEDS];

void setup() {
  pinMode(LED_PIN, OUTPUT);
  FastLED.addLeds<WS2811, LED_PIN, RGB>(leds, NUM_LEDS);
  // initialise the target and current colours to 0
  memset(tr, 0, sizeof(int) * NUM_LEDS);
  memset(tg, 0, sizeof(int) * NUM_LEDS);
  memset(tb, 0, sizeof(int) * NUM_LEDS);
  memset(cr, 0, sizeof(int) * NUM_LEDS);
  memset(cg, 0, sizeof(int) * NUM_LEDS);
  memset(cb, 0, sizeof(int) * NUM_LEDS);
  // seed random through some noise on pin 0
  randomSeed(analogRead(0));
}

// ITERATE_LED is a macro, which moves the currents[index] one step closer to targets[index].
// If they are already equal, it does nothing.
#define ITERATE_LED(index, targets, currents) do{ \
    int d = targets[index] - currents[index]; \
    if(d < 0){ \
      currents[index] --; \
    } else if(d > 0){ \
      currents[index] ++; \
    } \
  }while(0)

// cnt is an iteration counter, so we know when to re-randomise the colours on the LEDs.
int cnt = 0;
void loop() {
  if (!cnt) {
    // set new target colours for each LED
    for (int i = 0; i < NUM_LEDS; i++) {
      tr[i] = random(255);
      tg[i] = random(255);
      tb[i] = random(255);
    }
  }
  cnt++;
  cnt &= 0x3FF; // reset the counter every 1024 steps

  // move the current values closer to the targets.
  for (int i = 0; i < NUM_LEDS; i++) {
    ITERATE_LED(i, tr, cr);
    ITERATE_LED(i, tg, cg);
    ITERATE_LED(i, tb, cb);
    leds[i] = CRGB(cr[i], cg[i], cb[i]);
  }

  // update the LEDs and then sleep for a bit to slow the 'animation'
  FastLED.show();
  delay(50);
}
