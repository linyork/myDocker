#!/bin/bash
BASEDIR=$(dirname "$0")
cd "${BASEDIR}/.."

showVersion(){
    printf "\E[0;33m"
    echo "__     __           _       _____                _               "
    echo "\ \   / /          | |     |  __ \              | |              "
    echo " \ \_/ /___   _ __ | | __  | |  | |  ___    ___ | | __ ___  _ __ "
    echo "  \   // _ \ | '__|| |/ /  | |  | | / _ \  / __|| |/ // _ \| '__|"
    echo "   | || (_) || |   |   <   | |__| || (_) || (__ |   <|  __/| |   "
    echo '   |_| \___/ |_|   |_|\_\  |_____/  \___/  \___||_|\_\\___||_|   '
    echo ' '
    echo -e "Welcome to use York's Docker Interface. v1.1.1"
    printf "\E[0m"
    echo "York Docker v1.1.1 (built: Jun 2019)"
    echo "Copyright (c) 2018-2019 Heat & York"
}
showHelp(){
    echo "Usage: codo [option]"
    echo ""
    echo -e "  [install] \t Install codo bin"
    echo -e "  [ll] \t\t Display project list"
    echo -e "  [r]  \t\t Start up"
    echo -e "  [l]  \t\t Display docker state"
    echo -e "  [s]  \t\t Display project status"
    echo -e "  [i]  \t\t Into the container"
    echo -e "  [o]  \t\t Open project from browser"
    echo -e "  [c]  \t\t Shut down"
    echo -e "  [d]  \t\t Delete project"
    echo -e "  [new] \t Add new project"
    echo -e "  [v]  \t\t Version number"
}
showProjectList(){
    # 讀取所有 project
    rawProjectList=$(ls './project')
    # 去掉 example 資料夾
    declare -a _PROJECT_LIST=(${rawProjectList/_example/})
    echo -e "\033[0;32m編號\t專案名稱\033[0m"
    # 依序顯示
    for i in ${!_PROJECT_LIST[@]}
    do
        projectName=${_PROJECT_LIST[${i}]}
        echo -e "${i}\t${projectName}"
    done
}
getProjectName(){
    # 讀取所有 project
    rawProjectList=$(ls './project')
    # 去掉 example 資料夾
    declare -a _PROJECT_LIST=(${rawProjectList/_example/})
    # 取得 project name
    echo ${_PROJECT_LIST[${1}]}

}
close(){
    # docker 操作
    id=($(docker ps -a -q))
    if [[ ${id} ]]
    then
        docker rm -f $(docker ps -a -q) | awk '{print "移除 \""$1"\" Container"}'
    fi
}

option1=${1}
# 所有指令
case $option1 in
    install)
        echo "export PATH="\$PATH:$(pwd)/bin"" >> ~/.bash_profile
        chmod u+x $(pwd)"/bin/codo"
        echo "Export codo bin  from ~/.bash_profile Success."
        ;;
    v)
        showVersion
        ;;
    ll)
        showProjectList
        ;;
    r)
        close
        # 顯示清單
        showProjectList
        # 詢問
        read -p "要啟動哪一個專案: " projectNumber
        # 未輸入編號狀況
        if [[ ${projectNumber} == "" ]];then
            showHelp
            continue
        fi
        # 取得名稱
        projectName=$(getProjectName ${projectNumber})
        # 啟動專案
        _SELECTED_PROJECT_YML="./project/${projectName}/docker-compose.yml"
        docker-compose -p core_docker --project-directory . -f ${_SELECTED_PROJECT_YML} up -d
        ;;
    l)
        # 執行 command
        docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.ID}}"
        ;;
    s)
        # 顯示清單
        showProjectList
        # 詢問
        read -p "要查詢哪一個專案: " projectNumber
        # 未輸入編號狀況
        if [[ ${projectNumber} == "" ]];then
            showHelp
            continue
        fi
        # 取得名稱
        projectName=$(getProjectName ${projectNumber})
        # 顯示專案狀態
        newProjectDockerCompose=$(pwd)/project/${projectName}/docker-compose.yml
        echo -e "\033[32mProject Name: \033[0m"${projectName}
        echo -e "\033[32mLocal Domain: \033[0m"$(sed -n 2,2p ${newProjectDockerCompose} | sed 's/#//g')
        cat ${newProjectDockerCompose} | grep -n "container_name" | awk '{sub(/container_name:/,"\033[32mContainer:\033[0m")}{print $2$3}'
        cat ${newProjectDockerCompose} | grep -n "PMA_PASSWORD" | awk '{sub(/PMA_PASSWORD:/,"\033[32mCloudDbPassword:\033[0m")}{print $2$3}'
        ;;
    i)
        # 查看目前的 container
        docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.ID}}"
        echo  -e "\033[37;41m請輸入 Container Name(ex: apache)\033[0m"
        read -p "選擇欲進入的容器:" containerName
        #  進入 container
        if [[ ${containerName} ]]; then
            docker exec -it ${containerName} bash
        fi
        ;;
    o)
        # 顯示清單
        showProjectList
        # 詢問
        read -p "要查詢哪一個專案: " projectNumber
        # 未輸入編號狀況
        if [[ ${projectNumber} == "" ]];then
            showHelp
            continue
        fi
        # 取得名稱
        projectName=$(getProjectName ${projectNumber})
        # 進入專案
        newProjectDockerCompose=$(pwd)/project/${projectName}/docker-compose.yml
        domain=$(sed -n 2,2p ${newProjectDockerCompose} | sed 's/#//g')
        /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome "https://"${domain}
        ;;
    c)
        close
        ;;
    d)
        # 顯示清單
        showProjectList
        # 詢問
        read -p "要查詢哪一個專案: " projectNumber
        # 未輸入編號狀況
        if [[ ${projectNumber} == "" ]];then
            showHelp
            continue
        fi
        # 取得名稱
        projectName=$(getProjectName ${projectNumber})

        # 詢問是否刪除該專案document
        printf "\E[0;31m"
        echo -e "請問是否刪除專案 ${projectName} 的檔案(y/n)"
        read -p "輸入: " yesno
        printf "\E[0m"
        if [[ ${yesno} = 'y' || ${yesno} = 'Y' ]]; then
            pwd
        fi
        printf "\E[0m"

        # 詢問是否刪除該專案
        printf "\E[0;31m"
        echo "請問是否刪除專案 ${projectName} 的環境(y/n)"
        read -p "輸入: " yesno
        printf "\E[0m"
        if [[ ${yesno} = 'y' || ${yesno} = 'Y' ]]; then
            rm -r ./project/${_SELECTED_PROJECT_NAME}
            echo "已刪除"
        fi

        ;;
    new)
        # 詢問專案名稱
        read -p "請輸入專案名稱: " newPjName

        # 詢問專案path
        echo "請輸入專案位置(可輸入相對位置) 不填寫直接按Enter預設位置為(./../{{PROJECT_NAME}})"
        read -p "專案位置: " newPjPath

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
            baseDir=$(pwd);
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
            newProjectLocalDomain=local.${newProjectName}.jp;
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

            #  詢問是否開啟 laravel 專案
            read -p "是否開啟laravel 專案(y/n): " laravel
            if [[ "$laravel" == "y" ]]; then
                composer create-project --prefer-dist laravel/laravel ./../${newProjectName}
            fi
        fi
        ;;
    h)
        showHelp
        ;;
    *)
        showHelp
        ;;
esac