# PYLON modernization plan

PYLON can be improved, but provenance has to stay clear. The repository's MIT license credits the original copyright holder, and the README references an upstream source. Any modernization should preserve that attribution and distinguish original work from later changes.

## 1. Verify provenance before presenting the project publicly

- Keep the existing MIT copyright and permission notice.
- Locate and record the original upstream repository if it is still available.
- If the upstream can no longer be verified, say exactly that instead of guessing.
- Document which components are inherited and which were added later.
- Do not remove attribution or rewrite history to imply original authorship.

## 2. Decide what PYLON actually is

The repository currently contains two different directions:

1. an AWUS1900 / RTL8814AU adapter-management shell utility; and
2. Docker/Fleet/cyberrange configuration added later.

Choose one of these structures before adding more features:

### Option A — focused wireless utility

Keep PYLON as the adapter-management and diagnostics project. Move Fleet/cyberrange material to a separate repository.

### Option B — modular lab appliance

Redefine PYLON as a defensive lab appliance and split functionality into named modules (`wireless/`, `fleet/`, `lab/`) with separate setup, threat model, and rollback documentation.

Do not continue mixing unrelated systems under one README.

## 3. Fix host-safety problems before feature growth

The current `pylon.sh` makes privileged host changes. Treat reversibility as a first-class requirement.

Priority fixes:

- add `--help`, `--version`, and `--dry-run`;
- run a preflight before changing packages, interfaces, firewall rules, or udev;
- require explicit confirmation before package installation or persistent host changes;
- back up PYLON-managed configuration before replacing it;
- add an uninstall/restore path;
- never flush or replace an unrelated system firewall ruleset;
- create/delete only PYLON-owned nftables tables/chains/elements;
- detect naming conflicts instead of assuming the interface can always become `PYLON`;
- check driver/kernel capabilities before claiming a mode transition succeeded;
- fail with actionable diagnostics rather than continuing after a critical command fails.

## 4. Make terminology technically accurate

"Monitor mode" and "low transmit power" are useful controls, but they do not guarantee invisibility or "stealth." Driver, firmware, regulatory rules, background services, and hardware behavior all matter.

Public documentation should describe observable configuration rather than make guarantees the code cannot verify.

## 5. Add a real diagnostics mode

A useful PYLON feature for other people would be a read-only diagnostic report that checks:

- USB VID/PID and chipset;
- bound kernel module and version;
- kernel version;
- regulatory domain;
- current interface names and modes;
- supported frequencies/bands;
- monitor-mode support;
- rfkill state;
- NetworkManager ownership;
- relevant nftables state;
- driver/firmware warnings.

The report should redact host-specific identifiers that are not required for troubleshooting.

## 6. Build reversible setup profiles

Separate installation from operation.

Suggested profiles:

- Kali + AWUS1900;
- Parrot + AWUS1900;
- Ubuntu lab host + AWUS1900.

Each profile should have:

1. preflight;
2. proposed changes;
3. apply;
4. verify;
5. rollback.

## 7. Add tests and quality gates

- ShellCheck.
- shfmt.
- Bats tests for parsing/state logic.
- mocked command-output fixtures for hardware detection.
- CI that does not require root or a physical adapter.
- optional manual hardware test checklist for supported adapters/kernels.

## 8. Useful directions beyond mode switching

### Troubleshooting bundle

Export a support bundle containing hardware/driver/kernel/state information with sensitive values redacted.

### Classroom/lab readiness check

Give instructors/students a one-command report confirming whether the adapter is correctly installed and capable of the intended authorized lab exercise.

### Passive RF observation profile

Provide an explicitly passive configuration for authorized defensive observation, with clear boundaries around what the tool does and does not transmit.

### Compatibility knowledge base

Track known kernel/driver/adapter combinations and their verified status. A reliable compatibility matrix may be more useful to AWUS1900 owners than another one-click installer.

## Release gate

A modernized public PYLON should have:

- verified/properly documented provenance;
- one coherent project definition;
- reversible privileged changes;
- no global firewall destruction;
- diagnostic-first behavior;
- automated quality checks;
- clear authorization boundaries;
- claims limited to behavior the tool can actually verify.
