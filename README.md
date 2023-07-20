# FloresCCTVStreamServer

Streaming server for the camera

## How it works
The Pi streams the output of the camera module through a rtsp server created with the help of the `uv4l-webrtc` package. Devices connected to the same network will be able to access the camera stream via

```
https://<raspberry_pi_ip>:9000
```

## Hardware

* Raspberry Pi 4 Model B (4GB RAM)
* [Raspberry Pi Camera V2](https://www.amazon.com/Raspberry-Pi-Camera-Module-Megapixel/dp/B01ER2SKFS?th=1)
* [Youmi Mini USB Mic](https://www.amazon.com/Newest-YOUMI-Microphone-Laptop-desktop/dp/B01MQ2AA0X)
* [Shuley Mini USB Speaker](https://www.amazon.com/Speaker-Portable-Computer-Notebook-Checkout/dp/B07K8DFY3Q/ref=sr_1_5?crid=19XM5MABQS6P5&keywords=mini+usb+speaker&qid=1689828097&s=electronics&sprefix=mini+usb+speake%2Celectronics%2C148&sr=1-5)

## Preconditions

The following steps assume all the hardware components are connected to the Raspberry Pi (except the SD card)

### Setup the SD card
From the [Raspberry Pi Imager](https://www.raspberrypi.com/software), select the Raspberry Pi OS Lite (32-bit) as the Operating System

Then, open the Advanced Options (click the gear icon) and configure the following fields:
- `Set hostname` - try to set it as something relating to the camera's scope/view in the house like `florescctv-front` if the camera will have a front view to the house for example
- `Enable SSH` - you can select either password auth or pub-key auth, its completely up to you
- `Set username and password` - the username should be something like `cam` or `camera` and the password should follow typical password standards
- `Configure wireless LAN` - the Imager software might prompt you to fill these fields in automatically, but if not, you will have to fill them in manually so that the Raspberry Pi can connect to your network when it first boots
- `Set locale settings` - set the timezone for the pi

Finally, hit `Save` and then `Write` to begin writing the OS to the SD card. The process takes a few minutes. Once it's done you can insert the SD card into the rPi and power it on

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

When adding the ssh key to the account, make sure the title is something descriptive like `Front of house camera` or perhaps just the hostname of the pi, its completely up to you but just make sure the title uniquely describes the camera/raspberry pi the ssh key belongs to

### Update raspi config 

**Enable the Legacy Camera**

Open the config interface by running
```
sudo raspi-config
```
Then go to `Interface Options > Legacy Camera > Yes`

**Set the GPU memory limit**

Go to `Performance Options > GPU Memory` and set the limit to `256`

After updating these options you can select `Finish` so that the pi can reboot

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

Note: If this file doesn't exist, then create it
```
pcm.!default {
   type asym
   playback.pcm "plug:hw:<card number>"
   capture.pcm "plug:dsnoop:<card number>"
}
```
To find the `<card number>` for `playback.pcm` run the command `aplay -l`, you will see output
```
**** List of PLAYBACK Hardware Devices ****

card 2: UACDemoV10 [UACDemoV1.0], device 0: USB Audio [USB Audio]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```
in this case the `<card number>` is `2`

To find the `<card number>` for `capture.pcm` run the command `arecord -l`, you will see output
```
**** List of CAPTURE Hardware Devices ****

card 1: Device [USB PnP Sound Device], device 0: USB Audio [USB Audio]
  Subdevices: 1/1
```
in this case the `<card number>` is `1`

## Installation

### Install System Dependencies
Update apt
```
sudo apt update
sudo apt upgrade
```

**Install Node**
```
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs
```

**Install Git**
```
sudo apt install git
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

### Cloning the project
Open up a terminal window and clone the repo to your desired folder:

```
git clone git@github.com:ArvinFlores/FloresCCTVStreamServer.git
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

#### Run with Janus (optional)
[Janus Gateway](https://github.com/meetecho/janus-gateway) is a webrtc server that allows uv4l to stream to multiple clients, without it, uv4l will only be able to stream to 1 client at a time which can be a bad user experience

This step is optional, but if you'd like to leverage Janus to stream, make sure you set the following env variables
```
# Example
FLORESCCTV_JANUS_URL=http://localhost:8088
FLORESCCTV_JANUS_ROOT=/janus
FLORESCCTV_JANUS_ROOM=1234
FLORESCCTV_JANUS_USERNAME=User123
```
You must set *ALL* of these variables, otherwise the `start.sh` script will skip trying to connect to Janus

Additionally, you must also follow the installation instructions [here](https://github.com/ArvinFlores/FloresCCTVGatewayServer) to get the Janus server up and running

### Launch the server
From the root of the project run

```
./start.sh
```

You will now be able to access the project at `https://<raspberry_pi_ip>:9000`

Note: When running the project in `DEV` mode, you will just see a barebones html page. Continue reading to see how to get the camera streaming to your device

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

### Starting the server on boot

It would be nice to start the streaming server on boot, to do that we can make use of `systemctl`

Create the service script by doing
```
sudo nano /etc/systemd/system/florescctv.service
```

Paste the following content replacing `/path/to` with the path where you have installed the `FloresCCTVStreamServer` repo
```
[Unit]
Description=FloresCCTV Streaming Server

[Service]
ExecStart=/path/to/FloresCCTVStreamServer/start.sh
WorkingDirectory=/path/to/FloresCCTVStreamServer

[Install]
WantedBy=multi-user.target
```

Set the file permissions
```
sudo chmod 664 /etc/systemd/system/florescctv.service
```

Finally reload the daemon and enable the service so that it starts on boot
```
sudo systemctl daemon-reload
sudo systemctl enable florescctv
```

Test that this works by running `sudo reboot` and then navigating to the url where the raspberry pi camera stream should be running to confirm the service now starts on boot
