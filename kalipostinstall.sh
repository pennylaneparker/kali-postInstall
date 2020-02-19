#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: kali-rolling.sh             (Update: 2020-02-18) #
#-Info--------------------------------------------------------#
#  Personal post-install script for Kali Linux Rolling        #
#-Original Author(s)------------------------------------------#
#  g0tmilk ~ https://blog.g0tmi1k.com/                        #
#-Customisation-----------------------------------------------#
#  Asli Koksal ~  https://github.com/pennylaneparker          #
#-Operating System--------------------------------------------#
#  Designed for: Kali Linux Rolling [x64] (VM - VMware)       #
#     Tested on: Kali Linux 2019.4 x64 (VM - VMware)          #
#-Licence-----------------------------------------------------#
#  MIT License ~ http://opensource.org/licenses/MIT           #
#-Notes-------------------------------------------------------#
#  Run as root straight after a clean install of Kali Rolling #
#                             ---                             #
#  You will need 25GB+ free HDD space before running.         #
#                             ---                             #
#  Command line arguments:                                    #
#    -alias = Add personalised aliases                        #
#                                                             #
#    -hostname <value> = Change the hostname                  #
#    -shortcutfolder <value> = Desktop folder                 #
#                                                             #
# e.g.                                                        #
# bash kali-rolling.sh -alias -hostname pentest -shortcutfolder Tools   #
#                             ---                             #
#  Will cut it up (so modular based), at a later date...      #
#                             ---                             #
#             ** This script is meant for _ME_. **            #
#         ** EDIT this to meet _YOUR_ requirements! **        #
#-References--------------------------------------------------#
# https://github.com/g0tmi1k/os-scripts                       #
# https://github.com/zardus/ctf-tools                         #
# https://github.com/TomNomNom                                #
# https://github.com/nahamsec/Resources-for-Beginner-Bug-Bounty-Hunters/blob/master/assets/tools.md #
# https://bugbountyforum.com/tools/                           #
# https://github.com/nullenc0de/Kali-Install-Script           #
#-------------------------------------------------------------#

#-Defaults-------------------------------------------------------------#

start_time=$(date +%s)

##### Hardcoded versions:
pycharm="https://download.jetbrains.com/python/pycharm-community-2016.2.3.tar.gz"
dex2jar="https://github.com/pxb1988/dex2jar/files/1867564/dex-tools-2.1-SNAPSHOT.zip"
jdgui="https://github.com/java-decompiler/jd-gui/releases/download/v1.6.5/jd-gui-1.6.5.jar"
ffuf="https://github.com/ffuf/ffuf/releases/download/v1.0.1/ffuf_1.0.1_linux_amd64.tar.gz"
amass="https://github.com/OWASP/Amass/releases/download/v3.4.3/amass_v3.4.3_linux_amd64.zip"
nmapvulscan="http://www.computec.ch/projekte/vulscan/download/nmap_nse_vulscan-2.0.tar.gz"
sonicvis="https://code.soundsoftware.ac.uk/attachments/download/2606/sonic-visualiser_4.0.1_amd64.deb"
apktool="https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.1.jar"
dextools="https://github.com/pxb1988/dex2jar/files/1867564/dex-tools-2.1-SNAPSHOT.zip"
mingw="http://sourceforge.net/projects/mingw/files/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip/download"
py27="https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi"
pywin="http://sourceforge.net/projects/pywin32/files/pywin32/Build%20219/pywin32-219.win32-py2.7.exe/download"
stegsolve="http://www.caesum.com/handbook/Stegsolve.jar"
cfr="http://www.benf.org/other/cfr/cfr_0_116.jar"
lazagne="https://github.com/AlessandroZ/LaZagne/releases/download/2.4.3/lazagne.exe"
gitrob="https://github.com/michenriksen/gitrob/releases/download/v2.0.0-beta/gitrob_linux_amd64_2.0.0-beta.zip"

##### Directories:
ctfdir="/opt/ctf"
cryptodir="/opt/ctf/crypto"
mobiledir="/opt/ctf/mobile"
pwndir="/opt/ctf/pwn"
stegdir="/opt/ctf/steg"
fordir="/opt/forensic"
diffdir="/opt/diff"
miscdir="/opt/misc"
pentestdir="/opt/pentest"
passdir="/opt/pentest/password"
expdir="/opt/pentest/exploit"
rcedir="/opt/pentest/rce"
lfidir="/opt/pentest/lfi"
osdir="/opt/pentest/osexploit"
webdir="/opt/pentest/webexploit"
xssdir="/opt/pentest/xss"
postexpdir="/opt/pentest/postexp"
windir="/opt/pentest/postexp/windows"
recondir="/opt/pentest/recon"
discdir="/opt/pentest/recon/discovery"
gitdir="/opt/pentest/recon/gitrepo"
googledir="/opt/pentest/recon/google"
smbdir="/opt/pentest/recon/smb"
subdomdir="/opt/pentest/recon/subdomain"
wordlistdir="/opt/pentest/wordlist"
revdir="/opt/reverse"

##### Hostname and folder information
host_name=""                # Set hostname                                              [ --hostname wonderland ]
shortcutfolder=""           # Set Desktop shortcut folder                               [ --shortcutfolder Tools ]

##### Optional steps
addaliases=false            # Add personalised aliases     [ --alias ]
shortcutadd=false           # Shortcut opt folder to the Desktop as given name in desktopshortcut parameter [ --shortcutadd ]
hostnamechange=false        # Change hostname (not everyone wants it...)    [ --hostnamechange ]

##### (Optional) Enable debug mode?
#set -x

##### (Cosmetic) Colour output
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

STAGE=0                                                         # Where are we up to
TOTAL=$( grep '(${STAGE}/${TOTAL})' $0 | wc -l );(( TOTAL-- ))  # How many things have we got todo


##### Check if we are running as root - else this script will fail (hard!)
if [[ "${EUID}" -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" This script must be ${RED}run as root${RESET}" 1>&2
  echo -e ' '${RED}'[!]'${RESET}" Quitting..." 1>&2
  exit 1
else
  echo -e " ${BLUE}[*]${RESET} ${BOLD}Kali Linux rolling post-install script${RESET}"
  sleep 3s
fi


#-Arguments------------------------------------------------------------#


##### Read command line arguments
while [[ "${#}" -gt 0 && ."${1}" == .-* ]]; do
  opt="${1}";
  shift;
  case "$(echo ${opt} | tr '[:upper:]' '[:lower:]')" in
    -|-- ) break 2;;

    -alias|--alias )
      addaliases=true;;

    -shortcutfolder|--shortcutfolder )
      shortcutadd=true; shortcutfolder="${1}"; shift;;
    -shortcutfolder=*|--shortcutfolder=* )
      shortcutadd=true; shortcutfolder="${opt#*=}";;

    -hostname|--hostname )
      hostnamechange=true; host_name="${1}"; shift;;
    -hostname=*|--hostname=* )
      hostnamechange=true; host_name="${opt#*=}";;
    
    *) echo -e ' '${RED}'[!]'${RESET}" Unknown option: ${RED}${x}${RESET}" 1>&2 \
      && exit 1;;
   esac
done


########################################################################################################################
##### GENERAL TOOLS #####
echo -e "\n\n ${GREEN}[+]${RESET}${GREEN} Starting to install GENERAL tools! ${RESET}"

##### Make dirs:
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN} Creating directories! ${RESET}"
mkdir -p ${ctfdir}
mkdir -p ${cryptodir}
mkdir -p ${mobiledir}
mkdir -p ${pwndir}
mkdir -p ${stegdir}
mkdir -p ${fordir}
mkdir -p ${diffdir}
mkdir -p ${miscdir}
mkdir -p ${pentestdir}
mkdir -p ${passdir}
mkdir -p ${expdir}
mkdir -p ${rcedir}
mkdir -p ${lfidir}
mkdir -p ${osdir}
mkdir -p ${webdir}
mkdir -p ${xssdir}
mkdir -p ${postexpdir}
mkdir -p ${windir}
mkdir -p ${recondir}
mkdir -p ${discdir}
mkdir -p ${gitdir}
mkdir -p ${googledir}
mkdir -p ${smbdir}
mkdir -p ${subdomdir}
mkdir -p ${wordlistdir}
mkdir -p ${revdir}
mkdir -p /usr/local/bin/

##### Enable default network repositories ~ http://docs.kali.org/general-use/kali-linux-sources-list-repositories
#--- Add network repositories
file=/etc/apt/sources.list; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
#--- Main
grep -q '^deb .* kali-rolling' "${file}" 2>/dev/null \
  || echo -e "\n\n# Kali Rolling\ndeb http://http.kali.org/kali kali-rolling main contrib non-free" >> "${file}"
#--- Source
grep -q '^deb-src .* kali-rolling' "${file}" 2>/dev/null \
  || echo -e "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" >> "${file}"
#--- Disable CD repositories
sed -i '/kali/ s/^\( \|\t\|\)deb cdrom/#deb cdrom/g' "${file}"
#--- incase we were interrupted
dpkg --configure -a
#--- Update
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Running a package upgrade ${GREEN}latest upgrades${RESET}"
apt -qq -y update && apt-get -qq dist-upgrade -y
apt -qq full-upgrade -y
apt-get -qq -y autoremove
apt-get -qq -y autoclean
if [[ "$?" -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" There was an ${RED}issue accessing network repositories${RESET}" 1>&2
  echo -e " ${YELLOW}[i]${RESET} Are the remote network repositories ${YELLOW}currently being sync'd${RESET}?"
  echo -e " ${YELLOW}[i]${RESET} Here is ${BOLD}YOUR${RESET} local network ${BOLD}repository${RESET} information (Geo-IP based):\n"
  curl -sI http://http.kali.org/README
  exit 1
fi


##### Install required packages
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}required packages${RESET}"
apt -y -qq install curl unixodbc-dev python-dnspython windows-binaries make gcc git cifs-utils libgmp3-dev libmpc-dev libfftw3-single3 libfishsound1 libid3tag0 liblo7 liblrdf0 libmad0 liboggz2 libopusfile0 python3-dev libffi-dev build-essential virtualenvwrapper ruby-dev libpcap-dev python-pip python3-pip exploitdb unrar wordlists \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Upgrade pip
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Upgrading ${GREEN}pip${RESET}"
python2 -m pip install --upgrade pip \
  || echo -e ' '${RED}'[!] Issue with pip upgrade'${RESET} 1>&2
python3 -m pip install --upgrade pip \
  || echo -e ' '${RED}'[!] Issue with pip upgrade'${RESET} 1>&2


##### Install kernel headers
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}kernel headers${RESET}"
apt -y -qq install "linux-headers-$(uname -r)" \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
if [[ $? -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" There was an ${RED}issue installing kernel headers${RESET}" 1>&2
  echo -e " ${YELLOW}[i]${RESET} Are you ${YELLOW}USING${RESET} the ${YELLOW}latest kernel${RESET}?"
  echo -e " ${YELLOW}[i]${RESET} ${YELLOW}Reboot${RESET} your machine"
  #exit 1
  sleep 30s
fi


##### Configure bash - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}bash${RESET} ~ CLI shell"
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.bashrc
grep -q "cdspell" "${file}" \
  || echo "shopt -sq cdspell" >> "${file}"             # Spell check 'cd' commands
grep -q "autocd" "${file}" \
 || echo "shopt -s autocd" >> "${file}"                # So you don't have to 'cd' before a folder
#grep -q "CDPATH" "${file}" \
# || echo "CDPATH=/etc:/usr/share/:/opt" >> "${file}"  # Always CD into these folders
grep -q "checkwinsize" "${file}" \
 || echo "shopt -sq checkwinsize" >> "${file}"         # Wrap lines correctly after resizing
grep -q "nocaseglob" "${file}" \
 || echo "shopt -sq nocaseglob" >> "${file}"           # Case insensitive pathname expansion
grep -q "HISTSIZE" "${file}" \
 || echo "HISTSIZE=" >> "${file}"                 # Bash history (memory scroll back)
grep -q "HISTFILESIZE" "${file}" \
 || echo "HISTFILESIZE=" >> "${file}"             # Bash history (file .bash_history)
#--- Apply new configs
source "${file}" || source ~/.zshrc


##### Install vim - all users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}vim${RESET} ~ CLI text editor"
apt -y -qq install vim \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Configure vim
file=/etc/vim/vimrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #~/.vimrc
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
sed -i 's/.*syntax on/syntax on/' "${file}"
sed -i 's/.*set background=dark/set background=dark/' "${file}"
sed -i 's/.*set showcmd/set showcmd/' "${file}"
sed -i 's/.*set showmatch/set showmatch/' "${file}"
sed -i 's/.*set ignorecase/set ignorecase/' "${file}"
sed -i 's/.*set smartcase/set smartcase/' "${file}"
sed -i 's/.*set incsearch/set incsearch/' "${file}"
sed -i 's/.*set autowrite/set autowrite/' "${file}"
sed -i 's/.*set hidden/set hidden/' "${file}"
sed -i 's/.*set mouse=.*/"set mouse=a/' "${file}"
grep -q '^set number' "${file}" 2>/dev/null \
  || echo 'set number' >> "${file}"                                                                      # Add line numbers
grep -q '^set expandtab' "${file}" 2>/dev/null \
  || echo -e 'set expandtab\nset smarttab' >> "${file}"                                                  # Set use spaces instead of tabs
grep -q '^set softtabstop' "${file}" 2>/dev/null \
  || echo -e 'set softtabstop=4\nset shiftwidth=4' >> "${file}"                                          # Set 4 spaces as a 'tab'
grep -q '^set foldmethod=marker' "${file}" 2>/dev/null \
  || echo 'set foldmethod=marker' >> "${file}"                                                           # Folding
grep -q '^nnoremap <space> za' "${file}" 2>/dev/null \
  || echo 'nnoremap <space> za' >> "${file}"                                                             # Space toggle folds
grep -q '^set hlsearch' "${file}" 2>/dev/null \
  || echo 'set hlsearch' >> "${file}"                                                                    # Highlight search results
grep -q '^set laststatus' "${file}" 2>/dev/null \
  || echo -e 'set laststatus=2\nset statusline=%F%m%r%h%w\ (%{&ff}){%Y}\ [%l,%v][%p%%]' >> "${file}"     # Status bar
grep -q '^filetype on' "${file}" 2>/dev/null \
  || echo -e 'filetype on\nfiletype plugin on\nsyntax enable\nset grepprg=grep\ -nH\ $*' >> "${file}"    # Syntax highlighting
grep -q '^set wildmenu' "${file}" 2>/dev/null \
  || echo -e 'set wildmenu\nset wildmode=list:longest,full' >> "${file}"                                 # Tab completion
grep -q '^set invnumber' "${file}" 2>/dev/null \
  || echo -e ':nmap <F8> :set invnumber<CR>' >> "${file}"                                                # Toggle line numbers
grep -q '^set pastetoggle=<F9>' "${file}" 2>/dev/null \
  || echo -e 'set pastetoggle=<F9>' >> "${file}"                                                         # Hotkey - turning off auto indent when pasting
grep -q '^:command Q q' "${file}" 2>/dev/null \
  || echo -e ':command Q q' >> "${file}"                                                                 # Fix stupid typo I always make
#--- Set as default editor
export EDITOR="vim"   #update-alternatives --config editor
file=/etc/bash.bashrc; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^EDITOR' "${file}" 2>/dev/null \
  || echo 'EDITOR="vim"' >> "${file}"
git config --global core.editor "vim"
#--- Set as default mergetool
git config --global merge.tool vimdiff
git config --global merge.conflictstyle diff3
git config --global mergetool.prompt false


##### Install go
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}go${RESET} ~ programming language"
apt -y -qq install golang \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
echo "export GO111MODULE=on" >> /root/.bashrc
source /root/.bashrc
#go files in /root/go/bin unless you specify other


##### Install PyCharm (Community Edition)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}PyCharm (Community Edition)${RESET} ~ Python IDE"
timeout 300 curl --progress-bar -k -L -f ${pycharm} > /tmp/pycharms-community.tar.gz \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pycharms-community.tar.gz" 1>&2       #***!!! hardcoded version!
if [ -e /tmp/pycharms-community.tar.gz ]; then
  tar -xf /tmp/pycharms-community.tar.gz -C /tmp/
  mv -f /tmp/pycharm-community-*/ ${miscdir}/pycharms
  ln -sf ${miscdir}/pycharms/bin/pycharm.sh /usr/local/bin/pycharms
fi


##### Install proxychains-ng (https://bugs.kali.org/view.php?id=2037)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}proxychains-ng${RESET} ~ Proxifier"
git clone -q https://github.com/rofl0r/proxychains-ng.git ${miscdir}/proxychains-ng/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${miscdir}/proxychains-ng/ >/dev/null
git pull -q
make -s clean
./configure --prefix=/usr --sysconfdir=/etc >/dev/null
make -s 2>/dev/null && make -s install   # bad, but it gives errors which might be confusing (still builds)
popd >/dev/null
#--- Add to path (with a 'better' name)
ln -sf /usr/bin/proxychains4 /usr/local/bin/proxychains-ng


##### Install htop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}htop${RESET} ~ CLI process viewer"
apt -y -qq install htop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install powertop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}powertop${RESET} ~ CLI power consumption viewer"
apt -y -qq install powertop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install iotop
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}iotop${RESET} ~ CLI I/O usage"
apt -y -qq install iotop \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install zip & unzip
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}zip${RESET} & ${GREEN}unzip${RESET} ~ CLI file extractors"
apt -y -qq install zip unzip \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install WINE
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WINE${RESET} ~ run Windows programs on *nix"
apt -y -qq install wine winetricks \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Using x64?
if [[ "$(uname -m)" == 'x86_64' ]]; then
  echo -e " ${GREEN}[i]${RESET} Configuring ${GREEN}WINE (x64)${RESET}"
  dpkg --add-architecture i386
  apt -qq update
  apt -y -qq install wine32 \
    || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
fi
#--- Run WINE for the first time
[ -e /usr/share/windows-binaries/whoami.exe ] && wine /usr/share/windows-binaries/whoami.exe &>/dev/null
#--- Setup default file association for .exe
file=~/.local/share/applications/mimeapps.list; [ -e "${file}" ] && cp -n $file{,.bkup}
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
echo -e 'application/x-ms-dos-executable=wine.desktop' >> "${file}"


##### Install MinGW (Windows) ~ cross compiling suite
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MinGW (Windows)${RESET} ~ cross compiling suite"
apt -y -qq install wine curl unzip \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
timeout 300 curl --progress-bar -k -L -f ${mingw} > /tmp/mingw-get.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading mingw-get.zip" 1>&2       #***!!! hardcoded path!
mkdir -p ~/.wine/drive_c/MinGW/bin/
unzip -q -o -d ~/.wine/drive_c/MinGW/ /tmp/mingw-get.zip
pushd ~/.wine/drive_c/MinGW/ >/dev/null
for FILE in mingw32-base mingw32-gcc-g++ mingw32-gcc-objc; do   #msys-base
  wine ./bin/mingw-get.exe install "${FILE}" 2>&1 | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
done
popd >/dev/null
#--- Add to windows path
grep -q '^"PATH"=.*C:\\\\MinGW\\\\bin' ~/.wine/system.reg \
  || sed -i '/^"PATH"=/ s_"$_;C:\\\\MinGW\\\\bin"_' ~/.wine/system.reg


##### Install Python (Windows via WINE)
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Python (Windows)${RESET}"
echo -n '[1/2]'; timeout 300 curl --progress-bar -k -L -f ${py27} > /tmp/python.msi \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading python.msi" 1>&2       #***!!! hardcoded path!
echo -n '[2/2]'; timeout 300 curl --progress-bar -k -L -f ${pywin} > /tmp/pywin32.exe \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pywin32.exe" 1>&2      #***!!! hardcoded path!
wine msiexec /i /tmp/python.msi /qb 2>&1 | grep -v 'If something goes wrong, please rerun with\|for more detailed debugging output'
pushd /tmp/ >/dev/null
rm -rf "PLATLIB/" "SCRIPTS/"
unzip -q -o /tmp/pywin32.exe
cp -rf PLATLIB/* ~/.wine/drive_c/Python27/Lib/site-packages/
cp -rf SCRIPTS/* ~/.wine/drive_c/Python27/Scripts/
rm -rf "PLATLIB/" "SCRIPTS/"
popd >/dev/null

##### Install apt-file
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}apt-file${RESET} ~ which package includes a specific file"
apt -y -qq install apt-file \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
apt-file update


##### Install apt-show-versions
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}apt-show-versions${RESET} ~ which package version in repo"
apt -y -qq install apt-show-versions \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install hashid
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}hashid${RESET} ~ identify hash types"
apt -y -qq install hashid \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which hashid` ${miscdir}


##### Install libreoffice
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}LibreOffice${RESET} ~ GUI office suite"
apt -y -qq install libreoffice \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which libreoffice` ${miscdir}


##### Install asciinema
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}asciinema${RESET} ~ CLI terminal recorder"
apt -y -qq install asciinema \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which asciinema` ${miscdir}

##### Install gedit
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gedit${RESET} ~ GUI text editor"
apt -y -qq install gedit \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which gedit` ${miscdir}


##### Install chrome
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Google Chrome${RESET} ~ Browser"
timeout 300 curl --progress-bar -k -L -f "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" > /tmp/chrome.deb \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading google chrome" 1>&2       #***!!! hardcoded path!
dpkg -i --force-depends /tmp/chrome.deb
apt-get -f install -y
dpkg -i --force-depends /tmp/chrome.deb



########################################################################################################################
##### DIFF TOOLS #####
echo -e "\n\n ${GREEN}[+]${RESET}${GREEN} Starting to install DIFF tools! ${RESET}"

##### Install wdiff
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wdiff${RESET} ~ Compares two files word by word"
apt -y -qq install wdiff wdiff-doc \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which wdiff` ${diffdir}


##### Install meld
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}meld${RESET} ~ GUI text compare"
apt -y -qq install meld \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#--- Configure meld
gconftool-2 -t bool -s /apps/meld/show_line_numbers true
gconftool-2 -t bool -s /apps/meld/show_whitespace true
gconftool-2 -t bool -s /apps/meld/use_syntax_highlighting true
gconftool-2 -t int -s /apps/meld/edit_wrap_lines 2
ln -sf `which meld` ${diffdir}


##### Install vbindiff
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}vbindiff${RESET} ~ visually compare binary files"
apt -y -qq install vbindiff \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which vbindiff` ${diffdir}


##### Install dhex
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dhex${RESET} ~ CLI hex compare"
apt -y -qq install dhex \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which dhex` ${diffdir}



########################################################################################################################
##### FORENSIC TOOLS #####
echo -e "\n\n ${GREEN}[+]${RESET}${GREEN} Starting to install Forensic tools! ${RESET}"

##### Install volatility3
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}volatility3${RESET} ~ memory analysis tool"
git clone -q https://github.com/volatilityfoundation/volatility3.git ${fordir}/volatility3/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#--- Add to path
file=/usr/local/bin/volatility3
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${fordir}/volatility3/ && python3 vol.py "\$@"
EOF
chmod +x "${file}"


##### Install volatility2
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}volatility2${RESET} ~ memory analysis tool"
apt -y -qq install volatility \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which volatility` ${fordir}


##### Install volatility-bitlocker plugin
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}volatility-bitlocker${RESET} ~ Volatility plugin to extract BitLocker FVEK"
git clone -q https://github.com/tribalchicken/volatility-bitlocker.git ${fordir}/volatility-bitlocker/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install exiftool
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}exiftool${RESET} ~ Read write metadata"
apt -y -qq install exiftool \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which exiftool` ${fordir}


##### Install fcrackzip
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}fcrackzip${RESET} ~ Zip Password Cracker"
apt -y -qq install fcrackzip \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which fcrackzip` ${fordir}


##### Install foremost
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}foremost${RESET} ~ File carver"
apt -y -qq install foremost \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which foremost` ${fordir}



########################################################################################################################
##### CTF TOOLS #####
echo -e "\n\n ${GREEN}[+]${RESET}${GREEN} Starting to install CTF tools! ${RESET}"

##### Install featherduster
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}featherduster${RESET} ~ An automated, modular cryptanalysis tool."
git clone -q https://github.com/nccgroup/featherduster.git ${cryptodir}/featherduster/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${cryptodir}/featherduster/ >/dev/null
python setup.py install
git pull -q
popd >/dev/null


##### Install kasiski
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}kasiski${RESET} ~ Vigenere Cipher Hacker"
git clone -q https://github.com/nytr0gen/kasiski.git ${cryptodir}/kasiski/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install RsaCtfTool
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}RsaCtfTool${RESET} ~ RSA attack tool"
git clone -q https://github.com/Ganapati/RsaCtfTool.git ${cryptodir}/RsaCtfTool/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
sudo apt -y -qq install libgmp3-dev libmpc-dev
pip install -r ${cryptodir}"/RsaCtfTool/requirements.txt"


##### Install rsatool
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}rsatool${RESET} ~ RSA attack tool"
git clone -q https://github.com/ius/rsatool.git ${cryptodir}/rsatool/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${cryptodir}/rsatool/ >/dev/null
python setup.py install
git pull -q
popd >/dev/null


##### Install vigenereHacker
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}vigenereHacker${RESET} ~ Vigenere Cipher Hacker"
timeout 300 curl --progress-bar -k -L -f "https://inventwithpython.com/vigenereHacker.py" > ${cryptodir}/vigenereHacker.py \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading vigenereHacker" 1>&2       #***!!! hardcoded path!


##### Install xortool
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}xortool${RESET} ~ XOR analysis tool"
python3 -m pip install xortool  \
  || echo -e ' '${RED}'[!] Issue with pip install'${RESET} 1>&2
ln -sf `which xortool` ${cryptodir}


##### Install apktool
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}apktool${RESET} ~ A tool for reverse engineering 3rd party, closed, binary Android apps. "
timeout 300 curl --progress-bar -k -L -f ${apktool} > ${mobiledir}/apktool.jar \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading apktool" 1>&2       #***!!! hardcoded path!
#--- Add to path
file=/usr/local/bin/apktool
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${mobiledir}/ && java -jar apktool.jar "\$@"
EOF
chmod +x "${file}"


##### Install dex2jar
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dex2jar${RESET} ~ convert dex files into jar"
timeout 300 curl --progress-bar -k -L -f ${dex2jar} > /tmp/dex2jar.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading dex2jar" 1>&2       #***!!! hardcoded path!
unzip -q -o /tmp/dex2jar.zip -d ${mobiledir}/dex2jar/


##### Install dextools
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dextools${RESET} "
timeout 300 curl --progress-bar -k -L -f ${dextools} > /tmp/dextools.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading dextools" 1>&2       #***!!! hardcoded path!
unzip -q -o /tmp/dextools.zip -d ${mobiledir}/dextools/


##### Install sign
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}sign${RESET} ~ Automatically sign an apk with the Android test certificate."
git clone -q https://github.com/appium/sign.git ${mobiledir}/sign/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install ROPgadget
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ROPgadget${RESET} ~ search gadgets for ROP exploitation"
sudo pip install capstone \
  || echo -e ' '${RED}'[!] Issue with pip install'${RESET} 1>&2
git clone -q https://github.com/JonathanSalwan/ROPgadget.git ${pwndir}/ROPgadget/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${pwndir}/ROPgadget/ >/dev/null
python setup.py install
git pull -q
popd >/dev/null


##### Install pngtools
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pngtools${RESET} ~ PNG analysis tool"
apt -y -qq install pngtools \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install ffmpeg
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ffmpeg${RESET} ~ Hyper fast Audio and Video encoder"
apt -y -qq install ffmpeg \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which ffmpeg` ${stegdir}


##### Install steghide
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}steghide${RESET}"
apt -y -qq install steghide \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which steghide` ${stegdir}


##### Install zsteg
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}zsteg${RESET} ~ detect hidden data in png and bmp files"
gem install zsteg \
  || echo -e ' '${RED}'[!] Issue with gem install'${RESET} 1>&2
ln -sf `which zsteg` ${stegdir}


##### Install Sonic Visualiser
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Sonic Visualiser${RESET} ~ Audio file visualization"
timeout 300 curl --progress-bar -k -L -f ${sonicvis} > /tmp/sonicvisualiser.deb \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading Sonic Visualiser" 1>&2       #***!!! hardcoded path!
apt-get -y -qq install libfftw3-single3 libfishsound1 libid3tag0 liblo7 liblrdf0 libmad0 liboggz2 libopusfile0 \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
dpkg -i /tmp/sonicvisualiser.deb  \
  || echo -e ' '${RED}'[!] Issue with dpkg install'${RESET} 1>&2
ln -sf `which sonic-visualiser` ${stegdir}


##### Install outguess
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}outguess${RESET} ~ steganographic software"
apt -y -qq install outguess \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which outguess` ${stegdir}


##### Install Wavsteg
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Wavsteg${RESET} ~ Wav Stegano"
git clone -q https://github.com/ragibson/Steganography.git ${stegdir}/Steganography/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${stegdir}/Steganography/ >/dev/null
python3 setup.py install
git pull -q
popd >/dev/null


##### Install Stegsolve
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Stegsolve${RESET} ~ Image steganography solver"
timeout 300 curl --progress-bar -k -L -f ${stegsolve} > ${stegdir}/stegsolve.jar \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading Stegsolve" 1>&2       #***!!! hardcoded path!
#--- Add to path
file=/usr/local/bin/stegsolve
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${stegdir}/ && java -jar stegsolve.jar "\$@"
EOF
chmod +x "${file}"



########################################################################################################################
##### REVERSE TOOLS #####
echo -e "\n\n ${GREEN}[+]${RESET}${GREEN} Starting to install Reverse Engineering tools! ${RESET}"

##### Install angr
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}angr${RESET} ~ Next-generation binary analysis engine"
apt -y -qq install python3-dev libffi-dev build-essential virtualenvwrapper \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
pip install virtualenvwrapper \
  || echo -e ' '${RED}'[!] Issue with pip install'${RESET} 1>&2
mkdir ~/.virtualenvs
echo "export WORKON_HOME=~/.virtualenvs" >> ~/.bashrc
echo "source /usr/share/virtualenvwrapper/virtualenvwrapper.sh" >> ~/.bashrc 
mkvirtualenv --python=$(which python3) angr && pip install angr


##### Install cfr
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}cfr${RESET} ~ java-decompiler"
timeout 300 curl --progress-bar -k -L -f ${cfr} > ${revdir}/cfr.jar \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading cfr" 1>&2       #***!!! hardcoded path!
#--- Add to path
file=/usr/local/bin/cfr
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${revdir}/ && java -jar cfr.jar "\$@"
EOF
chmod +x "${file}"


##### Install checksec
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}checksec${RESET} ~ check *nix OS for security features"
timeout 300 curl --progress-bar -k -L -f "http://www.trapkit.de/tools/checksec.sh" > ${revdir}/checksec.sh \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading checksec.sh" 1>&2     #***!!! hardcoded patch
chmod +x ${revdir}/checksec.sh


##### Install jdgui
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}jdgui${RESET} ~ Java Decompiler"
timeout 300 curl --progress-bar -k -L -f ${jdgui} > ${revdir}/jd-gui.jar \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading jd-gui" 1>&2       #***!!! hardcoded path!
#--- Add to path
file=/usr/local/bin/jd-gui
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${revdir}/ && java -jar jd-gui.jar "\$@"
EOF
chmod +x "${file}"


##### Install nasmshell
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}nasmshell${RESET} ~ Shell for nasm"
git clone -q https://github.com/fishstiqz/nasmshell.git ${revdir}/nasmshell/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install pwndbg gef peda
##### https://medium.com/bugbountywriteup/pwndbg-gef-peda-one-for-all-and-all-for-one-714d71bf36b8
##### gdb-peda
##### gdb-pwndbg
##### gdb-gef
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}pwndbg gef peda${RESET} ~ GDB plugins"
if [ -f ~/.gdbinit ] || [ -h ~/.gdbinit ]; then
    echo "[+] backing up gdbinit file"
    cp ~/.gdbinit ~/.gdbinit.back_up
fi
git clone -q https://github.com/pwndbg/pwndbg.git ${revdir}/pwndbg/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
${revdir}/pwndbg/setup.sh
mv ${revdir}/pwndbg/ ~/pwndbg-src
echo "source ~/pwndbg-src/gdbinit.py" > ~/.gdbinit_pwndbg

git clone -q https://github.com/longld/peda.git ~/peda \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
wget -q -O ~/.gdbinit-gef.py https://github.com/hugsy/gef/raw/master/gef.py
echo source ~/.gdbinit-gef.py >> ~/.gdbinit
echo "define init-peda" > ~/.gdbinit
echo "source ~/peda/peda.py" >> ~/.gdbinit
echo "end" >> ~/.gdbinit
echo "document init-peda" >> ~/.gdbinit
echo "Initializes the PEDA (Python Exploit Development Assistant for GDB) framework" >> ~/.gdbinit
echo "end" >> ~/.gdbinit
echo "" >> ~/.gdbinit
echo "define init-pwndbg" >> ~/.gdbinit
echo "source ~/.gdbinit_pwndbg" >> ~/.gdbinit
echo "end" >> ~/.gdbinit
echo "document init-pwndbg" >> ~/.gdbinit
echo "Initializes PwnDBG" >> ~/.gdbinit
echo "end" >> ~/.gdbinit
echo "" >> ~/.gdbinit
echo "define init-gef" >> ~/.gdbinit
echo "source ~/.gdbinit-gef.py" >> ~/.gdbinit
echo "end" >> ~/.gdbinit
echo "document init-gef" >> ~/.gdbinit
echo "Initializes GEF (GDB Enhanced Features)" >> ~/.gdbinit
echo "end" >> ~/.gdbinit
echo '#!/bin/sh' > /usr/bin/gdb-peda
echo 'exec gdb -q -ex init-peda "$@"' >> /usr/bin/gdb-peda
echo '#!/bin/sh' > /usr/bin/gdb-pwndbg
echo 'exec gdb -q -ex init-pwndbg "$@"' >> /usr/bin/gdb-pwndbg
echo '#!/bin/sh' > /usr/bin/gdb-gef
echo 'exec gdb -q -ex init-gef "$@"' >> /usr/bin/gdb-gef
chmod +x /usr/bin/gdb-*


##### Install python-exe-unpacker
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}python-exe-unpacker${RESET} ~ unpacking and decompiling EXEs compiled from python code"
git clone -q https://github.com/countercept/python-exe-unpacker.git ${revdir}/python-exe-unpacker/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pip install -r ${revdir}"/python-exe-unpacker/requirements.txt"


##### Install responder
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Responder${RESET} ~ rogue server"
apt -y -qq install responder \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which responder` ${revdir}


##### Install shellconv
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}shellconv${RESET} ~ shellcode disassembler"
git clone -q https://github.com/hasherezade/shellconv.git ${revdir}/shellconv/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${revdir}/shellconv/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
file=/usr/local/bin/shellconv
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${revdir}/shellconv/ && python shellconv.py "\$@"
EOF
chmod +x "${file}"


##### Install uncompyle6
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}uncompyle6${RESET} ~ python cross-version decompiler"
git clone -q https://github.com/rocky/python-uncompyle6.git ${revdir}/uncompyle6/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${revdir}/uncompyle6/ >/dev/null
python setup.py install
git pull -q
popd >/dev/null


##### Install ltrace strace
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ltrace strace ${RESET}"
apt -y -qq install ltrace strace \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2



########################################################################################################################
##### PENTEST TOOLS #####
echo -e "\n\n ${GREEN}[+]${RESET}${GREEN} Starting to install Pentest tools! ${RESET}"

##### Install the backdoor factory
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Backdoor Factory${RESET} ~ bypassing anti-virus"
apt -y -qq install backdoor-factory \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2


##### Install veil framework
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}veil-evasion framework${RESET} ~ bypassing anti-virus"
apt -y -qq install veil-evasion \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
#bash /usr/share/veil-evasion/setup/setup.sh --silent
mkdir -p /var/lib/veil-evasion/go/bin/
touch /etc/veil/settings.py
sed -i 's/TERMINAL_CLEAR=".*"/TERMINAL_CLEAR="false"/' /etc/veil/settings.py


##### Install commix
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}commix${RESET} ~ automatic command injection"
apt -y -qq install commix \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which commix` ${rcedir}


##### Install tplmap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}tplmap${RESET} ~ exploitation of Code Injection and Server-Side Template Injection vulns"
git clone -q https://github.com/epinna/tplmap.git ${rcedir}/tplmap/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#remove first line in requirements.txt because it is breaking the installation process
perl -ni -e 'print unless $. == 1' ${rcedir}/tplmap/requirements.txt
python2.7 -m pip install -r ${rcedir}/tplmap/requirements.txt


##### Install LFISuite
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}LFISuite${RESET} ~ scan and exploit Local File Inclusion vulnerabilities"
git clone -q https://github.com/D35m0nd142/LFISuite.git ${lfidir}/LFISuite/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#--- Add to path
file=/usr/local/bin/lfisuite
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${lfidir}/LFISuite/ && python lfisuite.py "\$@"
EOF
chmod +x "${file}"


#####  Install linux-exploit-suggester
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}linux-exploit-suggester${RESET} "
timeout 300 curl --progress-bar -k -L -f https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh > ${osdir}/linux-exploit-suggester.sh \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading linux-exploit-suggester.sh" 1>&2       #***!!! hardcoded path!
chmod +x ${osdir}/linux-exploit-suggester.sh


#####  Install linux-exploit-suggester-2
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}linux-exploit-suggester-2${RESET} "
git clone -q https://github.com/jondonas/linux-exploit-suggester-2.git ${osdir}/linux-exploit-suggester2/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


#####  Install wesng
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wesng${RESET} ~ Windows Exploit Suggester"
git clone -q https://github.com/bitsadmin/wesng.git ${osdir}/wes/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install clusterd
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}clusterd${RESET} ~ clustered attack toolkit (JBoss, ColdFusion, WebLogic, Tomcat etc)"
apt -y -qq install clusterd \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which clusterd` ${webdir}


##### Install CMSmap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CMSmap${RESET} ~ CMS detection"
git clone -q https://github.com/Dionach/CMSmap.git ${webdir}/cmsmap/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${webdir}/cmsmap/ >/dev/null
git pull -q
popd >/dev/null
#--- Add to path
file=/usr/local/bin/cmsmap
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${webdir}/cmsmap/ && python3 cmsmap.py "\$@"
EOF
chmod +x "${file}"


##### Install droopescan
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}DroopeScan${RESET} ~ Drupal vulnerability scanner"
pip install droopescan \
  || echo -e ' '${RED}'[!] Issue when pip install'${RESET} 1>&2
ln -sf `which droopescan` ${webdir}


#####  Install joomscan
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}joomscan${RESET} ~ OWASP Joomla Vulnerability Scanner"
git clone -q https://github.com/rezasp/joomscan.git ${webdir}/joomscan/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#--- Add to path
file=/usr/local/bin/joomscan
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${webdir}/joomscan/ && perl joomscan.pl "\$@"
EOF
chmod +x "${file}"


#####  Install web-cve-tests
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}web-cve-tests${RESET} ~ A simple framework for sending test payloads for known web CVEs"
git clone -q https://github.com/foospidy/web-cve-tests.git ${webdir}/web-cve-tests/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pip install -r ${webdir}/web-cve-tests/requirements.txt
#--- Add to path
file=/usr/local/bin/webcve
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${webdir}/web-cve-tests/ && python3 webcve.py "\$@"
EOF
chmod +x "${file}"


#####  Install Struts
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Struts${RESET} ~ An exploit for Apache Struts CVE-2017-5638"
timeout 300 curl --progress-bar -k -L -f https://raw.githubusercontent.com/mazen160/struts-pwn/master/struts-pwn.py > ${webdir}/struts.py \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading Struts" 1>&2       #***!!! hardcoded path!


#####  Install XSStrike
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}XSStrike${RESET} ~ Advanced XSS Detection Suite"
git clone -q https://github.com/s0md3v/XSStrike.git ${xssdir}/XSStrike/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pip install -r ${xssdir}/XSStrike/requirements.txt
#--- Add to path
file=/usr/local/bin/xsstrike
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${xssdir}/XSStrike/ && python3 xsstrike.py "\$@"
EOF
chmod +x "${file}"


#####  Install XSS-Radar
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}XSS-Radar${RESET} ~ Chrome extension for fast and easy XSS fuzzing"
git clone -q https://github.com/bugbountyforum/XSS-Radar.git ${xssdir}/XSS-Radar/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#Visit chrome://extensions/
#Enable Developer Mode via the checkbox
#Select "Load Unpacked Extension"
#Finally, locate and select the inner extension folder


#####  Install getsploit
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}getsploit${RESET} ~ Command line search and download tool for Vulners Database"
git clone -q https://github.com/vulnersCom/getsploit.git ${expdir}/getsploit/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${expdir}/getsploit/ >/dev/null
python setup.py install
git pull -q
popd >/dev/null
#Please, register at Vulners website. Go to the personal menu by clicking at your name at the right top corner. Follow "API KEYS" tab. Generate API key with scope "api" and use it with the getsploit.


##### Install php-reverse-shell
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}php-reverse-shell${RESET} ~ Php-rev-shell from pentestmonkey"
git clone -q https://github.com/pentestmonkey/php-reverse-shell.git ${expdir}/php-reverse-shell/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install sharesearch
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}sharesearch${RESET} ~ ShareSearch tool goes through hosts with SMB, NFS, checking credentials, looking for interesting stuff and greping sensitive data in it. WARNING! Alfa version, a lot of bugs and spaghetti code."
git clone -q https://github.com/nikallass/sharesearch.git ${expdir}/sharesearch/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pip install -r ${expdir}/sharesearch/requirements.txt
#--- Add to path
file=/usr/local/bin/sharesearch
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${expdir}/sharesearch/ && python3 sharesearch.py "\$@"
EOF
chmod +x "${file}"


##### Install MiniReverse_Shell_With_Parameters
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}MiniReverse_Shell_With_Parameters${RESET} ~ Generate shellcode for a reverse shell"
git clone -q https://github.com/xillwillx/MiniReverse_Shell_With_Parameters.git ${expdir}/minireverse-shell-with-parameters/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${expdir}/minireverse-shell-with-parameters/ >/dev/null
git pull -q
popd >/dev/null
ln -sf /usr/share/windows-binaries/MiniReverse ${expdir}/minireverse-shell-with-parameters/


##### Install brutespray
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}brutespray${RESET} ~ BruteSpray takes nmap GNMAP/XML output or newline seperated JSONS and automatically brute-forces services with default credentials using Medusa."
apt -y -qq install brutespray \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which brutespray` ${passdir}


##### Install patator
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}patator${RESET} ~ Brute force credendtials"
apt -y -qq install patator \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which patator` ${passdir}


##### Install CrackMapExec
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}CrackMapExec${RESET} ~ Swiss army knife for Windows environments"
git clone -q https://github.com/byt3bl33d3r/CrackMapExec.git ${windir}/crackmapexec/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${windir}/crackmapexec/ >/dev/null
git pull -q
popd >/dev/null


##### Install credcrack
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}credcrack${RESET} ~ credential harvester via Samba"
git clone -q https://github.com/gojhonny/CredCrack.git ${windir}/credcrack/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${windir}/credcrack/ >/dev/null
git pull -q
popd >/dev/null


##### Install Empire
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Empire${RESET} ~ PowerShell post-exploitation"
git clone -q https://github.com/PowerShellEmpire/Empire.git ${windir}/empire/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${windir}/empire/ >/dev/null
git pull -q
popd >/dev/null


##### Install SessionGopher
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}SessionGopher${RESET} ~ Quietly digging up saved session information for PuTTY, WinSCP, FileZilla, SuperPuTTY, and RDP"
git clone -q https://github.com/Arvanaghi/SessionGopher.git ${windir}/SessionGopher/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install LaZagne
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}LaZagne${RESET} ~ retrieve lots of passwords stored on a local computer"
timeout 300 curl --progress-bar -k -L -f ${lazagne} > ${windir}/lazagne.exe \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading Struts" 1>&2       #***!!! hardcoded path!


##### Install Babel scripts
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Babel scripts${RESET} ~ post exploitation scripts"
git clone -q https://github.com/attackdebris/babel-sf.git ${postexpdir}/babelscripts/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${postexpdir}/babelscripts/ >/dev/null
git pull -q
popd >/dev/null


##### Install exe2hex
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}exe2hex${RESET} ~ Inline file transfer"
apt -y -qq install exe2hexbat \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which exe2hex` ${postexpdir}


##### Downloading AccessChk.exe
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Downloading ${GREEN}AccessChk.exe${RESET} ~ Windows environment tester"
echo -n '[1/2]'; timeout 300 curl --progress-bar -k -L -f "https://web.archive.org/web/20080530012252/http://live.sysinternals.com/accesschk.exe" > /usr/share/windows-binaries/accesschk_v5.02.exe \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading accesschk_v5.02.exe" 1>&2   #***!!! hardcoded path!
echo -n '[2/2]'; timeout 300 curl --progress-bar -k -L -f "https://download.sysinternals.com/files/AccessChk.zip" > /usr/share/windows-binaries/AccessChk.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading AccessChk.zip" 1>&2
unzip -q -o -d /usr/share/windows-binaries/ /usr/share/windows-binaries/AccessChk.zip
rm -f /usr/share/windows-binaries/{AccessChk.zip,Eula.txt}


##### Downloading PsExec.exe
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Downloading ${GREEN}PsExec.exe${RESET} ~ Pass The Hash 'phun'"
echo -n '[1/2]'; timeout 300 curl --progress-bar -k -L -f "https://download.sysinternals.com/files/PSTools.zip" > /tmp/pstools.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pstools.zip" 1>&2
echo -n '[2/2]'; timeout 300 curl --progress-bar -k -L -f "http://www.coresecurity.com/system/files/pshtoolkit_v1.4.rar" > /tmp/pshtoolkit.rar \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading pshtoolkit.rar" 1>&2  #***!!! hardcoded path!
unzip -q -o -d /usr/share/windows-binaries/pstools/ /tmp/pstools.zip
unrar x -y /tmp/pshtoolkit.rar /usr/share/windows-binaries/ >/dev/null


##### Install UACScript
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}UACScript${RESET} ~ UAC Bypass for Windows 7"
git clone -q https://github.com/Vozzie/uacscript.git ${postexpdir}/uacscript/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${postexpdir}/uacscript/ >/dev/null
git pull -q
popd >/dev/null


##### Install smbmap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}smbmap${RESET} ~ SMB enumeration tool"
apt -y -qq install smbmap \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which smbmap` ${smbdir}


##### Install smbspider
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}smbspider${RESET} ~ search network shares"
git clone -q https://github.com/T-S-A/smbspider.git ${smbdir}/smbspider/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${smbdir}/smbspider/ >/dev/null
git pull -q
popd >/dev/null


##### Install Goohak
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Goohak${RESET} ~ Google Hacking"
git clone -q https://github.com/1N3/Goohak.git ${googledir}/Goohak/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
chmod +x ${googledir}/Goohak/goohak
ln -sf ${googledir}/Goohak/goohak /usr/local/bin/goohak


#####  Install GoogD0rker
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}GoogD0rker${RESET} ~ Google Hacking"
git clone -q https://github.com/ZephrFish/GoogD0rker.git ${googledir}/GoogD0rker/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pip install -r ${googledir}/GoogD0rker/requirements.txt
#--- Add to path
file=/usr/local/bin/googd0rker
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${googledir}/GoogD0rker/ && python3 googd0rker.py "\$@"
EOF
chmod +x "${file}"


#####  Install gitrob
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gitrob${RESET} ~ find potentially sensitive files pushed to public repositories on Github"
timeout 300 curl --progress-bar -k -L -f ${gitrob} > /tmp/gitrob.zip \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading gitrob" 1>&2       #***!!! hardcoded path!
unzip -q -o /tmp/gitrob.zip -d ${gitdir}/gitrob/
ln -sf ${gitdir}/gitrob/gitrob /usr/local/bin/gitrob
# https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line
# Gitrob will need a Github access token in order to interact with the Github API. Create a personal access token and save it in an environment variable in your .bashrc or similar shell configuration file:
# export GITROB_ACCESS_TOKEN=deadbeefdeadbeefdeadbeefdeadbeefdeadbeef
# Alternatively you can specify the access token with the -github-access-token option, but watch out for your command history!


##### Install truffleHog
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}truffleHog${RESET} ~ Searches through git repositories for secrets, digging deep into commit history and branches"
python2.7 -m pip install truffleHog  \
  || echo -e ' '${RED}'[!] Issue with pip install'${RESET} 1>&2
ln -sf `which trufflehog` ${gitdir}


#####  Install gitleaks
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gitleaks${RESET} ~ Audit git repos for secrets."
export GOPATH=${gitdir}/gitleaks
go get -u github.com/zricethezav/gitleaks/v3@latest  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${gitdir}/gitleaks/bin/gitleaks /usr/local/bin/gitleaks


##### Install amass
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}amass${RESET} ~ In-depth Attack Surface Mapping and Asset Discovery"
apt -y -qq install amass \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which amass` ${discdir}
#create your own config.ini with tokens (https://github.com/OWASP/Amass/blob/master/examples/config.ini)


#####  Install Arjun
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Arjun${RESET} ~ HTTP Parameter Discovery Suite"
git clone -q https://github.com/s0md3v/Arjun.git ${discdir}/Arjun/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#--- Add to path
file=/usr/local/bin/arjun
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${discdir}/Arjun/ && python3 arjun.py "\$@"
EOF
chmod +x "${file}"


#####  Install bfac
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}bfac${RESET} ~ Advanced Backup-File Artifacts Testing for Web-Applications"
git clone -q https://github.com/mazen160/bfac.git ${discdir}/bfac/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pip install -r ${discdir}/bfac/requirements.txt
pushd ${discdir}/bfac/ >/dev/null
python setup.py install
git pull -q
popd >/dev/null


#####  Install dirsearch
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dirsearch${RESET} ~ brute force directories and files in websites"
git clone -q https://github.com/maurosoria/dirsearch.git ${discdir}/dirsearch/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#--- Add to path
file=/usr/local/bin/dirsearch
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${discdir}/dirsearch/ && python3 dirsearch.py "\$@"
EOF
chmod +x "${file}"


#####  Install parameth
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}parameth${RESET} ~ brute discover GET and POST parameters"
git clone -q https://github.com/maK-/parameth.git ${discdir}/parameth/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
python2.7 -m pip install -r ${discdir}/parameth/requirements.txt
#--- Add to path
file=/usr/local/bin/parameth
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${discdir}/parameth/ && python parameth.py "\$@"
EOF
chmod +x "${file}"


#####  Install ffuf
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ffuf${RESET} ~ A fast web fuzzer written in Go"
timeout 300 curl --progress-bar -k -L -f ${ffuf} > /tmp/ffuf.tar.gz \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading Struts" 1>&2       #***!!! hardcoded path!
mkdir -p ${discdir}/ffuf
tar -xf /tmp/ffuf.tar.gz --directory ${discdir}/ffuf
ln -sf ${discdir}/ffuf/ffuf /usr/local/bin/ffuf


#####  Install gobuster
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gobuster${RESET} ~ brute force, URIs (directories and files) in web sites, DNS subdomains (with wildcard support), Virtual Host names on target web servers"
export GOPATH=${discdir}/gobuster
go get -u github.com/OJ/gobuster  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${discdir}/gobuster/bin/gobuster /usr/local/bin/gobuster


#####  Install hakrawler
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}hakrawler${RESET} ~ Go web crawler designed for easy, quick discovery of endpoints and assets within a web application. It can be used to discover Forms, Endpoints, Subdomains, Related documents and JS Files"
export GOPATH=${discdir}/hakrawler
go get -u github.com/hakluke/hakrawler  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${discdir}/hakrawler/bin/hakrawler /usr/local/bin/hakrawler


#####  Install meg
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}meg${RESET} ~ tool for fetching lots of URLs but still being 'nice' to servers"
export GOPATH=${discdir}/meg
go get -u github.com/tomnomnom/meg  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${discdir}/meg/bin/meg /usr/local/bin/meg


#####  Install assetfinder
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}assetfinder${RESET} ~ Find domains and subdomains potentially related to a given domain"
export GOPATH=${subdomdir}/assetfinder
go get -u github.com/tomnomnom/assetfinder  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${subdomdir}/assetfinder/bin/assetfinder /usr/local/bin/assetfinder


#####  Install filter-resolved
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}filter-resolved${RESET} ~ Take domains on stdin and output them on stdout if they resolve"
export GOPATH=${subdomdir}/filter-resolved
go get -u github.com/tomnomnom/hacks/filter-resolved  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${subdomdir}/filter-resolved/bin/filter-resolved /usr/local/bin/filter-resolved


#####  Install dnscan
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}dnscan${RESET} ~ python wordlist-based DNS subdomain scanner"
git clone -q https://github.com/rbsec/dnscan.git ${subdomdir}/dnscan/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pip install -r ${subdomdir}/dnscan/requirements.txt
#--- Add to path
file=/usr/local/bin/dnscan
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${subdomdir}/dnscan/ && python3 dnscan.py "\$@"
EOF
chmod +x "${file}"


#####  Install findomain
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}findomain${RESET} ~ The fastest and cross-platform subdomain enumerator"
timeout 300 curl --progress-bar -k -L -f https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux > ${subdomdir}/findomain \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading findomain" 1>&2       #***!!! hardcoded path!
chmod +x ${subdomdir}/findomain
ln -sf ${subdomdir}/findomain /usr/local/bin/findomain


#####  Install httprobe
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}httprobe${RESET} ~ Take a list of domains and probe for working http and https servers"
export GOPATH=${subdomdir}/httprobe
go get -u github.com/tomnomnom/httprobe  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${subdomdir}/httprobe/bin/httprobe /usr/local/bin/httprobe


#####  Install Knockpy
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Knockpy${RESET} ~ Python tool designed to enumerate subdomains on a target domain through a wordlist."
git clone -q https://github.com/guelfoweb/knock.git ${subdomdir}/knock/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${subdomdir}/knock/ >/dev/null
python setup.py install
git pull -q
popd >/dev/null
#Set your virustotal API_KEY:
#nano knockpy/config.json


#####  Install massdns
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}massdns${RESET} ~ DNS stub resolver"
git clone -q https://github.com/blechschmidt/massdns.git ${subdomdir}/massdns/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pushd ${subdomdir}/massdns/ >/dev/null
make
git pull -q
popd >/dev/null
ln -sf ${subdomdir}/massdns/bin/massdns /usr/local/bin/massdns


#####  Install revip
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}revip.py${RESET} ~ Using YouGetSignal API to get domains hosted on the same IP - Reverse IP"
timeout 300 curl --progress-bar -k -L -f https://gist.github.com/ayoubfathi/57c3fef7d4eada575a8b080cc3c4a562/raw/394ec7442ca90140ba95f5a9c1c431805b130bf3/revip.py > ${subdomdir}/revip.py \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading findomain" 1>&2       #***!!! hardcoded path!


#####  Install subfinder
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}subfinder${RESET} ~ subdomain discovery tool that discovers valid subdomains for websites by using passive online sources"
export GOPATH=${subdomdir}/subfinder
go get -u github.com/projectdiscovery/subfinder/cmd/subfinder  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${subdomdir}/subfinder/bin/subfinder /usr/local/bin/subfinder


##### Install Sublist3r
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}Sublist3r${RESET} ~ enumerate subdomains of websites using OSINT"
git clone -q https://github.com/aboul3la/Sublist3r.git ${subdomdir}/Sublist3r/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pip install -r ${subdomdir}/Sublist3r/requirements.txt
#--- Add to path
file=/usr/local/bin/sublist3r
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${subdomdir}/Sublist3r/ && python3 sublist3r.py "\$@"
EOF
chmod +x "${file}"	


#####  Install changeme
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}changeme${RESET} ~ Scanner for default credentials"
git clone -q https://github.com/ztgrace/changeme.git ${recondir}/changeme/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
pip install -r ${recondir}/changeme/requirements.txt
#--- Add to path
file=/usr/local/bin/changeme
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#!/bin/bash

cd ${recondir}/changeme/ && python3 changeme.py "\$@"
EOF
chmod +x "${file}"	


#####  Install html-tool
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}html-tool${RESET} ~ Take URLs or filenames for HTML documents on stdin and extract tag contents, attribute values, or comments"
export GOPATH=${recondir}/html-tool
go get -u github.com/tomnomnom/hacks/html-tool  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${recondir}/html-tool/bin/html-tool /usr/local/bin/html-tool


##### Install httprint
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}httprint${RESET} ~ GUI web server fingerprint"
apt -y -qq install httprint \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which httprint` ${recondir}


#####  Install nmap-vulners
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}nmap-vulners${RESET} ~ NSE script using some well-known service to provide info on vulnerabilities"
git clone -q https://github.com/vulnersCom/nmap-vulners.git /usr/share/nmap/scripts/nmap-vulners/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2


##### Install snmpenum
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}snmpenum${RESET} ~ Snmp enumeration"
apt -y -qq install snmpenum \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which snmpenum` ${recondir}


#####  Install unfurl
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}unfurl${RESET} ~ Pull out bits of URLs provided on stdin"
export GOPATH=${recondir}/unfurl
go get -u github.com/tomnomnom/unfurl  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${recondir}/unfurl/bin/unfurl /usr/local/bin/unfurl


##### Install unicornscan
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}unicornscan${RESET} ~ fast port scanner"
apt -y -qq install unicornscan \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which unicornscan` ${recondir}


##### Install vulscan script for nmap
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}vulscan script for nmap${RESET} ~ vulnerability scanner add-on"
apt -y -qq install nmap \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
mkdir -p /usr/share/nmap/scripts/vulscan/
timeout 300 curl --progress-bar -k -L -f ${nmapvulscan} > /tmp/nmap_nse_vulscan.tar.gz \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading file" 1>&2      #***!!! hardcoded version! Need to manually check for updates
gunzip /tmp/nmap_nse_vulscan.tar.gz
tar -xf /tmp/nmap_nse_vulscan.tar -C /usr/share/nmap/scripts/
#--- Fix permissions (by default its 0777)
chmod -R 0755 /usr/share/nmap/scripts/; find /usr/share/nmap/scripts/ -type f -exec chmod 0644 {} \;


##### Install wafw00f
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wafw00f${RESET} ~ WAF detector"
apt -y -qq install wafw00f \
  || echo -e ' '${RED}'[!] Issue with apt install'${RESET} 1>&2
ln -sf `which wafw00f` ${recondir}


#####  Install waybackurls
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}waybackurls${RESET} ~ Fetch all the URLs that the Wayback Machine knows about for a domain"
export GOPATH=${recondir}/waybackurls
go get -u github.com/tomnomnom/waybackurls  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
ln -sf ${recondir}/waybackurls/bin/waybackurls /usr/local/bin/waybackurls


#####  Install WhatWeb
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WhatWeb${RESET} ~ Identifies websites"
git clone -q https://github.com/urbanadventurer/WhatWeb.git ${recondir}/WhatWeb \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
ln -sf ${recondir}/WhatWeb/whatweb /usr/local/bin/whatweb


#####  Install WhatCMS
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}WhatCMS${RESET} ~ CMS Detection and Exploit Kit based on Whatcms.org API"
timeout 300 curl --progress-bar -k -L -f https://raw.githubusercontent.com/HA71/WhatCMS/master/whatcms.sh > ${recondir}/whatcms.sh \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading file" 1>&2      #***!!! hardcoded version! Need to manually check for updates
chmod +x ${recondir}/whatcms.sh
ln -sf ${recondir}/whatcms.sh /usr/local/bin/whatcms
# Set your WhatCMS API Key on the source code


#####  Install gf
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}gf${RESET} ~ A wrapper around grep to avoid typing common patterns"
export GOPATH=${recondir}/gf
go get -u github.com/tomnomnom/gf  \
  || echo -e ' '${RED}'[!] Issue with go get'${RESET} 1>&2
#echo 'source $GOPATH/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc
ln -sf ${recondir}/gf/bin/gf /usr/local/bin/gf
#cp -r $GOPATH/src/github.com/tomnomnom/gf/examples ~/.gf

##### Install Wordlists
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}wordlists${RESET} "
timeout 300 curl --progress-bar -k -L -f https://gist.githubusercontent.com/nullenc0de/96fb9e934fc16415fbda2f83f08b28e7/raw/146f367110973250785ced348455dc5173842ee4/content_discovery_nullenc0de.txt > ${wordlistdir}/content_discovery_nullenc0de.txt \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading content_discovery_nullenc0de wordlist" 1>&2       #***!!! hardcoded path!

timeout 300 curl --progress-bar -k -L -f https://gist.githubusercontent.com/nullenc0de/538bc891f44b6e8734ddc6e151390015/raw/a6cb6c7f4fcb4b70ee8f27977886586190bfba3d/passwords.txt > ${wordlistdir}/passwords.txt \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading passwords wordlist" 1>&2       #***!!! hardcoded path!

timeout 300 curl --progress-bar -k -L -f https://gist.githubusercontent.com/nullenc0de/9cb36260207924f8e1787279a05eb773/raw/0197d33c073a04933c5c1e2c41f447d74d2e435b/params.txt > ${wordlistdir}/params.txt \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading params wordlist" 1>&2       #***!!! hardcoded path!

timeout 300 curl --progress-bar -k -L -f https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt > ${wordlistdir}/jhaddixall.txt \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading jason haddix all wordlist" 1>&2       #***!!! hardcoded path!

timeout 300 curl --progress-bar -k -L -f https://gist.githubusercontent.com/jhaddix/b80ea67d85c13206125806f0828f4d10/raw/c81a34fe84731430741e0463eb6076129c20c4c0/content_discovery_all.txt > ${wordlistdir}/jhaddixcontent_discovery_all.txt \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading jason haddix content_discovery_all wordlist" 1>&2       #***!!! hardcoded path!

git clone -q https://github.com/danielmiessler/SecLists.git ${wordlistdir}/SecLists/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
##THIS FILE BREAKS MASSDNS AND NEEDS TO BE CLEANED
cat ${wordlistdir}/SecLists/Discovery/DNS/dns-Jhaddix.txt | head -n -14 > ${wordlistdir}/SecLists/Discovery/DNS/clean-jhaddix-dns.txt

git clone -q https://github.com/danielmiessler/RobotsDisallowed.git ${wordlistdir}/RobotsDisallowed/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2

git clone -q https://github.com/assetnote/commonspeak2-wordlists.git ${wordlistdir}/commonspeak2/ \
  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2

#--- Extract rockyou wordlist
[ -e /usr/share/wordlists/rockyou.txt.gz ] \
  && gzip -dc < /usr/share/wordlists/rockyou.txt.gz > ${wordlistdir}/rockyou.txt
#--- Add 10,000 Top/Worst/Common Passwords
mkdir -p /usr/share/wordlists/
(curl --progress-bar -k -L -f "http://xato.net/files/10k most common.zip" > /tmp/10kcommon.zip 2>/dev/null \
  || curl --progress-bar -k -L -f "http://download.g0tmi1k.com/wordlists/common-10k_most_common.zip" > /tmp/10kcommon.zip 2>/dev/null) \
  || echo -e ' '${RED}'[!]'${RESET}" Issue downloading 10kcommon.zip" 1>&2
unzip -q -o -d ${wordlistdir} /tmp/10kcommon.zip 2>/dev/null   #***!!! hardcoded version! Need to manually check for updates
mv -f ${wordlistdir}/10k{\ most\ ,_most_}common.txt
#--- Linking to more - folders
[ -e /usr/share/dirb/wordlists ] \
  && ln -sf /usr/share/dirb/wordlists ${wordlistdir}/dirb
[ -e ${discdir}/dirsearch/db/ ] \
  && ln -sf ${discdir}/dirsearch/db/ ${wordlistdir}/dirsearch
#--- Not enough? Want more? Check below!
#apt search wordlist
#find / \( -iname '*wordlist*' -or -iname '*passwords*' \) #-exec ls -l {} \;


########################################################################################################################
##### UPDATES AND FINAL STEPS #####
echo -e "\n\n ${GREEN}[+]${RESET}${GREEN} Updating some tools and finalising ${RESET}"

#####  Update wpscan
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}wpscan${RESET} "
wpscan --update \
  || echo -e ' '${RED}'[!]'${RESET}" Issue updating wpscan" 1>&2


#####  Update nmap script DB
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Updating ${GREEN}nmap scripts${RESET} "
nmap --script-updatedb


#####  Configure Metasploit
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}Metasploit${RESET} "
sudo service postgresql stop
sudo service postgresql start
msfdb init
gem install bundler:1.17.3
bundle update --bundler
sleep 5s


########################################################################################################################
##### PERSONALIZATION #####
echo -e "\n\n ${GREEN}[+]${RESET}${GREEN} personalisation steps. They are all disabled by default. ${RESET}"

#####  Create shortcut in Desktop to the opt folder
if [ "${shortcutadd}" == "true" ]; then
    (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Creating ${GREEN}tools folder in Desktop${RESET} "
    ln -sf /opt/ /root/Desktop/
    mv /root/Desktop/opt /root/Desktop/${shortcutfolder}
    sleep 2s
fi

#####  Setup personal aliases
if [ "${addaliases}" == "true" ]; then
    (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setup ${GREEN}Personal Aliases${RESET} "
    echo "alias fuck='sudo \$(fc -ln -1)'" >> ~/.bash_aliases
    echo "alias godmode='sudo su -'" >> ~/.bash_aliases
    echo "alias lt='ls -alth'" >> ~/.bash_aliases
    source ~/.bash_aliases
    sleep 2s
fi

#####  Setup personal hostname
if [ "${hostnamechange}" == "true" ]; then
    (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setup ${GREEN}Personal Hostname${RESET} "
    cp /etc/hostname /etc/hostname.bak
    echo "${host_name}" > /etc/hostname

    cp /etc/hosts /etc/hosts.bak
    echo "127.0.0.1       localhost" > /etc/hosts
    echo "127.0.1.1       ${host_name}" >> /etc/hosts
    echo "" >> /etc/hosts
    echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
    echo "::1     localhost ip6-localhost ip6-loopback" >> /etc/hosts
    echo "ff02::1 ip6-allnodes" >> /etc/hosts
    echo "ff02::2 ip6-allrouters" >> /etc/hosts
    sleep 2s
fi


#--- Update
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Running a package upgrade ${GREEN}latest upgrades${RESET}"
apt -qq -y update && apt-get -qq dist-upgrade -y
apt -qq full-upgrade -y
apt-get -qq -y autoremove
apt-get -qq -y autoclean
if [[ "$?" -ne 0 ]]; then
  echo -e ' '${RED}'[!]'${RESET}" There was an ${RED}issue accessing network repositories${RESET}" 1>&2
  echo -e " ${YELLOW}[i]${RESET} Are the remote network repositories ${YELLOW}currently being sync'd${RESET}?"
  echo -e " ${YELLOW}[i]${RESET} Here is ${BOLD}YOUR${RESET} local network ${BOLD}repository${RESET} information (Geo-IP based):\n"
  curl -sI http://http.kali.org/README
  exit 1
fi





########################################################################################################################
##### Clean the system #####
echo -e "\n\n ${GREEN}[+]${RESET}${GREEN} Cleaning ${RESET}"

##### Clean the system
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) ${GREEN}Cleaning${RESET} the system"
#--- Clean package manager
for FILE in clean autoremove; do apt -y -qq "${FILE}"; done
apt -y -qq purge $(dpkg -l | tail -n +6 | egrep -v '^(h|i)i' | awk '{print $2}')   # Purged packages
#--- Update slocate database
updatedb
#--- Reset folder location
cd ~/ &>/dev/null
#--- Remove any history files (as they could contain sensitive info)
history -cw 2>/dev/null
for i in $(cut -d: -f6 /etc/passwd | sort -u); do
  [ -e "${i}" ] && find "${i}" -type f -name '.*_history' -delete
done


##### Time taken
finish_time=$(date +%s)
echo -e "\n\n ${YELLOW}[i]${RESET} Time (roughly) taken: ${YELLOW}$(( $(( finish_time - start_time )) / 60 )) minutes${RESET}"
echo -e " ${YELLOW}[i]${RESET} Stages skipped: $(( TOTAL-STAGE ))"


#-Done-----------------------------------------------------------------#


##### Done!
echo -e "\n ${YELLOW}[i]${RESET} Don't forget to:"
echo -e " ${YELLOW}[i]${RESET} + Check the above output (Did everything install? Any errors? (${RED}HINT: What's in RED${RESET}?)"
echo -e " ${YELLOW}[i]${RESET} + Setup git:   ${YELLOW}git config --global user.name <name>;git config --global user.email <email>${RESET}"
echo -e " ${YELLOW}[i]${RESET} + Setup ${YELLOW}getsploit:   ${RESET}Please, register at Vulners website. Go to the personal menu by clicking at your name at the right top corner. Follow 'API KEYS' tab. Generate API key with scope 'api' and use it with the getsploit."
echo -e " ${YELLOW}[i]${RESET} + Setup ${YELLOW}amass:   ${RESET}create your own config.ini with tokens (https://github.com/OWASP/Amass/blob/master/examples/config.ini)"
echo -e " ${YELLOW}[i]${RESET} + Setup ${YELLOW}knockpy:   ${RESET}Set your virustotal API_KEY: 'nano knockpy/config.json'"
echo -e " ${YELLOW}[i]${RESET} + Setup ${YELLOW}WhatCMS:   ${RESET}Set your WhatCMS API Key on the source code"
echo -e " ${YELLOW}[i]${RESET} + Enable ${YELLOW}XSSRadar extension:   ${RESET}Visit chrome://extensions/; Enable Developer Mode via the checkbox; Select 'Load Unpacked Extension'; Finally, locate and select the inner extension folder"
echo -e " ${YELLOW}[i]${RESET} + Setup ${YELLOW}gitrob:   ${RESET}https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line; Gitrob will need a Github access token in order to interact with the Github API. Create a personal access token and save it in an environment variable in your .bashrc or similar shell configuration file: export GITROB_ACCESS_TOKEN=deadbeefdeadbeefdeadbeefdeadbeefdeadbeef; Alternatively you can specify the access token with the -github-access-token option, but watch out for your command history!"
echo -e " ${YELLOW}[i]${RESET} + You might need to run the following commands for angr: ${YELLOW}mkvirtualenv --python=$(which python3) angr && pip install angr${RESET}"
echo -e " ${YELLOW}[i]${RESET} + go files in ${YELLOW}/root/go/bin unless you specify other ${RESET}"
echo -e " ${YELLOW}[i]${RESET} + run chrome for the first time with: ${YELLOW}google-chrome --no-sandbox ${RESET}"
echo -e " ${YELLOW}[i]${RESET} + run sonicvisualiser for the first time"
echo -e " ${YELLOW}[i]${RESET} + run burp for the first time if there is an update, update it, download the certificate"
echo -e " ${YELLOW}[i]${RESET} + add chrome, firefox, burp to the panel"
echo -e " ${YELLOW}[i]${RESET} + configure mozilla proxy settings"
echo -e " ${YELLOW}[i]${RESET} + check bash configs: ${YELLOW}history=unlimited, transparancy=0 ${RESET}"
echo -e " ${YELLOW}[i]${RESET} + customise desktop background"
echo -e " ${YELLOW}[i]${RESET} + Configure timezone and keyboard layout"
echo -e " ${YELLOW}[i]${RESET} + ${BOLD}Change default passwords${RESET}: PostgreSQL/MSF, MySQL, OpenVAS, BeEF XSS, etc"
echo -e " ${YELLOW}[i]${RESET} + Change root PW"
echo -e " ${YELLOW}[i]${RESET} + manually add your wordlists if you have any"
echo -e " ${YELLOW}[i]${RESET} + remove iso if there is any"
echo -e " ${YELLOW}[i]${RESET} + configure network adapter settings"
echo -e " ${YELLOW}[i]${RESET} + there are more: ${YELLOW}/usr/share/wordlists,webshells,windows-binaries ${RESET}"
echo -e " ${YELLOW}[i]${RESET} + disable autolock from powersaver"
echo -e " ${YELLOW}[i]${RESET} + Install EyeWitness. check the commented section just below this."

#########################################
#####  Install EyeWitness manually or in antoher script because it is breaking the output.
#(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}EyeWitness${RESET} ~ take screenshots of websites"
#git clone -q https://github.com/FortyNorthSecurity/EyeWitness.git ${discdir}/EyeWitness/ \
#  || echo -e ' '${RED}'[!] Issue when git cloning'${RESET} 1>&2
#${discdir}/EyeWitness/setup/setup.sh -y
#--- Add to path
#file=/usr/local/bin/eyewitness
#cat <<EOF > "${file}" \
#  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
##!/bin/bash
#
#cd ${discdir}/EyeWitness/ && python3 EyeWitness.py "\$@"
#EOF
#chmod +x "${file}"


echo -e " ${YELLOW}[i]${RESET} + ${YELLOW}Reboot${RESET}"
(dmidecode | grep -iq virtual) \
  && echo -e " ${YELLOW}[i]${RESET} + Take a snapshot   (Virtual machine detected)"

echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0
