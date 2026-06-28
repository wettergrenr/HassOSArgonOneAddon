# ArgonOne V3 — Setup Guide

## What You Need

- Argon ONE **V3** case with Raspberry Pi **5**
- Home Assistant OS **18** or newer
- The **Advanced SSH & Web Terminal** add-on
  - Install it from the Add-on Store
  - Go to its **Info** tab
  - **Turn Protection Mode OFF**

---

## Optional: Flash the Patched Firmware

**Recommended if you have many add-ons or Docker containers.**

**Stock firmware:** the case cuts power about 17.5 seconds after shutdown starts.
A long shutdown can be cut off before it finishes.

**Patched firmware:** extends this to about 45 seconds.
This gives Docker containers time to stop cleanly.

### Download the Firmware

**Download the firmware file from the link below.**

[ArgonOne\_patched.uf2](https://github.com/wettergrenr/HassOSArgonOneAddon/releases/download/v666/ArgonOne_patched.uf2)

> This is a modified version of the Argon ONE firmware.
> It increases the hard power-off timer so all Docker containers have time to stop before power is cut.
> **Use at your own risk.**
> **Keep your original firmware so you can go back.**

### What Else You Need

- A **data** USB-C cable (not a charge-only cable)
- A computer to plug the cable into

### Steps

1. **Open** the Argon ONE V3 case to reach the fan board.
2. **Find** the small USB-C port on the RP2040 fan board.
3. **Hold** the power button on the case.
4. **While holding**, plug the USB-C cable into the fan board and your computer.
5. **Release** the button when a drive called **RPI-RP2** appears on your computer.
6. **Drag** `ArgonOne_patched.uf2` onto the **RPI-RP2** drive.
7. **Wait** for the drive to eject on its own.

---

## Step 1: Enable I2C and UART

Both I2C **and** UART must be enabled.
The power button will **not** work without them.

### Get a host shell

The SSH terminal runs inside a container.
To edit `/mnt/boot/config.txt` and `/etc/`, you need a host shell.

**These commands change system files. Type them exactly.**

**Run this in the Advanced SSH terminal:**

```bash
docker run --rm -it --privileged --pid=host alpine nsenter -t 1 -m
```

You now have a root shell on the HAOS host.

### Edit `/mnt/boot/config.txt`

```bash
echo "dtparam=i2c_arm=on" >> /mnt/boot/config.txt
echo "enable_uart=1" >> /mnt/boot/config.txt
```

> **Important:** `enable_uart=1` is required.
> Without it, the case does a **hard power-off after only a few seconds** — before shutdown finishes.

### Enable the I2C kernel module

```bash
echo "i2c-dev" > /etc/modules-load.d/i2c-dev.conf
```

### Set POWER_OFF_ON_HALT in the EEPROM

This tells the Pi to signal the case when shutdown is finished.

```bash
rpi-eeprom-config > /tmp/ee.conf
sed -i 's/POWER_OFF_ON_HALT=0/POWER_OFF_ON_HALT=1/' /tmp/ee.conf
grep -q POWER_OFF_ON_HALT /tmp/ee.conf || echo 'POWER_OFF_ON_HALT=1' >> /tmp/ee.conf
rpi-eeprom-config --apply /tmp/ee.conf
```

### Reboot

```bash
reboot
```

---

## Step 2: Add This Repository

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Click the **⋮ menu** (top right).
3. Click **Repositories**.
4. Paste: `https://github.com/wettergrenr/HassOSArgonOneAddon`
5. Click **Add**.

---

## Step 3: Install the Add-on

1. Find **ArgonOne V3 Active Linear Cooling** in the store.
2. Click **Install**.
3. Go to the **Configuration** tab.
4. Set your temperature range.
5. Click **Start**.

---

## Configuration

### Celsius or Fahrenheit

Choose your temperature unit.

Default is **Celsius**.

### Temperature Range

- **Minimum Temperature** — fan turns on at this temperature. Default: **55 °C**
- **Maximum Temperature** — fan runs at 100% at this temperature. Default: **65 °C**

The fan is **off** below the minimum.
The fan runs at **100%** at the maximum.
Speed rises smoothly between the two.

### Fan Speed Entity

Turn on **Create a Fan Speed entity in Home Assistant**
to see the current fan speed on your HA dashboard.

### Temperature Logging

Turn on **Log current temperature every 30 seconds**
to watch temperature and fan speed in the add-on log.

---

## How the Power Button Works

Press the button **once**.

The add-on will:

1. Ask Home Assistant to **shut down gracefully**.
2. Send a **power-cut command** (`i2cset 0x86 0x01`) to the case MCU.

The case counts down (about 17.5 s with stock firmware, about 45 s with the patched firmware), then **cuts power completely**.

- The red LED goes off.
- The Pi is fully powered down.
- Press the button again to restart.

**Debounce:** a real press produces a brief HIGH pulse (rising then falling edge within 1 s).
A stuck line or noise spike will **not** trigger a shutdown.

---

## Troubleshooting

**Fan not spinning**
- Check the add-on log for I2C errors.
- Make sure I2C is enabled (Step 1 above).

**Power button does nothing**
- Check the log for: `Power button watcher started`
- If that line is missing, `/dev/gpiochip0` is not accessible.

**Case cuts power before shutdown finishes**
- Flash the patched firmware (see top of this page).

**HTTP 403 on shutdown**
- A 403 means the add-on was not allowed to shut down Home Assistant.
- This add-on already requests the right permission (`hassio_role: manager`).
- If you see 403, the permission may not have been applied.
- **Remove the add-on completely, then re-add it** so the permission is granted fresh.
- Also check you are running version **666** of this fork — other Argon add-ons do not request this permission.

---

## Support

[Community thread](https://community.home-assistant.io/t/argon-one-active-cooling-addon/262598/)
