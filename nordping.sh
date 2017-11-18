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
      -d, --directory  Sets the directory where to find all *.ovpn files
      -f, --filter     Filter by prefix
    Exit status:
       0, if ok.
       1, some error occurred.
  
    Todo:
            Long options not implemented yet.
  
    Author:
            Written by Ruben Carlo Benante <rcb@beco.cc>  
            2017-02-18         
EOF
    exit 1
}

# The copyright function
Copyr()
{
    echo 'nordping - 20170218.210221'
    echo
    echo 'Copyright (C) 2017 Ruben Carlo Benante <rcb@beco.cc>, GNU GPL version 2'
    echo '<http://gnu.org/licenses/gpl.html>. This  is  free  software:  you are free to change and'
    echo 'redistribute it. There is NO WARRANTY, to the extent permitted by law. USE IT AS IT IS. The author'
    echo 'takes no responsability to any damage this software may inflige in your data.'
    echo
    exit 1
}

# The main function
main()
{
    verbose=0
    DIR="."
    #getopt example with switch/case
    while getopts "hVvp:d:f:" FLAG; do
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
            *)
                Help
                ;;
        esac
    done
  
    echo Starting nordping.sh script, by beco, version 20170804.014727...
    echo Verbose level: $verbose
    date

    if [ "$QNPROTO" == "UDP" ]; then
        QPROTO="1194"
    else
        QPROTO="443"
    fi

    if [ "$verbose" -gt "0" ]; then
        echo "Protocol: $QPROTO"
    fi

    for F in "$DIR"/"$PREFIX"*.ovpn ; do 
        [ ! -e $F ] && echo 'Please give a path with ovpn files' && break
        LIN=`grep "remote " $F`
        PROTO=`echo $LIN | cut -d' ' -f3`
        if [ "$PROTO" != "$QPROTO" ]; then
            continue
        fi
        IP=`echo $LIN | cut -d' ' -f2`
        DL=`ping -c3 -q $IP | tail -n2`
        if grep "100% packet loss" <(echo $DL) > /dev/null ; then
            echo -e "$F \t $IP \t 3000.333 \t error"
        else
            TI=`echo $DL | cut -d'/' -f5`
            echo -e "$F \t $IP \t $TI"
        fi
    done
}

#Calling main with all args
main $*
exit 0

#/* -------------------------------------------------------------------------- */
#/* vi: set ai et ts=4 sw=4 tw=0 wm=0 fo=croql : SHELL config for Vim modeline */
#/* Template by Dr. Beco <rcb at beco dot cc> Version 20160714.124739          */

