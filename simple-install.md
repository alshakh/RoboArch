# Archlinux Installation & Configuration Notes

These are my Archlinux installation notes; mostly just to remind me what to do.

## PreChroot

### Boot from CD

### Check internet connection

  - for wifi, use `wifi-menu`.
  - `ping google.com`

###  Setup timedate

  ```sh
  timedatectl set-ntp true
  timedatectl set-timezone Asia/Riyadh
  ```

### Partition & Filesystems

  - Create partitions: _`fdisk` or `cfdisk`_ : boot & system-root & swap & home?

  - Maybe LVM?

    > Example
    >
    > ```
    > NAME        SIZE TYPE MOUNTPOINT
    > sda          64G disk 
    > ├─sda1        2G part /boot
    > └─sda2       62G part 
    > └─sys-root 40G lvm  /
    > └─sys-swap 5G  lvm  [SWAP]
    > ```
    >
    > 
    >

  - It's possible to put boot in an lvm volume, Just make sure to include "LVM2" in initramfs

    And disk MUST at least have on partition

    >
    > ```
    > NAME        SIZE TYPE MOUNTPOINT
    > sda          64G disk 
    > └─sda1       62G part 
    > 	├─sys-boot 1G  lvm /boot
    > 	├─sys-root 40G lvm  /
    > 	└─sys-swap 5G  lvm  [SWAP]
    >```




### Mount on `/mnt` & `/mnt/boot` & `/mnt/home/`

### Sort Mirrors

  Edit `/etc/pacman.d/mirrorlist` and sort as intended

### Install system

  ```sh
  pacstrap /mnt base base-devel
  ```

### fstab

  ```sh
  genfstab -U /mnt >> /mnt/etc/fstab
  ```

### chroot

  ```sh
  arch-chroot /mnt
  ```

## PostChroot

### Enable NetworkManager

  ```sh
  pacman -S networkmanager
  ```

  ```sh
  systemctl enable NetworkManager
  ```

### Setup timezone

  ```sh
  ln -sf /usr/share/zoneinfo/Asia/Riyadh /etc/localtime
  hwclock --systohc
  ```

### Setup locale

  ```sh
  #uncomment `en_US.UTF-8 UTF-8` in `/etc/locale.gen`
  locale-gen
  echo 'LANG=en_US.UTF-8' > /etc/locale.conf
  ```

### Hostname

  ```sh
  echo '<hostname>' > /etc/hostname
  echo 127.0.0.1  localhost >> /etc/hosts
  echo ::1        localhost >> /etc/hosts
  echo 127.0.1.1  <hostname> >> /etc/hosts
  ```

### Configure mkinitcpio

  In case your root filesystem is on LVM, you will need to enable the appropriate mkinitcpio hooks, otherwise your system might not boot. Edit `/etc/mkinitcpio.conf` and insert `lvm2` between `block` and `filesystems` like so:

  ```
  HOOKS=(base udev ... block lvm2 filesystems)
  ```

  - then `mkinitcpio -p linux`.

### Bootloader

  ```
  pacman -S grub
  ```


  ```sh
  grub-install /dev/sda`
  grub-mkconfig -o /boot/grub/grub.cfg
  ```

### Set root password

### Setup normal user & add to wheel group

  ```sh
  useradd -G wheel -m me
  ```

* Enable sudo for `wheel` group

  use `visudo` and uncomment the `%wheel` rule in sudoers

### Exit & Reboot

## Post-Installation

### Setup&Check Network Connection

**Wired Connection** will work by its own.

**Wifi Connection**  use `nmcli` or `nmtui` to configure wifi.



### GPU drivers

#### intel

```shell
pacman -S mesa lib32-mesa xf86-video-intel
```

#### nVidia

##### General

https://wiki.archlinux.org/index.php/NVIDIA#Installation

##### For dual GPU laptops
https://wiki.archlinux.org/index.php/NVIDIA_Optimus



### AUR Support

#### pakku (_aur_)

```sh
git clone https://aur.archlinux.org/pakku.git
cd pakku
makepkg -si
```

### Basic Packages and Application

```sh
pakku -S --needed \
	bash-completion vim git zip unzip unrar p7zip  `#basic terminal utilities` \
	linux-headers `#required for many things` \
```

The following packages are usually provided by the desktop environment, but if not this is a basic collection.

```sh
pakku -S --needed \
	firefox chromium pepper-flash `# or google-chrome` `# web browsers` \
	file-roller `# archiver` \
	evince `# pdf reader` \
	gedit typora `#text editor & markdown editor` \
	gnome-terminal `#terminal emulator` \
	gksu `# gui frontend for sudo and su` \
	clementine `# music player` \
	parole baka-mplayer `#video players` \
	gnome-system-monitor `# system monitor` \
	a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gst-libav gst-plugin-libde265 gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly ffmpeg x264  `#multimedia codecs` \
	
	
	
	vlc libreoffice-fresh `# other apps`
```



### Linux LTS Kernel

```sh
pacman -S linux-lts linux-lts-headers
mkinitcpio -p linux-lts
grub-mkconfig -o /boot/grub/grub.cfg
```



### Grub config

#### Disable submenu

If you have multiple kernels installed, say linux and linux-lts, by default grub-mkconfig groups them in a submenu. If you do not like this behaviour you can go back to one single menu by adding the following line to `/etc/default/grub`:

```
GRUB_DISABLE_SUBMENU=y
```

Then regenerate grub configuration files.

#### Make grub boot from last choosen kernel

GRUB can remember the last entry you booted from and use this as the default entry to boot from next time. This is useful if you have multiple kernels (i.e., the current Arch one and the LTS kernel as a fallback option) or operating systems. To do this, edit `/etc/default/grub` and change the value of `GRUB_DEFAULT`:
```
GRUB_DEFAULT=saved
```

This ensures that GRUB will default to the saved entry. To enable saving the selected entry, add the following line to `/etc/default/grub`:

```
GRUB_SAVEDEFAULT=true
```

Then regenerate grub configuration files.

#### Themes

Choose a theme `grub-themes-stylishdark` `arch-silence-grub-theme` `grub2-theme-arch-leap`; install like below

```sh
pakku -S <theme name>
```

edit `/etc/default/grub`, and add `GRUB_THEME=` to the appropriate theme file. Then, regenerate grub configuration files.

#### Show/Hide boot details

Add or Remove `quiet` in `GRUB_CMDLINE_LINUX_DEFAULT=` in `/etc/default/grub`, then regenerate grub configuration files.



### Enable Hibernation

First, must have adequet SWAP space allocated.
Then

1. Add `resume=<swap-block>` to `/etc/default/grub`. prefer using UUID of the block.

```sh
GRUB_CMDLINE_LINUX_DEFAULT="resume=UUID=a7a53764-381a-4489-ad72-47a4029b28b2"
# or 
# GRUB_CMDLINE_LINUX_DEFAULT="resume=/dev/sda1"
# GRUB_CMDLINE_LINUX_DEFAULT="resume=/dev/mapper/vg_swaplv"
```

now, regenerate grub configurations

2. Add `resume` hook to `/etc/mkinitcpio.conf`, like below

```sh
HOOKS=(... keyboard resume fsck)
```

now, regenerate initramfs by using `mkinitcpio -p linux` and `mkinitcpio -p linux-lts`.

3. Reboot



### SSH

```sh
pacman -S openssh
systemctl mask sshd
```

#### change terminal background when ssh

1. add the following to your bash profile

```sh
function ssh_alias() {
    ssh $@;
    setterm --default --clear all;
}

alias ssh=ssh_alias
```

2. enable running local commands  in `/etc/ssh/ssh_config`

```
PermitLocalCommand yes
```

3. create `~/.ssh/config` with the following content
```
Host *
  LocalCommand setterm --background red --clear all
```



### ~~Firewalld~~

```sh
pacman -S firewalld
systemctl enable firewalld
systemctl start firewalld
# configure zone
# 	'drop' : to block all incomming
# 	'public' : normall (just delete ssh service)
```



### Fonts

```sh
pakku -S --needed ttf-inconsolata ttf-liberation ttf-dejavu ttf-roboto noto-fonts ttf-ms-fonts ttf-freefont ttf-amiri ttf-arabeyes-fonts ttf-font-awesome noto-fonts-emoji
```



### virtualbox-guest-additions

`pacman -S virtualbox-guest-utils` with `dkms`



### Pacman helper scripts

```sh
pacman -S pacman-contrib
```



### pamac (_pacman gui_)

```sh
pakku -Sy pamac-aur
```

### Graphical User Environment

#### Theme

```sh
pakku -S --needed arc-gtk-theme papirus-icon-theme arc-icon-theme 
# optional : elementary-icon-theme moka-icon-theme-git 
```
#### KDE (_desktop environment_)
```
pacman -S plasma kde-applications sddm
```
```
systemctl enable sddm
```



#### Cinnamon (_desktop environment_)

```sh
pacman -S --needed cinnamon xorg  nemo-fileroller
```

**Apply Theme** by using 'Themes' app. Then **modify panel and launchers** to fit your requirements.



#### Lightdm (_display manager_)

```sh
pacman -S --needed lightdm lightdm-gtk-greeter xorg
systemctl enable lightdm
```

**Apply Theme** by editing `/etc/lightdm/lightdm-gtk-greeter.conf `, add the following 

```
[greeter]
theme-name = Arc
icon-theme-name = Numix
background = /usr/share/backgrounds/gnome/Wood.jpg
user-background = true
position = 5%,start 30%,center
```
_or use `lightdm-gtk-greeter-settings` for gui lightdm-gtk-greeter configurations_



**Enable numlock by default**, by installing `numlockx` package and then editing `/etc/lightdm/lightdm.conf`: 

```
[Seat:*]
greeter-setup-script=/usr/bin/numlockx on
```

> #### ~~XFCE4 (_desktop environment_)~~
>
>   - ~~`pakku -S xorgs xfce4 xfce4-goodies compton`~~
>   - ~~`echo 'exec startxfce4 > ~/.xinitrc'`~~
>   - ~~disable compositing from 'windows tweaks'~~
>   - ~~add `compton` to autostart in 'xfce4 session'~~
>   - ~~set theme in 'Appearance' and 'Window Manager' Settings~~
>





## Other Notes

### Restore pacman mirrors

```sh
curl -o /etc/pacman.d/mirrorlist https://www.archlinux.org/mirrorlist/all
```



### Cleanup unneeded packages

  * list unneeded packages ( reads explicitly installed and reads backwards )

    ``` bash
    comm -23 <(pacman -Q | awk '{ print $1 }' | sort | uniq) <(pacman -Qe | awk '{ print $1 }' | xargs -n 1 pactree -u | sort | uniq )
    ```

* delete list of packages

  ```sh
  pacman -R $(cat package-list.txt)
  ```



### Restrict Internet access  (_experimental_)

```sh
# Restrict for all user accounts
firewall-cmd --direct --add-rule ipv4 filter OUTPUT 1 -j DROP
firewall-cmd --direct --add-rule ipv4 filter OUTPUT 0 -d 127.0.0.0/8 -j ACCEPT

# Allow for only specific user accounts
firewall-cmd --direct --add-rule ipv4 filter OUTPUT 0 -m owner --uid-owner <username> -j ACCEPT

# Make rules permanent
firewall-cmd --runtime-to-permanent
```

### GUI application by different account

```sh
gksudo -u <other-username> <command>
```



### Fix boot issues after moving/resizing partitions

_sometimes_ when you play with partition sizes or locations, boot failes. Follow the steps to fix it.

1. boot with live CD
2. mount your partitions (root,boot,home,..) in a temporary directory
3. `arch-chroot` to your system. _if only regular `chroot` is available, make sure /dev,/proc and /sys are mounted_.
4. run `grub-install /dev/sda`.
5. reboot



### Run GUI applications eg. _gparted_ during archlinux installation

1. make sure to have adequate space to install packages

   ```sh
   mount -o remount,size=1G /run/archiso/cowspace
   # extra space is taken from memory, so be conservative.
   ```

2. Install packages

   ```sh
   pacman -Sy xorg-server xorg-xinit xterm
   pacman -Sy gparted
   ```
   
3. run the application with the command

   
   ```sh
   xinit gparted
   ```

4. GUI should be running now. If errors appear, check `/var/log/xorg.*.log`.

--------
