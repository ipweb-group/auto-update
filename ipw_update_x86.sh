#!/usr/bin/env bash

curl --version > /dev/null 2>&1 || apt-get install -y curl

export REMOTE_VER=$(curl https://ipweb-download.oss-ap-northeast-1.aliyuncs.com/version | cut -f3 -d' ')

export LOCAL_BIN=/usr/local/bin/ipws

export TMP_BIN=/tmp/update-bin

if which ipws > /dev/null 2>&1
  then
  export LOCAL_VER=$(ipws version | cut -f3 -d' ')
    if [ "$(echo $REMOTE_VER $LOCAL_VER | tr " " "\n" | sort -V | head -n 1)" != "$REMOTE_VER" ]
      then
        curl -o $TMP_BIN https://ipweb-download.oss-ap-northeast-1.aliyuncs.com/$REMOTE_VER/x86/ipws

        # Stop IPWS
        echo "Stop IPWS"
        $LOCAL_BIN shutdown >/dev/null 2>&1

        mv $TMP_BIN $LOCAL_BIN
        chmod +x $LOCAL_BIN

        # Start IPWS
        echo "Start IPWS"
        $LOCAL_BIN daemon >/dev/null 2>&1 &
    fi
  else
    curl -o $LOCAL_BIN https://ipweb-download.oss-ap-northeast-1.aliyuncs.com/$REMOTE_VER/x86/ipws
    chmod +x $LOCAL_BIN

    #IPWS INIT
    echo "Init IPWS"
    $LOCAL_BIN init
    if [ ! -d "/data/ipws" ]; then
      echo "Init Error: /data/ipws is not found."
      exit 1
    fi

    #Set PrivateKey
    if [ -z $PRIVATE_KEY ];then
      read -p "Enter your private key:" PRIVATE_KEY
      echo "PRIVATE_KEY = $PRIVATE_KEY"
    fi

    echo "Set Private Key"
    $LOCAL_BIN config Chain.WalletPriKey $PRIVATE_KEY

    # Start IPWS
    echo "Start IPWS"
    $LOCAL_BIN daemon >/dev/null 2>&1 &
fi

# weekly auto update
command_update=`basename "$0"`
job_update="@weekly bash $PWD/$command"
cat <(fgrep -i -v "$command_update" <(crontab -l)) <(echo "$job_update") | crontab -

# reboot start
job_reboot="@reboot $LOCAL_BIN daemon >/dev/null 2>&1 &"
cat <(fgrep -i -v "$LOCAL_BIN" <(crontab -l)) <(echo "$job_reboot") | crontab -