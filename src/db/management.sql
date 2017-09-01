create database if not exists db_mp_conf;
use db_mp_conf;

#活动库
create table if not exists `t_workflows` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `status`  int(3) DEFAULT 0 comment '0-deactive 1-active',
    `name` char(64) NOT NULL,
    `ctime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `event` char(32) NOT NULL comment 'eg: "login", "register, ..',  
    `affecting` char(32) NOT NULL DEFAULT 'user',
    PRIMARY KEY (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table if not exists `t_routes` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `workflowid` int(10) unsigned NOT NULL,
    `criterias`  varchar(512) NOT NULL,
    `action` int(3) DEFAULT 0 comment '1-review 2-decision',
    `reviewid` int(10) unsigned DEFAULT 0,
    `decisionid` int(10) unsigned DEFAULT 0,
    PRIMARY KEY (`id`),
    CONSTRAINT `t_workflows_id` FOREIGN KEY (`workflowid`) REFERENCES `t_workflows` (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table if not exists `t_decisions` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `name` char(64) NOT NULL,
    `category` char(32) NOT NULL DEFAULT 'Block' comment 'Block, Watch, Accept',
    `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `create_by` char(64) NOT NULL DEFAULT '',
    `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_by` char(64) NOT NULL DEFAULT '',
    PRIMARY KEY (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


