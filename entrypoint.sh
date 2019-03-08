#!/bin/bash
set -e

export LC_ALL=zh_CN.UTF-8
adjust_memory()
{
    if [[ $Xmx && $Xmx && $Xmn ]]; then
        echo -Xmx=$Xmx -Xmx=$Xmx -Xmn=$Xmn
        sed -i s/-Xms.*/-Xms${Xms}/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh
        sed -i s/-Xmx.*/-Xmx${Xms}/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh
        sed -i s/-Xmn.*/-Xmn${Xms}/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh
        return
    fi
    
    memory_size=`free -g  | grep 'Mem:' | awk '{print $2}'`
    if [[ $memory_size -lt 2 ]]; then
        # 小于2g
        echo -Xmx=512m -Xmx=512m -Xmn=128m
        sed -i s/-Xms.*/-Xms512m/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh
        sed -i s/-Xmx.*/-Xmx512m/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh
        sed -i s/-Xmn.*/-Xmn128m/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh   
    elif [[ $memory_size -lt 16 ]]; then
        # 大于2g  小于16g
        heap=`expr $memory_size / 4`
        Xms=${heap}g
        Xmx=${heap}g
        Xmn= 
        if [[ ${heap} -lt 4 ]]; then
            Xmn=`expr ${heap} \* 1000 / 4`m
        else
            Xmn=`expr ${heap} / 4`g
        fi
        echo -Xmx=$Xmx -Xmx=$Xmx -Xmn=$Xmn
        sed -i s/-Xms.*/-Xms${Xms}/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh
        sed -i s/-Xmx.*/-Xmx${Xms}/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh
        sed -i s/-Xmn.*/-Xmn${Xms}/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh 
    else
        # 大于16g
        echo -Xmx=8g -Xmx=8g -Xmn=3g
        sed -i s/-Xms.*/-Xms8g/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh
        sed -i s/-Xmx.*/-Xmx8g/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh
        sed -i s/-Xmn.*/-Xmn3g/ /home/threathunter/nebula/nebula-onlineserver/start_sync.sh 
    fi
}

adjust_memory

exec "$@"
