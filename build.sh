#!/bin/bash

DLD=$(wget -q "https://www.mozilla.org/pt-BR/firefox/all/" -O - | grep -E "os=linux64&amp;lang=pt-BR" | cut -d'"' -f2 | head -n 1)
wget -c $DLD --trust-server-names
ls firefox-*.tar.bz2 | cut -d "-" -f 2 | sed -e 's|.tar.bz2||g' > VERSION
tar xf firefox*.tar.bz2
URL2=$(wget -c "https://api.github.com/repos/gorhill/uBlock/releases" -O - | grep browser_download_url | grep 'firefox.signed.xpi"' | head -n 1 | cut -d '"' -f 4)
URL5=$(wget -q -c "https://addons.mozilla.org/en-US/firefox/addon/i-dont-care-about-cookies/" -O - | sed -e 's|\\\u002F|/|g' | grep -Po 'https://addons.mozilla.org/firefox/downloads/file/[0-9]*/.*?xpi' | head -n 1)

wget -c "$URL2" "$URL5"

mkdir -p usr/lib/webapp-player/browser/extensions/

cp -r firefox/* usr/lib/webapp-player
cp *firefox.signed.xpi "usr/lib/webapp-player/browser/extensions/uBlock0@raymondhill.net.xpi"
cp i_dont_care_about_cookies-*.xpi usr/lib/webapp-player/browser/extensions/jid1-KKzOGWgsW3Ao4Q@jetpack.xpi

mkdir -p usr/bin
wget -q "https://raw.githubusercontent.com/peppermintos/ice/master/usr/bin/ice-firefox" -O usr/bin/ice

mkdir -p usr/lib/peppermint/ice/
wget -q "https://raw.githubusercontent.com/peppermintos/ice/master/usr/lib/peppermint/ice/ice.glade"          -O usr/lib/peppermint/ice/ice.glade
wget -q "https://raw.githubusercontent.com/peppermintos/ice/master/usr/lib/peppermint/ice/places.sqlite"      -O usr/lib/peppermint/ice/places.sqlite
wget -q "https://raw.githubusercontent.com/peppermintos/ice/master/usr/lib/peppermint/ice/search.json.mozlz4" -O usr/lib/peppermint/ice/search.json.mozlz4

sed -i "s|^execute = 'firefox -profile '|execute = '/usr/lib/webapp-player/firefox -profile '|g" usr/bin/ice

chmod +x usr/bin/ice

mkdir -p pacote/DEBIAN
mv usr pacote

(
 echo "Package: webapp-player"
 echo "Priority: required"
 echo "Version: $(date +%y.%m.%d%H%M%S)"
 echo "Architecture: all"
 echo "Maintainer: Natanael Barbosa Santos"
 echo "Depends: "
 echo "Description: Firefox Webapp Player"
 echo
) > "pacote/DEBIAN/control"

dpkg -b pacote webapp-player.deb

chmod 777 webapp-player.deb
chmod -x  webapp-player.deb
