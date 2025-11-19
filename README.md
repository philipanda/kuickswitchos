# KuickSwitchOS

KuickSwitchOS is a simple KDE Plasma 6 Plasmoid that allows to quickly boot
into another OS in an UEFI multiboot system using a simple GUI panel.

<img width="328" height="275" alt="image" src="https://github.com/user-attachments/assets/67ce3a84-23af-4306-a0a4-6cd7d3c2515f" />

## Usage

1. The plasmoid is supposed to go onto your Plasma Panel
2. Click the icon to display the available OSes detected using `efibootmgr`
3. Check a radio button next to the chosen OS
4. Press `Apply & Reboot` to:
   1. set the `nextboot` UEFI variable
   2. display the Plasma reboot prompt
   3. after rebooting let UEFI do its job and boot the selected OS

## Installation

Installation can be performed manually by cloning the project into your plasmoids directory.

Example:
```shell
git clone https://github.com/philipanda/kuickswitchos $HOME/.local/share/plasma/plasmoids/com.github.philipanda.kuickswitchos
```

## Uninstallation

Remove the widget from your Plasma Panel and delete the files at your plasmoids directory:

```shell
rm -rf $HOME/.local/share/plasma/plasmoids/com.github.philipanda.kuickswitchos
```