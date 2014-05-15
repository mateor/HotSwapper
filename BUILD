#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2014 Mateor
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

# Config for patchScripts 

# CHANGE THIS SECTION!!

# This is my personal set up. I include it as an example, but it would be easy to
#  end up clong the entire AOSP in a new directory, if you aren't aware.


# ************  Start Editing Environment Here *****************

# Identity
# You can leave this as is to stay anonymous- but git and AOSP ask for email/name.
# This file is ignored by version control, so your info will not get pushed to github by default
GIT_NAME="Your name"
GIT_EMAIL="you@example.com"

# where you keep your source.
ANDROID_HOME=~/android/system/jellybean

# TARGET and MANUFACTURER should match your device tree
TARGET=grouper
MANUFACTURER=asus

# update as needed. For getting SDK as defaults. Hotswapper should work even if slightly out of date
CURRENT_SDK=http://dl.google.com/android/android-sdk_r22.6-linux.tgz
MOST_RECENT_API=19
ANDROID_VERSION=4.4

# this is how many threads. If you have old computer or bad internet set to 8 or even 4.
JOBS=24

# default build command- generally don't edit unless targeting subsections of build
#         ( i.e. framework.jar or recovery.img, etc.)
BUILD_COMMAND="make bacon"

# ************  End Editing  **********************


IPC=$HOT_SWAPPER_LOC/.iproc
SETUP_FILE=.setup

bold=$(tput bold)
normal=$(tput sgr0)

exit_code=0
