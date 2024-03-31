﻿

Turingpi2 with talos linux as Kubernetes 



I've been waiting a long time for the RK1 card to arrive, so that I had plenty of time to prepare my thoughts on this. Started out with only 1CM4 Pi4 Card - so not that much to prepare - But when only Unbuntu and talos imagesa are prepared for the RK1. Nevertheless - I do not like ubuntu on such small PC's - so talos is my choice – since talos also new for me. 
But I cannot take the credit for all the works others have done. 
Sources: 
    https://blog.itrestauracion.online/installing-kubernetes-talos-dev-in-rk1-turingpi-2-en-d578aa6ea35c
    

But here's how I've done it. 

Build a cluster on the turingPi2 motherboard.
After the default installation of the RK1 - we'll need to setup some small things after the talos are installed. To get a better picture of what we're doing here: 
  * Flashing the Images from sdcard (fastest)
  * Generate standard configuration (and edit it to fit our requirements)
  * Apply configuration 
  * Bootstrap the cluster
  * Adding nodes to the cluster
  * Pushing updates of the configurations

Since I've been struggling with getting the cluster up and running - I've created a small script for resetting all the 4 nodes on the turingPi2. -it'll start flashing node 1 and start node 1 - before flashing node 2 + 3 + 4 - and power the 3nodes up in the end of the scripts - this can be done from localhost or through network – Sdcard is by far the easiest way.

Requirements
The turingpi2 Board + 4x RK1 cards - you will need talosctl and kubectl installed on your workstation, and in our Router we created the DNS turingpi.local to point to a static IP we set in our DNS server so that name should resolve to the static ip of the motherboard - otherwise you can add it manually to the localhosts hosts file

    # Installing talosctl
    curl -sL https://talos.dev/install | sh

    # Installing kubectl 
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 

    # Installing cilium
    sudo apt install cilium-cli

    # Default User and password 
    Username:   root
    Password:  turing

    A 16BG exfat formatted micro-Sdcard. content with a link to the download the correct images for the RK1 cards


Sdcard preparation
For making  everything a lot easier for our self – we can download latest talos RAW image from turingpi firmware - Added to a sdcard - mountet on the back of the Turingpi motherboard - for making everything easier.Add the reset script to the SD card also.
Set the SDcard into the back of the turingpi and power on

For making the setup a little easier - we'll create an alias to use instead of the normal tpi with user host etc - add in our ~/.zshrc. - add add our SSH key to /root/.ssh/authorized_keys

    alias master-tpi='/usr/bin/tpi --host turingpi.local --user=root --password=turing'
    alias turing='ssh turingpi.local -l root' 

## Installing talos
The easiest way I found - was through a small simple script to reset the nodes (change image etc) 

    $ turing
    # /mnt/sdcard/reset.sh 
    Starting the script – power off all nodes
    ok
    flashing node 1
    request flashing of talos-1.6.6_rk1-arm64.raw to node 1
     started transfer of 1.22 GiB..
    ⠙ [00:02:25][#########################>] 1.22 GiB/1.22 GiB (0.1s)Done
    Finished flashing node 1 - Power it on before starting flashing node2 
    ok
    flashing node 2
    request flashing of talos-1.6.6_rk1-arm64.raw to node 2
    started transfer of 1.22 GiB..
⠙ [00:02:25][#########################>] 1.22 GiB/1.22 GiB (0.1s)Done
    flashing node 3
    request flashing of talos-1.6.6_rk1-arm64.raw to node 3
    started transfer of 1.22 GiB..
⠙ [00:02:25][#########################>] 1.22 GiB/1.22 GiB (0.1s)Done
    flashing node 4
    request flashing of talos-1.6.6_rk1-arm64.raw to node 4
    started transfer of 1.22 GiB..
⠙ [00:02:25][#########################>] 1.22 GiB/1.22 GiB (0.1s)Done
    Finished with Flashing the nodes
    Will now power on the other 3 nodes
    ok
    ok
    ok
    End of the script 
    # exit 
    Connection to turingpi.local closed

Now Talos is installed on all four nodes 

## Configuration on the nodes: 
Our plan for the nodes are: 
    * node 1 - Controlplane + worker
    * node 2 – worker
    * node 3 - worker
    * node 4 - Controlplane + worker 
Generating the talos configuration 
