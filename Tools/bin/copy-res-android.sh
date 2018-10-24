#!/usr/bin/env bash

cd $( cd "$( dirname "$0"  )" && pwd  )
cd ../lib

node copyRes.js -a $@