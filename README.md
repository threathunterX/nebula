> # ⚠️ 本仓库已归档 —— Nebula 1.x 历史版本
>
> **本项目已停止维护,请勿用于生产环境。**
>
> Nebula 1.x 于 2019 年开源,此后代码未再更新。其依赖的技术栈(Python 2、
> OpenResty 1.11、Esper 6、jackson 1.9、commons-collections 3.2.1 等)均已
> 停止支持并存在已知漏洞,其中 commons-collections 3.2.1 含经典反序列化利用链。
>
> ### 👉 新版本:[Nebula 2.0](https://github.com/threathunterX/nebula2)
>
> 2.0 基于 Flink 重写,继承了 1.x 的全部风控领域资产(17 个事件模型、
> 253 个统计变量、170 条策略模板),并解决了 1.x 的架构与安全问题。
> 目前处于开发阶段,进展见新仓库。
>
> ### 关于本仓库的当前状态
>
> - 已清理历史遗留的凭据、内部地址与示例数据中的第三方信息;配置中的口令
>   已替换为 `CHANGE_ME_*` 占位符
> - 仓库保留公开,仅作历史存档与设计参考
> - **注意**:清理仅作用于当前代码,git 历史中仍保留原始内容;此前 fork
>   出去的副本亦不受影响
>
> ### 构建说明
>
> 本仓库通过 git submodule 引用 13 个组件仓库,这些组件仓库现已转为私有,
> 因此 `git submodule update` 会失败。即使能拉取,本项目也无法构建 —— 它
> 依赖的私有 PyPI 源与若干未提交的构建产物均已不可用。请以 2.0 为准。

---

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

![](http://ww1.sinaimg.cn/large/66d0828fgy1g1p9h25nhpj21cs0bkwzg.jpg)


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
    * [运营决策](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.5.md)
    * [策略配置](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.6.md)
    * [日志解析](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.7.md)
    * [脚本定制](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3/section3.8.md)
* [星云系统配置功能](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section4.md)
* [阻断星云中发现的风险](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section5.md)
    
## 设计理念

* [数据采集](https://github.com/threathunterX/nebula_doc/blob/master/chapter4/section1.md)
* [数据分析](https://github.com/threathunterX/nebula_doc/blob/master/chapter4/section2.md)
* [架构设计](https://github.com/threathunterX/nebula_doc/blob/master/chapter4/section3.md)

## 二次开发

* [Sniffer原理及驱动定制](https://github.com/threathunterX/nebula_doc/blob/master/chapter5/section1.md)
* [nginx+lua+kafka 驱动介绍](https://github.com/threathunterX/nebula_doc/blob/master/chapter5/section2.md)
* [Sniffer测试以及debug](https://github.com/threathunterX/nebula_doc/blob/master/chapter5/section3.md)

## 更新说明

** 商业版代码在持续更新中，并有以下提升：

1. 增加api、logstash、rabbitmq等10+种流量捕获接入方式
2. 线性扩展能力，以保证任何规模的数据量都可以处理
3. 无单点故障，高可靠，以保证运营商级的服务
4. 其他bug修复以及改进见下表

## 授权说明

威胁猎人团队2016年成立，核心团队成员均来自于国内一线互联网企业安全部门。我们的团队有来自情报分析、数据分析、业务风控、逆向、反欺诈等领域的资深专家，拥有多年黑产研究对抗经验。当您需要使用Github上的nebula代码时，**建议您购买商业授权**，获取商业授权后可以收到我们提供的nebula商业版全部源代码， 以及我们专业安全团队的协助。`购买商业授权为您节省大量开发、测试和完善时间，让您有更多时间用于创新及盈利`。

<br/>
负责人：卡卡<br/>
微信号：imakaka<br/>

## 需求定制

威胁猎人提供基于nebula的需求咨询与功能开发定制，即使您不懂技术，也可以根据您的需求为您定制成品

## 商业版代码更新内容

**2019-7-25**

4、修复mac上部署sniffer，bro驱动起不来的bug<br/>
3、修复部分界面展示异常bug<br/>
2、修复正常流量统计不实时bug<br/>
1、修复偶尔断流bug<br/>






