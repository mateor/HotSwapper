#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2013, 2014 Mateor
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# order builds for SlimRom, CyanogenMod, AOKP, AOSP, PAC-man, OmniRom, ParanoidAndroid and whomever else.

# If you want to adjust, do it in BUILD if possible.
[[ "$ANDROID_HOME" == "" ]] && ANDROID_HOME=~/android/system/jellybean
[[ "$TARGET" == "" ]] && TARGET=mako
[[ "$MANUFACTURER" == "" ]] && MANUFACTURER=lge                    # not often needed, only AOKP right now.

#TODO handle missing LOC variables so script can be called not as child.


# adjust as per your machine- 8 might be a good start.
REPO_SYNC_COMMAND="repo sync -j${JOBS} -f"
[[ "$JOBS" == "" ]] && JOBS=24

# this is for using github.com address as argument. For full builds, change this to "brunch $TARGET"
LUNCH_COMMAND="lunch ${1}_${TARGET}-userdebug"

# Needed to allow for AOKP, and anyone else who gets cute.
DEFAULT_LUNCH_COMMAND="lunch aosp_$TARGET-userdebug"

[[ "$BUILD_COMMAND" == "" ]] && BUILD_COMMAND="make -j${JOBS} bacon"

print_error() {
     echo ""
     echo "!!! error: $@ !!!"
     echo ""
     echo "Your build was not ordered correctly"
     echo ""
}

get_proprietary() {
# This adds the appropriate proprietary files without requiring user to connect an actual device
# One of those "grey areas" of the custom scene

# Thanks to @CyanogenMod and @TheMuppets for maintaining the repos.

     MANIFEST_HOME="$ANDROID_HOME"/.repo/local_manifests
     MANIFEST="$MANIFEST_HOME"/hot_props.xml

     # parse the CM branch
     case "$ANDROID_VERSION" in
     4.0)
          PROP_BRANCH=ics
          ;;
     4.1)
          PROP_BRANCH=jellybean
          ;;
     4.2)
          PROP_BRANCH=cm-10.1
          ;;
     4.3)
          PROP_BRANCH=cm-10.2
          ;;
     4.4)
          PROP_BRANCH=cm-11.0
          ;;
     esac
     mkdir -p "$MANIFEST_HOME"
     touch "$MANIFEST"
     # create our own local_manifest to handle proprietary files
     echo '<?xml version="1.0" encoding="UTF-8"?>' > "$MANIFEST"
     echo '<manifest>' >> "$MANIFEST"
     echo '  <remote name="github_cm" fetch="git://github.com" />' >> "$MANIFEST"
     echo -n '  <project name="TheMuppets/proprietary_vendor_' >> "$MANIFEST"
     echo -n "$MANUFACTURER" >> "$MANIFEST"
     echo -n '" path="vendor/' >> "$MANIFEST"
     echo -n "$MANUFACTURER" >> "$MANIFEST"
     echo -n '" remote="github_cm" revision="' >> "$MANIFEST"
     echo -n "$PROP_BRANCH" >> "$MANIFEST"
     echo '" />' >> "$MANIFEST"
     echo '</manifest>' >> "$MANIFEST"
}

if [[ $# == 2 ]]; then
     ANDROID_VERSION="$2"
fi
[[ "$ANDROID_VERSION" == "" ]] && ANDROID_VERSION=4.4

# Perhaps one day to be expanded to take 'files to place' as a second parameter.
if [[ $# -lt 1 ]]; then
     echo ""
     echo "### Error ###"
     echo ""
     echo "You must indicate what the romtype and Android version is."
     echo ""
     echo " Usage is"
     echo "./orderBuilds cm 4.3"
     echo "   or"
     echo "./orderBuilds aosp 4.4"
     echo ""
     echo "Supported options are ${ROM_OPTIONS[@]}"
     exit
fi

case "$1" in
     aosp)
          GITHUB=android/platform_manifest
          case "$ANDROID_VERSION" in
               4.0)
               TARGET_BRANCH=android-4.0.4_r2
               ;;
               4.1)
               TARGET_BRANCH=android-4.1.2_r2.1
               ;;
               4.2)
               TARGET_BRANCH=android-4.2.2_r1.2
               ;;
               4.3)
               TARGET_BRANCH=android-4.3_r3
               ;;
               4.4)
               TARGET_BRANCH=android-4.4_r1.1
               ;;
          esac
          BUILD_COMMAND="make otapackage"
     ;;
     cm)
          GITHUB=CyanogenMod/android
          case "$ANDROID_VERSION" in
               4.0)
               TARGET_BRANCH=ics
               ;;
               4.1)
               TARGET_BRANCH=jellybean
               ;;
               4.2)
               TARGET_BRANCH=cm-10.1
               ;;
               4.3)
               TARGET_BRANCH=cm-10.2
               ;;
               4.4)
               TARGET_BRANCH=cm-11.0
               ;;
          esac
          BUILD_COMMAND="mka bacon"
     ;;
     aokp)
          GITHUB=AOKP/platform_manifest
          case "$ANDROID_VERSION" in
               4.0)
               TARGET_BRANCH=ics
               ;;
               4.1)
               TARGET_BRANCH=jb
               ;;
               4.2)
               TARGET_BRANCH=jb-mr1
               ;;
               4.3)
               TARGET_BRANCH=jb-mr2
               ;;
               4.4)
               TARGET_BRANCH=kitkat
               ;;
          esac
     ;;
     slim)
          GITHUB=SlimRoms/platform_manifest
          case "$ANDROID_VERSION" in
               4.1)
               TARGET_BRANCH=jb
               ;;
               4.2)
               TARGET_BRANCH=jb4.2
               ;;
               4.3)
               TARGET_BRANCH=jb4.3
               ;;
               4.4)
               TARGET_BRANCH=kk4.4
               ;;
          esac
     ;;
     vanir)
          GITHUB=VanirAOSP/platform_manifest
          case "$ANDROID_VERSION" in
               4.1)
               TARGET_BRANCH=jb
               ;;
               4.2)
               TARGET_BRANCH=jb42
               ;;
               4.3)
               TARGET_BRANCH=jb43
               ;;
               4.4)
               TARGET_BRANCH=kk44
               ;;
          esac
     ;;
     pa)
          GITHUB=ParanoidAndroid/manifest
          case "$ANDROID_VERSION" in
               4.2)
               TARGET_BRANCH=jellybean
               ;;
               4.3)
               TARGET_BRANCH=jb43
               ;;
               4.4)
               TARGET_BRANCH=kk4.4
               ;;
          esac
          BUILD_COMMAND="./rom-build.sh $TARGET"
     ;;
     pac)
          GITHUB=PAC-man/android
          case "$ANDROID_VERSION" in
               4.1)
               TARGET_BRANCH=jellybean
               ;;
               4.2)
               TARGET_BRANCH=cm-10.1
               ;;
               4.3)
               TARGET_BRANCH=cm-10.2
               ;;
               4.4)
               TARGET_BRANCH=pac-4.4
               ;;
          esac
     ;;
     omni)
          GITHUB=OmniRom/android
          case "$ANDROID_VERSION" in
               4.3)
               TARGET_BRANCH=android-4.3
               ;;
               4.4)
               TARGET_BRANCH=android-4.4
               ;;
          esac
     ;;
     http*)
          GITHUB_ADDRESS="$1"
          GITHUB=${GITHUB_ADDRESS//*.com\//}
          TARGET_BRANCH="$ANDROID_VERSION"
          # The below works for us but won't provide full build. parsing lunch menu may be only current hope
          LUNCH_COMMAND="$DEFAULT_LUNCH_COMMAND"
     ;;
     *)
     print_error "Not a valid rom target." && exit -1
     ;;
esac

if [[ "$1" == aokp ]]; then
     REPO_INIT_COMMAND="repo init -u https://github.com/$GITHUB -b $TARGET_BRANCH -g all,-notdefault,$TARGET,$MANUFACTURER"
else
     REPO_INIT_COMMAND="repo init -u https://github.com/${GITHUB} -b $TARGET_BRANCH"
fi

# order builds
cd $ANDROID_HOME

# Only remove old manifests if we are switching roms

#check last build ROMTYPE
current=$(cat $IPC)
# record current ROMTYPE
echo "$1" > $IPC

# remove old manifests and repo init if switching rom types
remove_manifests() {

     rm -rf .repo/manifests manifests.xml
     rm -rf .repo/local_manifests local_manifests.xml
     $REPO_INIT_COMMAND

}
if [[ "$1" != $current  ]]; then
     remove_manifests
fi

# This runs twice because it error-catches problems from canceled jobs
$REPO_INIT_COMMAND

# fetch the proprietary files
get_proprietary "$ANDROID_VERSION" || print_error "Something went wrong with getting the proprietary files!"

$REPO_SYNC_COMMAND || remove_manifests

. build/envsetup.sh
$LUNCH_COMMAND

install_term() {
     # deal with CM's totally irritating way of incorporating Android Terminal
     cd "$ANDROID_HOME"/vendor/cm
     ./get-prebuilts
     cd "$ANDROID_HOME"
}

if [[ "$1" == "cm" ]] || [[ "$1" == "pac" ]]; then
     install_term
fi

# I may have to just check that the above went without error manually. I could capture stderr...hmmmph.
$BUILD_COMMAND


