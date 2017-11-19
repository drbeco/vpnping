#!/bin/bash

## **************************************************************************
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
# **************************************************************************

# Fetch the .ovpn files from NordVPN
wget https://nordvpn.com/api/files/zip -O config.zip
# Unzip into a folder
unzip config.zip -d vpn
# Remove VPNs from countries with mass surveilance programs ("Five Eyes", "Nine Eyes", "Fourteen Eyes")
# http://www.giswatch.org/en/communications-surveillance/unmasking-five-eyes-global-surveillance-practices
# 1. Australia
# 2. Canada
# 3. New Zealand
# 4. United Kingdom
# 5. United States of America
# 6. Denmark
# 7. France
# 8. Netherlands
# 9. Norway
# 10. Belgium
# 11. Germany
# 12. Italy
# 13. Spain
# 14. Sweden
find vpn -type f -name '[au|ca|nz|uk|us|dk|fr|fx|nl|an|no|be|de|it|es|se]*.ovpn' | xargs rm

rm config.zip
