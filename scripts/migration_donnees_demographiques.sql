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

--
-- Contenu de la table `location`
--

INSERT INTO `location` (`location_id`, `name`, `description`, `address1`, `address2`, `city_village`, `state_province`, 
`postal_code`, `country`, `latitude`, `longitude`, `creator`, `date_created`, `county_district`,
 `address3`, `address4`, `address5`, `address6`, `retired`, `retired_by`, `date_retired`, `retire_reason`, `parent_location`, `uuid`, `changed_by`, `date_changed`) VALUES
(12, "UGP MSPP network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(14, "UMaryland network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(15, "FOSREF network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(16, "ICC network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(17, "Non associée network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(18, "GHESKIO network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(19, "PATHFINDER network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(20, "HTW network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(21, "CDS network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(23, "ITECH network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(24, "MATHEUX network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(25, "UMiami network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(26, "URC network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(27, "CMMB network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(28, "SSQH network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(29, "PIH network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(30, "CRS network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(31, "JHPIEGO network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(32, "POZ network", NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2000-01-10 11:00:00', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

 
/*Requetes pour inserer location de isante vers openmrs */
INSERT INTO location(location_id, name, city_village, country, latitude, longitude, creator, date_created, parent_location) 
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
END
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
	GROUP BY itech.patient.patientID LIMIT 200;
 
/*FIN create table intermediaire*/
/*Requetes pour inserer patient de isante vers openmrs(table person) */
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
	INSERT INTO person_name(person_id, preferred, given_name, family_name, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs,1,itech.patient.fname,itech.patient.lname, 1,  MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0
	GROUP BY itech.patient.patientID;

/*Requetes pour inserer patient de isante vers openmrs(table person_address)*/
INSERT INTO person_address(person_id, preferred, address1, city_village, creator, date_created, uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs,1,itech.patient.addrDistrict,itech.patient.addrSection, 1,  MIN(itech.encounter.createDate), UUID()
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID 
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0
	GROUP BY itech.patient.patientID;
/*Requetes pour inserer patient de isante vers openmrs(table patient)*/
INSERT INTO patient(patient_id, creator, date_created)
	SELECT itech.patient_id_itech.id_patient_openmrs, 1, MIN(itech.encounter.createDate)
	FROM itech.patient INNER JOIN itech.encounter ON itech.patient.patientID = itech.encounter.patientID
	INNER JOIN itech.patient_id_itech ON itech.patient.patientID=itech.patient_id_itech.id_patient_isante
	WHERE itech.patient.location_id>0
	GROUP BY itech.patient.patientID;
/*Requetes pour inserer patient de isante vers openmrs(table patient_identifier-code NATIONAL)*/
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
	/*SELECT MIN(itech.patient_id_itech.id_patient_openmrs)-1 INTO @minid1 FROM itech.patient_id_itech;*/
	INSERT INTO patient_identifier(patient_id, identifier, identifier_type, preferred, location_id, creator, date_created, uuid)
	SELECT patient.patient_id, idgen_log_entry.identifier,1,1,patient_identifier.location_id, 1, patient_identifier.date_created,UUID()
	FROM patient INNER JOIN idgen_log_entry ON patient.patient_id = idgen_log_entry.id
	INNER JOIN patient_identifier ON idgen_log_entry.id=patient_identifier.patient_id
	AND patient_identifier.identifier_type=4;
	
	DELETE FROM idgen_log_entry WHERE identifier IN(SELECT identifier FROM patient_identifier WHERE identifier_type=1);
	/* END OF DEMOGRAPHIC PATIENT DATA MIGRATION */
	
	