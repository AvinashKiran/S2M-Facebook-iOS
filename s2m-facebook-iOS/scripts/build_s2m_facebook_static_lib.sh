#!/bin/sh


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
#  limitations under the License.


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
XCODEBUILD=xcodebuild

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

cd $SRCPATH

$XCODEBUILD -target "s2m-facebook-iOS" -sdk "iphonesimulator" -configuration "Release" SYMROOT=$BUILDDIR clean build || die "iOS Simulator build failed"
$XCODEBUILD -target "s2m-facebook-iOS" -sdk "iphoneos" -configuration "Release" SYMROOT=$BUILDDIR clean build || die "iOS Device build failed"

\rm -rf $LIBOUTPUTDIR

mkdir -p $LIBOUTPUTDIR

# combine lib files for various platforms into one
lipo -create $BUILDDIR/Release-iphonesimulator/libs2m-facebook-iOS.a $BUILDDIR/Release-iphoneos/libs2m-facebook-iOS.a -output $LIBOUTPUTDIR/libs2m-facebook-iOS.a || die "Could not create static output library"

\cp $HEADER_PATH/*.h $LIBOUTPUTDIR/
\mkdir $LIBOUTPUTDIR/Object
\cp $HEADER_PATH/Object/*.h $LIBOUTPUTDIR/Object/
\mkdir $LIBOUTPUTDIR/List
\cp $HEADER_PATH/List/*.h $LIBOUTPUTDIR/List/
\mkdir $LIBOUTPUTDIR/Internal
\cp $HEADER_PATH/Internal/*.h $LIBOUTPUTDIR/Internal/


echo "Finish to make s2m-facebook-iOS SDK"
echo ""
echo "You can now use the static library that can be found at:"
echo ""
echo $LIBOUTPUTDIR
echo ""

exit 0
