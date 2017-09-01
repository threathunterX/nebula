CREATE TABLE `user` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `email` varchar(255) DEFAULT NULL,
      `password` varchar(255) DEFAULT NULL,
      `active` tinyint(1) DEFAULT NULL,
      `confirmed_at` datetime DEFAULT NULL,
      PRIMARY KEY (`id`),
      UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1

CREATE TABLE `roles_users` (
      `user_id` int(11) DEFAULT NULL,
      `role_id` int(11) DEFAULT NULL,
      KEY `user_id` (`user_id`),
      KEY `role_id` (`role_id`),
      CONSTRAINT `roles_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
      CONSTRAINT `roles_users_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1

CREATE TABLE `role` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(80) DEFAULT NULL,
      `description` varchar(255) DEFAULT NULL,
      PRIMARY KEY (`id`),
      UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1
