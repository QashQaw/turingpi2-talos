![QashQaw](https://user-images.githubusercontent.com/130484646/233855095-e4c90972-46a2-46c2-a7e6-89c0bf854a0a.png)

# [Turingpi2](https://turingpi.com/product/turing-pi-2/) with [talos linux](https://www.talos.dev/) and [Kubernetes Cluster](https://kubernetes.io/)

I've been waiting a long time for the RK1 card to arrive, so that I had plenty of time to prepare my thoughts on this. Started out with only 1CM4 Pi4 Card - so not that much to prepare - But when only Unbuntu and talos imagesa are prepared for the RK1. Never the less - I do not like ubuntu on such small PC's - so talos is my choice. But I cannot take the credit for all the works others have done. 

But here's how I've done it. 

## Build a cluster on the turingPi2 motherboard
After the default installation of the RK1 - we'll need to setup som small things after the DietPi is finished with the default setup. To get a better picture of what we're doing here: 
  * Flashing the Images from sdcard (fastest)
  * Generate standard configuration (and edit it to fit our requirements)
  * apply configuration 
  * Bootstrap the cluster
  * Adding nodes to the cluster
  * pushing updates of the cconfiurations

Since I've been struggling wit hgetting the cluster up and running - I've created [a small script for resetting](https://gitlab.webmeup.dk/QashQaw/kubernetes/-/raw/master/TuringPi2/talos/reset-talos.sh?ref_type=heads) all the 4 nodes on the turingPi2. -it'll start flashing node 1 and start node 1 - before flashine node 2 + 3 + 4 - and power the 3nodes up in the end of the scripts - this can be 

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
    1 x Samsung EVO 940 NVME disk attached to node 3 - should be used as storage: 


For making the setup a little easier - we'll create an alias to use instead of the normal tpi with user host etc - add in our ~/.zshrc. - add add our SSH key to /root/.ssh/authorized_keys

    alias master-tpi='/usr/bin/tpi --host turingpi.local --user=root --password=turing'
    alias turing='ssh turingpi.local -l root' 
