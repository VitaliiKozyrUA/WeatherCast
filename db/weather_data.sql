-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 29, 2024 at 08:49 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `weather_data`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `decrypt_measurement_value` (IN `enc_key` VARCHAR(20))   BEGIN
    UPDATE `measurement`
    SET `value` = CAST(AES_DECRYPT(UNHEX(`encrypted_value`), enc_key) AS DECIMAL(10, 2)),
    encrypted_value = "";
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `encrypt_measurement_value` (IN `enc_key` VARCHAR(20))   BEGIN
    UPDATE `measurement`
    SET `encrypted_value` = HEX(AES_ENCRYPT(`value`, enc_key)),
    `value` = 0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SimulateWeatherData` ()   BEGIN
    DECLARE stationCount INT;
    DECLARE i INT DEFAULT 1;
    DECLARE randTemperature FLOAT;
    DECLARE randHumidity INT;
    DECLARE randPressure INT;
    DECLARE randCloudiness INT;
    DECLARE randWindDirection INT;
    DECLARE randWindSpeed FLOAT;
    DECLARE randRadiation FLOAT;
    DECLARE randPollution FLOAT;
    DECLARE currentTime DATETIME;

    SELECT COUNT(*) INTO stationCount FROM station;

    SET currentTime = NOW();

    WHILE i <= stationCount DO
        SET randTemperature = ROUND(RAND() * 40 - 10, 1);
        SET randHumidity = FLOOR(RAND() * 100);
        SET randPressure = FLOOR(RAND() * 50 + 750);
        SET randCloudiness = FLOOR(RAND() * 100);
        SET randWindDirection = FLOOR(RAND() * 360);
        SET randWindSpeed = ROUND(RAND() * 20, 1);
        SET randRadiation = ROUND(RAND() * 0.1, 3);
        SET randPollution = ROUND(RAND() * 50, 1);

        INSERT INTO measurement (station_id, value, timestamp, parameter_name, parameter_unit) VALUES
            (i, randTemperature, currentTime, 'Температура', '°C'),
            (i, randHumidity, currentTime, 'Вологість', '%'),
            (i, randPressure, currentTime, 'Тиск повітря', 'мм рт. ст.'),
            (i, randCloudiness, currentTime, 'Хмарність', '%'),
            (i, randWindDirection, currentTime, 'Напрямок вітру', '°'),
            (i, randWindSpeed, currentTime, 'Сила вітру', 'м/с'),
            (i, randRadiation, currentTime, 'Радіаційний фон', 'мкЗв/год'),
            (i, randPollution, currentTime, 'Забрудненість шкідливими домішками', 'мкг/м³');

        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `flat_location`
-- (See below for the actual view)
--
CREATE TABLE `flat_location` (
`country_id` smallint(6)
,`country_name` varchar(50)
,`province_id` smallint(6)
,`province_name` varchar(50)
,`region_id` smallint(6)
,`region_name` varchar(50)
,`latitude` decimal(9,6)
,`longitude` decimal(9,6)
);

-- --------------------------------------------------------

--
-- Table structure for table `location`
--

CREATE TABLE `location` (
  `location_id` smallint(6) NOT NULL,
  `parent_location_id` smallint(6) DEFAULT NULL,
  `name` varchar(50) NOT NULL,
  `lat` decimal(9,6) NOT NULL DEFAULT 0.000000,
  `lon` decimal(9,6) NOT NULL DEFAULT 0.000000
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `location`
--

INSERT INTO `location` (`location_id`, `parent_location_id`, `name`, `lat`, `lon`) VALUES
(3, NULL, 'Україна', 0.000000, 0.000000),
(5, 3, 'Полтавська', 0.000000, 0.000000),
(6, 5, 'Подільський', 49.581976, 34.576546),
(7, 5, 'Київський', 49.608658, 34.528371),
(8, 3, 'Київська', 0.000000, 0.000000),
(9, 8, 'Шевченківський', 50.464677, 30.466523),
(10, 3, 'Львівська', 0.000000, 0.000000),
(11, 10, 'Галицький', 49.832851, 24.025013),
(12, 10, 'Шевченківський', 49.857885, 24.021689);

-- --------------------------------------------------------

--
-- Table structure for table `measurement`
--

CREATE TABLE `measurement` (
  `measurement_id` int(11) NOT NULL,
  `station_id` tinyint(4) NOT NULL,
  `value` float NOT NULL,
  `timestamp` datetime NOT NULL,
  `parameter_name` varchar(50) NOT NULL,
  `parameter_unit` varchar(20) NOT NULL,
  `encrypted_value` varbinary(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci
PARTITION BY RANGE (to_days(`timestamp`))
(
PARTITION p202412 VALUES LESS THAN (739586) ENGINE=InnoDB,
PARTITION p202501 VALUES LESS THAN (739617) ENGINE=InnoDB,
PARTITION p202502 VALUES LESS THAN (739648) ENGINE=InnoDB,
PARTITION p202503 VALUES LESS THAN (739676) ENGINE=InnoDB,
PARTITION p202504 VALUES LESS THAN (739707) ENGINE=InnoDB,
PARTITION p202505 VALUES LESS THAN (739737) ENGINE=InnoDB,
PARTITION pMax VALUES LESS THAN MAXVALUE ENGINE=InnoDB
);

--
-- Dumping data for table `measurement`
--

INSERT INTO `measurement` (`measurement_id`, `station_id`, `value`, `timestamp`, `parameter_name`, `parameter_unit`, `encrypted_value`) VALUES
(0, 1, 15.7, '2024-12-26 09:35:48', 'Температура', '°C', ''),
(0, 1, 12, '2024-12-26 09:35:48', 'Вологість', '%', ''),
(0, 1, 785, '2024-12-26 09:35:48', 'Тиск повітря', 'мм рт. ст.', ''),
(0, 1, 14, '2024-12-26 09:35:48', 'Хмарність', '%', ''),
(0, 1, 216, '2024-12-26 09:35:48', 'Напрямок вітру', '°', ''),
(0, 1, 11.5, '2024-12-26 09:35:48', 'Сила вітру', 'м/с', ''),
(0, 1, 0.01, '2024-12-26 09:35:48', 'Радіаційний фон', 'мкЗв/год', ''),
(0, 1, 30.7, '2024-12-26 09:35:48', 'Забрудненість шкідливими домішками', 'мкг/м³', ''),
(0, 2, 24.8, '2024-12-26 09:35:48', 'Температура', '°C', ''),
(0, 2, 50, '2024-12-26 09:35:48', 'Вологість', '%', ''),
(0, 2, 796, '2024-12-26 09:35:48', 'Тиск повітря', 'мм рт. ст.', ''),
(0, 2, 9, '2024-12-26 09:35:48', 'Хмарність', '%', ''),
(0, 2, 252, '2024-12-26 09:35:48', 'Напрямок вітру', '°', ''),
(0, 2, 4.6, '2024-12-26 09:35:48', 'Сила вітру', 'м/с', ''),
(0, 2, 0, '2024-12-26 09:35:48', 'Радіаційний фон', 'мкЗв/год', ''),
(0, 2, 26.3, '2024-12-26 09:35:48', 'Забрудненість шкідливими домішками', 'мкг/м³', ''),
(0, 3, 10.1, '2024-12-26 09:35:48', 'Температура', '°C', ''),
(0, 3, 92, '2024-12-26 09:35:48', 'Вологість', '%', ''),
(0, 3, 756, '2024-12-26 09:35:48', 'Тиск повітря', 'мм рт. ст.', ''),
(0, 3, 89, '2024-12-26 09:35:48', 'Хмарність', '%', ''),
(0, 3, 27, '2024-12-26 09:35:48', 'Напрямок вітру', '°', ''),
(0, 3, 13.8, '2024-12-26 09:35:48', 'Сила вітру', 'м/с', ''),
(0, 3, 0.02, '2024-12-26 09:35:48', 'Радіаційний фон', 'мкЗв/год', ''),
(0, 3, 2.2, '2024-12-26 09:35:48', 'Забрудненість шкідливими домішками', 'мкг/м³', ''),
(0, 4, 12, '2024-12-26 09:35:48', 'Температура', '°C', ''),
(0, 4, 61, '2024-12-26 09:35:48', 'Вологість', '%', ''),
(0, 4, 771, '2024-12-26 09:35:48', 'Тиск повітря', 'мм рт. ст.', ''),
(0, 4, 31, '2024-12-26 09:35:48', 'Хмарність', '%', ''),
(0, 4, 102, '2024-12-26 09:35:48', 'Напрямок вітру', '°', ''),
(0, 4, 9.3, '2024-12-26 09:35:48', 'Сила вітру', 'м/с', ''),
(0, 4, 0.05, '2024-12-26 09:35:48', 'Радіаційний фон', 'мкЗв/год', ''),
(0, 4, 1.7, '2024-12-26 09:35:48', 'Забрудненість шкідливими домішками', 'мкг/м³', ''),
(0, 5, 18.2, '2024-12-26 09:35:48', 'Температура', '°C', ''),
(0, 5, 42, '2024-12-26 09:35:48', 'Вологість', '%', ''),
(0, 5, 751, '2024-12-26 09:35:48', 'Тиск повітря', 'мм рт. ст.', ''),
(0, 5, 82, '2024-12-26 09:35:48', 'Хмарність', '%', ''),
(0, 5, 18, '2024-12-26 09:35:48', 'Напрямок вітру', '°', ''),
(0, 5, 15.7, '2024-12-26 09:35:48', 'Сила вітру', 'м/с', ''),
(0, 5, 0.08, '2024-12-26 09:35:48', 'Радіаційний фон', 'мкЗв/год', ''),
(0, 5, 23.3, '2024-12-26 09:35:48', 'Забрудненість шкідливими домішками', 'мкг/м³', ''),
(0, 1, 14, '2024-12-26 09:35:50', 'Температура', '°C', ''),
(0, 1, 69, '2024-12-26 09:35:50', 'Вологість', '%', ''),
(0, 1, 784, '2024-12-26 09:35:50', 'Тиск повітря', 'мм рт. ст.', ''),
(0, 1, 31, '2024-12-26 09:35:50', 'Хмарність', '%', ''),
(0, 1, 187, '2024-12-26 09:35:50', 'Напрямок вітру', '°', ''),
(0, 1, 13.3, '2024-12-26 09:35:50', 'Сила вітру', 'м/с', ''),
(0, 1, 0.08, '2024-12-26 09:35:50', 'Радіаційний фон', 'мкЗв/год', ''),
(0, 1, 40.6, '2024-12-26 09:35:50', 'Забрудненість шкідливими домішками', 'мкг/м³', ''),
(0, 2, 21, '2024-12-26 09:35:50', 'Температура', '°C', ''),
(0, 2, 44, '2024-12-26 09:35:50', 'Вологість', '%', ''),
(0, 2, 794, '2024-12-26 09:35:50', 'Тиск повітря', 'мм рт. ст.', ''),
(0, 2, 10, '2024-12-26 09:35:50', 'Хмарність', '%', ''),
(0, 2, 306, '2024-12-26 09:35:50', 'Напрямок вітру', '°', ''),
(0, 2, 19, '2024-12-26 09:35:50', 'Сила вітру', 'м/с', ''),
(0, 2, 0.02, '2024-12-26 09:35:50', 'Радіаційний фон', 'мкЗв/год', ''),
(0, 2, 7.9, '2024-12-26 09:35:50', 'Забрудненість шкідливими домішками', 'мкг/м³', ''),
(0, 3, -2.7, '2024-12-26 09:35:50', 'Температура', '°C', ''),
(0, 3, 43, '2024-12-26 09:35:50', 'Вологість', '%', ''),
(0, 3, 781, '2024-12-26 09:35:50', 'Тиск повітря', 'мм рт. ст.', ''),
(0, 3, 88, '2024-12-26 09:35:50', 'Хмарність', '%', ''),
(0, 3, 186, '2024-12-26 09:35:50', 'Напрямок вітру', '°', ''),
(0, 3, 18.5, '2024-12-26 09:35:50', 'Сила вітру', 'м/с', ''),
(0, 3, 0.01, '2024-12-26 09:35:50', 'Радіаційний фон', 'мкЗв/год', ''),
(0, 3, 31.6, '2024-12-26 09:35:50', 'Забрудненість шкідливими домішками', 'мкг/м³', ''),
(0, 4, 26.4, '2024-12-26 09:35:50', 'Температура', '°C', ''),
(0, 4, 65, '2024-12-26 09:35:50', 'Вологість', '%', ''),
(0, 4, 776, '2024-12-26 09:35:50', 'Тиск повітря', 'мм рт. ст.', ''),
(0, 4, 69, '2024-12-26 09:35:50', 'Хмарність', '%', ''),
(0, 4, 321, '2024-12-26 09:35:50', 'Напрямок вітру', '°', ''),
(0, 4, 7.6, '2024-12-26 09:35:50', 'Сила вітру', 'м/с', ''),
(0, 4, 0.02, '2024-12-26 09:35:50', 'Радіаційний фон', 'мкЗв/год', ''),
(0, 4, 47, '2024-12-26 09:35:50', 'Забрудненість шкідливими домішками', 'мкг/м³', ''),
(0, 5, -8.1, '2024-12-26 09:35:50', 'Температура', '°C', ''),
(0, 5, 42, '2024-12-26 09:35:50', 'Вологість', '%', ''),
(0, 5, 799, '2024-12-26 09:35:50', 'Тиск повітря', 'мм рт. ст.', ''),
(0, 5, 63, '2024-12-26 09:35:50', 'Хмарність', '%', ''),
(0, 5, 83, '2024-12-26 09:35:50', 'Напрямок вітру', '°', ''),
(0, 5, 5, '2024-12-26 09:35:50', 'Сила вітру', 'м/с', ''),
(0, 5, 0.06, '2024-12-26 09:35:50', 'Радіаційний фон', 'мкЗв/год', ''),
(0, 5, 1.1, '2024-12-26 09:35:50', 'Забрудненість шкідливими домішками', 'мкг/м³', ''),
(0, 1, -2.7, '2024-12-26 10:27:22', 'Температура', '°C', NULL),
(0, 1, 17, '2024-12-26 10:27:22', 'Вологість', '%', NULL),
(0, 1, 765, '2024-12-26 10:27:22', 'Тиск повітря', 'мм рт. ст.', NULL),
(0, 1, 5, '2024-12-26 10:27:22', 'Хмарність', '%', NULL),
(0, 1, 118, '2024-12-26 10:27:22', 'Напрямок вітру', '°', NULL),
(0, 1, 9.6, '2024-12-26 10:27:22', 'Сила вітру', 'м/с', NULL),
(0, 1, 0.041, '2024-12-26 10:27:22', 'Радіаційний фон', 'мкЗв/год', NULL),
(0, 1, 30.6, '2024-12-26 10:27:22', 'Забрудненість шкідливими домішками', 'мкг/м³', NULL),
(0, 2, 23.4, '2024-12-26 10:27:22', 'Температура', '°C', NULL),
(0, 2, 33, '2024-12-26 10:27:22', 'Вологість', '%', NULL),
(0, 2, 757, '2024-12-26 10:27:22', 'Тиск повітря', 'мм рт. ст.', NULL),
(0, 2, 77, '2024-12-26 10:27:22', 'Хмарність', '%', NULL),
(0, 2, 154, '2024-12-26 10:27:22', 'Напрямок вітру', '°', NULL),
(0, 2, 16.2, '2024-12-26 10:27:22', 'Сила вітру', 'м/с', NULL),
(0, 2, 0.077, '2024-12-26 10:27:22', 'Радіаційний фон', 'мкЗв/год', NULL),
(0, 2, 20.7, '2024-12-26 10:27:22', 'Забрудненість шкідливими домішками', 'мкг/м³', NULL),
(0, 3, 20.5, '2024-12-26 10:27:22', 'Температура', '°C', NULL),
(0, 3, 57, '2024-12-26 10:27:22', 'Вологість', '%', NULL),
(0, 3, 778, '2024-12-26 10:27:22', 'Тиск повітря', 'мм рт. ст.', NULL),
(0, 3, 15, '2024-12-26 10:27:22', 'Хмарність', '%', NULL),
(0, 3, 17, '2024-12-26 10:27:22', 'Напрямок вітру', '°', NULL),
(0, 3, 15.7, '2024-12-26 10:27:22', 'Сила вітру', 'м/с', NULL),
(0, 3, 0.077, '2024-12-26 10:27:22', 'Радіаційний фон', 'мкЗв/год', NULL),
(0, 3, 24.7, '2024-12-26 10:27:22', 'Забрудненість шкідливими домішками', 'мкг/м³', NULL),
(0, 4, -3.5, '2024-12-26 10:27:22', 'Температура', '°C', NULL),
(0, 4, 32, '2024-12-26 10:27:22', 'Вологість', '%', NULL),
(0, 4, 757, '2024-12-26 10:27:22', 'Тиск повітря', 'мм рт. ст.', NULL),
(0, 4, 78, '2024-12-26 10:27:22', 'Хмарність', '%', NULL),
(0, 4, 168, '2024-12-26 10:27:22', 'Напрямок вітру', '°', NULL),
(0, 4, 19.7, '2024-12-26 10:27:22', 'Сила вітру', 'м/с', NULL),
(0, 4, 0.051, '2024-12-26 10:27:22', 'Радіаційний фон', 'мкЗв/год', NULL),
(0, 4, 30, '2024-12-26 10:27:22', 'Забрудненість шкідливими домішками', 'мкг/м³', NULL),
(0, 5, 8.8, '2024-12-26 10:27:22', 'Температура', '°C', NULL),
(0, 5, 54, '2024-12-26 10:27:22', 'Вологість', '%', NULL),
(0, 5, 766, '2024-12-26 10:27:22', 'Тиск повітря', 'мм рт. ст.', NULL),
(0, 5, 4, '2024-12-26 10:27:22', 'Хмарність', '%', NULL),
(0, 5, 78, '2024-12-26 10:27:22', 'Напрямок вітру', '°', NULL),
(0, 5, 18.9, '2024-12-26 10:27:22', 'Сила вітру', 'м/с', NULL),
(0, 5, 0.008, '2024-12-26 10:27:22', 'Радіаційний фон', 'мкЗв/год', NULL),
(0, 5, 27, '2024-12-26 10:27:22', 'Забрудненість шкідливими домішками', 'мкг/м³', NULL),
(0, 1, -5.6, '2024-12-28 22:11:38', 'Температура', '°C', NULL),
(0, 1, 93, '2024-12-28 22:11:38', 'Вологість', '%', NULL),
(0, 1, 767, '2024-12-28 22:11:38', 'Тиск повітря', 'мм рт. ст.', NULL),
(0, 1, 95, '2024-12-28 22:11:38', 'Хмарність', '%', NULL),
(0, 1, 260, '2024-12-28 22:11:38', 'Напрямок вітру', '°', NULL),
(0, 1, 14.9, '2024-12-28 22:11:38', 'Сила вітру', 'м/с', NULL),
(0, 1, 0.056, '2024-12-28 22:11:38', 'Радіаційний фон', 'мкЗв/год', NULL),
(0, 1, 28.5, '2024-12-28 22:11:38', 'Забрудненість шкідливими домішками', 'мкг/м³', NULL),
(0, 2, -3.5, '2024-12-28 22:11:38', 'Температура', '°C', NULL),
(0, 2, 10, '2024-12-28 22:11:38', 'Вологість', '%', NULL),
(0, 2, 751, '2024-12-28 22:11:38', 'Тиск повітря', 'мм рт. ст.', NULL),
(0, 2, 88, '2024-12-28 22:11:38', 'Хмарність', '%', NULL),
(0, 2, 103, '2024-12-28 22:11:38', 'Напрямок вітру', '°', NULL),
(0, 2, 15.9, '2024-12-28 22:11:38', 'Сила вітру', 'м/с', NULL),
(0, 2, 0.012, '2024-12-28 22:11:38', 'Радіаційний фон', 'мкЗв/год', NULL),
(0, 2, 9.6, '2024-12-28 22:11:38', 'Забрудненість шкідливими домішками', 'мкг/м³', NULL),
(0, 3, 14.6, '2024-12-28 22:11:38', 'Температура', '°C', NULL),
(0, 3, 50, '2024-12-28 22:11:38', 'Вологість', '%', NULL),
(0, 3, 782, '2024-12-28 22:11:38', 'Тиск повітря', 'мм рт. ст.', NULL),
(0, 3, 77, '2024-12-28 22:11:38', 'Хмарність', '%', NULL),
(0, 3, 324, '2024-12-28 22:11:38', 'Напрямок вітру', '°', NULL),
(0, 3, 3.8, '2024-12-28 22:11:38', 'Сила вітру', 'м/с', NULL),
(0, 3, 0.024, '2024-12-28 22:11:38', 'Радіаційний фон', 'мкЗв/год', NULL),
(0, 3, 31.5, '2024-12-28 22:11:38', 'Забрудненість шкідливими домішками', 'мкг/м³', NULL),
(0, 4, 7.2, '2024-12-28 22:11:38', 'Температура', '°C', NULL),
(0, 4, 26, '2024-12-28 22:11:38', 'Вологість', '%', NULL),
(0, 4, 750, '2024-12-28 22:11:38', 'Тиск повітря', 'мм рт. ст.', NULL),
(0, 4, 28, '2024-12-28 22:11:38', 'Хмарність', '%', NULL),
(0, 4, 139, '2024-12-28 22:11:38', 'Напрямок вітру', '°', NULL),
(0, 4, 1.7, '2024-12-28 22:11:38', 'Сила вітру', 'м/с', NULL),
(0, 4, 0.025, '2024-12-28 22:11:38', 'Радіаційний фон', 'мкЗв/год', NULL),
(0, 4, 1, '2024-12-28 22:11:38', 'Забрудненість шкідливими домішками', 'мкг/м³', NULL),
(0, 5, 3.5, '2024-12-28 22:11:38', 'Температура', '°C', NULL),
(0, 5, 62, '2024-12-28 22:11:38', 'Вологість', '%', NULL),
(0, 5, 756, '2024-12-28 22:11:38', 'Тиск повітря', 'мм рт. ст.', NULL),
(0, 5, 75, '2024-12-28 22:11:38', 'Хмарність', '%', NULL),
(0, 5, 141, '2024-12-28 22:11:38', 'Напрямок вітру', '°', NULL),
(0, 5, 14.1, '2024-12-28 22:11:38', 'Сила вітру', 'м/с', NULL),
(0, 5, 0.034, '2024-12-28 22:11:38', 'Радіаційний фон', 'мкЗв/год', NULL),
(0, 5, 28.9, '2024-12-28 22:11:38', 'Забрудненість шкідливими домішками', 'мкг/м³', NULL);

--
-- Triggers `measurement`
--
DELIMITER $$
CREATE TRIGGER `validate_measurement_data` BEFORE INSERT ON `measurement` FOR EACH ROW BEGIN
  IF NEW.parameter_name = 'Температура' AND (NEW.value < -50 OR NEW.value > 60) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Температура має бути в межах від -50 до 60°C';
  END IF;

  IF NEW.parameter_name = 'Вологість' AND (NEW.value < 0 OR NEW.value > 100) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Вологість має бути в межах від 0% до 100%';
  END IF;

  IF NEW.parameter_name = 'Тиск повітря' AND (NEW.value < 300 OR NEW.value > 1100) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Тиск повітря має бути в межах від 300 до 1100 мм рт. ст.';
  END IF;

  IF NEW.parameter_name = 'Хмарність' AND (NEW.value < 0 OR NEW.value > 100) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Хмарність має бути в межах від 0% до 100%';
  END IF;

  IF NEW.parameter_name = 'Напрямок вітру' AND (NEW.value < 0 OR NEW.value >= 360) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Напрямок вітру має бути в межах від 0° до 360°';
  END IF;

  IF NEW.parameter_name = 'Сила вітру' AND (NEW.value < 0 OR NEW.value > 150) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Сила вітру має бути в межах від 0 до 150 м/с';
  END IF;

  IF NEW.parameter_name = 'Радіаційний фон' AND (NEW.value < 0 OR NEW.value > 1) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Радіаційний фон має бути в межах від 0 до 1 мкЗв/год';
  END IF;

  IF NEW.parameter_name = 'Забрудненість шкідливими домішками' AND (NEW.value < 0 OR NEW.value > 500) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Забрудненість шкідливими домішками має бути в межах від 0 до 500 мкг/м³';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `station`
--

CREATE TABLE `station` (
  `station_id` tinyint(4) NOT NULL,
  `location_id` smallint(6) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `station`
--

INSERT INTO `station` (`station_id`, `location_id`, `name`, `description`) VALUES
(1, 9, 'Столична', 'Метеостанція, що відстежує погодні умови в центральній частині Києва. Забезпечує точні дані для столиці та прилеглих районів.'),
(2, 6, 'Південний вітер', 'Метеостанція на півдні Полтави, що спеціалізується на вимірюваннях вітрових показників та температури.'),
(3, 7, 'Північна хвиля', 'Метеостанція, розташована на півночі Полтави. Збирає дані для вивчення змін клімату в цій частині України.\r\n'),
(4, 11, 'Площа Метеор', 'Метеостанція, розташована в серці Львова, в Галицькому районі. Відстежує погодні зміни в центральній частині міста, зокрема температуру та атмосферний тиск.'),
(5, 12, 'Західний обрій', 'Метеостанція у Шевченківському районі Львова, що забезпечує точні дані про кліматичні умови на заході міста, зокрема вітрові показники та вологість повітря.');

--
-- Triggers `station`
--
DELIMITER $$
CREATE TRIGGER `station_delete` AFTER DELETE ON `station` FOR EACH ROW BEGIN
  INSERT INTO station_journal (station_id, location_id, name, description, action_type, old_value)
  VALUES (OLD.station_id, OLD.location_id, OLD.name, OLD.description, 'DELETE', CONCAT('Deleted Name: ', OLD.name, ', Deleted Description: ', OLD.description));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `station_insert` AFTER INSERT ON `station` FOR EACH ROW BEGIN
  INSERT INTO station_journal (station_id, location_id, name, description, action_type)
  VALUES (NEW.station_id, NEW.location_id, NEW.name, NEW.description, 'INSERT');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `station_update` AFTER UPDATE ON `station` FOR EACH ROW BEGIN
  INSERT INTO station_journal (station_id, location_id, name, description, action_type, old_value)
  VALUES (NEW.station_id, NEW.location_id, NEW.name, NEW.description, 'UPDATE', CONCAT('Old Name: ', OLD.name, ', Old Description: ', OLD.description));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `station_journal`
--

CREATE TABLE `station_journal` (
  `journal_id` int(11) NOT NULL,
  `station_id` int(11) NOT NULL,
  `location_id` smallint(6) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(500) NOT NULL,
  `action_type` enum('INSERT','UPDATE','DELETE') NOT NULL,
  `action_timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `old_value` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure for view `flat_location`
--
DROP TABLE IF EXISTS `flat_location`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `flat_location`  AS SELECT `l1`.`location_id` AS `country_id`, `l1`.`name` AS `country_name`, `l2`.`location_id` AS `province_id`, `l2`.`name` AS `province_name`, `l3`.`location_id` AS `region_id`, `l3`.`name` AS `region_name`, `l3`.`lat` AS `latitude`, `l3`.`lon` AS `longitude` FROM ((`location` `l1` join `location` `l2` on(`l2`.`parent_location_id` = `l1`.`location_id`)) join `location` `l3` on(`l3`.`parent_location_id` = `l2`.`location_id`)) WHERE `l1`.`location_id` is not null ORDER BY `l1`.`location_id` ASC, `l2`.`location_id` ASC, `l3`.`location_id` ASC ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `location`
--
ALTER TABLE `location`
  ADD PRIMARY KEY (`location_id`),
  ADD KEY `parent_location_id` (`parent_location_id`);

--
-- Indexes for table `measurement`
--
ALTER TABLE `measurement`
  ADD KEY `idx_timestamp` (`timestamp`);

--
-- Indexes for table `station`
--
ALTER TABLE `station`
  ADD PRIMARY KEY (`station_id`),
  ADD UNIQUE KEY `location_id` (`location_id`);

--
-- Indexes for table `station_journal`
--
ALTER TABLE `station_journal`
  ADD PRIMARY KEY (`journal_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `location`
--
ALTER TABLE `location`
  MODIFY `location_id` smallint(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `station`
--
ALTER TABLE `station`
  MODIFY `station_id` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `station_journal`
--
ALTER TABLE `station_journal`
  MODIFY `journal_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `location`
--
ALTER TABLE `location`
  ADD CONSTRAINT `location_ibfk_1` FOREIGN KEY (`parent_location_id`) REFERENCES `location` (`location_id`);

--
-- Constraints for table `station`
--
ALTER TABLE `station`
  ADD CONSTRAINT `station_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`);

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `SimulateWeatherEvent` ON SCHEDULE EVERY 2 SECOND STARTS '2024-12-26 07:32:22' ON COMPLETION NOT PRESERVE ENABLE DO CALL SimulateWeatherData()$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
