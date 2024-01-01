# Mikrotik VPN Bandwidth Test

This script simplifies the configuration of L2TP and SSTP VPN interfaces on MikroTik routers. It enforces a specific naming convention for VPN interfaces. Follow the instructions below to set up your VPN interfaces.

## Prerequisites

- A MikroTik router with RouterOS installed.
- Access to the MikroTik router either via Winbox or SSH.

## Usage

1. **Download the Script:**
   Download the `vpn-bandwidth-test.rsc` script from this repository.

2. **Upload Script to MikroTik:**
   Use Winbox or SCP to upload the script to your MikroTik router.

3. **Run the Script:**
   In the MikroTik terminal, run the following command:
```bash
/import vpn-bandwidth-test.rsc
```
4. **Schedule the Script:**
```bash
/system scheduler
add interval=15m name=vpn-performance-script on-event=vpn-bandwidth-test policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup
