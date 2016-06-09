CREATE TABLE IF NOT EXISTS `location` (
  `location_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `description` varchar(255) default NULL,
  `address1` varchar(255) default NULL,
  `address2` varchar(255) default NULL,
  `city_village` varchar(255) default NULL,
  `state_province` varchar(255) default NULL,
  `postal_code` varchar(50) default NULL,
  `country` varchar(50) default NULL,
  `latitude` varchar(50) default NULL,
  `longitude` varchar(50) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL,
  `county_district` varchar(255) default NULL,
  `address3` varchar(255) default NULL,
  `address4` varchar(255) default NULL,
  `address5` varchar(255) default NULL,
  `address6` varchar(255) default NULL,
  `retired` tinyint(1) NOT NULL default '0',
  `retired_by` int(11) default NULL,
  `date_retired` datetime default NULL,
  `retire_reason` varchar(255) default NULL,
  `parent_location` int(11) default NULL,
  `uuid` char(38) default NULL,
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  PRIMARY KEY  (`location_id`),
  UNIQUE KEY `location_uuid_index` (`uuid`),
  KEY `name_of_location` (`name`),
  KEY `location_retired_status` (`retired`),
  KEY `user_who_created_location` (`creator`),
  KEY `user_who_retired_location` (`retired_by`),
  KEY `parent_location` (`parent_location`),
  KEY `location_changed_by` (`changed_by`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=95699 ;

SET foreign_key_checks = 0;
TRUNCATE location;
SET foreign_key_checks = 1;


--
-- Contenu de la table `location`
--

INSERT INTO `location` (`location_id`, `name`, `description`, `address1`, `address2`, `city_village`, `state_province`, `postal_code`, `country`, `latitude`, `longitude`, `creator`, `date_created`, `county_district`, `address3`, `address4`, `address5`, `address6`, `retired`, `retired_by`, `date_retired`, `retire_reason`, `parent_location`, `uuid`, `changed_by`, `date_changed`) VALUES
(1, 'Unknown Location', NULL, '', '', '', '', '', '', NULL, NULL, 1, '2005-09-22 00:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '8d6c993e-c2cc-11de-8d13-0010c6dffd0f', NULL, NULL),
(8, 'Amani Hospital', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, '2013-08-01 18:46:15', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, 'aff27d58-a15c-49a6-9beb-d30dcfc0c66e', NULL, NULL),
(2, 'Pharmacy', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, '2013-08-01 18:48:37', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 8, '7f65d926-57d6-4402-ae10-a5b3bcbf7986', 2, '2016-04-05 09:09:20'),
(3, 'Laboratory', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, '2013-08-01 18:48:51', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 8, '7fdfa2cb-bc95-405a-88c6-32b7673c0453', 2, '2016-04-05 09:09:20'),
(4, 'Isolation Ward', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, '2013-08-01 18:48:19', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 8, '2131aff8-2e2a-480a-b7ab-4ac53250262b', 2, '2016-04-05 09:09:20'),
(5, 'Registration Desk', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, '2013-08-01 18:49:07', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 8, '6351fcf4-e311-4a19-90f9-35667d99a8af', 2, '2016-04-05 09:09:20'),
(6, 'Inpatient Ward', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, '2013-08-01 18:47:29', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 8, 'b1a8b05e-3542-4037-bbd3-998ee9c40574', 2, '2016-04-05 09:09:20'),
(7, 'Outpatient Clinic', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, '2013-08-01 18:47:12', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 8, '58c57d25-8d39-41ab-8422-108a0c277d98', 2, '2016-04-05 09:09:20'),
(12, 'UGP MSPP network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c6c82-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(14, 'UMaryland network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c6f52-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(15, 'FOSREF network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7088-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(16, 'ICC network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7196-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(17, 'Non associée network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c729a-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(18, 'GHESKIO network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c739e-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(19, 'PATHFINDER network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c748e-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(20, 'HTW network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7588-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(21, 'CDS network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7682-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(23, 'ITECH network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7768-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(24, 'MATHEUX network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7858-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(25, 'UMiami network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7952-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(26, 'URC network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7c68-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(27, 'CMMB network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7d58-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(28, 'SSQH network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7e3e-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(29, 'PIH network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c7f24-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(30, 'CRS network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c8000-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(31, 'JHPIEGO network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c80f0-6d86-1034-a3b4-c83a35dda668', NULL, NULL),
(32, 'POZ network', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, '604c81d6-6d86-1034-a3b4-c83a35dda668', NULL, NULL);


 
/*Requetes pour inserer location de isante vers openmrs */
INSERT INTO location(location_id, name, city_village, country, latitude, longitude, creator, date_created, parent_location, uuid) 
select itech.clinicLookup.siteCode, itech.clinicLookup.clinic, itech.clinicLookup.commune,'Haiti',itech.clinicLookup.lat,
itech.clinicLookup.lng, 1,'2001-01-10', 
case when itech.clinicLookup.network="UGP MSPP" then 12 
when itech.clinicLookup.network="UMaryland" then 14 
when itech.clinicLookup.network="FOSREF" then 15 
when itech.clinicLookup.network="ICC" then 16 
when itech.clinicLookup.network="Non associée" then 17 
when itech.clinicLookup.network="GHESKIO" then 18 
when itech.clinicLookup.network="PATHFINDER" then 19 
when itech.clinicLookup.network="HTW" then 20 
when itech.clinicLookup.network="CDS" then 21
when itech.clinicLookup.network="ITECH" then 23
when itech.clinicLookup.network="MATHEUX" then 24
when itech.clinicLookup.network="UMiami" then 25
when itech.clinicLookup.network="URC" then 26
when itech.clinicLookup.network="CMMB" then 27
when itech.clinicLookup.network="SSQH" then 28
when itech.clinicLookup.network="PIH" then 29
when itech.clinicLookup.network="CRS" then 30
when itech.clinicLookup.network="JHPIEGO" then 31
when itech.clinicLookup.network="POZ" then 32
else NULL
END, UUID()
from itech.clinicLookup;
 /*Fin location */


/*create table (Une table intermediare) intermediate table in ISante*/
DROP TABLE IF EXISTS itech.patient_id_itech;
CREATE TABLE itech.patient_id_itech (    
  id INT(11) NOT NULL auto_increment,
  id_patient_openmrs INT(11) NOT NULL,
  id_patient_isante VARCHAR(11) NOT NULL,
  date_created datetime,
  CONSTRAINT pkpatientiditech PRIMARY KEY (id)
);
SELECT MAX(openmrs.person.person_id) INTO @maxid FROM openmrs.person;
INSERT INTO itech.patient_id_itech (itech.patient_id_itech.id_patient_openmrs, itech.patient_id_itech.id_patient_isante, itech.patient_id_itech.date_created)
SELECT @maxid:=@maxid+1, itech.patient.patientID, MIN(itech.encounter.createDate) 
FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID 
	WHERE itech.patient.location_id>0 AND itech.patient.patStatus=255
	GROUP BY itech.patient.patientID LIMIT 2000;
 
/*FIN create table intermediaire*/
/*Requetes pour inserer patient de isante vers openmrs(table person) */

SET foreign_key_checks = 0;
TRUNCATE person;
SET foreign_key_checks = 1;
/*default person*/
INSERT INTO `person` (`person_id`, `gender`, `birthdate`, `birthdate_estimated`, `dead`, `death_date`, `cause_of_death`, `creator`, `date_created`, `changed_by`, `date_changed`, `voided`, `voided_by`, `date_voided`, `void_reason`, `uuid`, `deathdate_estimated`, `birthtime`) VALUES
(1, 'M', NULL, 0, 0, NULL, NULL, NULL, '2005-01-01 00:00:00', NULL, NULL, 0, NULL, NULL, NULL, '04eced72-4c88-1034-97f9-c83a35dda668', 0, NULL),
(2, 'F', NULL, 0, 0, NULL, NULL, 2, '2016-04-05 09:09:12', NULL, NULL, 0, NULL, NULL, NULL, 'bff28a52-05bf-4005-b344-d9f914f61856', 0, NULL),
(3, 'M', NULL, 0, 0, NULL, NULL, 2, '2016-04-05 09:09:21', NULL, NULL, 0, NULL, NULL, NULL, '007037a0-0500-11e3-8ffd-0800200c9a66', 0, NULL),
(4, 'F', NULL, 0, 0, NULL, NULL, 2, '2016-04-05 09:09:21', NULL, NULL, 0, NULL, NULL, NULL, '9bed23d0-0502-11e3-8ffd-0800200c9a66', 0, NULL),
(5, 'M', NULL, 0, 0, NULL, NULL, 2, '2016-04-05 09:09:21', NULL, NULL, 0, NULL, NULL, NULL, 'af7c3340-0503-11e3-8ffd-0800200c9a66', 0, NULL),
(6, 'F', NULL, 0, 0, NULL, NULL, 2, '2016-04-05 09:09:21', NULL, NULL, 0, NULL, NULL, NULL, 'b7009090-4015-11e4-8e9b-2939a1809c8e', 0, NULL);

INSERT INTO person(person_id,gender, birthdate, birthdate_estimated, dead, death_date, creator, date_created, uuid)
SELECT itech.patient_id_itech.id_patient_openmrs,
	CASE WHEN itech.patient.sex=1 then 'F'
	ELSE 'M'
	END,
	CASE WHEN itech.patient.dobYy = 'XXXX' OR itech.patient.dobYy = '0000' OR itech.patient.dobYy="" 
	OR itech.patient.dobMm = "" OR itech.patient.dobMm = "XX" OR itech.patient.dobMm = "00" then NULL
	WHEN (itech.patient.dobYy<>'XXXX' OR itech.patient.dobYy<>'0000' OR itech.patient.dobYy<>"") 
	AND(itech.patient.dobMm<>"" OR itech.patient.dobMm<>"XX" OR itech.patient.dobMm<>"00")
	AND(itech.patient.dobDd="" OR itech.patient.dobDd="00" OR itech.patient.dobDd="XX") THEN CONCAT(itech.patient.dobYy, '-', itech.patient.dobMm,'-',01)
	ELSE
	CONCAT(itech.patient.dobYy, '-', itech.patient.dobMm,'-', itech.patient.dobDd)
	END,
	CASE WHEN (itech.patient.dobYy>0 AND itech.patient.dobMm>0) 
	AND (itech.patient.dobDd="" OR itech.patient.dobDd="00" OR itech.patient.dobDd="XX") then 1
	END,
	CASE WHEN date(itech.patient.deathDt)<>"0000-00-00" then 1
	END,
	CASE WHEN date(itech.patient.deathDt)="0000-00-00" then NULL
	ELSE
	itech.patient.deathDt
	END, 
	1, MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID 
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0
	GROUP BY itech.patient.patientID;
/*Requetes pour inserer patient de isante vers openmrs(table person_name) */
	SET foreign_key_checks = 0;
	TRUNCATE person_name;
	SET foreign_key_checks = 1;	
	/*default person_name*/
	INSERT INTO `person_name` (`person_name_id`, `preferred`, `person_id`, `prefix`, `given_name`, `middle_name`, `family_name_prefix`, `family_name`, `family_name2`, `family_name_suffix`, `degree`, `creator`, `date_created`, `voided`, `voided_by`, `date_voided`, `void_reason`, `changed_by`, `date_changed`, `uuid`) VALUES
	(1, 1, 1, NULL, 'Super', NULL, NULL, 'User', NULL, NULL, NULL, 1, '2005-01-01 00:00:00', 0, NULL, NULL, NULL, 2, '2016-04-05 09:09:21', '04eedc36-4c88-1034-97f9-c83a35dda668'),
	(2, 1, 2, NULL, 'Unknown', NULL, NULL, 'Provider', NULL, NULL, NULL, 2, '2016-04-05 09:09:12', 0, NULL, NULL, NULL, NULL, NULL, '0efca7b0-eff6-4264-b0c2-19ca4fe55f97'),
	(3, 0, 3, NULL, 'John', NULL, NULL, 'Smith', NULL, NULL, NULL, 2, '2016-04-05 09:09:21', 0, NULL, NULL, NULL, NULL, NULL, '9931751c-99e8-49b8-b04e-66efb93637ba'),
	(4, 0, 4, NULL, 'Jane', NULL, NULL, 'Smith', NULL, NULL, NULL, 2, '2016-04-05 09:09:21', 0, NULL, NULL, NULL, NULL, NULL, '886485fb-8bdb-4cb1-a1ac-0d89e9ee0595'),
	(5, 0, 5, NULL, 'Jake', NULL, NULL, 'Smith', NULL, NULL, NULL, 2, '2016-04-05 09:09:21', 0, NULL, NULL, NULL, NULL, NULL, 'f0d23bb3-63e5-4f11-aff7-89187c5c17d7'),
	(6, 0, 6, NULL, 'Julie', NULL, NULL, 'Smith', NULL, NULL, NULL, 2, '2016-04-05 09:09:21', 0, NULL, NULL, NULL, NULL, NULL, '0f56f9e2-92fa-4f5d-82cc-9264ce1c459d');
	
	
	INSERT INTO person_name(person_id, preferred, given_name, family_name, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs,1,itech.patient.fname,itech.patient.lname, 1,  MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0
	GROUP BY itech.patient.patientID;

/*Requetes pour inserer patient de isante vers openmrs(table person_address)*/
	SET foreign_key_checks = 0;
	TRUNCATE person_address;
	SET foreign_key_checks = 1;
INSERT INTO person_address(person_id, preferred, address1, city_village, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs,1,itech.patient.addrDistrict,itech.patient.addrSection, 1,  MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID 
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0
	GROUP BY itech.patient.patientID;
	
	
/*Requetes pour inserer patient de isante vers openmrs(table patient)*/
	SET foreign_key_checks = 0;
	TRUNCATE patient;
	SET foreign_key_checks = 1;
INSERT INTO patient(patient_id, creator, date_created)
	SELECT itech.patient_id_itech.id_patient_openmrs, 1, MIN(itech.encounter.createDate)
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0
	GROUP BY itech.patient.patientID;
/*Requetes pour inserer patient de isante vers openmrs(table patient_identifier-code NATIONAL)*/
	SET foreign_key_checks = 0;
	TRUNCATE patient_identifier;
	SET foreign_key_checks = 1;

	INSERT INTO patient_identifier(patient_id, identifier, identifier_type, preferred, location_id, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs, itech.patient.nationalID,4,0,itech.patient.location_id,1,MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID 
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0 AND itech.patient.nationalID<>"" 
	GROUP BY itech.patient.patientID;
/*Requetes pour inserer patient de isante vers openmrs(table patient_identifier CODE ST)*/
	INSERT INTO patient_identifier(patient_id, identifier, identifier_type, preferred, location_id, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs, itech.patient.clinicPatientID,5, 0, itech.patient.location_id, 1, MIN(itech.encounter.createDate),UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID 
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0 AND itech.patient.clinicPatientID<>""
	GROUP BY itech.patient.patientID;
/*Requetes pour inserer patient de isante vers openmrs(table person_attribute pour nom de la mere du patient)*/

	SET foreign_key_checks = 0;
	TRUNCATE person_attribute;
	SET foreign_key_checks = 1;
INSERT INTO person_attribute(person_id, value, person_attribute_type_id, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs, itech.patient.fnameMother,4, 1, MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID 
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0
	GROUP BY itech.patient.patientID;
/*Requetes pour inserer patient de isante vers openmrs(table person_attribute pour telephone du patient)*/
 INSERT INTO person_attribute(person_id, value, person_attribute_type_id, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs, itech.patient.telephone, 8, 1, MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0	
	GROUP BY itech.patient.patientID;
/*Requetes pour inserer patient de isante vers openmrs(table person_attribute pour lieu de naissance patient)*/
	
 INSERT INTO person_attribute(person_id, value, person_attribute_type_id, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs, itech.patient.birthDistrict, 2, 1, MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0	
	GROUP BY itech.patient.patientID;
	
/*Requetes pour inserer patient de isante vers openmrs(table person_attribute pour status patient)*/
	INSERT INTO person_attribute(person_id, value, person_attribute_type_id, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs,
	/*CASE WHEN itech.patient.maritalStatus=16 THEN 1057*/
	CASE WHEN itech.patient.maritalStatus=1 THEN 5555 /*MARRIED*/
	WHEN itech.patient.maritalStatus=8 THEN 1056 /*SEPARATED-SEPARE*/
	WHEN itech.patient.maritalStatus=4 THEN 1059 /*WIDOWED=veuve*/
	ELSE
	1057 /*Single-celebataire*/
	END,
	5,1, MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0
	GROUP BY itech.patient.patientID;
	
	/*Requetes pour inserer patient de isante vers openmrs(table patient_identifier OpenMRS ID)*/
	/*intermediate table for patient_identifier OpenMRS ID*/
	DROP TABLE IF EXISTS itech.idgen_log_entry;
	CREATE TABLE itech.idgen_log_entry (    
	  id INT(11) NOT NULL auto_increment,
	  identifier VARCHAR(50) NOT NULL,
	  CONSTRAINT pkpatientiditech PRIMARY KEY (id)
	);
	
	SELECT (MIN(openmrs.patient.patient_id)-1) INTO @minid FROM openmrs.patient;
	SELECT COUNT(openmrs.patient.patient_id) INTO @nb FROM openmrs.patient;
	INSERT INTO itech.idgen_log_entry (itech.idgen_log_entry.id, itech.idgen_log_entry.identifier)
	SELECT @minid:=@minid+1, openmrs.idgen_log_entry.identifier FROM openmrs.idgen_log_entry WHERE openmrs.idgen_log_entry.identifier<>'';
	/*Insertion in patient_identifier for OpenMRS ID*/
	INSERT INTO patient_identifier(patient_id, identifier, identifier_type, preferred, location_id, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs, itech.idgen_log_entry.identifier,1,1,itech.patient.location_id,1,MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID 
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.idgen_log_entry ON itech.patient_id_itech.id_patient_openmrs=itech.idgen_log_entry.id
	WHERE itech.patient.location_id>0 AND itech.idgen_log_entry.identifier<>''
	GROUP BY itech.patient.patientID;
	
	DELETE FROM idgen_log_entry WHERE identifier IN(SELECT identifier FROM patient_identifier WHERE identifier_type=1);
	/* END OF DEMOGRAPHIC PATIENT DATA MIGRATION */
	
	
