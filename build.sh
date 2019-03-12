PRG="$0"
while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done
WORK_DIR=`dirname "$PRG"`

update_submodules()
{
    cd $WORK_DIR
    # 拉取所有子模块代码更新
    git submodule update --remote
    echo "update submodules done"
}

build_image()
{
    cd $WORK_DIR
    if [ -z "$version" ];then
        echo "invalid version($version)"
        exit 0
    else
        echo "Docker Image Version = nabula:$version"
        docker build -t nebula:$version .
    fi
}

build_apps()
{   

    cd $WORK_DIR/src/
    
    echo "======install threathunter_common_java v1.0.1 ======"
    cd java_lib/threathunter_common_java/1.0.1/ && mvn clean install -Dmaven.test.skip=true && cd ../../../
    
    echo "======install threathunter_common_java v1.0.2 ======"
    cd java_lib/threathunter_common_java/1.0.2/ && mvn clean install -Dmaven.test.skip=true && cd ../../../
    
    echo "======install threathunter_common_java v1.0.3 ======"
    cd java_lib/threathunter_common_java/1.0.3/ && mvn clean install -Dmaven.test.skip=true && cd ../../../
    
    echo "======install threathunter_common_java v1.1.0 ======"
    cd java_lib/threathunter_common_java/1.1.0/ && mvn clean install -Dmaven.test.skip=true && cd ../../../
   
    echo "====== install threathunter_basictools_java v1.1.0 ======"
    cd java_lib/threathunter_basictools_java/ && mvn clean install -Dmaven.test.skip=true && cd ../../
    
    echo "====== install babel_java v1.1.0======"
    cd java_lib/babel_java && mvn clean install -Dmaven.test.skip=true && cd ../../
    
    echo "====== install greatdant ======"
    cd greatdant &&  mvn clean install -Dmaven.test.skip=true && cd ../ 

    echo "====== install labrador ======"
    cd labrador &&  mvn clean install -Dmaven.test.skip=true && cd ../ 
    
    echo "====== install apiserver ======"
    cd apiserver &&  mvn clean install -Dmaven.test.skip=true && cd ../ 
    
    echo "====== offline ======"
    cd offline &&  mvn clean install -Dmaven.test.skip=true -P prod && cd ../
    
    echo "====== install greyhound ======"
    cd greyhound  &&  mvn clean install -Dmaven.test.skip=true && cd ../ 
    
    echo "====== install online ======"
    cd online &&  mvn clean install -Dmaven.test.skip=true && cd ../ 
   
    cd BChart

    echo "====== package BChart  ======"
    mv .git .git.bak
    npm install
    npm run install && npm pack
    rm -rf ./.git && mv .git.bak .git
    cd ../

    echo "====== package nebula_fe  ======"
    cp BChart/BChart-1.1.16.tgz nebula_fe && cd nebula_fe
    mv .git .git.bak
    npm install
    npm install BChart-1.1.16.tgz
    cd scripts && sh build.sh
    cd ../
    rm -rf ./.git && mv .git.bak .git
    cd ../

    echo "====== module copying ======"
    # copy java模块
    echo "copy java module"
    cp offline/target/nebula_offline_slot-prod.tar.gz ../nebula_apps/
    cp online/nebula-onlineserver/target/nebula-onlineserver.tar.gz ../nebula_apps/
    cp apiserver/web-manager/target/java-web-release.tar.gz ../nebula_apps/
    cp labrador/application/target/labrador-release.tar.gz ../nebula_apps/
    # copy python模块
    echo "copy python module"
    cp -r python_lib/ ../nebula_apps/
    cp -r nebula_db_writer/ ../nebula_apps/
    cp -r nebula_query_web/ ../nebula_apps/
    cp -r nebula_web/ ../nebula_apps/
    # copy 前端展示模块
    echo "copy javascript module"
    cp nebula_fe/build/nebula_fe.tar.gz ../nebula_apps/


    cd ../nebula_apps/
    
    echo "====== uncompress ======" 
    echo "uncompress java-web"
    is_exist "java-web"
    tar -zxf java-web-release.tar.gz
    rm -rf ./java-web-release.tar.gz
    
    echo "uncompress labrador"
    is_exist "labrador"
    tar -zxf labrador-release.tar.gz
    rm -rf ./labrador-release.tar.gz
    
    echo "uncompress nebula-onlineserver"
    is_exist "nebula-onlineserver"
    tar -zxf nebula-onlineserver.tar.gz
    rm -rf ./nebula-onlineserver.tar.gz
    
    echo "uncompress nebula_offline_slot"
    is_exist "nebula_offline_slot"
    tar -zxf nebula_offline_slot-prod.tar.gz
    rm -rf ./nebula_offline_slot-prod.tar.gz
    
    echo "uncompress nebula_fe"
    is_exist "nebula_fe"
    tar -zxf ./nebula_fe.tar.gz -C ./nebula_fe
    rm -rf ./nebula_fe.tar.gz
    cd $WORK_DIR
}

is_exist(){
    if [ ! -d "$1/" ];then
        mkdir $1
    else
        sudo rm -rf $1 && mkdir $1
    fi
}

build_help()
{
    echo "Usage:"
    echo "-u|--update: update submodules"
    echo "-v|--version: version"
    echo "--apps: build all apps"
    echo "--image: build docker imageps"
    echo "--all: build apps and docker image"
}

# first round for config
OLDINPUT=("$*")
while [ -n "$1" ]
do
    case "$1" in
    -h|--help) build_help; exit 0;;
    -u|--update) 
        update_submodules; shift 1;;
    -v|--version) 
        version=$2; shift 2;;
    --apps)
        shift 1;;
    --image)
        shift 1;;
    --all)
        shift 1;;
    *)
        echo "invalid options $1"; build_help; exit ;;
    esac
done

# second round for commands
set -- $OLDINPUT
while [ -n "$1" ]
do
    case "$1" in
    -h|--help) build_help; exit 0;;
    -u|--update) 
        shift 1;;
    -v|--version) 
        shift 2;;
    --apps) 
        build_apps; shift 1;;
    --image) 
        build_image; shift 1;;
    --all)
        build_apps;build_image; shift 1;;
    *)
        echo "invalid options $1"; build_help; exit ;;
    esac
done

