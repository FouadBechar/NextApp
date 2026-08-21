# `fouad-port-reaper`

Kill processes by port instantly on Windows.

A simple and fast CLI tool to find and terminate processes that are blocking your ports.

## Package and command

- npm package: `fouad-port-reaper`
- CLI command: `port-reaper`

## Install from npm

```bash
npm install -g fouad-port-reaper
port-reaper --help
```

## Usage

```bash
port-reaper 3000
port-reaper 3000 --dry-run
port-reaper --kill 3000
port-reaper 3000 --force
port-reaper --list
port-reaper --version
```

## What it does

- Finds the process using a specific port
- Displays process name, PID, and address
- Allows safe or forced termination
- Lists all listening ports with merged IPv4/IPv6 entries when they belong to the same process
- Prevents killing critical system processes
- Shows clearer Windows permission errors

## Notes

- Windows only
- The tool only targets processes in the `LISTENING` state
- `--kill` runs a quicker output mode for direct termination
- `--list` shows all listening ports before you choose one to kill
- When the same process listens on both IPv4 and IPv6, `--list` combines them into one entry
- `--dry-run` shows what would be killed without actually killing it
- `--force` overrides process protection for a specific port (advanced users)
- Protected system processes are blocked by default
- Permission-related failures are reported with a friendlier Windows-specific message
- Ports are strictly validated as numeric values between `1` and `65535`

## Example output

```text
Listening Ports

[3000] -> node.exe (PID: 12345) | TCP | IPv4 + IPv6

Port Reaper

-> Port: 3000
-> Process: node.exe (PID: 12345)
-> Address: 0.0.0.0:3000
-> Protocol: TCP

Terminated successfully
```
