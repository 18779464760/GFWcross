# !/bin/bash
attempt_num=0
max_attempts=3
ca='zerossl'

read -p "输入域名:" dns

# 升级所有安装包
update() {
    while [ $attempt_num -lt $max_attempts ]
    do
        echo -e "\033[32m正在升级所有安装包\033[0m"
        apt update -y
        if [ $? -eq 0 ]
        then
            installCurl
            break
        else
            attempt_num=$[$attempt_num+1]
            echo -e "\033[31m升级所有安装包失败，重试中\033[0m"
        fi
    done
    if [ $attempt_num -eq $max_attempts]; then
    echo "任务失败超过 $max_attempts 次，请检查."
    exit 1
    fi
}

# 安装curl
installCurl() {
    attempt_num=0
    while [ $attempt_num -lt $max_attempts ]
    do
        echo -e "\033[32m正在安装curl\033[0m"
        apt install -y curl
        if [ $? -eq 0 ]
        then
            installSocat
            break
        else
            attempt_num=$[$attempt_num+1]
            echo -e "\033[31m安装curl失败，重试中\033[0m"
        fi
    done
    if [ $attempt_num -eq $max_attempts]; then
    echo "任务失败超过 $max_attempts 次，请检查."
    exit 1
    fi
}

# 安装socat
installSocat() {
    attempt_num=0
    while [ $attempt_num -lt $max_attempts ]
    do
        echo -e "\033[32m正在安装socat\033[0m"
        apt install -y socat
        if [ $? -eq 0 ]
        then
            installCron
            break
        else
            attempt_num=$[$attempt_num+1]
            echo -e "\033[31m安装socat失败，重试中\033[0m"
        fi
    done
    if [ $attempt_num -eq $max_attempts]; then
    echo "任务失败超过 $max_attempts 次，请检查."
    exit 1
    fi
}

installCron() {
    attempt_num=0
    while [ $attempt_num -lt $max_attempts ]
    do
        echo -e "\033[32m正在安装cron\033[0m"
        apt-get -y install cron
        if [ $? -eq 0 ]
        then
            curlAcme
            break
        else
            attempt_num=$[$attempt_num+1]
            echo -e "\033[31m安装cron失败，重试中\033[0m"
        fi
    done
    if [ $attempt_num -eq $max_attempts]; then
    echo "任务失败超过 $max_attempts 次，请检查."
    exit 1
    fi
}

# 请求acme证书服务
curlAcme() {
    attempt_num=0
    while [ $attempt_num -lt $max_attempts ]
    do
        echo -e "\033[32m正在请求acme证书服务\033[0m"
        curl https://get.acme.sh | sh
        if [ $? -eq 0 ]
        then
            registerAcme
            break
        else
            attempt_num=$[$attempt_num+1]
            echo -e "\033[31m请求acme证书服务失败，重试中\033[0m"
        fi
    done
    if [ $attempt_num -eq $max_attempts]; then
    echo "任务失败超过 $max_attempts 次，请检查."
    exit 1
    fi
}

# 切换acmeCA
switchCa() {
    ca='letsencrypt'
    attempt_num=0
    while [ $attempt_num -lt $max_attempts ]
    do
        echo -e "\033[32m正在切换acmeCA\033[0m"
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
        if [ $? -eq 0 ]
        then
            registerAcme
            break
        else
            attempt_num=$[$attempt_num+1]
            echo -e "\033[31m切换acmeCA失败，重试中\033[0m"
        fi
    done
    if [ $attempt_num -eq $max_attempts]; then
    echo "任务失败超过 $max_attempts 次，请检查."
    exit 1
    fi
}

# 使用邮箱申请证书
registerAcme() {
    attempt_num=0
    while [ $attempt_num -lt $max_attempts ]
    do
        echo -e "\033[32m正在使用邮箱申请证书\033[0m"
        ~/.acme.sh/acme.sh --register-account -m 2316429288@qq.com
        if [ $? -eq 0 ]
        then
            standaloneCert
            break
        else
            attempt_num=$[$attempt_num+1]
            echo -e "\033[31m使用邮箱申请证书失败，重试中\033[0m"
        fi
    done
    if [ $attempt_num -eq $max_attempts]; then
    echo "任务失败超过 $max_attempts 次，请检查."
    exit 1
    fi
}

# 为域名安装证书
standaloneCert() {
    attempt_num=0
    while [ $attempt_num -lt 3 ]
    do
        echo -e "\033[32m正在为域名安装证书\033[0m"
        ~/.acme.sh/acme.sh  --issue -d $dns --standalone
        if [ $? -eq 0 ]
        then
            installCert
            break
        else
            attempt_num=$[$attempt_num+1]
            echo -e "\033[31m为域名安装证书失败，重试中\033[0m"
        fi
    done
    if [ $attempt_num -eq $max_attempts -a $ca == 'zerossl' ]
    then
        echo "任务失败超过 $max_attempts 次，切换CA重试中."
        switchCa
        break
    elif [ $attempt_num -eq $max_attempts -a $ca == 'letsencrypt' ]
        then
        echo "任务失败超过 $max_attempts 次，请检查."
        exit 1
    fi
}

# 将证书安装到根目录
installCert() {
    attempt_num=0
    while [ $attempt_num -lt $max_attempts ]
    do
        echo -e "\033[32m正在将证书安装到根目录\033[0m"
        ~/.acme.sh/acme.sh --installcert -d $dns --key-file /root/private.key --fullchain-file /root/cert.crt
        if [ $? -eq 0 ]
        then
            installXUi
            break
        else
            attempt_num=$[$attempt_num+1]
            echo -e "\033[31m将证书安装到根目录失败，重试中\033[0m"
        fi
    done
    if [ $attempt_num -eq $max_attempts]; then
    echo "任务失败超过 $max_attempts 次，请检查."
    exit 1
    fi
}

# 安装x-ui面板
installXUi() {
echo -e "\033[32m正在安装x-ui面板\033[0m"
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh) <<EOF
y
admin
admin
8971
EOF
if [ $? -eq 0 ]
    then
        installBbr2
        break
fi
}

# 安装bbr2内核
installBbr2() {
    attempt_num=0
    while [ $attempt_num -lt $max_attempts ]
    do
        echo -e "\033[32m正在安装bbr2内核\033[0m"
        wget --no-check-certificate -q -O bbr2.sh "https://github.com/yeyingorg/bbr2.sh/raw/master/bbr2.sh" && chmod +x bbr2.sh && bash bbr2.sh auto
        if [ $? -eq 0 ]
        then
            echo -e "\033[32m安装完成\033[0m"
            break
        else
            attempt_num=$[$attempt_num+1]
            echo -e "\033[31m安装bbr2内核失败，重试中\033[0m"
        fi
    done
}

update
