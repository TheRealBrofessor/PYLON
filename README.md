# PYLON

PYLON is a small Linux utility for managing an ALFA AWUS1900 / RTL8814AU adapter in an authorized lab environment. It provides a repeatable way to inspect the adapter state and switch between a monitor/listen-oriented profile and an active managed profile.

This repository is a derivative project, not original work from scratch. The existing MIT license credits the original copyright holder. That notice stays with the project. The historical README referenced an `Exterus/PYLON` upstream; that source should be treated as unverified until it can be located and documented. See [MODERNIZATION.md](MODERNIZATION.md) for the provenance and cleanup plan.

## Current status

Experimental. Review `pylon.sh` before running it as root.

Recent cleanup removed two high-risk defects from the script:

- PYLON no longer generates an nftables file that begins with `flush ruleset`; it should only manage its own `inet pylon` table.
- An orphaned `toggle)` case block after the program entry point was removed so the script has one command router.

Hardware/driver behavior still needs testing across current Kali kernels before this should be treated as a polished release.

## What it does

### `audit`

Shows the current PYLON interface state, including mode, MAC information, driver/version information when available, and the PYLON-owned nftables table.

### `listen`

Attempts to:

- put the adapter in monitor mode;
- randomize the MAC address;
- request lower transmit power;
- block outbound traffic from the PYLON interface through a dedicated nftables table.

This is a **listen-oriented profile**, not a guarantee of invisibility or “stealth.” Driver, firmware, kernel, regulatory settings, and background services can affect actual radio behavior.

### `loud`

Attempts to return the adapter to managed mode, randomize the MAC address, and remove the PYLON interface from the outbound block.

### `switch`

Switches between the listen and active profiles based on the current interface mode.

### `toggle`

Attempts to toggle configured transmit power between 10 dBm and 20 dBm. Actual support depends on the adapter driver and regulatory configuration.

### `boot-listen`

Can install/remove a systemd service that requests the listen profile at boot.

## Requirements

The script is currently written for Debian/Kali-style systems and expects tools including:

- `iw`
- `rfkill`
- `macchanger`
- `ethtool`
- `nftables`
- standard `ip`/udev/systemd tooling

The setup command currently uses `apt`, so read it before running it on any system where package or network configuration matters.

## Install for development/testing

```bash
git clone https://github.com/TheRealBrofessor/PYLON.git
cd PYLON
chmod +x pylon.sh
./pylon.sh
```

The script prints usage without applying a mode. Commands that modify the host or adapter require appropriate privileges.

Example:

```bash
sudo ./pylon.sh audit
sudo ./pylon.sh listen
sudo ./pylon.sh loud
sudo ./pylon.sh switch
sudo ./pylon.sh toggle
sudo ./pylon.sh boot-listen on
sudo ./pylon.sh boot-listen off
```

## Before wider use

The next work is intentionally boring but important:

1. add dry-run and preflight behavior;
2. make every persistent host change reversible;
3. add ShellCheck/shfmt and shell tests;
4. test current AWUS1900 driver/kernel combinations;
5. separate or clearly modularize the unrelated Fleet/cyberrange material in this repository;
6. verify and document upstream provenance.

See [MODERNIZATION.md](MODERNIZATION.md) for the full plan.

## Authorization

Use PYLON only on equipment and networks you own or are explicitly authorized to test. Monitor mode and wireless tooling can expose traffic or capabilities that are inappropriate outside an authorized lab.

## License and attribution

MIT. See [LICENSE](LICENSE). The original copyright notice in that file must remain with copies or substantial portions of the software.

The earlier project documentation also referenced the `morrownr/rtl8814au` driver project. PYLON does not claim authorship of that driver or other third-party driver work.
