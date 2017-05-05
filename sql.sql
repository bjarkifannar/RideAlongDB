USE getaride;

# Tables
CREATE TABLE IF NOT EXISTS notifications (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT(10) UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    sent TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    seen BOOLEAN NOT NULL DEFAULT 0,
    from_user_id INT(10) UNSIGNED NULL DEFAULT NULL,
    matched BOOLEAN DEFAULT NULL,
    action_taken BOOLEAN NOT NULL DEFAULT 0,
	FOREIGN KEY fk_from_user_id_notifications (from_user_id)
		REFERENCES users (id)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	FOREIGN KEY fk_user_id_notifications (user_id)
		REFERENCES users (id)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS location (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(255) NOT NULL,
    lat DECIMAL(12, 2) NOT NULL,
    lng DECIMAL(13, 3) NOT NULL
);

CREATE TABLE IF NOT EXISTS ride (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    to_id INT NOT NULL,
    from_id INT NOT NULL,
    message VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    available BOOLEAN NOT NULL DEFAULT 1,
    is_request BOOLEAN NOT NULL,
    FOREIGN KEY (to_id)
		REFERENCES location(id),
	FOREIGN KEY (from_id)
		REFERENCES location(id)
);

CREATE TABLE IF NOT EXISTS `planner` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plan_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=18 ;

CREATE TABLE IF NOT EXISTS `dayplanner` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `day` int(11) NOT NULL,
  `leaving` varchar(5) COLLATE utf8_unicode_ci NOT NULL,
  `to_id` int(11) NOT NULL,
  `from_id` int(11) NOT NULL,
  `plan_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `to_id` (`to_id`),
  KEY `from_id` (`from_id`),
  KEY `user_id` (`plan_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=20 ;

ALTER TABLE `planner`
  ADD CONSTRAINT `fk_user_id_plan` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `dayplanner`
  ADD CONSTRAINT `fk_from_id_week` FOREIGN KEY (`from_id`) REFERENCES `location` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_plan_id` FOREIGN KEY (`plan_id`) REFERENCES `planner` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_to_id_week` FOREIGN KEY (`to_id`) REFERENCES `location` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE `social_accounts` ADD `user_img` TEXT NULL DEFAULT NULL AFTER `provider`;

ALTER TABLE `social_accounts`
  ADD CONSTRAINT `fk_social_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

# Stored Procedures
DELIMITER //

CREATE PROCEDURE send_notification
	(in_user_id INT(10) UNSIGNED, in_title VARCHAR(255), in_message TEXT, in_from_user_id INT(10) UNSIGNED, in_matched BOOLEAN)
BEGIN
	INSERT INTO notifications
		(user_id, title, message, from_user_id, matched)
        VALUES (in_user_id, in_title, in_message, in_from_user_id, in_matched);
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_schedule 
		(in_user_id INT(11) UNSIGNED, in_day INT(11))
BEGIN
SELECT weekplanner.day AS day, 
	weekplanner.leaving AS leaving, 
	weekplanner.to_id AS to_id, 
	weekplanner.from_id AS from_id, 
	weekplanner.plan_id AS plan_id,
	planner.id AS id
	FROM weekplanner
	JOIN planner ON weekplanner.plan_id=planner.id
	WHERE planner.user_id = in_user_id AND weekplanner.day = in_day
	ORDER BY day;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_notification_list
	(in_user_id INT(10) UNSIGNED)
BEGIN
	SELECT id, title, sent, seen FROM notifications WHERE user_id=in_user_id ORDER BY id DESC;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE `get_plan_info` (IN `in_user_id` INT(10) UNSIGNED)
	NOT DETERMINISTIC
	CONTAINS SQL
	SQL SECURITY DEFINER
BEGIN
	SELECT dayplanner.day AS day,
			dayplanner.leaving AS leaving,
			dayplanner.to_id AS to_id,
			dayplanner.from_id AS from_id,
			dayplanner.plan_id AS plan_id,
			planner.id AS id
				FROM dayplanner
					JOIN planner ON dayplanner.plan_id=planner.id
				WHERE dayplanner.plan_id = in_user_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE `get_ride_info`
		(IN `in_to_id` INT(11), IN `in_from_id` INT(11)) 
		NOT DETERMINISTIC 
		CONTAINS SQL 
		SQL SECURITY DEFINER 
BEGIN 
	SELECT ride.message AS ride_message, 
			ride.updated_at AS ride_time, 
			users.id AS user_id, 
			users.name AS user_name 
				FROM ride 
					INNER JOIN users ON ride.user_id = users.id 
				WHERE ride.to_id = in_to_id AND ride.from_id = in_from_id AND ride.available = 1 
				ORDER BY ride.id ASC; 
END //

DELIMITER ;

DELIMITER //
	
CREATE PROCEDURE `get_dayplan`(IN `in_user_id` INT(10) UNSIGNED, IN `in_day` INT(11))
		NOT DETERMINISTIC 
		CONTAINS SQL 
		SQL SECURITY DEFINER 
BEGIN 
	SELECT dayplanner.day AS day, 
		dayplanner.leaving AS leaving, 
		dayplanner.to_id AS to_id, 
		dayplanner.from_id AS from_id, 
		dayplanner.plan_id AS plan_id, 
		planner.id AS id 
			FROM dayplanner 
				JOIN planner ON dayplanner.plan_id=planner.id 
			WHERE dayplanner.day = in_day AND planner.user_id = in_user_id; 
END //
	
DELIMITER ;

# Triggers

DELIMITER //

CREATE TRIGGER insert_img_link BEFORE INSERT ON social_accounts
FOR EACH ROW
	BEGIN
    	IF NEW.provider = 'facebook' THEN
			SET NEW.user_img = CONCAT('http://graph.facebook.com/', NEW.provider_user_id, '/picture?width=300');
        END IF;
    END //

DELIMITER ;

# Insert Statements
INSERT INTO location (location_name, lat, lng) VALUES
	('Hallgrímskirkja', 64.1425650000, -21.9278090000),
	('Tækniskólinn - Skólavörðuholti', 64.1420920000, -21.9255880000);

INSERT INTO notifications (user_id, title, message) VALUES (2, 'Test', 'This is a test notification!');

INSERT INTO notifications (user_id, title, message) VALUES (2, 'Test 2', 'This is the 2nd test notification!');

INSERT INTO notifications (user_id, title, message) VALUES (1, 'Testing', 'This is a test notification!');