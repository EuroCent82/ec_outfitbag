-- =============================================================================
-- ec_outfitbag — Datenbank-Schema (ESX / QBCore / QBox)
-- Resource: ec_outfitbag
-- Sprache:  Config.Language in shared/config.lua (locales/*.lua)
-- Import je Server:
--   ESX:    mysql -u root ESXLegacy_F9E16F < install.sql
--   QBCore: mysql -u root QBCore_0E64EF < install.sql
--   QBox:   mysql -u root Qbox_0E6853 < install.sql
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `ec_outfitbag_profiles` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(128) NOT NULL COMMENT 'Charakter-ID (ESX identifier / QB citizenid)',
    `max_slots` INT NOT NULL DEFAULT 5 COMMENT 'Max. Outfit-Slots für diesen Charakter',
    `active_slot` INT NULL DEFAULT NULL COMMENT 'Zuletzt aktives Outfit (Slot-Nr.)',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_ecofb_profiles_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ec_outfitbag_outfits` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(128) NOT NULL COMMENT 'Besitzer-Charakter',
    `slot` INT NOT NULL COMMENT 'Slot 1..max_slots',
    `name` VARCHAR(64) NOT NULL,
    `icon` VARCHAR(32) NOT NULL DEFAULT 'shirt',
    `color` VARCHAR(16) NOT NULL DEFAULT 'red',
    `appearance` JSON NOT NULL COMMENT 'Skin/Appearance JSON je Framework',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_ecofb_outfits_identifier_slot` (`identifier`, `slot`),
    KEY `idx_ecofb_outfits_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ec_outfitbag_world` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `bag_uid` VARCHAR(64) NOT NULL COMMENT 'Eindeutige Welt-Instanz',
    `owner_identifier` VARCHAR(128) NOT NULL COMMENT 'Spieler der die Tasche gelegt hat',
    `pos_x` DOUBLE NOT NULL,
    `pos_y` DOUBLE NOT NULL,
    `pos_z` DOUBLE NOT NULL,
    `heading` DOUBLE NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_ecofb_world_bag_uid` (`bag_uid`),
    KEY `idx_ecofb_world_owner` (`owner_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
