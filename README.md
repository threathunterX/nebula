## 星云（TH-Nebula)业务风控系统介绍：

### 简介：

星云风控系统是一套互联网风控分析和检测平台，可以对企业遇到的各种业务风险场景进行细致的分析，找出威胁流量，帮助用户减少损失。星云采用旁路流量的方式进行数据采集，无需在业务逻辑上做数据埋点或侵入，同时支持本地私有化部署和Docker镜像云端部署。
另外考虑到部分使用者风控经验不足，星云会提供基础的风控策略模板（基础内置五大风险场景：访客风险、帐号风险、支付风险、订单风险和营销风险），使用者可以结合业务实际情况，灵活的进行配置和调整。考虑到攻防对抗的时效性，策略调整之后实时生效，无需重新编译和上线。

### 产品特点：

**1.轻量级部署** 

星云采用完全旁路流量解析的方式来采集业务信息，企业只需要与运维配合即可完成部署。值得一提的是，即使在业务增加、变化的情况下企业都可快速地获取到网络访问、登陆、注册、下单、参与活动等业务行为。 

**2.内置风险识别规则，简单易用** 

在“星云”上内置了大量业务场景下的攻防规则，并采用可视化规则编辑的方式，企业可以快速编辑策略并进行实际环境下的测试。 

**3.无埋点，无敏感数据泄漏风险** 

星云不需要企业研发埋点即可实现访问、登陆、注册、信息修改等的数据实时采集，无敏感数据外泄风险，更好的保护企业数据隐私。

### 解决问题：

风控系统的本质是为了能够让企业有能力主动发现业务风险，我们希望星云的开源能让企业能够快速的度过早期的基础建设阶段，进入到攻防效率提升阶。基于星云风控系统，企业可以针对不同的业务场景进行攻防对抗。 



## 快速接入

* [快速入门](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section1.md)
    * [星云系统架构](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section1/section1.1.md)
    * [星云工作原理](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section1/section1.2.md)
* [安装](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section2.md)
    * [配置要求](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section2/section2.1.md)
    * [二进制安装](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section2/section2.2.md)
    * [源码安装](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section2/section2.3.md)
    
## 使用手册

* [基本功能](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section1.md)
* [常见使用指引](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section2.md)
* [业务对接](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3.md)
    * [场景介绍](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.1.md)
    * [事件介绍](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.2.md)
    * [变量介绍](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.3.md)
    * [规则梳理](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.4.md)
    * [脚本定制](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.5.md)
    * [策略配置](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.6.md)
    * [运营决策](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.7.md)
    * [规则迭代](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.8.md)
* [星云系统配置功能](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section4.md)
* [阻断星云中发现的风险](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section5.md)
    
## 设计理念

* [数据采集](https://github.com/threathunterX/nebula_doc/blob/master/chapter4/section1.md)
* [数据分析](https://github.com/threathunterX/nebula_doc/blob/master/chapter4/section2.md)
* [架构设计](https://github.com/threathunterX/nebula_doc/blob/master/chapter4/section3.md)

## 二次开发

* [Sniffer原理及驱动定制](https://github.com/threathunterX/nebula_doc/blob/master/chapter5/section1.md)

## 模拟演示
下面是我们在阿里云上部署的一套星云，用户可以利用以下链接和账号密码登录，进行功能的查看。（注意该页面资源较多，请耐心等待加载）

地址：http://112.74.58.210:9001

账号：threathunter_test

密码：threathunter


## 特别感谢

感谢GitHub ID：nancheal、icxcoffee、kerlingcode、zhujunlu、emmaaii、bsmial4、allanxia、lilololi的用户给我们提的Issue，我们会尽快跟进和修复相关问题

感谢340位用户的Star

感谢249为Followers

官网地址：www.threathuter.cn
技术支持：添加威胁猎人助手，邀请您加入星云风控系统沟通群。
![kzjzQO.png](https://s2.ax1x.com/2019/03/08/kzjzQO.png)
