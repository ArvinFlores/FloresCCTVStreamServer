# FloresCCTVStreamServer

Streaming server for the camera

## How it works
The Pi streams the output of the camera module through a rtsp server created with the help of the `uv4l-webrtc` package. Devices connected to the same network will be able to access the camera stream via

```
https://<raspberry_pi_ip>:9000
```

## Hardware / Software

* Raspberry Pi 4 Model B (4GB RAM)
* Raspberry Pi OS Lite (32-bit)
* [Raspberry Pi Camera V2](https://www.amazon.com/Raspberry-Pi-Camera-Module-Megapixel/dp/B01ER2SKFS?th=1)
* [Youmi Mini USB Mic](https://www.amazon.com/Newest-YOUMI-Microphone-Laptop-desktop/dp/B01MQ2AA0X)

## Preconditions

The following steps assume the Raspberry Pi is assembled and all the hardware components are connected (except the SD card)

### Setup the SD card
From the [Raspberry Pi Imager](https://www.raspberrypi.com/software), select the Raspberry Pi OS Lite (32-bit) as the Operating System

Then, open the Advanced Options (click the gear icon) and configure the following fields:
- `Set hostname` - try to set it as something relating to the camera's scope/view in the house like `florescctv-front` if the camera will have a front view to the house for example
- `Enable SSH` - you can select either password auth or pub-key auth, its completely up to you
- `Set username and password` - the username should be something like `cam` or `camera` and the password should follow typical password standards
- `Configure wireless LAN` - the Imager software might prompt you to fill these fields in automatically, but if not, you will have to fill them in manually so that the Raspberry Pi can connect to your network when it first boots
- `Set locale settings` - set the timezone for the pi

Finally, hit `Save` and then `Write` to begin writing the OS to the SD card. The process takes a few minutes. Once it's done you can power on the Pi

### SSH into the Pi
If the OS was written successfully into the SD card then you should now be able to find the Pi on your local network, you can type the following to find the Pi on your LAN
```
ping <hostname>.local
```
where `<hostname>` is whatever value you entered for the `Set hostname` field earlier

you should see some output (specifically an ip address) from the `ping` command like this
```
PING <hostname>.local (192.168.1.220): 56 data bytes
64 bytes from 192.168.1.220: icmp_seq=0 ttl=64 time=6.032 ms
```

now you can ssh into the Pi with this command
```
ssh <username>@<ip address>
```
The `username` is whatever value you entered for the `Set username and password` field earlier

Alternatively, a shorthand can also be this
```
ssh <username>@<hostname>.local
```

### Setup SSH keys for Github access
See [this guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) for how to create and add an ssh key to the github account of this repo

When adding the ssh key to the account, make sure the title for the key follows the format `Raspberry Pi <serial number>`. To find the serial number of the pi you can run the following to get the desired output
```
cat /proc/cpuinfo | grep -i serial
Serial          : <serial number>
```

### Enable the Legacy Camera
Open the config interface by running
```
sudo raspi-config
```
Then go to `Interface Options > Legacy Camera > Yes`. You will then be prompted to reboot, please do so

### Verify the camera is connected
Check to see that the camera is being detected by the board by running
```
vcgencmd get_camera
```
you should see some output like this
```
supported=1 detected=1, libcamera interfaces=0
```

### Update asound.conf
For uv4l to be able to use the usb mic and speaker as the default input/output devices, we have to update the `/etc/asound.conf` file with these settings:
```
pcm.!default {
   type asym
   playback.pcm "plug:hw:0"
   capture.pcm "plug:dsnoop:1"
}
```
Note: If the file doesn't exist, then create it

## Installation

### Cloning the project
Open up a terminal window and clone the repo to your desired folder:

```
git clone git@github.com:ArvinFlores/FloresCCTVStreamServer.git
```

### Install uv4l
The installation instructions outlined [here](https://www.linux-projects.org/uv4l/installation/) should be referenced prior to the steps outlined in this section. We're only including the steps here to keep things brief

Run these commands in a terminal
```
sudo rpi-update # You might not need to run this command if you have a fresh install of RPi OS
echo /opt/vc/lib/ | sudo tee /etc/ld.so.conf.d/vc.conf
sudo ldconfig
```

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
```
sudo openssl genrsa -out ./selfsign.key 2048 &&  sudo openssl req -new -x509 -key ./selfsign.key -days 3650 -out ./selfsign.crt -sha256
```
Note: Normally the `-days` flag should be something low like 365 but it's ok in this case as the app is only accessible on a LAN

### Create env file
Create an `.env` file at the project root and add the following:
```
FLORESCCTV_ENV=DEV
```
Note: Not setting this variable will cause the `start.sh` script to throw an error

### Launch the server
From the root of the project run

```
./start.sh
```

You will now be able to access the project at `https://<raspberry_pi_ip>:9000`

## Development

Because this repo relies on `uv4l`, a closed source project, there is not much to develop for this particular repo except uv4l configuration changes most likely. Instead, see the [web assets repo](https://github.com/ArvinFlores/FloresCCTVWebAssets/tree/master) to get started on developing the UI locally

## Production

### Running the app in production

In the `.env` file, set the env flag to production:
```
FLORESCCTV_ENV=PROD
```
Start the application as you normally would:
```
./start.sh
```
You should now see the production version of the app running on `https://<raspberry_pi_ip>:9000`
