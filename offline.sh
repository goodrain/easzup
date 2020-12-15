#!/bin/bash

function ansible_image_list(){
    
    cp ./ansible-base/main.yml ./ansible-file/roles/install-rainbond/tasks/main.yml
    cp ./ansible-base/rbdaio.yml ./ansible-file/roles/install-rainbond/tasks/rbdaio.yml
    rm -rf ./ansible-file/tools && mkdir ./ansible-file/tools && cp ./ansible-base/02.addnode.yml ./ansible-file/tools/02.addnode.yml

    cat images_list | tr "/" ":" | awk -F":" '{print $3".tar.gz"}' | while read line ;do 
        sed -i "/RAINBOND-IMAGE-LIST/a\          \- \"$line\"" ./ansible-file/roles/install-rainbond/tasks/*.yml ;
    done

    cat images_list | tr "/" ":" | awk -F":" '{print $3".tar.gz"}' | while read line ;do 
        sed -i "/RAINBOND-IMAGE-LIST/a\    \- \"$line\"" ./ansible-file/tools/*.yml ;
    done

    sed -i "/RAINBOND-IMAGE-LIST/d" ./ansible-file/roles/install-rainbond/tasks/*.yml ;

    sed -i "/RAINBOND-IMAGE-LIST/d" ./ansible-file/tools/*.yml ;

}

function build_kubeasz_image(){

    KUBEASZ_VER=v5.3.0

    ansible_image_list

    docker build -t registry.cn-hangzhou.aliyuncs.com/goodrain/kubeasz:${KUBEASZ_VER} .
    docker login  --username=lius@goodrain --password=${HUBPASS} registry.cn-hangzhou.aliyuncs.com
    docker push registry.cn-hangzhou.aliyuncs.com/goodrain/kubeasz:${KUBEASZ_VER}
    docker logout registry.cn-hangzhou.aliyuncs.com
    
}

function run_easzup(){

    ./easzup -R && echo -e "[INFO] \033[33mdownload successful\033[0m"
    cd /etc/ansible && tar zcvf rainbond-offline.tgz ./* && echo -e "[INFO] \033[33mtar successful\033[0m"
}

function main() {
    # check if use bash shell
    readlink /proc/$$/exe|grep -q "dash" && { echo "[ERROR] you should use bash shell, not sh"; exit 1; }
    # check if use with root
    [[ "$EUID" -ne 0 ]] && { echo "[ERROR] you should run this script as root"; exit 1; }

    [[ "$#" -eq 0 ]] && { usage >&2; exit 1; }

    export REGISTRY_MIRROR="CN"
    ACTION=""
    while getopts "ID" OPTION; do
        case "$OPTION" in
            I)
                ACTION="build_kubeasz_image"
                ;;
            D)
                ACTION="run_easzup"
                ;;
        esac
    done

    [[ "$ACTION" == "" ]] && { echo "[ERROR] illegal option"; usage; exit 1; }

    # excute cmd "$ACTION" 
    echo -e "[INFO] \033[33mAction begin\033[0m : $ACTION"
    ${ACTION} || { echo -e "[ERROR] \033[31mAction failed\033[0m : $ACTION"; return 1; }
    echo -e "[INFO] \033[32mAction successed\033[0m : $ACTION"
}

main "$@"

