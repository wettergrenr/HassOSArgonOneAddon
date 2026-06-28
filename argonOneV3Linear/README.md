# ArgonOne V3 Active Linear Cooling

**Automatic fan control and power-button shutdown for the Argon ONE V3 + Raspberry Pi 5.**

---

## What it does

- Controls fan speed **linearly** between your minimum and maximum temperature
- Handles the **power button** — one press triggers a graceful shutdown
- After shutdown, the case cuts board power completely

---

## Fan speed

- Fan is **off** below the minimum temperature
- Fan runs at **100%** at the maximum temperature
- Speed rises smoothly in between

---

## Setup

See **[DOCS.md](DOCS.md)** for full setup instructions including I2C, UART, and firmware.
