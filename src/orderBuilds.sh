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

# order builds for SlimRom, CyanogenMod, AOKP, AOSP, PAC-man, OmniRom, ParanoidAndroid etc..

# If you want to adjust, do it in BUILD if possible.
[[ "$ANDROID_HOME" == "" ]] && ANDROID_HOME=~/android/system/jellybean
[[ "$TARGET" == "" ]] && TARGET=mako
[[ "$MANUFACTURER" == "" ]] && MANUFACTURER=lge    # not often needed, only AOKP right now.

#Setting git info globally is not ideal, as we default to anonymous. But it is needed for all repos
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

#TODO handle missing LOC variables so script can be called not as child.

# This is to add proprietary files. There WILL be sync errors. Unfortunate but not fatal.
MANIFEST_HOME="$ANDROID_HOME"/.repo/local_manifests
MANIFEST=hot_props.xml

# adjust in the BUILD file as per your machine- 8 might be a good start.
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
     exit 1
}

remove_manifests() {
     rm -rf .repo/manifests
     rm -rf .repo/local_manifests
}

get_proprietary() {
# This adds the appropriate proprietary files without requiring user to connect an actual device
# One of those "grey areas" of the custom scene

# Thanks to @CyanogenMod and @TheMuppets for maintaining the repos.
     mkdir -p "$MANIFEST_HOME"

     touch "$MANIFEST_HOME"/"$MANIFEST"
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
     while read xml_line; do
          if [[ "$xml_line" != *">" ]]; then
               echo $xml_line "revision=\"$PROP_BRANCH\" />" >> "$MANIFEST_HOME"/"$MANIFEST"
          else
               echo $xml_line >> "$MANIFEST_HOME"/"$MANIFEST"
          fi
     done < "$HOT_SWAPPER_LOC"/lib/template.xml
}

clobber() {
     make clobber
}

install_term() {
     # deal with CM's totally irritating way of incorporating Android Terminal
     cd "$ANDROID_HOME"/vendor/cm
     ./get-prebuilts
     cd "$ANDROID_HOME"
}

if [[ $# == 2 ]]; then
     ANDROID_VERSION="$2"
fi
[[ "$ANDROID_VERSION" == "" ]] && ANDROID_VERSION=4.4


BRANCH=0
if [[ $# == 3 ]]; then
     BRANCH=1
     BRANCH_NAME="$3"
fi

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
          GITHUB=https://android.googlesource.com/platform/manifest
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
          REPO_INIT_COMMAND="repo init -u $GITHUB -b $TARGET_BRANCH"
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
               *)
               TARGET_BRANCH=$ANDROID_VERSION
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
               BUILD_COMMAND="./rom-build.sh $TARGET"
               ;;
               4.3)
               TARGET_BRANCH=jb43
               BUILD_COMMAND="./rom-build.sh $TARGET"
               ;;
               4.4)
               TARGET_BRANCH=kitkat
               GITHUB=AOSPA/manifest
               ;;
          esac
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
          BUILD_COMMAND="./build-pac.sh $TARGET"
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
          # This is not guaranteed to work right now. Needs testing/better solution.
          LUNCH_COMMAND="$DEFAULT_LUNCH_COMMAND"
     ;;
     *)
     print_error "Not a valid rom target."
     ;;
esac

# Support arbitrary branch names...this has ZERO error catching. If misspelled...woe.
[[ "$BRANCH" -gt 0 ]] && TARGET_BRANCH="$BRANCH_NAME"

case $1 in
aokp)
     REPO_INIT_COMMAND="repo init -u https://github.com/$GITHUB -b $TARGET_BRANCH -g all,-notdefault,$TARGET,$MANUFACTURER"
     ;;
aosp)
     ;;
*)
     REPO_INIT_COMMAND="repo init -u https://github.com/${GITHUB} -b $TARGET_BRANCH"
     ;;
esac

# order builds
cd $ANDROID_HOME

# Only remove old manifests if we are switching roms

#check last build ROMTYPE
# TODO: Handle null case
current=$(cat $IPC)
# record current ROMTYPE
echo "$1" > $IPC


if [[ "$1" != "$current"  ]]; then
     # remove old manifests and repo init if switching rom types
     remove_manifests
     CLOBBER=true
fi

# echo "y" allows colors in term, needs to be done since we unset the user each run.
echo "Running: $REPO_INIT_COMMAND"
echo "y" | $REPO_INIT_COMMAND

$REPO_SYNC_COMMAND

. build/envsetup.sh
$LUNCH_COMMAND

# Sets up prop files

# Some roms supply prop files, some don't. We have failed builds if we assume wrongly either way
[[ -f "$MANIFEST_HOME"/"$MANIFEST" ]] && rm "$MANIFEST_HOME"/"$MANIFEST"

# If there are no "proprietary" repos in any manifests, add them ourselves.
if ( ! find .repo/*manifest* -name "*xml" | xargs grep -s "proprietary_vendor" 2>&1 ); then
     get_proprietary "$ANDROID_VERSION" || print_error "Problem with proprietary files!"
     $REPO_SYNC_COMMAND
fi

# this flag set if switching romtypes is detected
[[ "$CLOBBER" == "true" ]] && clobber


if [[ "$1" == "cm" ]] || [[ "$1" == "pac" ]]; then
     install_term
fi

# I may have to check that the above went without error manually. I could capture stderr...hmmmph.
$BUILD_COMMAND

# unset the global git names if unfilled by the user (in BUILD file)
git config --unset --global user.name "Your name"
git config --unset --global user.email "you@example.com"
