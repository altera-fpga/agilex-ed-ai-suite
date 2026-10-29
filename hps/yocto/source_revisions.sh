#!/bin/bash

# Required repos for building Yocto
export SRCREV_poky="d0b46a6624ec9c61c47270745dd0b2d5abbe6ac1"
export SRCREV_meta_intel_fpga="	11a37cebc717bf57e0821d24494379398ef7f5d6"
export SRCREV_YOCTO_BRANCH=walnascar

if [[ -z ${CHECKOUT_DIR} ]]; then
    CHECKOUT_DIR=`pwd`
else
    if [[ ! -d ${CHECKOUT_DIR} ]]; then
        echo "[ERROR] The specified checkout directory ( $CHECKOUT_DIR ) does not exist"
        exit 1
    fi
fi

pushd $CHECKOUT_DIR > /dev/null
    # Clone poky layer
    if [ ! -d poky ] ; then
        echo "[INFO] Adding poky layer"
        mkdir poky  
        git clone -b $SRCREV_YOCTO_BRANCH https://git.yoctoproject.org/git/poky.git poky
    fi

    # Checkout correct poky revision
    pushd poky > /dev/null
        if [[ ! -z "$SRCREV_poky" ]] && git checkout ${SRCREV_poky}; then
            echo "[INFO] checked out poky revision ${SRCREV_poky}"
        else
            echo "[ERROR] checkout poky failed."
            popd > /dev/null
            rm -fr poky
            exit 1
        fi
    popd > /dev/null

    # Clone meta-intel-fpga layer
    if [ ! -d meta-intel-fpga ] ; then
        echo "[INFO] Adding meta-intel-fpga layer"
        mkdir meta-intel-fpga
    
        git clone -b $SRCREV_YOCTO_BRANCH https://git.yoctoproject.org/git/meta-intel-fpga meta-intel-fpga
    fi

    # Checkout correct meta-intel-fpga revision
    pushd meta-intel-fpga > /dev/null
        if [[ ! -z "$SRCREV_meta_intel_fpga" ]] && git checkout ${SRCREV_meta_intel_fpga}; then
            echo "[INFO] checked out meta-intel-fpga revision ${SRCREV_meta_intel_fpga}"
        else
            echo "[ERROR] checkout meta-intel-fpga failed."
            popd > /dev/null
            rm -fr meta-intel-fpga
            exit 1
        fi
    popd > /dev/null
popd > /dev/null
