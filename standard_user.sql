/*
 Navicat Premium Data Transfer

 Source Server         : mysql8.0-local
 Source Server Type    : MySQL
 Source Server Version : 80016
 Source Host           : localhost:8016
 Source Schema         : wg-0511

 Target Server Type    : MySQL
 Target Server Version : 80016
 File Encoding         : 65001

 Date: 26/08/2020 17:19:26
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for standard_user
-- ----------------------------
DROP TABLE IF EXISTS `standard_user`;
CREATE TABLE `standard_user`  (
  `ID` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主键',
  `USER_NAME` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户名',
  `USER_PWD` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '密码',
  `BIRTHDAY` timestamp(0) NULL DEFAULT NULL COMMENT '生日',
  `NAME` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '姓名',
  `USER_ICON` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像图片',
  `SEX` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '2' COMMENT '性别, 1:男，0:女，2：保密',
  `NICKNAME` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '昵称',
  `STATUS` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '01' COMMENT '用户状态，01:正常，02:冻结',
  `USER_MALL` bigint(20) NULL DEFAULT NULL COMMENT '当前所属MALL',
  `LAST_LOGIN_DATE` timestamp(0) NULL DEFAULT NULL COMMENT '最后登录时间',
  `LAST_LOGIN_IP` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `SRC_OPEN_USER_ID` bigint(20) NULL DEFAULT NULL COMMENT '来源的联合登录',
  `EMAIL` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '邮箱',
  `MOBILE` bigint(20) NULL DEFAULT NULL COMMENT '手机',
  `DELETE_IDENTIFY` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标识0 未删除, 1 已删除',
  `EMAIL_CONFIRMED` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否绑定邮箱 0 未绑定 1 已绑定',
  `PHONE_CONFIRMED` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '是否绑定手机 0 未绑定 1 已绑定',
  `CREATER` bigint(20) NULL DEFAULT 0 COMMENT '创建人',
  `CREATE_TIME` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `UPDATE_TIME` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '修改日期',
  `PWD_INTENSITY` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '密码强度',
  `MOBILE_TGC` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机登录标识',
  `MAC` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'mac地址',
  `SOURCE` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '1:WEB,2:IOS,3:ANDROID,4:WIFI,5:管理系统, 0:未知',
  `ACTIVATE` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '激活，1：激活，0：未激活',
  `ACTIVATE_TYPE` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '激活类型，0：自动，1：手动',
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE INDEX `USER_NAME`(`USER_NAME`) USING BTREE,
  INDEX `MOBILE`(`MOBILE`) USING BTREE,
  INDEX `IDX_MOBILE_TGC`(`MOBILE_TGC`, `ID`) USING BTREE,
  INDEX `IDX_EMAIL`(`EMAIL`, `ID`) USING BTREE,
  INDEX `IDX_CREATE_DATE`(`CREATE_TIME`, `ID`) USING BTREE,
  INDEX `IDX_UPDATE_DATE`(`UPDATE_TIME`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
