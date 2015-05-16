
DROP TABLE IF EXISTS `ccake`.`social_profiles`;


CREATE TABLE `ccake`.`social_profiles` (
	`id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`user_id` int(10) UNSIGNED DEFAULT NULL,
	`social_network_name` varchar(64) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
	`social_network_id` varchar(128) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
	`email` varchar(128) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`display_name` varchar(128) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`first_name` varchar(128) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`last_name` varchar(128) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`link` varchar(512) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`picture` varchar(512) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`created` datetime DEFAULT NULL,
	`modified` datetime DEFAULT NULL,
	`status` tinyint(1) DEFAULT '1' NOT NULL,	PRIMARY KEY  (`id`)) 	DEFAULT CHARSET=latin1,
	COLLATE=latin1_swedish_ci,
	ENGINE=InnoDB;
