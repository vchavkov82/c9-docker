#!/bin/bash

exec 2>&1
set -e
set -x

NGINX_VERSION=1.15.8
NGX_CACHE_PURGE_VERSION=2.3
NGX_CACHE_HEADERS_MORE=0.33
NPS_VERSION=1.13.35.1-beta

WORK_DIR="/usr/src"

# Install basic packages and build tools
apt-get update
apt-get dist-upgrade -y
apt-get install -y \
    dpkg-dev \
    build-essential \
    zlib1g-dev \
    libssl-dev \
    libpcre3 \
    libpcre3-dev \
    unzip \
    uuid-dev \
    devscripts \
    debian-keyring \
    sed

cd "${WORK_DIR}"

# clean up
rm -rf "nginx_${NGINX_VERSION}"*

# nginx src
apt-get source nginx

# nginx deps
apt-get build-dep nginx

# pagespeed-ngx
wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip
unzip v${NPS_VERSION}.zip
nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d)
cd "$nps_dir"
NPS_RELEASE_NUMBER=${NPS_VERSION/beta/}
NPS_RELEASE_NUMBER=${NPS_VERSION/stable/}
psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
wget ${psol_url}
tar -xzvf $(basename ${psol_url})  # extracts to psol/

cd "${WORK_DIR}"

# ngx_cache_purge
wget https://github.com/vchavkov/static-assets/raw/master/nginx/ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz
tar -zxvf ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz && mv ngx_cache_purge-${NGX_CACHE_PURGE_VERSION} ngx_cache_purge && rm ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz

# headers-more-nginx
wget https://github.com/openresty/headers-more-nginx-module/archive/v${NGX_CACHE_HEADERS_MORE}.tar.gz
tar -zxvf v${NGX_CACHE_HEADERS_MORE}.tar.gz && mv headers-more-nginx-module-${NGX_CACHE_HEADERS_MORE} ngx_headers_more && rm v${NGX_CACHE_HEADERS_MORE}.tar.gz

cd /
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archives/*.deb