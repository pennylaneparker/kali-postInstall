# kali postinstall script
Customised version of the g0tmi1k's Kali Postinstall script (https://github.com/g0tmi1k/os-scripts/blob/master/kali-rolling.sh)

I personalised, added and removed some tools to the original script.

Tested on: Kali Linux 2019.4 x64 (VM - VMware) 

Run as root straight after a clean install of Kali.

## Command line arguments:
```
-alias = Add personalised aliases that are already defined in the script. false by default.
-hostname <value> = Change the hostname to the provided value. false by default.
-shortcutfolder <value> = Add shortcut for the /opt folder to the Desktop folder.
```

The following command will create already defined aliases, change hostname to `pentest` and add `Tools` named shortcut of the /opt folder to Desktop.

`bash kalipostinstall.sh -alias -hostname pentest -shortcutfolder Tools`

## References
* https://github.com/g0tmi1k/os-scripts
* https://github.com/zardus/ctf-tools
* https://github.com/TomNomNom
* https://github.com/nahamsec/Resources-for-Beginner-Bug-Bounty-Hunters/blob/master/assets/tools.md
* https://bugbountyforum.com/tools/
* https://github.com/nullenc0de/Kali-Install-Script
