#!/usr/bin/env bash

curl --version || apt-get install -y curl

export REMOTE_VER=$(curl https://ipweb-download.oss-ap-northeast-1.aliyuncs.com/version | cut -f3 -d' ')

export LOCAL_VER=$(ipws version | cut -f3 -d' ')

export LOCAL_BIN=/usr/local/bin/ipws

export TMP_BIN=/tmp/update-bin

if [ "$(echo $REMOTE_VER $LOCAL_VER | tr " " "\n" | sort -V | head -n 1)" != "$REMOTE_VER" ]
  then
    curl -o https://ipweb-download.oss-ap-northeast-1.aliyuncs.com/$REMOTE_VER/x86/ipws
    
    # Stop IPWS
    /usr/local/bin/ipws shutdown >/dev/null 2>&1
    mv $TMP_BIN $LOCAL_BIN
    # Start IPWS
    /usr/local/bin/ipws daemon >/dev/null 2>&1 &
fi
