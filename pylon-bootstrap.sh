#!/usr/bin/env bash
# pylon-bootstrap.sh — one command to take the AWUS1900 from plugged-in to ready.
# Recovers a wedged USB port, runs PYLON setup (deps + driver profile + udev),
# then confirms the PYLON interface. Never touches internal wifi (wlp98s0 / PCIe).
set -uo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo $0"; exit 1; }
HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

echo "=================== PYLON bootstrap ==================="

# 1. Is the adapter on the bus?
if ! lsusb | grep -qiE 'Realtek|0bda'; then
  echo "[1] Adapter not seen on USB. Attempting xHCI port recovery..."
  CTRL="$(basename "$(readlink -f /sys/bus/usb/devices/usb3/../..)")"
  echo "    xHCI controller: $CTRL"
  echo -n "$CTRL" > /sys/bus/pci/drivers/xhci_hcd/unbind 2>/dev/null; sleep 3
  echo -n "$CTRL" > /sys/bus/pci/drivers/xhci_hcd/bind   2>/dev/null; sleep 5
fi

if ! lsusb | grep -qiE 'Realtek|0bda'; then
  echo "[1] STILL not on USB after recovery."
  echo "    -> This is physical. Use a known-good USB 3.0 DATA cable, plug"
  echo "       straight into a blue port (no hub). A lit LED only means power."
  echo "    Latest port errors:"
  journalctl -k --since '-2min' --no-pager 2>/dev/null | grep -E 'usb 3-|usb3-port' | tail -6 | sed 's/^/      /'
  echo "    Internal wifi (untouched):"; ip -br addr show wlp98s0 | sed 's/^/      /'
  exit 1
fi
echo "[1] Adapter present: $(lsusb | grep -iE 'Realtek|0bda' | head -1)"

# 2. Run PYLON setup (idempotent: deps, driver profile, self-install, udev rule)
echo "[2] Running PYLON setup..."
bash "$HERE/pylon.sh" setup

# 3. Wait for the PYLON interface, unblock rf, bring it up
echo "[3] Waiting for the PYLON interface (udev rename, up to 20s)..."
IF=""
for i in $(seq 1 20); do
  IF="$(ls /sys/class/net | grep -E '^(PYLON|wlx)' | head -1)"
  [[ -n "$IF" ]] && break; sleep 1
done
if [[ -z "$IF" ]]; then
  echo "[3] Interface didn't appear. Unplug/replug the Alfa, then: sudo pylon.sh audit"
  exit 1
fi
rfkill unblock wlan 2>/dev/null || true
ip link set "$IF" up 2>/dev/null || true
echo "[3] Interface up: $IF"

# 4. Audit
echo "[4] State:"
bash "$HERE/pylon.sh" audit 2>/dev/null | sed 's/^/    /'
echo "    Internal wifi (untouched):"; ip -br addr show wlp98s0 | sed 's/^/    /'
echo "======================================================"
echo "READY.  Modes:  sudo pylon.sh listen | loud | switch | toggle"
