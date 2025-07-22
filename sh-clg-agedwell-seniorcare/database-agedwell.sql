/*
SQLyog Community v13.1.6 (64 bit)
MySQL - 5.7.9 : Database - sh_flutter_agedwell
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`sh_flutter_agedwell` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `sh_flutter_agedwell`;

/*Table structure for table `article` */

DROP TABLE IF EXISTS `article`;

CREATE TABLE `article` (
  `article_id` int(11) NOT NULL AUTO_INCREMENT,
  `article` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`article_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;

/*Data for the table `article` */

insert  into `article`(`article_id`,`article`) values 
(1,'%s'),
(2,'static/4f188883-b956-418a-83fb-3a7f60a6108a_Discover-5-Affordable-Wedding-Catering-Options-That-Wont-Break-the-Bank.jpg'),
(3,'static/5ff5cbe1-fe49-4488-9cfd-721827f8528d_People-At-A-Catered-Event.jpg'),
(4,'static/138e8ba9-5556-43a8-b24a-18cf83ad0572_wedges-catering.jpeg'),
(5,'static/8bdf54c5-9b21-4236-bc71-ede85dca42dd_wedges-catering.jpeg'),
(6,'static/071078ec-9c62-459e-bd39-7465b08eed90_gyanjee-caterers-10.jpg'),
(7,'static/05c7f7a6-f12c-476d-904d-3d763314e033_gyanjee-caterers-10.jpg'),
(8,'static/0a938196-d1be-4484-9b4f-67bb67c8c269_catering2.jpg'),
(9,'static/767da361-085d-40c2-8062-e9743bdcd55f_catering2.jpg'),
(10,'static/c9eb2db3-982c-42b7-a329-5d4422b5fafd_catering2.jpg'),
(11,'static/e125ea85-ec55-4b3b-9f53-ffbf5eba551f_catering2.jpg'),
(12,'static/851542d8-e278-404b-9dd2-135e7c61f831_trays@2x.png'),
(13,'static/1dca99ba-f178-42ad-b697-d8075ddb9af2_trays@2x.png'),
(14,'static/495886ea-9dfb-4a46-b4ac-a7f58691eb09_trays@2x.png'),
(15,'static/54f93638-aebc-412d-9fd9-2272e7448ed1_trays@2x.png'),
(16,'static/e080b04c-5d2a-41dc-8904-6bf0dc6ca1a6_trays@2x.png'),
(17,'static/7a841575-1de4-42c9-a461-6d7d62e2fd4f_trays@2x.png'),
(18,'static/b3778c60-f42d-4af5-8504-e00a67e60318_trays@2x.png'),
(19,'static/f871178e-3f54-40be-bf6f-7d82e24a43d8_trays@2x.png'),
(20,'static/f1cd2e20-0756-403c-a0fc-a6181fdb808e_trays@2x.png'),
(21,'static/0cc770b9-2872-487a-8c74-77ab6f31e7bb_trays@2x.png'),
(22,'static/ae7811a3-c4ad-46c4-a0d8-b68e7687ac58_trays@2x.png'),
(23,'static/8bfdb414-3f3a-4743-b02e-dbc648df20d6_trays@2x.png'),
(24,'static/e9cea135-1b73-4e5a-95ad-f4e1296687fe_trays@2x.png'),
(25,'static/87989c44-2c99-47f1-b067-7d081823cdc2_trays@2x.png'),
(26,'static/eecbd09d-92cd-43bd-ae68-db5aefe9e044_trays@2x.png');

/*Table structure for table `book_appo` */

DROP TABLE IF EXISTS `book_appo`;

CREATE TABLE `book_appo` (
  `book_appo_id` int(11) NOT NULL AUTO_INCREMENT,
  `volunteer_id` int(11) DEFAULT NULL,
  `app_title` varchar(100) DEFAULT NULL,
  `bookingdate` varchar(100) DEFAULT NULL,
  `booking_status` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`book_appo_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

/*Data for the table `book_appo` */

insert  into `book_appo`(`book_appo_id`,`volunteer_id`,`app_title`,`bookingdate`,`booking_status`) values 
(1,1,'abc','7-7-2024','accepted'),
(2,2,'ugd','2-11-2024','accepted');

/*Table structure for table `chat` */

DROP TABLE IF EXISTS `chat`;

CREATE TABLE `chat` (
  `chat_id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) DEFAULT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `message` varchar(100) DEFAULT NULL,
  `date` varchar(100) DEFAULT NULL,
  `sender_type` varchar(100) DEFAULT NULL,
  `receiver_type` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`chat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `chat` */

/*Table structure for table `class_video` */

DROP TABLE IF EXISTS `class_video`;

CREATE TABLE `class_video` (
  `class_video_id` int(11) NOT NULL AUTO_INCREMENT,
  `book_appo_id` int(11) DEFAULT NULL,
  `volunteer_id` int(11) DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `file_path` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`class_video_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

/*Data for the table `class_video` */

insert  into `class_video`(`class_video_id`,`book_appo_id`,`volunteer_id`,`title`,`file_path`) values 
(1,2,2,'hfttrs','static/74538a5a-d6e0-4d90-98d2-6aeb70bea5d9Exploring the role of volunteers in care settings for older people (ERVIC) - Short 5 (144p).mp4');

/*Table structure for table `demo_video` */

DROP TABLE IF EXISTS `demo_video`;

CREATE TABLE `demo_video` (
  `demo_video_id` int(11) NOT NULL AUTO_INCREMENT,
  `video` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`demo_video_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

/*Data for the table `demo_video` */

insert  into `demo_video`(`demo_video_id`,`video`) values 
(1,'static/006469b8-3f6a-4395-8461-468e7965193dExploring the role of volunteers in care settings for older people (ERVIC) - Short 5 (144p).mp4');

/*Table structure for table `donation_item` */

DROP TABLE IF EXISTS `donation_item`;

CREATE TABLE `donation_item` (
  `donation_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `donor_id` int(11) DEFAULT NULL,
  `item` varchar(100) DEFAULT NULL,
  `qty` varchar(100) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `date` varchar(100) DEFAULT NULL,
  `time` varchar(100) DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  `reply` varchar(100) DEFAULT NULL,
  `file_upload` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`donation_item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

/*Data for the table `donation_item` */

insert  into `donation_item`(`donation_item_id`,`donor_id`,`item`,`qty`,`type`,`date`,`time`,`status`,`reply`,`file_upload`) values 
(1,2,'fffw','3','dsd','3=7=2024','1:00','pending','ok','\"C:\\Users\\LENOVO\\Pictures\\photos\\2352498.png\"');

/*Table structure for table `donation_payment` */

DROP TABLE IF EXISTS `donation_payment`;

CREATE TABLE `donation_payment` (
  `donation_payment_id` int(11) NOT NULL AUTO_INCREMENT,
  `donor_id` int(11) DEFAULT NULL,
  `amount` varchar(100) DEFAULT NULL,
  `date` varchar(100) DEFAULT NULL,
  `reply` varchar(100) DEFAULT NULL,
  `file_upload` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`donation_payment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

/*Data for the table `donation_payment` */

insert  into `donation_payment`(`donation_payment_id`,`donor_id`,`amount`,`date`,`reply`,`file_upload`) values 
(1,3,'700','27-7-2024','ok','\"C:\\Users\\LENOVO\\Pictures\\photos\\rain wallpaper.jfif\"');

/*Table structure for table `donor` */

DROP TABLE IF EXISTS `donor`;

CREATE TABLE `donor` (
  `donor_id` int(11) NOT NULL AUTO_INCREMENT,
  `login_id` int(11) DEFAULT NULL,
  `dname` varchar(100) DEFAULT NULL,
  `demail` varchar(100) DEFAULT NULL,
  `dphone` varchar(100) DEFAULT NULL,
  `doccupation` varchar(100) DEFAULT NULL,
  `dgender` varchar(100) DEFAULT NULL,
  `ddateofbirth` varchar(100) DEFAULT NULL,
  `dcity` varchar(100) DEFAULT NULL,
  `dfile_upload` varchar(1000) DEFAULT NULL,
  `dp_image` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`donor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

/*Data for the table `donor` */

insert  into `donor`(`donor_id`,`login_id`,`dname`,`demail`,`dphone`,`doccupation`,`dgender`,`ddateofbirth`,`dcity`,`dfile_upload`,`dp_image`) values 
(1,2,'donar','donor@gmail.com','4646464646','abc','female','02-11-2002','ekm','pending','\"C:\\Users\\LENOVO\\Downloads\\pexels-matthiaszomer-339620.jpg\"'),
(2,3,'donor','d@gmail.com','7878787878','sss','male','02-11-2003','ekm','pending',NULL);

/*Table structure for table `food_request` */

DROP TABLE IF EXISTS `food_request`;

CREATE TABLE `food_request` (
  `food_request_id` int(11) NOT NULL AUTO_INCREMENT,
  `donor_id` int(11) DEFAULT NULL,
  `file_upload` varchar(100) DEFAULT NULL,
  `day` varchar(100) DEFAULT NULL,
  `date` varchar(100) DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`food_request_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

/*Data for the table `food_request` */

insert  into `food_request`(`food_request_id`,`donor_id`,`file_upload`,`day`,`date`,`status`) values 
(1,1,'static/190c9893-e7f8-4e19-b771-ae47547089ba_gyanjee-caterers-10.jpg','wednesday','22-7-2024','pending'),
(2,2,'static/190c9893-e7f8-4e19-b771-ae47547089ba_gyanjee-caterers-10.jpg','thursday','23-7-2024','accepted');

/*Table structure for table `login` */

DROP TABLE IF EXISTS `login`;

CREATE TABLE `login` (
  `login_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `usertype` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`login_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

/*Data for the table `login` */

insert  into `login`(`login_id`,`username`,`password`,`usertype`) values 
(1,'admin','admin','admin'),
(2,'donor','donor','donor'),
(3,'volunteer','volunteer','volunteer');

/*Table structure for table `review` */

DROP TABLE IF EXISTS `review`;

CREATE TABLE `review` (
  `review_id` int(11) NOT NULL AUTO_INCREMENT,
  `volunteer_id` int(11) DEFAULT NULL,
  `review` varchar(100) DEFAULT NULL,
  `rate` varchar(100) DEFAULT NULL,
  `date` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`review_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `review` */

/*Table structure for table `reward` */

DROP TABLE IF EXISTS `reward`;

CREATE TABLE `reward` (
  `reward_id` int(11) NOT NULL AUTO_INCREMENT,
  `volunteer_id` int(11) DEFAULT NULL,
  `reward` varchar(100) DEFAULT NULL,
  `date` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`reward_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `reward` */

/*Table structure for table `vol_pickup` */

DROP TABLE IF EXISTS `vol_pickup`;

CREATE TABLE `vol_pickup` (
  `vol_pickup` int(11) NOT NULL AUTO_INCREMENT,
  `donation_item_id` int(11) DEFAULT NULL,
  `volunteer_id` int(11) DEFAULT NULL,
  `pickup_time` varchar(100) DEFAULT NULL,
  `droptime` varchar(100) DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`vol_pickup`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

/*Data for the table `vol_pickup` */

insert  into `vol_pickup`(`vol_pickup`,`donation_item_id`,`volunteer_id`,`pickup_time`,`droptime`,`status`) values 
(1,1,1,'9:16','12:30','pending');

/*Table structure for table `volunteer` */

DROP TABLE IF EXISTS `volunteer`;

CREATE TABLE `volunteer` (
  `volunteer_id` int(11) NOT NULL AUTO_INCREMENT,
  `login_id` int(11) DEFAULT NULL,
  `vname` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(100) DEFAULT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `gender` varchar(100) DEFAULT NULL,
  `dateofbirth` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `file_upload` varchar(1000) DEFAULT NULL,
  `p_image` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`volunteer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

/*Data for the table `volunteer` */

insert  into `volunteer`(`volunteer_id`,`login_id`,`vname`,`email`,`phone`,`occupation`,`gender`,`dateofbirth`,`city`,`file_upload`,`p_image`) values 
(1,3,'abc','v@gmail.com','2323232323','abc','male','01-11-2003','ekm','\"C:\\Users\\LENOVO\\Pictures\\photos\\White And Black Modern Photo Collage Desktop Wallpaper.png\"','\"C:\\Users\\LENOVO\\Pictures\\photos\\White And Black Modern Photo Collage Desktop Wallpaper.png\"');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
