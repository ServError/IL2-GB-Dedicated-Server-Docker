#!/bin/bash
# shellcheck shell=bash

create_desktop_shortcut() {
    target_executable="$1"
    icon_path="$2"
    name="$3"
    terminalbool="$4"
    runpath="$5"
    desktop_file="$HOME/Desktop/${name// /_}.desktop"  # Replace spaces with underscores

    # Create the desktop shortcut file
    echo "[Desktop Entry]" > "$desktop_file"
    echo "Version=1.0" >> "$desktop_file"
    echo "Name=$name" >> "$desktop_file"
    echo "Comment=$name" >> "$desktop_file"
    echo "Exec=$target_executable" >> "$desktop_file"
    echo "Icon=$icon_path" >> "$desktop_file"
    echo "Terminal=$terminalbool" >> "$desktop_file"
    echo "Type=Application" >> "$desktop_file"
    echo "Categories=Game;" >> "$desktop_file"
    echo "Path=$runpath" >> "$desktop_file"

    # Make the desktop shortcut executable
    chmod +x "$desktop_file"
}

# Read the autoinstaller environment variables
IL2GBAUTOINSTALL="${IL2GBAUTOINSTALL:-0}"
FORCEREINSTALL="${FORCEREINSTALL:-0}"

# Validate IL2GBAUTOINSTALL as boolean (1 or 0)
if [[ "$IL2GBAUTOINSTALL" != "0" && "$IL2GBAUTOINSTALL" != "1" ]]; then
    echo "Invalid value for IL2GBAUTOINSTALL. Should be 0 or 1."
    exit 1
fi

if [ ! -f '/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/bin/game/launcher.exe' ] || [ "$FORCEREINSTALL" -eq 1 ]; then
    # Start the installer
    cd /config && innoextract -e -m IL2_setup_Great_Battles.exe
    mkdir -p "/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles"
    # Save contents of Multiplayer directory before reinstalling
    il2_multiplayer_dir="/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/data/Multiplayer"
    if [ -d "$il2_multiplayer_dir" ]; then
        mkdir -p "app/data"
        mv "$il2_multiplayer_dir" app/data/
    fi
    mv app/* "/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/" && rmdir app
    cd "/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/bin/game"
    mv Launcher.exe launcher.exe


    # Create working shortcuts.
    create_desktop_shortcut "wine '/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/bin/game/launcher.exe'" \
                            "package-upgrade" \
                            "Run IL2 GB Updater" \
                            "false" \
                            "/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/bin/game"

    create_desktop_shortcut "wine '/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/bin/game/DServer.exe'" \
                            "/app/il2_gb_server/desktop-setup/il2_tux.ico" \
                            "Run IL2 GB Server" \
                            "false" \
                            "/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/bin/game"

    create_desktop_shortcut "wine '/config/.wine/drive_c/Program Files/IL2-SimpleRadio-Standalone/IL2-SR-Server.exe'" \
                            "audio-volume-high" \
                            "Run IL2 SRS Server" \
                            "false" \
                            "/config/.wine/drive_c/Program Files/IL2-SimpleRadio-Standalone/"

    create_desktop_shortcut "xdg-open '/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/data/Multiplayer/'"\
                            "folder" \
                            "IL2 GB Missions Dir" \
                            "false"

    create_desktop_shortcut "xdg-open '/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/'"\
                            "folder" \
                            "IL2 GB Install Dir" \
                            "false"
fi

# Remove unneeded shortcuts.
rm -f /config/Desktop/Run_IL2_GB_Install.desktop

logfile="/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/bin/game/launcher.log"
touch "$logfile"

cd "/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/bin/game"
wine launcher.exe > "/config/.wine/drive_c/Program Files/IL-2 Sturmovik Great Battles/bin/game/launcher.log" &

sleep 10

gracetime=$((SECONDS+20))
while pidof -qx launcher.exe; do
    if grep -q -m 1 'Update status: failed' "$logfile"; then
        echo "Update failed."
        wine taskkill /im launcher.exe # May be better to simulate closing the window
        break
    elif grep -q -m 1 'Update status: pass' "$logfile"; then
        echo "Update successful."
        wine taskkill /im launcher.exe
        break
    elif grep -q -m 1 'Current Snapshot version is the same' "$logfile"; then
        echo "Update not needed."
        wine taskkill /im launcher.exe
        break
    elif [ $SECONDS -gt $gracetime ]; then
        #If the BOS Updater library hasn't printed to stdout after 30 seconds, nothing is updating (IL2 quirk. It will finally print on exit)
        if ! grep -q -m 1 'BOS update library' "$logfile"; then
            echo "Update not needed."
            wine taskkill /im launcher.exe
            break
        fi
    fi

    sleep 5
done

echo
echo "Install complete."
exit 0