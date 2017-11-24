#!/bin/bash

# **************************************************************************
# * (C)opyright 2017         by Ruben Carlo Benante                        *
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
    nordping - Ping a bunch of NordVPN servers to test the fastest
    Usage: ${1} [-v] ( [-h|-V] | [-p TCP|UDP ] )

    Options:
      -h, --help       Show this help.
      -V, --version    Show version.
      -v, --verbose    Turn verbose mode on (cumulative).
      -p, --protocol   Set the protocol to ping: TCP (default) or UDP
      -d, --directory  Sets the directory where to find all *.ovpn files (defaults to ./ovpn-files)
      -f, --filter     Filter by prefix
      -w, --wget       Download ovpn files from nordvpn site to directory ./ovpn-files
    Exit status:
       0, if ok.
       1, some error occurred.

    Todo:
            Long options not implemented yet.

    Author:
            Written by Ruben Carlo Benante <rcb@beco.cc>
            Created: 2017-02-18
EOF
    exit 1
}

# The copyright function
Copyr()
{
    echo "nordping - ${VERSION}"
    echo
    echo 'Copyright (C) 2017 Ruben Carlo Benante <rcb@beco.cc>, GNU GPL version 2'
    echo '<http://gnu.org/licenses/gpl.html>. This  is  free  software:  you are free to change and'
    echo 'redistribute it. There is NO WARRANTY, to the extent permitted by law. USE IT AS IT IS. The author'
    echo 'takes no responsability to any damage this software may inflige in your data.'
    echo
    exit 1
}

# The download function
Download()
{
    echo "Starting nordping.sh script, by beco, version ${VERSION}..."
    echo "Verbose level: $verbose"
    date
    TRUST="no"
    wget -q --show-progress https://nordvpn.com/api/files/zip -O config.zip || { echo "Can not download ovpn files" ; exit 1 ; }
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
    if [[ "${TRUST}" == "yes" || "${TRUST}" == "sureOK" ]] ; then
        unzip config.zip -d ovpn-files
        echo "Downloaded and unzipped successfuly"
        if [[ "${TRUST}" != "sureOK" ]] ; then
            echo
            echo "Warning: using a non-validated md5sum file"
            echo "Please report an issue (subject new md5sum) at https://github.com/drbeco/nordping"
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
    #getopt example with switch/case
    while getopts "hVvp:d:f:w" FLAG; do
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
            w)
                Download
                ;;
            *)
                Help
                ;;
        esac
    done

    if [ "$verbose" -gt "0" ] ; then
        echo "Starting nordping.sh script, by beco, version ${VERSION}"...
        echo "Verbose level: $verbose"
        date
    fi

    if [ "$QNPROTO" == "UDP" ]; then
        QPROTO="1194"
    else
        QPROTO="443"
    fi

    if [ "$verbose" -gt "0" ]; then
        echo "Protocol: $QPROTO"
    fi
    if [ "$verbose" -gt "1" ] ; then
        echo "ovpn file                                          protocol           average  timeout"
    fi

    for F in "$DIR"/"$PREFIX"*.ovpn ; do
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
            if [ "$PAV" == "3000.33" ] ; then
                echo -n "  error"
            fi
        else
            echo -en "$F \t $IP \t $TI"
            if [ "$TI" == "3000.33" ] ; then
                echo -en " \t error"
            fi
        fi
        echo
    done
}

#Calling main with all args
main $*
exit 0

#/* -------------------------------------------------------------------------- */
#/* vi: set ai et ts=4 sw=4 tw=0 wm=0 fo=croql : SHELL config for Vim modeline */
#/* Template by Dr. Beco <rcb at beco dot cc> Version 20160714.124739          */

