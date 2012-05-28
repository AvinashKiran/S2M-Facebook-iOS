#!/bin/sh
#
# Copyright 2012 SinnerSchrader Mobile GmbH. All Rights Reserved.
#

# Copyright 2012 SinnerSchrader Mobile GmbH.
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#  http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License

# This script will build a static library version of the S2M Facebook iOS SDK.
# You may want to use this script if you have a project that has the 
# Automatic Reference Counting feature turned on. Once you run this script
# you will get a directory under the iOS SDK project home path:
#    lib/s2m-facebook
# You can drag the TIClib-facebook directory into your Xcode project and
# copy the contents over or include it as a reference.

# Function for handling errors
die() {
    echo ""
    echo "$*" >&2
    exit 1
}

# The Xcode bin path
XCODEBUILD_PATH=/Developer/usr/bin
XCODEBUILD=$XCODEBUILD_PATH/xcodebuild

# Get the script path and set the relative directories used
# for compilation
cd $(dirname $0)
SCRIPTPATH=`pwd`
cd $SCRIPTPATH/../

# The home directory where the SDK is installed
PROJECT_HOME=`pwd`

echo "Project Home: $PROJECT_HOME"

# The facebook-ios-sdk src directory path
SRCPATH=$PROJECT_HOME/
HEADER_PATH=$PROJECT_HOME/s2m-facebook-iOS
# The directory where the target is built
BUILDDIR=$PROJECT_HOME/build

# The directory where the library output will be placed
LIBOUTPUTDIR=$PROJECT_HOME/lib/s2m-facebook

sh scripts/build_s2m_facebook_static_lib.sh

PRODUCT_NAME="S2M-Facebook"

cd $SRCPATH

FRAMEWORK=$PROJECT_HOME/framework/$PRODUCT_NAME.framework

echo "Create Framework...."
# Create framework directory structure.
rm -rf $FRAMEWORK
mkdir -p $FRAMEWORK/Versions/A/Headers
mkdir -p $FRAMEWORK/Versions/A/Resources


# Move files to appropriate locations in framework paths.
echo "copy .a file...."
cp $LIBOUTPUTDIR/libs2m-facebook-iOS.a $FRAMEWORK/Versions/A/$PRODUCT_NAME
echo "copy headers...."
cp $HEADER_PATH/*.h $FRAMEWORK/Versions/A/Headers
cp $HEADER_PATH/Object/*.h $FRAMEWORK/Versions/A/Headers
cp $HEADER_PATH/List/*.h $FRAMEWORK/Versions/A/Headers
cp $HEADER_PATH/Internal/*.h $FRAMEWORK/Versions/A/Headers

echo "link....."
echo "link current..."
ln -s A $FRAMEWORK/Versions/Current
echo "link headers..."
ln -s Versions/Current/Headers $FRAMEWORK/Headers
echo "link resources..."
ln -s Versions/Current/Resources $FRAMEWORK/Resources
echo "link ${PRODUCT_NAME}..."
ln -s Versions/Current/$PRODUCT_NAME $FRAMEWORK/$PRODUCT_NAME

echo "DONE........."

exit 0

