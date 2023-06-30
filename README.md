# FloresCCTVServer

Server package for the camera live stream

## How it works
The Pi streams the output of the camera module through a rtsp server created with the help of the `uv4l-webrtc` package. Devices connected to the same network will be able to access the camera stream via

```
https://<raspberry_pi_ip>:9000
```

## Hardware / Software

* Raspberry Pi 4 Model B (4GB RAM)
* Raspberry Pi OS 32-bit (Bullseye)
* Raspberry Pi Camera V2

## Preconditions

### Enable SSH access
See [this guide](https://www.raspberrypi.com/documentation/computers/remote-access.html#enabling-the-server) for how to enable ssh access for your raspberry pi

Alternatively, you can also configure SSH to be enabled when first installing the OS on the SD card

### Setup SSH keys for Github access
See [this guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) for how to create and add an ssh key to the github account of this repo

When adding the ssh key to the account, make sure the title for the key follows the format `Raspberry Pi <serial number>`. To find the serial number of the pi you can run the following to get the desired output
```
cat /proc/cpuinfo | grep -i serial
Serial          : <serial number>
```

## Installation

### Cloning the project
Open up a terminal window and clone the repo:

```
cd /path/to/my/projects
git clone git@github.com:ArvinFlores/FloresCCTVServer.git
```

### Install uv4l
The installation instructions outlined [here](https://www.linux-projects.org/uv4l/installation/) should be referenced prior to the steps outlined in this section. We're only including the steps here to keep things brief

Run these commands in a terminal
```
sudo rpi-update # You might not need to run this command if you have a fresh install of RPi OS
echo /opt/vc/lib/ | sudo tee /etc/ld.so.conf.d/vc.conf
sudo ldconfig
```

Enable the Legacy Camera
```
sudo raspi-config
```
Then go to `Interface Options > Legacy Camera > Yes`. You will then be prompted to reboot, please do so

Now you need to add the `uv4l` repo to be able to download the required packages
```
curl https://www.linux-projects.org/listing/uv4l_repo/lpkey.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/uv4l.gpg

echo "deb https://www.linux-projects.org/listing/uv4l_repo/raspbian/stretch stretch main" | sudo tee /etc/apt/sources.list.d/uv4l.list
```

Finally to install the packages
```
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install uv4l-webrtc
```

### Create ssl self-signed certificates
We need to add ssl certs to be able to use some HTML5 apis that require the page to be loaded through `https://`. From the root of the project run the following command:

Note: Normally the `-days` flag should be something low like 365 but it's ok in this case as the app is only accessible on a LAN
```
sudo openssl genrsa -out ./selfsign.key 2048 &&  sudo openssl req -new -x509 -key ./selfsign.key -days 3650 -out ./selfsign.crt -sha256
```

### Launch Web Stream
From the root of the project run

```
./start.sh
```

## Development

## Production
