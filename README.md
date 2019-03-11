
# TH-Nebula(星云)业务风控系统
风控系统的本质是为了能够让企业有能力主动发现业务风险，并快速的实施攻防对抗，星云采用旁路流量的方式进行数据采集，无需在业务逻辑上做数据埋点或侵入，同时支持本地私有化部署和`Docker`镜像云端部署；出于数据隐私和敏感性的考虑，我们不做任何数据的上传；  
  
另外考虑到部分使用者风控经验不足，星云会提供基础的风控策略模板，使用者可以结合业务实际情况，灵活的进行配置和调整。考虑到攻防对抗的时效性，策略调整之后实时生效，无需重新编译和上线。  
  
  
# 功能
- 1. 总览：观察网站流量和风险事件的情况
- 2. 风险名单管理：由你设置的某个具体的策略出发而产生，风险名单管理页面展示了风险名单的列别，通过这个页面可以进行风险名单的查询、删除和人工添加等操作。
- 3. 风险事件管理：风险事件由一组关联风险名单的基础事件组成，风险事件可以对不同的攻击进行整理成组，以便分析人员快速的针对一组风险事件进行查看。
- 4. 风险分析：风险分析页面提供了`IP`、`USER`、`PAGE`、`DEVICEID`四个维度的分析视角、允许分析人员通过不同的维度去查看某个`IP`、用户、设备或页面的细节以还原风险事件的整个流程。
- 5. 日志查询：通过自定义的方式去搜索历史日志中的数据
- 6. 策略管理：提供了可视化策略编辑功能，允许用户通过界面方式创建或编辑策略，并且可通过对策略状态的编辑快速的测试策略的有效程度，以及生产策略的下限。

# 文档
* [简介](https://github.com/threathunterX/nebula_doc/blob/master/Introduction.md)
* [1. 安装](https://github.com/threathunterX/nebula_doc/blob/master/chapter1/section0.md)
    * [1.1. 二进制安装](https://github.com/threathunterX/nebula_doc/blob/master/chapter1/section1.md)
    * [1.2. 源码安装](https://github.com/threathunterX/nebula_doc/blob/master/chapter1/section2.md)
* [2. 使用手册](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section0.md)
    * [2.1. 快速入门](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section1.md)
    * [2.2. 流量导入](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section2.md)
    * [2.3. 业务对接](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section3/section3.0.md)
        * [2.3.1. 场景介绍](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section3/section3.1.md)
        * [2.3.2. 事件介绍](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section3/section3.2.md)
        * [2.3.3. 变量介绍](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section3/section3.3.md)
        * [2.3.4. 规则梳理](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section3/section3.4.md)
        * [2.3.5. 脚本定制](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section3/section3.5.md)
        * [2.3.6. 策略配置](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section3/section3.6.md)
        * [2.3.7. 运营决策](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section3/section3.7.md)
        * [2.3.8. 规则迭代](https://github.com/threathunterX/nebula_doc/blob/master/chapter2/section3/section3.8.md)
* [3. 设计理念](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section0.md)
    * [3.1. 数据采集](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section1.md)
    * [3.2. 数据分析](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section2.md)
    * [3.3. 架构设计](https://github.com/threathunterX/nebula_doc/blob/master/chapter3/section3.md)
* [4. 实践经验](https://github.com/threathunterX/nebula_doc/blob/master/chapter4/section0.md)
* [5. 二次开发](https://github.com/threathunterX/nebula_doc/blob/master/chapter5/section0.md)
* [6. FAQ](https://github.com/threathunterX/nebula_doc/blob/master/chapter6/section0.md)

# 最后

与黑灰产的多年对抗中，我们看到了黑灰产无数次的狂欢，也看到了太多企业遭受攻击后的无奈和辛酸。但是目前整个互联网行业中的风控系统基础设施普及率还不到5%。通过开源，我们希望能让更多人意识到风控的重要性，能以更低的成本，完成风控体系从无到有的搭建。黑灰产已经是一个分工明确，合作紧密的“庞然大物”，而安全行业绝大多数仍处于相对封闭，各自为战的状态。虽然协同合作已经是行业共识，但一直缺乏有效的举措。通过开源星云业务风控系统，我们希望走出这一步，集结社区力量，让更多的安全从业者可以参与进来，贡献自己的力量。

# 联系我们

![5c85c6dae61ba.png](https://i.loli.net/2019/03/11/5c85c6dae61ba.png)

扫描下方二维码添加威胁猎人小助手，邀请您加入星云风控系统反馈群，如果您有在部署上的任何问题，可以随时与我们联系。 

![kzjzQO.png](https://s2.ax1x.com/2019/03/08/kzjzQO.png)


