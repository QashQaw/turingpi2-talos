﻿![QashQaw](docs/images/qashqaw.png)

# [Turingpi2](https://turingpi.com/product/turing-pi-2/) with [talos linux](https://www.talos.dev/) and [Kubernetes Cluster](https://kubernetes.io/)

Waited excited for recieving the RK1 cards (have only been using CM4 cards untill now). </br>
Only Ubuntu and Talos images are prepared for the RK at the moment. Never the less - I do not like ubuntu on such small PC's - so talos is my choice. 
But I cannot take the credit for all the works others have done. 
Sources: 
    https://blog.itrestauracion.online/installing-kubernetes-talos-dev-in-rk1-turingpi-2-en-d578aa6ea35c
    
<table>
    <tr>
        <td>
           <img src="docs/images/turingpi-board.jpg" width="392px" height="220px" alt="TuringPi-v2.4" />
        </td>
        <td>
            <table>
                <tr>
                    <td><img src="docs/images/RockChip.png" width="392px" height="220px" alt="Rockchip RK2588"></td>
                </tr>
                <tr>
                    <td><img src="docs/images/CM4.png" width="392px" height="220px" alt="RaspberryPi CM04"></td>
                </tr>
            </table>
        </td>
    </tr>
</table>    

### Table of content

[Plan for build a cluster](https://github.com/QashQaw/turingpi2-talos#plan-for-build-a-cluster)
* [Requirements](https://github.com/QashQaw/turingpi2-talos#requirenments)   
* [Installing talos](https://github.com/QashQaw/turingpi2-talos#installing-talos)    
* [Configuring the nodes](https://github.com/QashQaw/turingpi2-talos#configuration-on-the-nodes)
  - [pi01 Controlplane #1]()
  - [pi03 Controlplane #2]()
  - [pi04 Controlplane #3]()
  - [pi02 Worker]()

# Plan for build a cluster 
After the default installation of the RK1 - we'll need to setup som small things after the DietPi is finished with the default setup. To get a better picture of what we're doing here: 
  * update the BMC image to v2.0.5
  * Create the SDcard with images for Flashing the Images from sdcard (fastest)
  * Generate standard configuration (and edit it to fit our requirements)
  * apply configuration 
  * Bootstrap the cluster
  * Setup NFS-storage for all 4 nodes (At the moment added the )
  * Adding nodes to the cluster
  * pushing updates of the confiurations

Since I've been struggling with getting the cluster up and running - I've created [a small script for resetting](https://github.com/QashQaw/turingpi2-talos/blob/main/scripts/reset_tpi.sh)) all the 4 nodes on the turingPi2. -it'll start flashing node 1 and start node 1 - before flashine node 2- and power the 3nodes up in the end of the scripts - this can be 

## Requirenments
The turingpi2 Board + 4x RK1 cards - you will need talosctl and kubectl installed on the workstation, and in our Router we created the DNS turingpi.local to piont to a static IP we set in our DNS server so that name should resolve to the static ip of the motherboard - otherwise you can add it manually to the localhosts hosts file

    # Installing talosctl
    curl -sL https://talos.dev/install | sh

    # Installing kubectl 
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 

    # Installing cilium
    sudo apt install cilium-cli

    # Default User and password 
    Username:   root
    Password:  turing

    # Harddisk attached
    1 x Samsung EVO 940 NVME disk attached to node 3 - should be used as storage.
        But for now the get it started - I'm using a inhouse NFS from a Synology 

    Latest talos RAW image from turingpi. Added to sdcard - mountet on the back of the Turingpi motherboard - for making everything easier.
    Added [reset script](https://github.com/QashQaw/turingpi2-talos/blob/main/scripts/reset_tpi.sh) to th SD card also.
    Set the SDcatrd into the back of the turingpi and power off

For making the setup a little easier - we'll create an alias to use instead of the normal tpi with user host etc - add in our ~/.zshrc. - add add our SSH key to /root/.ssh/authorized_keys

    alias master-tpi='/usr/bin/tpi --host turingpi.local --user=root --password=turing'
    alias turing='ssh turingpi.local -l root' 

## Installing talos
The easiest way I found - was through a small simple script to reset the nodes (change image etc) Later on I changed the order to 1 - 3 - 4 - 2 according to the order of use on the 4 nodes. Reset all nodes according to the order and image file provided through the script 

    $ turing
    # /mnt/sdcard/reset.sh 

Now Talos is installed on all four nodes and are now ready to be configured with recieving the configuration, for starting the configuration of our nodes.

## Configuration on the nodes: 
Our plan for the nodes are: 
  * node 1 - Controlplane + worker                        # Attached HDMI and USB port
  * node 2 - worker                                       # Our Nodes which is only worker.                
  * node 3 - worker + local-storage                       # Attached NVME disk - will use as storage later on, since its connected with the 2sata ports.
  * node 4 - Controlplane + worker + storage prod2        # Can use PCIe and the 2 x USB3.0 and with 2xUSB3.0 connecter to front of a cabinet 
  * docker.webmeup.dk - NFS share 200GB                   # Is added since the NFS is not a part of Talos - so have a VM as storage on Proxmox Server.

Generating the talos configuration files, are done with a setup, patching our files with our requirements  


[def]: https://github.com/QashQaw/turingpi2-talos#installing-talos