# SDcard content
This folder contains the data and represents as the SD-card - mountet on the back of the turingpi2 board - which is created for easy flashing the turingPi2
the content of the SDcard is:
    reset.sh                # Scripts for ressetting all nodes
    talos-1.6.7.img         # Talos image  Raw Image
    ubuntu22.04.img         # Ubuntu Server Raw Image

The file versions.txt contains shortcuts to where to download them.

## Usage
Put your images on the sdcard along with the script - Then login to your turingPi and the command:

    /mnt/sdcard/reset.sh

Sometimes one flashing get stucks and you'll have to stop it manually and restart it.

    tpi power off -n [1-4]
    tpi flash -i /mnt/sdcard/talos-1.6.7.img -n [1-4]
    tpi power on -n [1-4]

Remember to correct the $IMAGE in reset.sh when updating to newer images. 

## Extra
If you add a line to your bash or zsh - you can use the tpi through the alias

    alias turing='ssh root@turingpi.local'
    alias master-tpi='/usr/bin/tpi --host turingpi.local --user=root --password="turing"'
 
 Which will set up aliases up for the easy way. 