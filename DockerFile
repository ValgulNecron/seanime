FROM debian:bullseye-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        wget \
        tar \
        jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Jellyfin's FFmpeg
RUN curl -fsSL https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | gpg --dearmor -o /usr/share/keyrings/jellyfin-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/jellyfin-archive-keyring.gpg] https://repo.jellyfin.org/debian bullseye main" | tee /etc/apt/sources.list.d/jellyfin.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends jellyfin-ffmpeg6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app/

RUN mkdir /downloads

# Download and install latest version
RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/5rahim/seanime/releases/latest | jq -r .tag_name) && \
    VERSION_NO_V=$(echo ${LATEST_VERSION} | sed 's/v//') && \
    echo "Latest version: ${LATEST_VERSION}" && \
    echo "Version without v: ${VERSION_NO_V}" && \
    wget "https://github.com/5rahim/seanime/releases/download/${LATEST_VERSION}/seanime-${VERSION_NO_V}_Linux_x86_64.tar.gz" && \
    tar -xzf "seanime-${VERSION_NO_V}_Linux_x86_64.tar.gz" && \
    rm "seanime-${VERSION_NO_V}_Linux_x86_64.tar.gz" && \
    chmod +x seanime

ENV PATH="/usr/lib/jellyfin-ffmpeg/:$PATH"

CMD ["./seanime"]
