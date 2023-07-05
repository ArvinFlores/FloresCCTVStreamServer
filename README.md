# FloresCCTVStreamServer

Streaming server for the camera

## How it works
The Pi streams the output of the camera module through a rtsp server created with the help of the `uv4l-webrtc` package. Devices connected to the same network will be able to access the camera stream via

```
https://<raspberry_pi_ip>:9000
```

## Hardware / Software

* Raspberry Pi 4 Model B (4GB RAM)
* Raspberry Pi OS 32-bit (Bullseye)
* [Raspberry Pi Camera V2](https://www.amazon.com/Raspberry-Pi-Camera-Module-Megapixel/dp/B01ER2SKFS?th=1)
* [Youmi Mini USB Mic](https://www.amazon.com/Newest-YOUMI-Microphone-Laptop-desktop/dp/B01MQ2AA0X)

## Preconditions

The following steps assume the Raspberry Pi has all the components connected already, the OS is installed, and everything is up and running

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
