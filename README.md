NVIDIA Power Indicator
===================
Indicator applet for laptop users with NVIDIA/Intel hybrid GPUs, allowing one to view which GPU is being used and to manually turn the dedicated GPU on or off when needed.

It should work on any Linux distribution that includes the minimum dependencies listed in the Prerequisites section.

This version features full power saving by completely disabling the NVIDIA GPU when it's not being used. 
NVIDIA PRIME won't do it by default, leaving NVIDIA GPU powered on even when it's using the Intel GPU only.
While this saves some power (because the NVIDIA GPU is idle), it still consumes about 4~5W more than with it 
completely off. Since this is not ideal, this version is extended to use bbswitch to power the NVIDIA GPU off. 
Still, should the need for it to be on arrise, this version provides an option to force it to stay powered on
when using integrated graphics only, so it can be used for GPGPU and other tasks other than rendering.

Although the `bumblebeed` daemon should take care of the power management properly, there are cases where it may fail to do so. This Indicator will allow the user to easily
identify when it happens and enable the user to manually turn the dGPU off if the user desires.

Prerequisites
=============
Make sure you have installed and enabled:

* NVIDIA driver, version 331.20 or higher
* `mesa-utils` package
* `python3` package
* `gir1.2-appindicator3` package
* `bbswitch-dkms` or equivalent package

Or simply run the following, which will install all dependencies and the latest NVIDIA driver for your GPU (if it's supported by NVIDIA's latest drivers).
```
sudo apt-get install python3 mesa-utils bbswitch-dkms gir1.2-appindicator3
sudo apt-get install $(sudo ubuntu-drivers devices | grep -o nvidia-[[:digit:]]*)
```

Troubleshooting
===============

### `appindicator` module missing
Install the `gir1.2-appindicator3` package.

### Couldn't find RGB GLX visual or fbconfig
Install the `mesa-utils` package.

### NVIDIA Power Indicator only shows a question mark or NVIDIA icon
If you're using `UEFI`, try disabling `Secure Boot` as NVIDIA's proprietary driver does NOT work with `Secure Boot` enabled and it might result in neither GPU being recognized.

### The icons look awful!
I've added some icon options! Edit the config file which resides in `$HOME/.config/nvidia-power-indicator/nvidia-power-indicator.cfg` and change the option `iconset` in the `Appearance` section to one of the following options:
* `theme-default`: uses icons provided by the icon theme you're using. Falls back to the color option if none is provided (default)
* `symbolic`: attempts to color the icons based on the GTK theme the system is using (depends on the theme's configuration, might not work at all)
* `color`: full color icons (blue Intel logo and green NVIDIA logo)
* `custom(<RGB Hex Color Code>)`: allows you to determine the color the icons should have using hexadecimal RGB values in the #`RR``GG``BB` format. You can select the color you want using many different utilities such as this [HTML Color Picker](http://www.w3schools.com/colors/colors_picker.asp). Example: `custom(#bebebe)` colors the icons gray.


Installation
============
```shell
chmod a+x setup.sh
sudo ./setup.sh
```
