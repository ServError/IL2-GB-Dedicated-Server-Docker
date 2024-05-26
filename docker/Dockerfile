#
# IL2-GB-Dedicated-Server-Docker Dockerfile.
#
#
FROM lscr.io/linuxserver/webtop:latest

LABEL maintainer="ServError"

# Wine 9.9 64Bit from edge for running EXE
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community wine-staging=9.9-r0
# Remaining packages from default repo
RUN apk add --no-cache mesa-vulkan-swrast freetype wget cabextract xdotool xdg-utils xvfb xvfb-run git python3 python3-dev py3-pip 7zip make cmake gcc g++ gfortran innoextract samba-winbind-clients zenity krb5 xz tcpdump

# Set up to give raw packet capabilities to wine preloader later
RUN apk add --no-cache build-base git libcap-static libcap-dev
RUN git clone --depth 1 https://git.kernel.org/pub/scm/libs/libcap/libcap
RUN gcc --static libcap/progs/setcap.c -o /bin/setcap -lcap

# Download the latest winetricks script (master="latest version") from Github.
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && chmod +x winetricks
RUN mv winetricks /usr/bin

COPY ./src/s6-services/s6-init-winepreqs-oneshot /etc/s6-overlay/s6-rc.d/init-winepreqs-oneshot
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-winepreqs-oneshot

COPY ./src/s6-services/s6-init-getlatest-il2-gb-installer-oneshot /etc/s6-overlay/s6-rc.d/init-getlatest-il2-gb-installer-oneshot
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-getlatest-il2-gb-installer-oneshot

COPY ./src/s6-services/s6-init-il2-srs-installer-oneshot /etc/s6-overlay/s6-rc.d/init-il2-srs-installer-oneshot
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-il2-srs-installer-oneshot

COPY ./src/s6-services/s6-init-desktop-setup-oneshot /etc/s6-overlay/s6-rc.d/init-desktop-setup-oneshot
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-desktop-setup-oneshot

COPY ./src/wine-dedicated-il2-gb-automated-installer /app/il2_gb_server/wine-dedicated-il2-gb-automated-installer
RUN chmod +x -R /app/il2_gb_server/wine-dedicated-il2-gb-automated-installer

COPY ./src/desktop-setup /app/il2_gb_server/desktop-setup
RUN chmod +x -R /app/il2_gb_server/desktop-setup

COPY ./src/s6-services/s6-init-il2-gb-auto-installer-updater-oneshot /etc/s6-overlay/s6-rc.d/init-il2-gb-auto-installer-updater-oneshot
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-il2-gb-auto-installer-updater-oneshot

COPY ./src/s6-services/s6-init-il2-gb-server-autostart-longrun /etc/s6-overlay/s6-rc.d/init-il2-gb-server-autostart-longrun
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/init-il2-gb-server-autostart-longrun
