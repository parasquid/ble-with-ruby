const neopixel = require("neopixel");

const rows = 8;
const cols = 8;
const bpp = 24;
const ledCount = 64;
const pin = 12;
const leds = Graphics.createArrayBuffer(
  rows,
  cols,
  bpp,
  {
    zigzag:true,
    color_order: 'gbr'
  }
);
leds.flip = () => { neopixel.write(pin, leds.buffer); };


const scale = (num) => num / 0xFF;

NRF.setTxPower(4);
NRF.setServices({
  "0x181C": {
    "0x2A3D": {
      value: [0,0,0,0,0],
      writable : true,
      description: "sets the value of a pixel: [r, g, b, x, y]",
      onWrite : function(e) {
        const data = new Uint8Array(e.data);
        leds.setColor(scale(data[0]), scale(data[1]), scale(data[2]));
        leds.setPixel(data[3], data[4]);
        leds.flip();
      }
    }
  }
}, { advertise: ['181C'] });


NRF.on('disconnect', function() {
  leds.clear(true);
  leds.flip();
});

E.on('init', function() {
  NRF.setConnectionInterval(7.5);
  console.log("Hello World!");
  leds.clear(true);
  leds.flip();
});
