/*
Navicat MySQL Data Transfer

Source Server         : sql
Source Server Version : 50505
Source Host           : 127.0.0.1:3306
Source Database       : sql

Target Server Type    : MYSQL
Target Server Version : 50505
File Encoding         : 65001

Date: 2016-01-26 10:05:08
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for bandera
-- ----------------------------
DROP TABLE IF EXISTS `bandera`;
CREATE TABLE `bandera` (
  `id` int(11) NOT NULL,
  `bandera` enum('N','S') DEFAULT 'N',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of bandera
-- ----------------------------
