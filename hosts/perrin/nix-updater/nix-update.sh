#!/usr/bin/env bash

function clone() {
    dir=$1
    name=$2
    if ! git clone git@github.com:martiert/$name $dir/$name ; then
        echo "Failed to clone $name"
        exit 1
    fi
}

function update_flake() {
    dir=$1
    name=$2
    cd $dir/$name
    
    if ! nix flake update ; then
        echo "Failed to update inputs for $name"
        exit 1
    fi
}

function cleanup() {
    echo "Cleaning up $1"
    cd
    rm -fr $1
}

function check_and_commit() {
    dir=$1
    name=$2
    cd $dir/$name

    if git diff-index --quiet HEAD ; then
        echo "No changes found in $name, skipping commit"
        return
    fi

    if ! nix flake check --all-systems ; then
        echo "Problem detected with newly updated $name"
        exit 1
    fi
    git add flake.lock
    if ! git commit -m "flake.lock: Update nix inputs" ; then
        echo "Failed to create new commit in $name"
        exit 1
    fi
    if ! git push ; then
        echo "Failed to push new commit"
        exit 1
    fi
}

dir=$(mktemp -d)
trap "cleanup $dir" EXIT

clone $dir nixos-module
clone $dir nixos-config

update_flake $dir nixos-module
update_flake $dir nixos-config

check_and_commit $dir nixos-module

cd $dir/nixos-config
nix flake update module
check_and_commit $dir nixos-config
