#!/usr/bin/env zsh
set -euo pipefail

hardware="kobo7"
firmware_month="Nov2021"
firmware_package="kobo-update-4.30.18838.zip"

plato_version="0.9.22"
plato_package="plato-${plato_version}.zip"

sources=(
    "https://kbdownload1-a.akamaihd.net/firmwares/${hardware}/${firmware_month}/${firmware_package}"
    "https://github.com/baskerville/plato/releases/download/${plato_version}/${plato_package}"
    "https://raw.githubusercontent.com/baskerville/plato/${plato_version}/contrib/plato.sh"
    "https://raw.githubusercontent.com/baskerville/plato/${plato_version}/contrib/firmware.patch"
)

cleanup() {
    rm -rf .kobo plato 
}

download() {
    for source in $sources; do
        wget -N "${source}"
    done
}

extract() {
    mkdir -p .kobo
    unzip -u "${firmware_package}" -d .kobo

    mkdir -p .kobo/usr/local/Plato
    unzip -u "${plato_package}" -d .kobo/usr/local/Plato
}

update() {
    cd .kobo
    gzip -vfdk KoboRoot.tgz
    tar -xvf KoboRoot.tar ./etc/init.d/rcS
    patch -p1 < ../firmware.patch

    install -m755 ../plato.sh usr/local/Plato/plato.sh
    touch usr/local/Plato/bootlock

    tar -uvf KoboRoot.tar ./etc/init.d/rcS ./usr/local/Plato 
    gzip --best KoboRoot.tar && mv KoboRoot.t{ar.,}gz
}

cleanup
download
extract
update
