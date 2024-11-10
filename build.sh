#!/bin/bash

set -euo pipefail

set -x

sudo apt-get update
sudo apt-get -y install binutils curl jq

git_tag="$(cd delta && git describe --tags)"

github_api_url="https://api.github.com/repos/dandavison/delta/releases/tags/${git_tag}"

package_path="${GITHUB_WORKSPACE}/packages/any-distro_any-version/"
mkdir -p "${package_path}"

mapfile -t deb_files < <(curl -1sLf "${github_api_url}" 2>/dev/null |
    jq -r '.assets[] | select(.name | endswith(".deb")) | [.name, .browser_download_url] | @sh')

for deb_file in "${deb_files[@]}"; do
    pkg_filename=$(echo "${deb_file}" | awk '{print $1}' | xargs)
    pkg_url=$(echo "${deb_file}" | awk '{print $2}' | xargs)

    curl -1sLf "${pkg_url}" -o "${GITHUB_WORKSPACE}/${pkg_filename}"

    mv "${GITHUB_WORKSPACE}/${pkg_filename}" "${package_path}/${pkg_filename}"
done
