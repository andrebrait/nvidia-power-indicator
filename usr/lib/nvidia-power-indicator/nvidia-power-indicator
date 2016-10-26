#!/usr/bin/python3

# -*- coding: utf-8 -*-
#
# This file is part of NVIDIA Power Indicator - indicator applet for NVIDIA Optimus laptops.
# Copyright (C) 2016 André Brait Carneiro Fabotti
#
# This work is based on the works of Alfred Neumayer and Clement Lefebvre.
#
# NVIDIA Power Indicator is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# NVIDIA Power Indicator is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NVIDIA Power Indicator.  If not, see <http://www.gnu.org/licenses/>.

import sys
import os
import re
import signal
import subprocess
import configparser

# Uncomment the following import if you want to enable type hinting
# and you're running Python >3.5, or you installed the typing package
# using pip.
# from typing import List 

import gi.repository

ICONS_FOLDER = "/icons/"

gi.require_version('Gtk', '3.0')
gi.require_version('AppIndicator3', '0.1')
from gi.repository import Gtk
from gi.repository import AppIndicator3

from threading import Timer

APP_NAME = "NVIDIA Power Indicator"
HOME_DIR = os.getenv("HOME")  # type:str
LIB_PATH = "/usr/lib/nvidia-power-indicator/"
SCRIPT_CMD = "sudo " + LIB_PATH + "gpuswitcher"
STD_ICONS_FOLDER = LIB_PATH + "icons/"
USER_ICONS_FOLDER = HOME_DIR + "/.config/nvidia-power-indicator/icons/"
CONFIG_PATH = HOME_DIR + "/.config/nvidia-power-indicator/nvidia-power-indicator.cfg"

NVIDIA = "nvidia"
INTEL = "intel"

NVIDIA_COLOR = STD_ICONS_FOLDER + "nvidia-power-indicator-nvidia.svg"
INTEL_COLOR = STD_ICONS_FOLDER + "nvidia-power-indicator-intel.svg"
NVIDIA_SYMBOLIC = USER_ICONS_FOLDER + "nvidia-power-indicator-nvidia-symbolic-themed.svg"
INTEL_SYMBOLIC = USER_ICONS_FOLDER + "nvidia-power-indicator-intel-symbolic-themed.svg"


class Indicator:
    def __init__(self):

        self.config = configparser.ConfigParser()
        self.check_config_integrity()

        self.pm_enabled = (self.config.get("PowerManagement", "enabled").strip().lower() == "true")  # type:bool

        self.theme_icons = self.config.get("Appearance", "iconset")  # type:str
        self.custom_color = None

        if self.theme_icons == "theme-default":
            theme = Gtk.IconTheme.get_default()
            if theme.has_icon(INTEL):
                self.intel_icon = theme.lookup_icon(INTEL, max(theme.get_icon_sizes(INTEL)), 0).get_filename()
            else:
                self.intel_icon = INTEL_COLOR
                print("ALERT: GTK Icon Theme does not provide an icon for Intel. Using default color icon instead!")
            if theme.has_icon(NVIDIA):
                self.nvidia_icon = theme.lookup_icon(NVIDIA, max(theme.get_icon_sizes(NVIDIA)), 0).get_filename()
            else:
                self.nvidia_icon = NVIDIA_COLOR
                print("ALERT: GTK Icon Theme does not provide an icon for NVIDIA. Using default color icon instead!")
        elif self.theme_icons == "color":
            self.nvidia_icon = NVIDIA_COLOR
            self.intel_icon = INTEL_COLOR
        else:
            if self.theme_icons.startswith("custom"):
                self.custom_color = re.search("custom\((.*)\)", self.theme_icons).group(1)
            self.create_themed_icons()
            self.nvidia_icon = NVIDIA_SYMBOLIC
            self.intel_icon = INTEL_SYMBOLIC

        self.menu = Gtk.Menu()

        self.toggle_power_management_enable = Gtk.CheckMenuItem("Enable NVIDIA GPU Power Management")
        self.toggle_power_management_enable.set_active(self.pm_enabled)
        self.toggle_power_management_enable.connect("toggled", self.toggle_pm)
        self.menu.append(self.toggle_power_management_enable)

        self.switch_power_management = Gtk.MenuItem()
        self.switch_power_management.connect("activate", self.switch_nv_power)
        self.menu.append(self.switch_power_management)

        self.toggle_power_management_enable.show()
        self.set_nv_pm_labels()

        item = Gtk.SeparatorMenuItem()
        item.show()
        self.menu.append(item)

        item = Gtk.MenuItem("Quit")
        item.connect("activate", self.terminate)
        item.show()
        self.menu.append(item)

        self.icon = AppIndicator3.Indicator.new(APP_NAME, "",
                                                AppIndicator3.IndicatorCategory.APPLICATION_STATUS)
        self.icon.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
        self.icon.set_menu(self.menu)

        self.t = None
        self.refresh()

    def create_themed_icons(self):
        fg_color_str = "#bebebe"
        if self.custom_color:
            fg_color_str = self.custom_color
        else:
            window = Gtk.Window()  # type:Gtk.Window
            style_context = window.get_style_context()
            style_fg_color = style_context.lookup_color('fg_color')  # type:tuple
            if style_fg_color[0]:
                fg_color_str = "#{r:02x}{g:02x}{b:02x}".format(r=int(style_fg_color[1].red * 255),
                                                               g=int(style_fg_color[1].green * 255),
                                                               b=int(style_fg_color[1].blue * 255))

        os.makedirs(USER_ICONS_FOLDER, exist_ok=True)
        with open(STD_ICONS_FOLDER + "nvidia-power-indicator-nvidia-symbolic.svg", "r") as fin:
            with open(NVIDIA_SYMBOLIC, "w") as fout:
                for line in fin:
                    fout.write(line.replace("#bebebe", fg_color_str))
        with open(STD_ICONS_FOLDER + "nvidia-power-indicator-intel-symbolic.svg", "r") as fin:
            with open(INTEL_SYMBOLIC, "w") as fout:
                for line in fin:
                    fout.write(line.replace("#bebebe", fg_color_str))

    def write_default_config(self):
        os.makedirs(os.path.dirname(CONFIG_PATH), exist_ok=True)
        self.config.clear()
        self.config.add_section("PowerManagement")
        self.config.add_section("Appearance")
        self.config.set("PowerManagement", "enabled", "true")
        self.config.set("Appearance", "iconset", "theme-default")
        with open(CONFIG_PATH, "w") as configfile:
            self.config.write(configfile)

    def check_config_integrity(self):
        if not os.path.exists(CONFIG_PATH) or not os.path.isfile(CONFIG_PATH):
            self.write_default_config()
        else:
            try:
                self.config.read(CONFIG_PATH)
                iconset = self.config.get("Appearance", "iconset")
                if iconset not in ["symbolic", "color", "theme-default"] and \
                        not re.search('^custom\(#([a-fA-F0-9]{2}){3}\)$', iconset) or \
                        self.config.get("PowerManagement", "enabled") not in ["true", "false"]:
                    self.write_default_config()
            except (configparser.NoSectionError, configparser.NoOptionError):
                self.write_default_config()

    def toggle_pm(self, dude):
        self.pm_enabled = self.toggle_power_management_enable.get_active()
        self.config.set(
            "PowerManagement", "enabled", str(self.pm_enabled))
        self.switch_power_management.set_sensitive(self.pm_enabled)
        with open(CONFIG_PATH, "w") as configfile:
            self.config.write(configfile)

    def terminate(self, window=None, data=None) -> None:
        self.t.cancel()
        Gtk.main_quit()

    def execute(self):
        Gtk.main()

    def nv_power_switch_string(self, nvidia_on) -> str:
        if nvidia_on is None:
            nvidia_on = self.is_nvidia_on()
        return "Force NVIDIA GPU to power " + ("OFF" if nvidia_on else "ON")

    def is_nvidia_on(self) -> bool:
        out = subprocess.getoutput("cat /proc/acpi/bbswitch")
        return out.lower().endswith("on")

    def switch_nv_power(self, dude) -> None:
        if self.is_nvidia_on():
            self.turn_nv_off()
        else:
            self.turn_nv_on()

    def turn_nv_on(self) -> None:
        os.system(SCRIPT_CMD + " on")
        self.set_nv_pm_labels()

    def turn_nv_off(self) -> None:
        primus_pids = subprocess.getoutput("pgrep -f primusrun")  # type:bytes
        optirun_pids = subprocess.getoutput("pgrep -f optirun")  # type:bytes
        if primus_pids or optirun_pids:
            message = "It seems there are programs using the NVIDIA GPU. " + \
                      "They need to be stopped before turning the GPU off."
            dialog = Gtk.MessageDialog(None, Gtk.DIALOG_MODAL, Gtk.MESSAGE_ERROR, Gtk.BUTTONS_OK, message)
            dialog.set_deletable(False)
            dialog.run()
        else:
            os.system(SCRIPT_CMD + " off")
            self.set_nv_pm_labels()

    def set_nv_pm_labels(self, nvidia_on=None) -> None:
        if self.pm_enabled:
            self.switch_power_management.set_label(self.nv_power_switch_string(nvidia_on))
            self.switch_power_management.show()

    def ignore(self, *args):
        return Gtk.ResponseType.CANCEL

    def refresh(self) -> None:
        self.t = Timer(2, self.refresh)
        self.t.start()

        nvidia_on = self.is_nvidia_on()
        self.icon.set_icon(self.nvidia_icon if nvidia_on else self.intel_icon)
        self.icon.set_title("Active graphics card: " + ("NVIDIA" if nvidia_on else "Intel"))
        self.set_nv_pm_labels(nvidia_on)


def kill_other_instances() -> None:
    otherpid = subprocess.getoutput("pgrep -f nvidia-power-indicator")  # type:bytes
    if otherpid:
        otherpid = str(otherpid)  # type:str
        pidlist = otherpid.splitlines()  # type:List[str]
        for pid in pidlist:
            if pid and pid.isnumeric():
                pid = int(pid)  # type:int
                if pid != os.getpid():
                    try:
                        os.kill(pid, signal.SIGTERM)
                        os.kill(pid, signal.SIGKILL)
                    except ProcessLookupError:
                        pass


if __name__ == "__main__":

    # If bbswitch isn't installed or isn't supported, exit cleanly
    if not os.path.isfile("/proc/acpi/bbswitch"):
        sys.exit(0)

    kill_other_instances()
    Indicator().execute()
