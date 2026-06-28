# ArgonOne V3 — Home Assistant Add-on

**Fan control and power-button shutdown for the Argon ONE V3 case with Raspberry Pi 5.**

This is a community fork of [adamoutler's HassOSArgonOne add-on](https://github.com/adamoutler/HassOSArgonOneAddon),
patched for the Argon ONE V3 + Raspberry Pi 5 + Home Assistant OS.

---

## What This Add-on Does

- **Fan control** — linearly adjusts fan speed between your min and max temperature
- **Power button** — press once for a graceful Home Assistant shutdown
- The case cuts power cleanly after shutdown completes

---

## Requirements

- Argon ONE **V3** case
- Raspberry Pi **5**
- Home Assistant OS **18** or newer
- I2C and UART enabled (see [DOCS.md](argonOneV3Linear/DOCS.md))

---

## Quick Start

1. **Enable I2C and UART** — follow [Step 1 in DOCS.md](argonOneV3Linear/DOCS.md#step-1-enable-i2c-and-uart)
2. **Add this repository** to the HA Add-on Store:
   `https://github.com/wettergrenr/HassOSArgonOneAddon`
3. **Install** ArgonOne V3 Active Linear Cooling
4. **Configure** your temperature range and start the add-on

---

## Optional: Patched Firmware

A patched MCU firmware is available as a download.

It gives the system more time to shut down cleanly before the case cuts power.

See [DOCS.md](argonOneV3Linear/DOCS.md) for the download link and flashing instructions.

---

## Support

[Community thread](https://community.home-assistant.io/t/argon-one-active-cooling-addon/262598/)
