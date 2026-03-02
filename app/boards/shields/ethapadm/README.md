# Sub-Etha Pad M ZMK Configuration

This is a ZMK firmware configuration for the Sub-Etha Pad M, a mechanical macropad with a large CNC rotary encoder.

## Hardware Features

- 8 mechanical keys with Kailh hotswap sockets
- Large aluminium CNC rotary encoder (100 steps per rotation)
- 0.91" 128x32 OLED display
- 6 RGB underglow LEDs (SK6812 MINI-E)
- Pro Micro compatible controller (tested with nice!nano)
- TRRS socket for daisy-chaining

## Pin Configuration

### Matrix Pins

- **Rows (2):**
  - Row 0: D4 (Pro Micro pin 7)
  - Row 1: B5 (Pro Micro pin 12)

- **Columns (4):**
  - Col 0: F4 (Pro Micro pin 20)
  - Col 1: F5 (Pro Micro pin 19)
  - Col 2: F6 (Pro Micro pin 18)
  - Col 3: F7 (Pro Micro pin 17)

### Encoder

- A: C6 (Pro Micro pin 8)
- B: D7 (Pro Micro pin 9)

### OLED Display

- SCL: D0 (Pro Micro pin 6)
- SDA: D1 (Pro Micro pin 5)

### RGB Underglow

- Data: E6 (Pro Micro pin 10)

## Key Layout

```
┌─────┬─────┬─────┬─────┐
│  7  │  8  │  9  │  -  │
├─────┼─────┼─────┼─────┤
│  4  │  5  │  6  │ FN  │
└─────┴─────┴─────┴─────┘
        [Encoder]
```

## Default Keymap

### Layer 0 (Default)

- Keys: Numpad layout (7, 8, 9, -, 4, 5, 6, FN)
- Encoder: Volume Up/Down

### Layer 1 (Function)

- Keys: Bluetooth controls and RGB settings
- Encoder: Page Up/Down

## Combos

- **Keys 0 + 7:** Clear Bluetooth bonds
- **Keys 0 + 1:** System reset
- **Keys 6 + 7:** Enter bootloader

## Building

To build the firmware for nice!nano v2:

```bash
west build -b nice_nano_v2 -- -DSHIELD=ethapadm
```

## Enabling Features

### RGB Underglow

Edit `ethapadm.conf` and uncomment:

```
CONFIG_ZMK_RGB_UNDERGLOW=y
CONFIG_WS2812_STRIP=y
```

Note: RGB underglow is only supported on boards with board-specific overlays (currently nice!nano and nice!nano_v2).

## Hardware Information

- **Designer:** piit79
- **Repository:** https://github.com/piit79/Sub-Etha-Pad
- **Vendor:** 42. Keebs
- **Website:** https://42keebs.eu/

## License

This ZMK configuration is licensed under the MIT License.

The hardware design is licensed under Creative Commons Attribution-NonCommercial-ShareAlike (see original repository).
