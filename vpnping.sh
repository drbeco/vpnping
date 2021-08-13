#!/bin/bash

# **************************************************************************
# * (C)opyright 2017         by Ruben Carlo Benante                        *
# *                                                                        *
# * VPNPing.sh ping your VPN servers and find the fastest                  *
# *                                                                        *
# * This program is free software; you can redistribute it and/or modify   *
# *  it under the terms of the GNU General Public License as published by  *
# *  the Free Software Foundation version 2 of the License.                *
# *                                                                        *
# * This program is distributed in the hope that it will be useful,        *
# *  but WITHOUT ANY WARRANTY; without even the implied warranty of        *
# *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
# *  GNU General Public License for more details.                          *
# *                                                                        *
# * You should have received a copy of the GNU General Public License      *
# *  along with this program; if not, write to the                         *
# *  Free Software Foundation, Inc.,                                       *
# *  59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
# *                                                                        *
# * Contact author at:                                                     *
# *  Ruben Carlo Benante                                                   *
# *  rcb@beco.cc                                                           *
# **************************************************************************

VERSION="20171118.225122"

# The help function
Help()
{
    cat << EOF
    vpnping - Ping a bunch of VPNs ovpn file (such as SurfShark VPN or NordVPN) servers to test the fastest ping response
    Usage: $ ./vpnping.sh [-v] ( [-h|-V] | [-p TCP|UDP ] )

    Options:
      -h, --help       Show this help.
      -V, --version    Show version.
      -v, --verbose    Turn verbose mode on (cumulative).
      -p, --protocol   Set the protocol to ping: tcp (default) or udp (lower case)
      -f, --filter     Filter by prefix
      -w, --wget       Download ovpn files from nordvpn site to directory ./ovpn-nord or surfshark to ./ovpn-shark
      -e, --stderr     Print also to stderr. Useful if piping, e.g.: $ ./vpnping.sh | sort -nk3
      -s, --server     Currently available options: -s shark or -s nord (defaults to shark)
      -d, --directory  Sets the directory where to find all *.ovpn files (defaults to ./ovpn-shark)

    Example:
        Example of a command: 
            ~/dir/$ ./vpnping.sh -f sp -p udp -d ./dir/ovpn-shark

        Example of an answer:
            ./ovpn-shark/sp1.sharkvpn.com.udp1122.ovpn         189.187.142.116          3000.33         error
            ./ovpn-shark/sp2.sharkvpn.com.udp1122.ovpn         175.183.176.2   418.501



    Exit status:
       0, if ok.
       1, some error occurred.

    Todo:
            Long options not implemented yet.

    Author:
            Written by Ruben Carlo Benante <rcb@beco.cc>
            Created: 2017-02-18
            Major mod: 2021-08-13
EOF
    exit 1
}

# The copyright function
Copyr()
{
    echo "vpnping - ${VERSION}"
    echo
    echo 'Copyright (C) 2017-2021+ Ruben Carlo Benante <rcb@beco.cc>, GNU GPL version 2'
    echo '<http://gnu.org/licenses/gpl.html>. This  is  free  software:  you are free to change and'
    echo 'redistribute it. There is NO WARRANTY, to the extent permitted by law. USE IT AS IT IS. The author'
    echo 'takes no responsability to any damage this software may inflige in your data.'
    echo
    exit 1
}

# The download function
Download()
{
    echo "Starting vpnping.sh script, by beco, version ${VERSION}..."
    echo "Verbose level: $verbose"
    date
    TRUST="no"

    if [ "$VPNSERVER" == "nord" ] ; then
        wget -q --show-progress https://nordvpn.com/api/files/zip -O nord-config.zip || { echo "Can not download nord ovpn files. NordVPN changed its policy. Now you have to download manually, one by one, the files you want to test. Put them into ./ovpn-nord/ directory." ; exit 1 ; }
        md5sum -c --status config.zip.md5
        SQ=$?
        if (( "10#0${SQ}" != 0 )) ; then
            echo "Cannot verify the md5sum signature. File corrupted or changed."
            echo "Type 'yes' only if you are sure in the next 15 seconds."
            read -t 15 -p "Do you trust the new file? " TRUST
            echo
        else
            echo "md5sum signature checked OK"
            TRUST="sureOK"
        fi
    else # surfshark
        wget -q --show-progress https://my.surfshark.com/vpn/api/v1/server/configurations -O shark-config.zip || { echo "Can not download shark ovpn files" ; exit 1 ; }
            echo "md5sum signature not checked"
            TRUST="sureOK"
    fi
    if [[ "${TRUST}" == "yes" || "${TRUST}" == "sureOK" ]] ; then
        unzip $VPNSERVER-config.zip -d ovpn-$VPNSERVER
        echo "Downloaded and unzipped successfuly"
        if [[ "${TRUST}" != "sureOK" ]] ; then
            echo
            echo "Warning: using a non-validated md5sum file"
            echo "Please report an issue (subject new md5sum) at https://github.com/drbeco/vpnping"
            echo "New md5sum:"
            md5sum config.zip
            echo "Old mdrsum:"
            cat config.zip.md5 | grep config.zip
            echo
            rm -rf config.zip
            exit 1
        fi
        rm -rf config.zip
        exit 0
    else
        rm -rf config.zip
        echo "Download/installation aborted"
        exit 1
    fi
}

# The main function
main()
{
    verbose=0
    DIR="./ovpn-files"
    PREFIX=""
    PRERR=0
    VPNSERVER="shark"
    QNPROTO="tcp"
    calldownload=0
    #getopt example with switch/case
    while getopts "hVvp:d:f:wes:" FLAG; do
        case $FLAG in
            h)
                Help
                ;;
            V)
                Copyr
                ;;
            v)
                let verbose=verbose+1
                ;;
            p)
                QNPROTO=$OPTARG
                ;;
            d)
                DIR=$OPTARG
                ;;
            f)
                PREFIX=$OPTARG
                ;;
            s)
                VPNSERVER=$OPTARG
                ;;
            w)
                calldownload=1
                ;;
            e)
                PRERR=1
                ;;
            *)
                Help
                ;;
        esac
    done

    if [ "$verbose" -gt "0" ] ; then
        echo "Starting vpnping.sh script, by beco, version ${VERSION}"...
        echo "Verbose level: $verbose"
        date
    fi

    if [ "$QNPROTO" == "udp" ]; then
        QPROTO="1194"
    else
        QPROTO="443"
    fi

    if [ "$verbose" -gt "1" ] ; then
        echo "Using $VPNSERVER VPN server"
        DIR="./ovpn-$VPNSERVER"
    fi
    if [ "$verbose" -gt "0" ]; then
        echo "Protocol: $QPROTO"
    fi
    if [ "$verbose" -gt "1" ] ; then
        echo "ovpn file                                          protocol           average  timeout"
    fi
    if [ "$calldownload" -eq "1" ] ; then
        Download
        exit 0
    fi

    for F in "$DIR"/"$PREFIX"*"$QNPROTO"*.ovpn ; do
        [ ! -e $F ] && echo -e 'Please give a valid path to where you downloaded ovpn files.\n(Try "-w" to automatically download them first or "-h" for help.)' && break
        LIN=`grep "remote " $F`
        PROTO=`echo $LIN | cut -d' ' -f3`
        if [ "$PROTO" != "$QPROTO" ]; then
            continue
        fi
        IP=`echo $LIN | cut -d' ' -f2`
        DL=`ping -c3 -q $IP | tail -n2`

        if grep "100% packet loss" <(echo $DL) > /dev/null ; then
            TI="3000.33"
        else
            TI=`echo $DL | cut -d'/' -f5`
        fi

        if [ "$verbose" -gt "0" ]; then
            # formatted output
            PFI=`printf '%-50s' "$F"`
            PIP=`printf '%-18s' "$IP"`
            PAV=`printf '%-7s' $TI`

            echo -en "$PFI $PIP $PAV"
            if [ "$PRERR" -eq "1" ]; then
                >&2 echo -en "$PFI $PIP $PAV"
            fi
            if [ "$PAV" == "3000.33" ] ; then
                echo -n "  error"
                if [ "$PRERR" -eq "1" ]; then
                    >&2 echo -n "  error"
                fi
            fi
        else
            echo -en "$F \t $IP \t $TI"
            if [ "$PRERR" -eq "1" ]; then
                >&2 echo -en "$F \t $IP \t $TI"
            fi
            if [ "$TI" == "3000.33" ] ; then
                echo -en " \t error"
                if [ "$PRERR" -eq "1" ]; then
                    >&2 echo -en " \t error"
                fi
            fi
        fi
        echo
        if [ "$PRERR" -eq "1" ]; then
            >&2 echo
        fi
    done
}

#Calling main with all args
main "$@"
exit 0

#/* -------------------------------------------------------------------------- */
#/* vi: set ai et ts=4 sw=4 tw=0 wm=0 fo=croql : SHELL config for Vim modeline */
#/* Template by Dr. Beco <rcb at beco dot cc> Version 20160714.124739          */

