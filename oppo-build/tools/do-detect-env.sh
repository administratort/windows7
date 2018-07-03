#! /usr/bin/env bash
#

#--------------------
set -e

UNAME_S=$(uname -s)
UNAME_SM=$(uname -sm)
echo "build on $UNAME_SM"

echo "ANDROID_NDK=$ANDROID_NDK"

if [ -z "$ANDROID_NDK" ]; then
    echo "You must define ANDROID_NDK before starting."
    echo "They must point to your NDK directories."
    echo ""
    exit 1
fi



# try to detect NDK version
export OPPO_GCC_VER=4.9
export OPPO_GCC_64_VER=4.9
export OPPO_MAKE_TOOLCHAIN_FLAGS=
export OPPO_MAKE_FLAG=
export OPPO_NDK_REL=$(grep -o '^r[0-9]*.*' $ANDROID_NDK/RELEASE.TXT 2>/dev/null | sed 's/[[:space:]]*//g' | cut -b2-)
case "$OPPO_NDK_REL" in
    10e*)
        # we don't use 4.4.3 because it doesn't handle threads correctly.
        if test -d ${ANDROID_NDK}/toolchains/arm-linux-androideabi-4.8
        # if gcc 4.8 is present, it's there for all the archs (x86, mips, arm)
        then
            echo "NDKr$OPPO_NDK_REL detected"

            case "$UNAME_S" in
                Darwin)
                    export OPPO_MAKE_TOOLCHAIN_FLAGS="$OPPO_MAKE_TOOLCHAIN_FLAGS --system=darwin-x86_64"
                ;;
                CYGWIN_NT-*)
                    export OPPO_MAKE_TOOLCHAIN_FLAGS="$OPPO_MAKE_TOOLCHAIN_FLAGS --system=windows-x86_64"
                ;;
            esac
        else
            echo "You need the NDKr10e or later"
            exit 1
        fi
    ;;
    *)
        OPPO_NDK_REL=$(grep -o '^Pkg\.Revision.*=[0-9]*.*' $ANDROID_NDK/source.properties 2>/dev/null | sed 's/[[:space:]]*//g' | cut -d "=" -f 2)
        echo "OPPO_NDK_REL=$OPPO_NDK_REL"
        case "$OPPO_NDK_REL" in
            11*|12*|13*|14*)
                if test -d ${ANDROID_NDK}/toolchains/arm-linux-androideabi-4.9
                then
                    echo "NDKr$OPPO_NDK_REL detected"
                else
                    echo "You need the NDKr10e or later"
                    exit 1
                fi
            ;;
            *)
                echo "You need the NDKr10e or later"
                exit 1
            ;;
        esac
    ;;
esac


case "$UNAME_S" in
    Darwin)
        export OPPO_MAKE_FLAG=-j`sysctl -n machdep.cpu.thread_count`
    ;;
    CYGWIN_NT-*)
        OPPO_WIN_TEMP="$(cygpath -am /tmp)"
        export TEMPDIR=$OPPO_WIN_TEMP/

        echo "Cygwin temp prefix=$OPPO_WIN_TEMP/"
    ;;
esac
