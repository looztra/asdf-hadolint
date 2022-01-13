#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/hadolint/hadolint"
TOOL_NAME="hadolint"
TOOL_TEST="hadolint --help"
SKIP_VERIFY="true"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if actionlint is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
  # Change this function if actionlint has other means of determining installable versions.
  list_github_tags
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"

    chmod +x "$install_path/$tool_cmd"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}

rename_bin() {
  local bin="$1"
  local tool_cmd
  tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"

  mv "$bin" "$(dirname "$bin")/$tool_cmd"
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"

  url="$(get_download_url "${version}" "bin")"

  echo "* Downloading $TOOL_NAME release $version from '${url}'..."

  if curl "${curl_opts[@]}" -o "$filename" -C - "$url"; then
    if [ "${SKIP_VERIFY}" == "false" ]; then
      echo "Verifying checksum..."
      verify "${version}" "${filename}"
    else
      echo "Skipping verifying checksums as not supported by the editor yet"
    fi
  else
    fail "Error: ${TOOL_NAME} version ${version} not found"
  fi
}

verify() {
  # Returns 1 on checksum error.
  local -r version="$1"
  local -r platform="$(get_platform)"
  local -r arch="$(get_arch)"
  local -r checksum_path="${ASDF_DOWNLOAD_PATH}/$(get_checksum_filename "${version}")"

  if ! curl "${curl_opts[@]}" "$(get_download_url "${version}" "checksum")" -o "${checksum_path}"; then
    echo "couldn't download checksum file" >&2
  fi

  shasum_command="shasum -a 256"

  if ! command -v shasum &>/dev/null; then
    shasum_command=sha256sum
  fi
  if ! (cd "${ASDF_DOWNLOAD_PATH}" && ${shasum_command} -c <(grep "$(get_tarball_filename "${version}")" "${checksum_path}")); then
    echo "checksum verification failed" >&2
    return 1
  fi
}

get_platform() {
  local -r kernel="$(uname -s)"
  if [[ $OSTYPE == "msys" || $kernel == "CYGWIN"* || $kernel == "MINGW"* ]]; then
    echo windows
  else
    uname
  fi
}

get_arch() {
  local -r machine="$(uname -m)"
  OVERWRITE_ARCH=${ASDF_OVERWRITE_ARCH:-"false"}
  if [[ $OVERWRITE_ARCH != "false" ]]; then
    echo "$OVERWRITE_ARCH"
  elif [[ $machine == "arm64" ]] || [[ $machine == "aarch64" ]]; then
    echo "arm64"
  elif [[ $machine == *"arm"* ]] || [[ $machine == *"aarch"* ]]; then
    echo "arm"
  elif [[ $machine == *"386"* ]]; then
    echo "386"
  else
    # echo "amd64"
    echo "x86_64"
  fi
}

get_tarball_filename() {
  local -r version="$1"
  local -r platform="$(get_platform)"
  local -r arch="$(get_arch)"
  echo "${TOOL_NAME}_${version}_${platform}_${arch}.tar.gz"
}

get_checksum_filename() {
  local -r version="$1"
  echo "${TOOL_NAME}_${version}_checksums.txt"
}

get_bin_name() {
  local -r version="$1"
  local -r platform="$(get_platform)"
  local -r arch="$(get_arch)"
  echo "${TOOL_NAME}-${platform}-${arch}"
}

get_download_url() {
  local -r version="$1"
  local -r type="$2"
  local -r keyid="${3:-}"

  case "${type}" in
  tarball)
    local -r filename="$(get_tarball_filename "${version}")"
    ;;
  checksum)
    local -r filename="$(get_checksum_filename "${version}")"
    ;;
  bin)
    local -r filename="$(get_bin_name "${version}")"
    ;;
  *)
    echo "${type} is not a valid type of URL to download" >&2
    exit 1
    ;;
  esac

  echo "$GH_REPO/releases/download/v${version}/${filename}"
}
