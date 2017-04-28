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

# Stored Procedures

# Triggers

# Insert Statements
INSERT INTO location (location_name, lat, lng) VALUES
('Hallgrímskirkja', 64.1425650000, -21.9278090000),
('Tækniskólinn - Skólavörðuholti', 64.1420920000, -21.9255880000);