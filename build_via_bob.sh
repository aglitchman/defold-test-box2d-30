#!/bin/bash

# Check if required environment variables are set
if [ -z "$DEFOLD_VERSION" ]; then
    echo "Error: DEFOLD_VERSION environment variable is not set"
    exit 1
fi

if [ -z "$DEFOLD_BOB_SHA1" ]; then
    echo "Error: DEFOLD_BOB_SHA1 environment variable is not set"
    exit 1
fi

TITLE="test_box2d_30"

echo "Building with Defold version: $DEFOLD_VERSION (SHA1: $DEFOLD_BOB_SHA1)"

# Clean up build directory
rm -rf build/bundle/${DEFOLD_VERSION}
mkdir -p build/bundle/${DEFOLD_VERSION}

# Download Bob
wget --progress=dot:mega -O build/bundle/${DEFOLD_VERSION}/bob.jar "https://d.defold.com/archive/${DEFOLD_BOB_SHA1}/bob/bob.jar"
java -jar build/bundle/${DEFOLD_VERSION}/bob.jar --version

# Build the project
PLATFORM="wasm-web"
VARIANT="release"
echo "- Building for platform: $PLATFORM with variant: $VARIANT"
java -jar build/bundle/${DEFOLD_VERSION}/bob.jar -e a@b.com -u 123 -tc -bo build/bundle/${DEFOLD_VERSION}/${PLATFORM} -p ${PLATFORM} --archive --variant ${VARIANT} clean resolve build bundle

PLATFORM="arm64-android"
VARIANT="release"
echo "- Building for platform: $PLATFORM with variant: $VARIANT"
# Update the package name in game.project to include the SHA1
echo "- Updating package name in game.project"
sed -i "s/package = .*/package = project.${TITLE}_${DEFOLD_BOB_SHA1}/" game.project
java -jar build/bundle/${DEFOLD_VERSION}/bob.jar -e a@b.com -u 123 -tc -bo build/bundle/${DEFOLD_VERSION}/${PLATFORM} -p ${PLATFORM} --archive --variant ${VARIANT} clean resolve build bundle

# Copy the build to the pages directory
mkdir -p build/bundle/pages
cp -r build/bundle/${DEFOLD_VERSION}/wasm-web/${TITLE} build/bundle/pages/${DEFOLD_VERSION}
cp -r build/bundle/${DEFOLD_VERSION}/arm64-android/${TITLE}/${TITLE}.apk build/bundle/pages/${DEFOLD_VERSION}/
