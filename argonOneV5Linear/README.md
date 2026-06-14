# Active Linear Cooling

![image](https://raw.githubusercontent.com/adamoutler/HassOSArgonOneAddon/main/gitResources/activecooling.jpg)

This is an addon for Argon One V5 in Home Assistant.
It's essentially a script that runs in a docker container.
It operates in **Observer Mode** to securely monitor and record telemetry for the Argon One V5 Active Cooling System.
It displays fan behavior in Home Assistant, but kernel-native fan control remains authoritative and decides the actual fan speed.

This Addon keeps an eye on your Argon ONE V5 case temperatures!

Unlike previous versions, the Argon ONE V5 case connects its fan directly to the Raspberry Pi 5's dedicated PWM fan header. 
This means the Linux kernel's thermal governor natively and automatically controls the fan speed based on your CPU temperature.

Because of this native integration, this Addon acts as an **Observer**. It securely reads the current fan speed and CPU temperature directly from the OS kernel without modifying it, and reports this data to Home Assistant.

If you wish to change the fan curve itself, you should edit the `/boot/firmware/config.txt` file directly on your Home Assistant OS host using `dtparam=fan_temp0=...` properties.

- The addon reads fan speed from 0 to 100%
- The fan speed will automatically adjust based on the OS kernel's thermal governor.

## Support

First, look in the Logs tab of the Addon's page in HA to see if there are any errors, such as failing to find the PWM fan cooling device.

Also, enable the "Log current temperature every 30 seconds" setting and look in the
 logs to see what the speed is. The fan is noisy and you might not be able to hear
 different speeds, but logging will verify any changes.

Need support? Click [here](https://community.home-assistant.io/t/argon-one-active-cooling-addon/262598/8).
When reporting issues, please provide as much relevant information as possible to help us assist you. 
Useful details include any error messages from the logs, steps to reproduce the behavior, and information about your host environment (e.g., Home Assistant OS version).
