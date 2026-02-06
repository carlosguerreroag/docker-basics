CREATE TABLE IF NOT EXISTS `ftp_groups` (
    `group_name` varchar(16) COLLATE utf8_general_ci NOT NULL,
    `gid` smallint(6) NOT NULL DEFAULT '5500',
    `members` varchar(16) COLLATE utf8_general_ci NOT NULL,
    KEY `group_name` (`group_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS `ftp_users` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `user_name` varchar(32) COLLATE utf8_general_ci NOT NULL DEFAULT '',
    `password` varchar(32) COLLATE utf8_general_ci NOT NULL DEFAULT '',
    `uid` smallint(6) NOT NULL DEFAULT '5500',
    `gid` smallint(6) NOT NULL DEFAULT '5500',
    `home_directory` varchar(255) COLLATE utf8_general_ci NOT NULL DEFAULT '',
    `shell` varchar(16) COLLATE utf8_general_ci NOT NULL DEFAULT '/sbin/nologin',
    `count` int(11) NOT NULL DEFAULT '0',
    `accessed_at` timestamp NULL,
    `modified_at` timestamp NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `userid` (`user_name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
