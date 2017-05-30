#!/bin/bash

# Used to generate the API HTML

set -e -o pipefail

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
RAML_DIR="${2:-"$REPO_DIR/docs"}"
TARGET_DIR="${3:-"$REPO_DIR/target"}"

mkdir -p "$TARGET_DIR"

# Build a docker image with raml2html
sudo docker build --tag ramltools "$REPO_DIR/docker/ramltools"

for RAML in $RAML_DIR/*.raml
do
  REPO_DIR_DOCKER="/src"
  RAML_DOCKER="$REPO_DIR_DOCKER/${RAML##"$REPO_DIR/"}"

  BASENAME="$(basename "$RAML")"
  NAME="${BASENAME%.*}"
  OUT_RAML="$TARGET_DIR/$NAME.raml"
  OUT_HTML="$TARGET_DIR/$NAME.html"
  OUT_SWAGGER="$TARGET_DIR/$NAME.swagger"

  # Generate the API HTML using the built docker image
  echo "Generating $OUT_HTML"
  sudo docker run \
    --volume="$REPO_DIR":"$REPO_DIR_DOCKER":ro \
    --rm ramltools /usr/local/bin/raml2html \
    "$RAML_DOCKER" > "$OUT_HTML"

  # Generate the API Swagger using the built docker image
  echo "Generating $OUT_SWAGGER"
  sudo docker run \
    --volume="$REPO_DIR":"$REPO_DIR_DOCKER":ro \
    --rm ramltools /usr/local/bin/raml2swagger \
    "$RAML_DOCKER" > "$OUT_SWAGGER"

  # Copy the API RAML
  echo "Generating $OUT_RAML"
  cp "$RAML" "$OUT_RAML"

done
