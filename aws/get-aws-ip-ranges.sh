#!/bin/bash

## GNU grep 2.5.1:
# wget -qO - --no-check-certificate https://forums.aws.amazon.com/ann.jspa?annID=1701 | grep -Eoh "[0-9.]+{4}/[0-9]+"

## BSD grep 2.5.1-FreeBSD 
wget -qO - --no-check-certificate https://forums.aws.amazon.com/ann.jspa?annID=1701 | grep -Eoh "[0-9.]+[0-9.]+[0-9.]+[0-9]+/[0-9]+"

