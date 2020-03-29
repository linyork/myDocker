#!/usr/bin/env bash
BASEDIR=$(dirname "$0")
cd "$BASEDIR"
clear

printFace() {
    printf "\E[0;33m"
    echo "__     __           _               "
    echo "\ \   / /          | |              "
    echo " \ \_/ /___   _ __ | | __ ___  _ __ "
    echo "  \   // _ \ | '__|| |/ // _ \| '__|"
    echo "   | || (_) || |   |   <|  __/| |   "
    echo '   |_| \___/ |_|   |_|\_\\___||_|   '
    echo ' '
    echo -e "Welcome to use York's Docker Interface. v1.1.1  ${PROJECT} ${INFO} ${ERROR}"
    printf "\E[0m"
    printPartition
}

pressAnyKeyToContinue() {
    removePIE
    read -n 1 -s -r -p "Press any key to continue..."
    clear
}

godzilla() {
    echo '                                   ,▄▄▄'
    echo '                                 ,█▓████▓b'
    echo '                                /▓████████▄'
    echo '                               ╔▓██▓█████"▀'
    echo '                             ▄.▓█████████▀'
    echo '                           ███▓████████'
    echo '                        ╔,p▓███████████'
    echo '                       ²███▓███████████▄'
    echo '                        ▓▓███████████████µ'
    echo '                      ╔▄▓▓████████████████▄'
    echo '                       ████████████████████Γ'
    echo '                     j▄████████████████████'
    echo '                     ▀████████████████████Γ'
    echo '                      █████████████████████▄▄▄'
    echo '                    -███▓████████████████▀████'
    echo '                    ▀█▓█████████████████▓'
    echo '                    ▐████████████████████'
    echo '                     ▓███████████████████▄'
    echo '                    å▓▓▓███████████████████▄'
    echo '                   ]▓▓█▓█████████████████████µ'
    echo '                   Å▓▓█▓██████████████████████▄╓'
    echo '     :▓██████▄,   ]▓▓██████████████████████████▄'
    echo '         `▀▀█████▄j▓▓███████████████████████████'
    echo '             █▓████▓████████████████████████████'
    echo '             ▐█▓████████████████████████████████'
    echo '             ╙██████████████████████████████████'
    echo '              "██▓██████████████████████████████'
    echo '               ╙▀█████████████████████████████▀'
    echo '                 ^█████████████████╖█████████'
    echo '                   ╙▀███████████▀Γ  @███████'
    echo '                     ▐████████▄     ████████▄,,'
    echo '                     ▓▓██████████w   ████████████▄'
    echo '                     ▐▓▀▀▀█▓▀▀▀▀Γ       "▀▀"▀▀▀▀ `^'
}

initCommend() {
    COMMENDSTRING=""
    local commendArray
    local stringArray
    declare commendArray
    declare stringArray

    commendArray=(a n r c l s i p d q)
    stringArray=('啟動編號' '跳置編號' '重啟' '關閉' '狀態' '查詢' '進入' '更新Image' '刪除' '結束')

    for key in ${!commendArray[@]}
    do
        COMMENDSTRING=${COMMENDSTRING}"   [\033[31m"${commendArray[$key]}"\033[0m]\033[30;42m"${stringArray[$key]}"\033[0m"
#        COMMENDSTRING=${COMMENDSTRING}"   [\033[31m"${commendArray[$key]}"\033[0m]"${stringArray[$key]}
    done
}

printPartition() {
    cols=""
    # 取得畫面寬
    local windowsWidth=$(tput cols)
    for((j=1; j<=${windowsWidth}; j++ ))
    do
        cols=${cols}-
    done
    echo  -e "\033[0;32m${cols}\033[0m"
}

printEmpty() {
    # 取得畫面高
    local windowsHigh=$(tput lines)
    for((j=0; j<=$[${windowsHigh}-16-${_PROJECT_MAX_NUM}]; j++ ))
    do
        echo ""
    done
}

showProject() {
    PROJECT="\033[37;46m${1}\033[0m"
}

removeProject() {
    PROJECT=""
}

showInfo() {
    INFO="\033[37;46m${1}\033[0m"
}

removeInfo() {
    INFO=""
}

showError() {
    ERROR="\033[37;41m${1}\033[0m"
}

removeError() {
    ERROR=""
}

removePIE(){
    removeProject
    removeInfo
    removeError
}

existedCurrentProject() {
    if [[ ${_CURRENT_PROJECT_NAME} ]]; then
        echo 1
    else
        echo 0
    fi
}

setSelectProject() {
    _SELECTED_PROJECT_NAME=${_PROJECT_LIST[$1]}
    _SELECTED_PROJECT_YML="./project/${_SELECTED_PROJECT_NAME}/docker-compose.yml"
    _SEKECTED_PROJECT_ENV="./project/${_SELECTED_PROJECT_NAME}/.env"
}

setCurrentProject() {
    _CURRENT_PROJECT_NAME=$1
    CURRENT_PROJECT_YML="./project/${_CURRENT_PROJECT_NAME}/docker-compose.yml"
}

prevItem() {
    ((_SELECTED_PROJECT_NUMBER--))
    if [[ ${_SELECTED_PROJECT_NUMBER} -lt 0 ]]; then
        _SELECTED_PROJECT_NUMBER=${_PROJECT_MAX_NUM}
    fi
}

nextItem() {
    ((_SELECTED_PROJECT_NUMBER++))
    if [[ ${_SELECTED_PROJECT_NUMBER} -gt ${_PROJECT_MAX_NUM} ]]; then
        _SELECTED_PROJECT_NUMBER=0
    fi
}

removeAllDockerContainer() {
    local id
    id=($(docker ps -a -q))

    if [[ ${id} ]]
    then
#        docker stop $(docker ps -a -q) | awk '{print "關閉 \""$1"\" Container"}'
#        docker rm $(docker ps -a -q) | awk '{print "移除 \""$1"\" Container"}'
        docker rm -f $(docker ps -a -q) | awk '{print "移除 \""$1"\" Container"}'
    fi
}

jumpToNum() {
    read -p '跳至編號: ' -r num
    [[ ${num} != '' ]] && [[ ${_PROJECT_LIST[$num]} ]] && _SELECTED_PROJECT_NUMBER=${num}
}

keyInput() {
    # 熱鍵前綴
    local ESC=$(printf "\033")
    local input
    input=$1
    # 上下左右 是 三字元 例: up => ${ESC}[A
    if [[ ${input} = ${ESC} ]] || [[ ${input} = '[' ]] ; then
        read -r -sn1 input
    fi;
    if [[ ${input} = ${ESC} ]] || [[ ${input} = '[' ]] ; then
        read -r -sn1 input
    fi;

    if [[ $input = A ]]; then echo up;
    elif [[ $input = B ]]; then echo down;
    elif [[ $input = C ]]; then echo right;
    elif [[ $input = D ]]; then echo left;
    elif [[ $input = "" ]]; then echo enter;
    else echo $input;
    fi;
}

createEnvExample(){
    baseDir=$(pwd);
    exampleProjectENV=${baseDir}/project/_example/.env.example;
    projectENV=${baseDir}/project/${1}/.env.example;
    # 替換 .env.example 文件新增至 new project 內
    sed "s/{{PROJECT_PATH}}/.\/..\/${1}/g" ${exampleProjectENV} > ${projectENV};
}

# 選擇的專案編號
_SELECTED_PROJECT_NUMBER=''
# 選擇的專案名稱
_SELECTED_PROJECT_NAME=''
# 選擇的專案docker-compose.yml
_SELECTED_PROJECT_YML=''

# 選擇的專案.ENV
_SEKECTED_PROJECT_ENV=''
# 當前專案名稱
_CURRENT_PROJECT_NAME=''


# 歡迎介面
printFace
printf "\E[0;32m"
read -p "請按Enter開始Docker... " admin
printf "\E[0m"
[[ ${admin} = 'admin' ]] && godzilla && pressAnyKeyToContinue
clear

# 基本介面
while :
do
    # init COMMENDSTRING
    initCommend
    # 讀取所有 project
    rawProjectList=$(ls './project')
    # 去掉example資料夾
    declare -a _PROJECT_LIST=(${rawProjectList/_example/})
    # 最大專案編號
    _PROJECT_MAX_NUM=$((${#_PROJECT_LIST[@]}-1))
    # 如有選擇專案 則執行 setSelectProject
    [ ${_SELECTED_PROJECT_NUMBER} ] && setSelectProject ${_SELECTED_PROJECT_NUMBER}

    # 介面分隔 & title & info & error
    printFace
    echo  -e "  狀態\t 編號\t 專案名稱\t"

    removePIE
    printPartition

    for i in ${!_PROJECT_LIST[@]}
    do
        projectName=${_PROJECT_LIST[${i}]}
        # 預設選擇第一個專案
        if [ -z ${_SELECTED_PROJECT_NUMBER} ];then
            _SELECTED_PROJECT_NUMBER=${i}
            setSelectProject ${_SELECTED_PROJECT_NUMBER}
        fi

        # 是選擇的專案 & 是當前專案
        if [  "${projectName}" == "${_SELECTED_PROJECT_NAME}" ] && [ "${projectName}" == "${_CURRENT_PROJECT_NAME}" ]; then
            echo -e "  \033[32m●\033[0m\t \033[31m${i}.\033[0m\t \033[30;43m${_PROJECT_LIST[${i}]}\033[0m"
        # 是選擇的專案
        elif [  "${projectName}" == "${_SELECTED_PROJECT_NAME}" ]; then
            echo -e "  \033[31m●\033[0m\t \033[31m${i}.\033[0m\t \033[30;43m${_PROJECT_LIST[${i}]}\033[0m"
        # 是當前專案
        elif [  "${projectName}" == "${_CURRENT_PROJECT_NAME}" ]; then
            echo -e "  \033[32m●\033[0m\t \033[31m${i}.\033[0m\t ${_PROJECT_LIST[${i}]}"
        # 其他
        else
            echo -e "  \033[31m●\033[0m\t \033[31m${i}.\033[0m\t ${_PROJECT_LIST[${i}]}"
        fi
    done

    # 計算介面及專案數印出 Ｎ row 空行
    printEmpty

    # 指令面板
    printPartition
    echo  -e ${COMMENDSTRING}
    printf "\33[?25l"
    read -r -sn1 input
    input=$(keyInput ${input})

    # case
    case ${input} in
        up)
            clear
            prevItem
            continue
            ;;
        down)
            clear
            nextItem
            continue
            ;;
        enter)
            clear

            # 顯示 project 名稱
            showProject "正在啟動${_SELECTED_PROJECT_NAME}..."

            # 設定 env ()
            if [[ -f ${_SEKECTED_PROJECT_ENV} ]] ; then
                export $(grep -v '^#' ${_SEKECTED_PROJECT_ENV} | xargs)
            else
                showInfo "該專案無.env檔, 額外撰寫.env.example, 請依照該檔案撰寫.env"
                createEnvExample ${_SELECTED_PROJECT_NAME}
            fi
            printFace
            # 關閉 container
            removeAllDockerContainer

            # docker up
            docker-compose -p core_docker --project-directory . -f ${_SELECTED_PROJECT_YML} up -d
            setCurrentProject ${_SELECTED_PROJECT_NAME}

            pressAnyKeyToContinue
            ;;
        a)
            read -p '執行編號: ' -r num

            # 輸入的編號
            if [[ ${num} != '' ]] && [[ ${_PROJECT_LIST[$num]} ]] && _SELECTED_PROJECT_NUMBER=${num} ; then
                [ ${_SELECTED_PROJECT_NUMBER} ] && setSelectProject ${_SELECTED_PROJECT_NUMBER}
                clear

                # 顯示 project 名稱
                showProject "正在啟動${_SELECTED_PROJECT_NAME}..."

                # 設定 env ()
                if [[ -f ${_SEKECTED_PROJECT_ENV} ]] ; then
                    export $(grep -v '^#' ${_SEKECTED_PROJECT_ENV} | xargs)
                else
                    showInfo "該專案無.env檔, 額外撰寫.env.example, 請依照該檔案撰寫.env"
                    createEnvExample ${_SELECTED_PROJECT_NAME}
                fi
                printFace

                # 關閉 container
                removeAllDockerContainer

                # docker up
                docker-compose -p core_docker --project-directory . -f ${_SELECTED_PROJECT_YML} up -d
                setCurrentProject ${_SELECTED_PROJECT_NAME}

                pressAnyKeyToContinue
                continue
            fi

            # 輸入編號不存在
            showError "沒有該專案編號"
            ;;
        n)
            # 光棒移至指定的編號
            jumpToNum
            clear
            ;;
        r)
            clear
            # 檢查當前專案存在
            if [[ $(existedCurrentProject) == 0 ]] ; then
                showError "沒有執行中的專案"
                continue
            fi
            printFace

            # 關閉 container
            removeAllDockerContainer

            # 啟動 all server
            docker-compose -p core_docker --project-directory . -f ${CURRENT_PROJECT_YML} up -d
            clear
            ;;
        c)
            showInfo "正在關閉當前所有容器"
            clear
            printFace
            _CURRENT_PROJECT_NAME=''

            # 關閉 container
            removeAllDockerContainer
            pressAnyKeyToContinue
            ;;
        l)
            clear
            printFace

            # 查看目前的 container
            docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.ID}}"
            pressAnyKeyToContinue
            ;;
        s)
            clear
            # 檢查當前專案存在
            if [[ $(existedCurrentProject) == 0 ]] ; then
                showError "沒有執行中的專案"
                continue
            fi
            printFace

            # 顯示當前專案的資訊
            newProjectDockerCompose=$(cd "$(dirname "$0")";pwd)/project/${_CURRENT_PROJECT_NAME}/docker-compose.yml
            echo -e "\033[32mProject Name: \033[0m"${_CURRENT_PROJECT_NAME}
            echo -e "\033[32mLocal Domain: \033[0m"$(sed -n 2,2p ${newProjectDockerCompose} | sed 's/#//g')
            cat ${newProjectDockerCompose} | grep -n "container_name" | awk '{sub(/container_name:/,"\033[32mContainer:\033[0m")}{print $2$3}'
            cat ${newProjectDockerCompose} | grep -n "PMA_PASSWORD" | awk '{sub(/PMA_PASSWORD:/,"\033[32mCloudDbPassword:\033[0m")}{print $2$3}'
            pressAnyKeyToContinue
            continue
            ;;
        i)
            clear
            printFace
            # 查看目前的 container
            docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.ID}}"
            echo  -e "\033[37;41m請輸入 Container Name(ex: apache)\033[0m"
            read -p "Name:" containerName
            clear
            #  進入 container
            if [[ ${containerName} ]]; then
                docker exec -it ${containerName} bash
            fi
            clear
            ;;
        q)
            clear
            # 離開程序
            exit
            ;;
        o)
            clear
            # 隱藏功能 for mac browser開啟該專案
            showProject "正在使用 chrome 開啟${SELECTED_PROJECT_NAME}..."
            printFace
            newProjectDockerCompose=$(cd "$(dirname "$0")";pwd)/project/${_SELECTED_PROJECT_NAME}/docker-compose.yml
            domain=$(sed -n 2,2p ${newProjectDockerCompose} | sed 's/#//g')
            /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome "https://"${domain}
            pressAnyKeyToContinue
            ;;
        p)
            clear
            printFace
            docker-compose -p core_docker --project-directory . -f ${_SELECTED_PROJECT_YML} pull
            ;;
        d)
            clear
            printFace
            # 詢問是否刪除該專案document
            printf "\E[0;31m"
            echo -e "請問是否刪除專案 ${_SELECTED_PROJECT_NAME} 的檔案(y/n)"
            read -p "輸入: " yesno
            printf "\E[0m"
            if [[ ${yesno} = 'y' || ${yesno} = 'Y' ]]; then
                pwd
            fi
            printf "\E[0m"
            printPartition

            # 詢問是否刪除該專案
            printf "\E[0;31m"
            echo "請問是否刪除專案 ${_SELECTED_PROJECT_NAME} 的環境(y/n)"
            read -p "輸入: " yesno
            printf "\E[0m"
            if [[ ${yesno} = 'y' || ${yesno} = 'Y' ]]; then
                rm -r ./project/${_SELECTED_PROJECT_NAME}
                echo "已刪除"
            fi
            printPartition

            pressAnyKeyToContinue
            ;;
        x)
            clear
            printFace
            echo  -e " \033[37;41m進階工具\033[0m"
            printPartition
            echo  -e "  \033[31mnewpj.\033[0m  建立新專案"
            echo  -e "  \033[31msa.\033[0m     顯示整份yml"
            echo  -e "  \033[31mimg.\033[0m    顯示本機所有image"
            echo  -e "  \033[31m*.\033[0m      離開進階工具(按任按鍵)"
            printPartition

            printf "\E[0;31m"
            read -p "Input: " xinput
            printf "\E[0m"

            case $xinput in
                newpj)
                    printPartition
                    # 詢問專案名稱
                    echo "請輸入專案名稱"
                    printf "\E[0;31m"
                    read -p "名稱: " newPjName
                    printf "\E[0m"
                    printPartition

                    # 詢問專案path
                    echo "請輸入專案位置(可輸入相對位置) 不填寫直接按Enter預設位置為(./../{{PROJECT_NAME}})"
                    printf "\E[0;31m"
                    read -p "專案位置: " newPjPath
                    printf "\E[0m"
                    printPartition


                    if [  "$newPjName" == "" ]; then
                        showError "\033[37;41m請輸入專案名稱\033[0m"
                    else
                        # 取得 project name & path
                        newProjectName=${newPjName}
                        if [  "$newPjPath" == "" ];
                        then
                            newProjectPath='.\/..\/'${newProjectName}
                        else
                            newProjectPath=${newPjPath}
                        fi
                        # 設定基本路徑
                        baseDir=$(cd "$(dirname "$0")";pwd);
                        apacheConfPath='/apache/conf';
                        nginxConfPath='/nginx/conf';
                        sqlFilePath='/sql';
                        # 取得 example & new project path
                        exampleDockerDir=${baseDir}/project/_example;
                        projectDockerDir=${baseDir}/project/${newProjectName};
                        # 建立 project dir 程序
                        if [ -d ${projectDockerDir} ]
                        then
                            showInfo '\033[37;41m已經建立 '${projectDockerDir}' 專案\033[0m'
                            continue
                        else
                            mkdir -m 755 ${projectDockerDir}
                            if [ ! -d ${projectDockerDir} ]
                            then
                                showError '\033[37;41mmkdir '${projectDockerDir}' 失敗\033[0m'
                                continue
                            fi
                        fi
                        mkdir -m 755 -p ${projectDockerDir}${apacheConfPath};
                        mkdir -m 755 -p ${projectDockerDir}${nginxConfPath};
                        mkdir -m 755 ${projectDockerDir}${sqlFilePath};
                        # 取的 conf 基本變數
                        newProjectLocalDomain=local.${newProjectName}.tw;
                        newProjectDocumentRoot='\/public';
                        exampleApacheConf=${exampleDockerDir}${apacheConfPath}/example.loc.conf
                        newProjectApacheConf=${projectDockerDir}${apacheConfPath}/${newProjectName}.conf
                        exampleNginxConf=${exampleDockerDir}${nginxConfPath}/example.loc.conf
                        newProjectNginxConf=${projectDockerDir}${nginxConfPath}/${newProjectName}.conf
                        exampleProjectENV=${exampleDockerDir}/.env.example
                        newProjectENV=${projectDockerDir}/.env
                        exampleDockerCompose=${exampleDockerDir}/docker-compose.yml
                        newProjectDockerCompose=${projectDockerDir}/docker-compose.yml
                        # 替換 apache conf 文件新增至 new project 內
                        sed "s/{{PROJECT_LOCAL_DOMAIN}}/${newProjectLocalDomain}/g;s/{{PROJECT_NAME}}/${newProjectName}/g;s/{{DOCUMENT_ROOT}}/${newProjectDocumentRoot}/g" ${exampleApacheConf} > ${newProjectApacheConf};
                        # 替換 nginx conf 文件新增至 new project 內
                        sed "s/{{PROJECT_LOCAL_DOMAIN}}/${newProjectLocalDomain}/g;s/{{PROJECT_NAME}}/${newProjectName}/g;s/{{DOCUMENT_ROOT}}/${newProjectDocumentRoot}/g" ${exampleNginxConf} > ${newProjectNginxConf};
                        # 替換 .env.example 文件新增至 new project 內
                        sed "s/{{PROJECT_PATH}}/${newProjectPath}/g" ${exampleProjectENV} > ${newProjectENV};
                        # 替換 docker compose 文件新增至 new project 內
                        sed "s/{{PROJECT_LOCAL_DOMAIN}}/${newProjectLocalDomain}/g;s/{{PROJECT_NAME}}/${newProjectName}/g" ${exampleDockerCompose} > ${newProjectDockerCompose};

                        showInfo "${newProjectName} 已建立請編輯該專案的 docker-compose.yml"

                        #  詢問是否開啟 laravel 專案
                        echo "是否開啟laravel 專案(y/n)"
                        printf "\E[0;31m"
                        read -p " 輸入: " laravel
                        printf "\E[0m"
                        if [[ "$laravel" == "y" ]]; then
                            composer create-project --prefer-dist laravel/laravel ./../${newProjectName}
                        fi
                        printPartition
                    fi
                    ;;
                sa)
                    clear
                    # 檢查當前專案存在
                    if [[ $(existedCurrentProject) == 0 ]] ; then
                        showError "\033[37;41m沒有執行中的專案\033[0m"
                        continue
                    fi

                    newProjectDockerCompose=$(cd "$(dirname "$0")";pwd)/project/${_CURRENT_PROJECT_NAME}/docker-compose.yml
                    cat ${newProjectDockerCompose} | more
                    pressAnyKeyToContinue
                    continue
                    ;;
                img)
                    clear
                    printFace
                    # 顯示所有 image
                    docker images
                    pressAnyKeyToContinue
                    ;;
                *)
                    clear
                    ;;
            esac
            ;;
        *)
            clear
            ;;
    esac
done
