# nordping

Ping nordvpn servers to find the best/fast for you

## How to use:

- Download this script to the same directory where you unzipped all \*.ovpn files
    - Optional: you may want to keep the script in the `$PATH`, but you must run it from the working directory where the \*.ovpn files are

- Usage:

       ``./nordping.sh [-v] ( [-h|-V] | [-p TCP|UDP] [-d PATH] )``

```
       Options:
         -h, --help       Show this help.
         -V, --version    Show version.
         -v, --verbose    Turn verbose mode on (cumulative).
         -p, --protocol   Set the protocol to ping: TCP (default) or UDP
         -d, --directory  Set the path where to find ovpn files
```

## Exit status:
       0, if ok.
       1, some error occurred.

## Author
      Written by Ruben Carlo Benante <rcb@beco.cc>  
      Date: 2017-02-18


