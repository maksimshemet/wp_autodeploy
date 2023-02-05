#!/bin/bash

while [ "$#" -gt 0 ]; do
  case "$1" in
    -v|--version)
      wp_version="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Define the target directory
TARGET_DIR="/tmp/wordpress"
if [ ! -d "$TARGET_DIR" ]; then
  mkdir "$TARGET_DIR"
fi


# Define wordpress url
WP_VERSION="wordpress-$wp_version"
WP_URL="https://wordpress.org/$WP_VERSION.tar.gz"

# Download the latest version of WordPress
curl -L $WP_URL -o $WP_VERSION.tar.gz

# Unpack the WordPress archive
tar xzf $WP_VERSION.tar.gz

# Remove the archive
rm $WP_VERSION.tar.gz

# Move the contents of the WordPress directory to the target directory
if [ -d "$TARGET_DIR" ]; then
  rm -rf "$TARGET_DIR"
fi
mv wordpress "$TARGET_DIR"

echo "WordPress has been successfully downloaded and unpacked into $TARGET_DIR"