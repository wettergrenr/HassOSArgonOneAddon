# Configuration

![image](https://raw.githubusercontent.com/adamoutler/HassOSArgonOneAddon/main/gitResources/linearsettings.png)

## Celsius or Fahrenheit

Choose Celsius or Fahrenheit.

- **Celsius or Fahrenheit** - Configures Celsius or Fahrenheit.

## Add-on Options

- **Celsius or Fahrenheit** - Choose Celsius or Fahrenheit for the Home Assistant sensor.
- **Create a Fan Speed entity in Home Assistant** - Toggle to create a dedicated fan speed sensor in your dashboard.
- **Log current temperature every 30 seconds** - Toggle to record temperature and fan state in the add-on logs.

## Changing the Fan Curve

Because the Argon ONE V5 connects its fan directly to the Raspberry Pi 5's dedicated PWM fan header, the fan speed is controlled natively by the Linux kernel's thermal governor.

To change the fan curve, you must edit the `/boot/firmware/config.txt` file directly on your Home Assistant OS host and use properties such as `dtparam=fan_temp0=...`. This add-on operates in Observer Mode and will faithfully report whatever speed the kernel decides.

## Support

Need support? Click [here](https://community.home-assistant.io/t/argon-one-active-cooling-addon/262598/8).
Try to be detailed about your feedback.
If you can't be detailed, then please be as obnoxious as you can be.
