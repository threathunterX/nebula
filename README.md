# Nebula "星云"业务风控系统

## 系统说明
#### 该系统目前定位为解决以下业务风控核心问题。

  恶意注册（Account Abuse）  
  账号被盗（Account Takeover）  
  内容欺诈（Content Abuse）  
#### 系统架构：
  ![](image/system.png  )
#### 系统组件：
  ![](image/componement.png  )
#### 工作方式：
  ![](image/workflow.png  )

## 项目说明
#### 目录结构
```
  db/                     #mysql初始化表  
  fakedata/               #伪造的用户登录日志（测试用）  
  go/  
    src/  
      /malicious_prevent  
        /automate         #风险决策控制模块  
        /mpevents         #业务接口分发模块  
        /rulengine        #数据计算模块：风险规则+风险评分  
        ...               #数据处理后台主逻辑  
  management/             #运营管理系统（flask+nginx，前后端分离）  
    app/                  #flask接口  
    config/               #nginx配置示例  
    loginapp/             #登录系统  
    static/               #html、js、css
    debug.py              
```

#### 项目部署
* 部署mysql、mongodb、redis
* mysql db初始化（db模块）， monodb日志数据生成（fakedata模块）
* gulp打包界面模块
* 部署nginx
* 启动运营管理平台python management/debug.py，配置风控决策
* \malicious_prevent：go test

## TODO
* 风险规则因子提取、风险规则制定
* 风险等级评分逻辑
* 管理平台完善



    
