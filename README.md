# vpnping

Ping a VPN server such as nordvpn or surfshark servers to find the best/fast for you

## How to use:

- Download this script to the same directory where you unzipped all \*.ovpn files
    - Optional: you may want to keep the script in the `$PATH`, but you must run it from the working directory where the \*.ovpn files are

- New `-e` key, prints also at stderr output, so you can easely pipe stdout to a sort command and still keeps track of progress

- Usage:

       ``./vpnping.sh [-v] ( [-h|-V] | [-p TCP|UDP] [-d PATH] )``

- Options:

```
      -h, --help       Show this help.
      -V, --version    Show version.
      -v, --verbose    Turn verbose mode on (cumulative).
      -p, --protocol   Set the protocol to ping: tcp (default) or udp (lower case)
      -f, --filter     Filter by prefix
      -w, --wget       Download ovpn files from nordvpn site to directory ./ovpn-nord or surfshark to ./ovpn-shark
      -e, --stderr     Print also to stderr. Useful if piping, e.g.: $ ./vpnping.sh | sort -nk3
      -s, --server     Currently available options: -s shark or -s nord (defaults to shark)
      -d, --directory  Sets the directory where to find all *.ovpn files (defaults to ./ovpn-shark)
```

- Example:

```
* Example of a command: 
            ~/dir/$ ./vpnping.sh -f sp -p udp -d ./dir/ovpn-shark

* Example of an answer:
            ./ovpn-shark/sp1.sharkvpn.com.udp1122.ovpn         189.187.142.116          3000.33         error
            ./ovpn-shark/sp2.sharkvpn.com.udp1122.ovpn         175.183.176.2   418.501

```

## Exit status:

* 0, if ok.
* 1, some error occurred.

## Author

* Written by Ruben Carlo Benante <rcb@beco.cc>  
* Date: 2017-02-18
* Modified: 2017-11-18
* Major mod: 2021-08-13


