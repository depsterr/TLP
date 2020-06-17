#! /bin/sh

# --- Constants
readonly USBD="/sys/bus/usb/devices"
readonly USBF="/tmp/tlp_usb_list"

# --- Global vars
usbdevices=""
no_runtimepm=0

# --- Main

# Check if Runtime PM is enabled
[ -z "$(ls $USBD/*/power/autosuspend*)" ] && no_runtimepm=1

# Make sure there is no previous usb file
rm -f "$USBF"

# Read USB device tree attributes as arrays into %usbdevices hash, indexed by Bus_Device
for udev in $(ls "$USBD"); do
	usbv="(autosuspend not available)"
	
    # get device id
	usbk="$(printf '%03d_%03d', "$(cat "$udev/busnum")", "$(cat "$udev/devnum")")"

    # get attributes
	[ -f "$udev/power/autosuspend_delay_ms" ] && [ -f "$udev/power/control" ] && \
		usbv="$(printf 'control = %-5s autosuspend_delay_ms = %4d' \
		"$(cat "$udev/power/autosuspend_delay_ms")," \
		"$(cat "$udev/power/control")")"

	printf '%s|%s|%s' "$usbk" "$udev" "$usbv" >> "$USBF"
done

lsusb | while read -r line; do
	bus="$(echo $line | sed -e 's/\sDevice.*$//g' -e 's/^Bus\s//g')"
	device="$(echo $line | sed -e 's/\sID.*$//g' -e 's/^.*Device\s//g')"
	# BELOW IS NOT FINISHED YET
	bus="$(echo $line | sed -e 's/ID\s\S*//g' -e 's/^Bus\s//g')"
	bus="$(echo $line | sed -e 's/\sDevice.*$//g' -e 's/^Bus\s//g')"
done

# clean up usb file
rm -f "$USBF"

[ "$no_runtimepm" = 1 ] && exit 4

exit 0
