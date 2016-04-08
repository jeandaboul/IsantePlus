/*DATA Migration for ADULT VIH FORM */
	/*First visit encounter - Saisie première visite adult*/
	/*create table (Une table intermediare) intermediate table in ISante*/
DROP TABLE IF EXISTS itech.encounter_vitals_obs;
CREATE TABLE itech.encounter_vitals_obs (    
  id INT(11) NOT NULL auto_increment,
  encounter_id INT(11) NOT NULL,
  patient_id VARCHAR(11) NOT NULL,
  siteCode INT(11) NOT NULL,
  date_created datetime,
  CONSTRAINT pkpatientiditech PRIMARY KEY (id)
);
INSERT INTO itech.encounter_vitals_obs(itech.encounter_vitals_obs.encounter_id, itech.encounter_vitals_obs.patient_id,
	itech.encounter_vitals_obs.siteCode,itech.encounter_vitals_obs.date_created)
	SELECT itech.encounter.encounter_id,itech.encounter.patientID,itech.encounter.siteCode,itech.encounter.createDate FROM itech.encounter;
	
	/*Encounter Migration*/
	INSERT INTO encounter(encounter_id,encounter_type,patient_id,location_id,form_id,encounter_datetime,creator,date_created,date_changed,uuid)
	SELECT itech.encounter_vitals_obs.id,1,itech.patient_id_itech.id_patient_openmrs,itech.encounter.siteCode,6,
	itech.encounter.visitDate,1,itech.encounter.createDate,itech.encounter.lastModified,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	WHERE itech.encounter.encounterType=1
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode; 
	/* SIGNES VITAUX MENU */
	/*DATA Migration for vitals Temp*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,5088,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.vitalTempUnits=1 THEN itech.vitals.vitalTemp
	WHEN itech.vitals.vitalTempUnits=2 THEN (ROUND(((itech.vitals.vitalTemp-32)/1.8000),2))
	/*ELSE NULL*/
	END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	LEFT JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE /*itech.vitals.siteCode=itech.encounter.siteCode*/
	itech.vitals.siteCode IN(select itech.encounter.siteCode FROM encounter WHERE itech.encounter.encounterType=1)
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND itech.encounter.visitDate=CONCAT(itech.vitals.visitDateYy,itech.vitals.visitDateMm,itech.vitals.visitDateDd)
	AND itech.encounter_vitals_obs.date_created=itech.encounter.createDate
	AND itech.vitals.vitalTemp<>'';
	
	/*DATA Migration for vitals TA*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,5085,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.vitalBPUnits=1 THEN itech.vitals.vitalBp1
	WHEN itech.vitals.vitalBPUnits=2 THEN itech.vitals.vitalBp1*10
	ELSE NULL
	END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND itech.encounter.visitDate=CONCAT(itech.vitals.visitDateYy,itech.vitals.visitDateMm,itech.vitals.visitDateDd)
	AND itech.vitals.vitalBp1<>'';
	
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,5086,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.vitalBPUnits=1 THEN itech.vitals.vitalBp2
	WHEN itech.vitals.vitalBPUnits=2 THEN vitalBp2*10
	END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND itech.encounter.visitDate=CONCAT(itech.vitals.visitDateYy,itech.vitals.visitDateMm,itech.vitals.visitDateDd)
	AND itech.vitals.vitalBp2<>'';
	
	/*DATA Migration for vitals POULS*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,5087,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,vitals.vitalHr,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND itech.encounter.visitDate=CONCAT(itech.vitals.visitDateYy,itech.vitals.visitDateMm,itech.vitals.visitDateDd)
	AND vitals.vitalHr<>'';
	
	/*DATA Migration for vitals FR*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,5242,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,vitals.vitalRr,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND itech.encounter.visitDate=CONCAT(itech.vitals.visitDateYy,itech.vitals.visitDateMm,itech.vitals.visitDateDd)
	AND vitals.vitalHr<>'';
	
	/*DATA Migration for vitals TAILLE*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs,5090,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.vitalHeightCm<>'' THEN itech.vitals.vitalHeightCm
	WHEN itech.vitals.vitalHeight<>''  THEN vitalHeight*100
	ELSE NULL
	END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND itech.encounter.visitDate=CONCAT(itech.vitals.visitDateYy,itech.vitals.visitDateMm,itech.vitals.visitDateDd)
	AND vitals.vitalHeight<>'';
	/*DATA Migration for vitals POIDS*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
	SELECT itech.patient_id_itech.id_patient_openmrs,5089,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.vitalWeightUnits=1 THEN itech.vitals.vitalWeight
	WHEN itech.vitals.vitalWeightUnits=2  THEN itech.vitals.vitalWeight/2.2046
	ELSE NULL
	END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND itech.encounter.visitDate=CONCAT(itech.vitals.visitDateYy,itech.vitals.visitDateMm,itech.vitals.visitDateDd)
	AND vitals.vitalWeight<>'';
	
	/*END OF SIGNES VITAUX MENU*/