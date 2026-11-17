#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

output=../../dist
wow='/home/norushflow/Games/World of Warcraft'
while (( $# )); do
    case $1 in
        --output-dir) output=${2:?Zielverzeichnis fehlt.}; shift 2 ;;
        --wow-dir) wow=${2:?WoW-Verzeichnis fehlt.}; shift 2 ;;
        *) echo 'Aufruf: ./tools/build.sh [--output-dir VERZEICHNIS] [--wow-dir VERZEICHNIS]' >&2; exit 2 ;;
    esac
done

addon=ZygorRetailSkin
toc="$addon.toc"
version=$(awk '/^## Version:/ {print $3; exit}' "$toc")
[[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo 'Ungültige Version in der TOC.' >&2; exit 1; }
[[ $(grep -c '^## Version:' "$toc") == 1 ]] || { echo 'Doppelte Version in der TOC.' >&2; exit 1; }
awk -v version="$version" '
    /^## / { active = ($0 == "## v" version); if (active) sections++; next }
    active && /^- [^[:space:]]/ { bullets++ }
    END { exit !(sections == 1 && bullets > 0) }
' RELEASE_NOTES.md || { echo "Release-Notizen für v$version fehlen oder sind mehrdeutig." >&2; exit 1; }
output=$(realpath -m -- "$output")
out="$output/$addon-$version.zip"
[[ ! -e $out && ! -L $out ]] || { printf 'ZIP existiert bereits: %s\n' "$out" >&2; exit 1; }

./tools/check-local.sh "$wow"
mkdir -p -- "$output"
stage=$(mktemp -d -- "$output/.zygor-skin.XXXXXXXX")
trap 'rm -rf -- "$stage"' EXIT
mkdir -- "$stage/$addon"
mapfile -t runtime < <(awk 'NF && $1 !~ /^#/ {print}' "$toc")
cp -- "$toc" "${runtime[@]}" README.md "$stage/$addon/"
install -D -m 0644 -- Media/Icon.tga "$stage/$addon/Media/Icon.tga"
(
    cd -- "$stage"
    export LC_ALL=C TZ=UTC
    find "$addon" -type f -exec chmod 0644 {} +
    find "$addon" -type f -exec touch -t 198001010000.00 {} +
    find "$addon" -type f -print | sort | ZIPOPT= zip -q -X -9 addon.zip -@
    unzip -tq addon.zip
    diff -q <(find "$addon" -type f -print | sort) <(unzip -Z -1 addon.zip | sort) >/dev/null ||
        { echo 'ZIP-Inhalt stimmt nicht mit den geprüften Paketdateien überein.' >&2; exit 1; }
    unzip -p addon.zip "$addon/$toc" | cmp -s "$addon/$toc" - ||
        { echo 'TOC im ZIP stimmt nicht überein.' >&2; exit 1; }
)
ln -T -- "$stage/addon.zip" "$out"
printf 'Installations-ZIP: %s\n' "$out"
