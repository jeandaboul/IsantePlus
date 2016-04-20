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
	/*
		MIGRATION FOR Date de prochaine visite 
	*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_datetime,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,5096,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.encounter.nxtVisitDd<1 AND itech.encounter.nxtVisitMm<1 AND itech.encounter.nxtVisitYy>0
		THEN CONCAT(itech.encounter.nxtVisitYy,'-',01,'-',01)
		WHEN itech.encounter.nxtVisitDd<1 AND itech.encounter.nxtVisitMm>0 AND itech.encounter.nxtVisitYy>0 
		THEN CONCAT(itech.encounter.nxtVisitYy,'-',itech.encounter.nxtVisitMm,'-',01)
		WHEN itech.encounter.nxtVisitDd>0 AND itech.encounter.nxtVisitMm>0 AND itech.encounter.nxtVisitYy>0 THEN 
		CONCAT(itech.encounter.nxtVisitYy,'-',itech.encounter.nxtVisitMm,'-',itech.encounter.nxtVisitDd)
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	WHERE itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND itech.encounter_vitals_obs.date_created=itech.encounter.createDate
	AND itech.encounter.nxtVisitYy>0;
	
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
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
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
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
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
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
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
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
	AND itech.vitals.vitalHr<>'';
	
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
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
	AND itech.vitals.vitalHr<>'';
	
	/*DATA Migration for vitals TAILLE*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,5090,itech.encounter_vitals_obs.id,
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
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
	AND itech.vitals.vitalHeight<>''
	OR itech.vitals.itech.vitals.vitalHeightCm<>'';
	/*DATA Migration for vitals POIDS*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,5089,itech.encounter_vitals_obs.id,
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
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
	AND itech.vitals.vitalWeight<>'';
	/*END OF SIGNES VITAUX MENU*/
	
	/*STARTING SOURCE DE RÉFÉRENCE MENU*/
	/*MIGRATION FOR Hôpital (patient a été hospitalisé antérieurement)*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159936,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.referHosp=1 THEN 5485
	ELSE NULL
	END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
	AND itech.vitals.referHosp=1;
	
	/*MIGRATION FOR Centres CDV intégrés*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159936,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.referVctCenter=1 THEN 159940
	ELSE NULL
	END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
	AND itech.vitals.referVctCenter=1;
	
	/*MIGRATION FOR Programme PTME*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159936,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.referPmtctProg=1 THEN 159937
	ELSE NULL
	END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
	AND itech.vitals.referPmtctProg=1;
	/*MIGRATION FOR Clinique Externe*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159936,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.referOutpatStd=1 THEN 160542
	ELSE NULL
	END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
	AND itech.vitals.referOutpatStd=1;
		/*MIGRATION FOR Programmes communautaires*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159936,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.referCommunityBasedProg=1 THEN 159938
	ELSE NULL
	END,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
	AND itech.vitals.referCommunityBasedProg=1;
	
	/*MIGRATION FOR Transfert d'un autre établissement de santé*/
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,comments,creator,date_created,uuid)
	SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159936,itech.encounter_vitals_obs.id,
	itech.encounter.visitDate,itech.encounter.siteCode,
	CASE WHEN itech.vitals.firstCareOtherFacText<>'' THEN 5622
	ELSE NULL
	END,itech.vitals.firstCareOtherFacText,1,itech.encounter.createDate,UUID()
	FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
	INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
	INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
	WHERE itech.vitals.siteCode=itech.encounter.siteCode
	AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
	AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
	AND itech.encounter.encounterType=1
	AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
	AND itech.vitals.firstCareOtherFacText<>'';
	
	/*END OF SOURCE DE RÉFÉRENCE MENU*/
	
	/*STARTING TEST ANTICORPS VIH MENU*/
	   /*Migration for Date du premier test (anticorps) VIH positif*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,160082,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.firstTestYy<>'' AND itech.vitals.firstTestMm<>'' THEN CONCAT(itech.vitals.firstTestYy,'-',itech.vitals.firstTestMm,'-',01)
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.firstTestYy<>''
		AND itech.vitals.firstTestMm<>'';
		
		/*Migration for Établissement où le test a été réalisé*/
		 /*Cet établissement */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159936,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.firstTestThisFac=1 THEN 163266
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.firstTestThisFac=1;
		
		/*Autre */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,comments,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159936,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.firstTestOtherFac=1 THEN 5622
		ELSE NULL
		END,itech.vitals.firstTestOtherFacText,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.firstTestOtherFac=1;
		
	/*END OF TEST ANTICORPS VIH MENU*/
	
	/*STARTING ANTECEDENTS OBSTETRIQUES ET GROSSESSE MENU*/
		/*GRAVIDA*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,5624,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.gravida<>'' THEN itech.vitals.gravida
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.gravida<>'';
		
		/*PARA*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1053,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.para<>'' THEN itech.vitals.para
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.para<>'';
		
		/*Aborta*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1823,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.aborta<>'' THEN itech.vitals.aborta
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.aborta<>'';
		
		/*Enfants vivants*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1825,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.children<>'' THEN itech.vitals.children
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.children<>'';
		
		/*Grossesse actuelle*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,5272,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.pregnant=1 THEN 1065
		WHEN itech.vitals.pregnant=2 THEN 1066
		WHEN itech.vitals.pregnant=4 THEN 1067
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.pregnant<>'';
		
		/*Migration for Date du dernier Pap Test*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163267,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.papTestDd<1 AND itech.vitals.papTestMm<1 AND itech.vitals.papTestYy>0 THEN CONCAT(itech.vitals.papTestYy,01,01)
		WHEN itech.vitals.papTestDd<1 AND itech.vitals.papTestMm>0 AND itech.vitals.papTestYy>0 THEN CONCAT(itech.vitals.papTestYy,itech.vitals.papTestMm,01)
		WHEN itech.vitals.papTestDd>0 AND itech.vitals.papTestMm>0 AND itech.vitals.papTestYy>0
		THEN CONCAT(itech.vitals.papTestYy,itech.vitals.papTestMm,itech.vitals.papTestDd)  
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.papTestYy>0;
		
		/* Migration for Date des dernières règles*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1427,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.papTestDd<1 AND itech.vitals.pregnantLmpMm<1 AND itech.vitals.pregnantLmpYy>0 THEN CONCAT(itech.vitals.pregnantLmpDd,01,01)
		WHEN itech.vitals.pregnantLmpDd<1 AND itech.vitals.pregnantLmpMm>0 AND itech.vitals.pregnantLmpYy>0 THEN CONCAT(itech.vitals.pregnantLmpYy,itech.vitals.pregnantLmpMm,01)
		WHEN itech.vitals.pregnantLmpDd>0 AND itech.vitals.pregnantLmpMm>0 AND itech.vitals.pregnantLmpYy>0
		THEN CONCAT(itech.vitals.pregnantLmpYy,itech.vitals.pregnantLmpMm,itech.vitals.pregnantLmpDd)  
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.pregnantLmpYy>0;
	
	/*END OF ANTECEDENTS OBSTETRIQUES ET GROSSESSE MENU*/
	
	/*STARTING ANTECEDENTS ÉTAT DE FONCTIONNEMENT MENU*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,162753,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.functionalStatus=1 THEN 159468
		WHEN itech.vitals.functionalStatus=2 THEN 160026
		WHEN itech.vitals.functionalStatus=4 THEN 162752
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.functionalStatus>0;
	/*END OF ANTECEDENTS ÉTAT DE FONCTIONNEMENT MENU*/
	/*STARTING MIGRATION FOR PLANNING FAMILIAL MENU*/
		/*YES OR NO / OUI OU Non */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,374,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.famPlan=1 THEN 965
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.famPlan=1;
		
		/*Préservatif */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,374,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.famPlan=1 AND itech.vitals.famPlanMethodCondom=1 THEN 190
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.famPlan=1
		AND itech.vitals.famPlanMethodCondom=1;
		
		/*DMPA */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,374,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.famPlan=1 AND itech.vitals.famPlanMethodDmpa=1 THEN 5279
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.famPlan=1
		AND itech.vitals.famPlanMethodDmpa=1;
		
		/*Pilules*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,374,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.famPlan=1 AND itech.vitals.famPlanMethodOcPills=1 THEN 780
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.famPlan=1
		AND itech.vitals.famPlanMethodOcPills=1;
		
		/* Autre  OTHER NON-CODED 5622*/
		/*INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,comments,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,374,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.famPlanOtherText<>'' THEN 5622
		ELSE NULL
		END,
		CASE WHEN itech.vitals.famPlan=1 AND itech.vitals.famPlanOtherText<>'' THEN itech.vitals.famPlanOtherText
		ELSE NULL
		END,
		1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND itech.encounter.visitDate=CONCAT(itech.vitals.visitDateYy,itech.vitals.visitDateMm,itech.vitals.visitDateDd)
		AND itech.vitals.famPlan=1
		AND itech.vitals.famPlanOtherText<>'';*/
	/*END OF MIGRATION FOR PLANNING FAMILIAL MENU*/
	/*STARTING MIGRATION FOR MODE PROBABLE DE TRANSMISSION DU VIH MENU*/
		/*Rapports sexuels avec un homme*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1061,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=1 AND itech.riskAssessments.riskAnswer=1 THEN 163290
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=1
		AND itech.riskAssessments.riskAnswer=1;
		
		/*Rapports sexuels avec une femme*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1061,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=3 AND itech.riskAssessments.riskAnswer=1 THEN 163291
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=3
		AND itech.riskAssessments.riskAnswer=1;
		/*Injection de drogues*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1061,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=9 AND itech.riskAssessments.riskAnswer=1 THEN 105
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=9
		AND itech.riskAssessments.riskAnswer=1;
		/*Bénéficier de sang/dérivé sanguin*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1061,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=15 AND itech.riskAssessments.riskAnswer=1 THEN 1063
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=15
		AND itech.riskAssessments.riskAnswer=1;
		/*FOR THE DATE*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163268,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=15 AND itech.riskAssessments.riskAnswer=1 AND itech.riskAssessments.riskDd<1 
		AND itech.riskAssessments.riskMm<1 AND itech.riskAssessments.riskYy>0 THEN CONCAT(itech.riskAssessments.riskYy,'-',01,'-',01)
		WHEN itech.riskAssessments.riskID=15 AND itech.riskAssessments.riskAnswer=1 AND itech.riskAssessments.riskDd<1 
		AND itech.riskAssessments.riskMm>0 AND itech.riskAssessments.riskYy>0 THEN CONCAT(itech.riskAssessments.riskYy,'-',itech.riskAssessments.riskMm,'-',01)
		WHEN itech.riskAssessments.riskID=15 AND itech.riskAssessments.riskAnswer=1 AND itech.riskAssessments.riskDd>0 
		AND itech.riskAssessments.riskMm>0 AND itech.riskAssessments.riskYy>0 THEN 
		CONCAT(itech.riskAssessments.riskYy,'-',itech.riskAssessments.riskMm,'-',itech.riskAssessments.riskDd)
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=15
		AND itech.riskAssessments.riskAnswer=1
		AND itech.riskAssessments.riskYy>0;
		/*Migration FOR Transmission mère a enfant*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1061,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=14 AND itech.riskAssessments.riskAnswer=1 THEN 163273
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=14
		AND itech.riskAssessments.riskAnswer=1;
		
		/*MIGRATION FOR Accident d'exposition au sang*/
			/*CREATE TABLE FOR CONCEPTS GROUP*/
			DROP TABLE IF EXISTS itech.obs_concept_group;
			CREATE TABLE itech.obs_concept_group (    
			  obs_id INT(11) NOT NULL,
			  person_id INT(11) NOT NULL,
			  concept_id INT(11) NOT NULL,
			  encounter_id INT(11) NOT NULL,
			  location_id INT(11) NOT NULL,
			  obs_datetime datetime,
			  CONSTRAINT pkobsconceptid PRIMARY KEY (obs_id)
			);
			/*Migration for obsgroup*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163288,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=12
		AND itech.riskAssessments.riskAnswer=1;
		
		INSERT INTO itech.obs_concept_group (obs_id,person_id,concept_id,encounter_id,location_id,obs_datetime)
		SELECT openmrs.obs.obs_id,openmrs.obs.person_id,openmrs.obs.concept_id,openmrs.obs.encounter_id,openmrs.obs.location_id,openmrs.obs.obs_datetime
		FROM openmrs.obs
		WHERE openmrs.obs.concept_id=163288;
		
		/*migration for the concept*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs, 160581,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.riskAssessments.riskID=12 AND itech.riskAssessments.riskAnswer=1 THEN 163274
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=12
		AND itech.riskAssessments.riskAnswer=1
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=163288;
		/*migration for the date*/
		
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs, 162601,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.riskAssessments.riskID=12 AND itech.riskAssessments.riskAnswer=1 AND itech.riskAssessments.riskDd<1 
		AND itech.riskAssessments.riskMm<1 AND itech.riskAssessments.riskYy>0 THEN CONCAT(itech.riskAssessments.riskYy,'-',01,'-',01)
		WHEN itech.riskAssessments.riskID=15 AND itech.riskAssessments.riskAnswer=1 AND itech.riskAssessments.riskDd<1 
		AND itech.riskAssessments.riskMm>0 AND itech.riskAssessments.riskYy>0 THEN CONCAT(itech.riskAssessments.riskYy,'-',itech.riskAssessments.riskMm,'-',01)
		WHEN itech.riskAssessments.riskID=15 AND itech.riskAssessments.riskAnswer=1 AND itech.riskAssessments.riskDd>0 
		AND itech.riskAssessments.riskMm>0 AND itech.riskAssessments.riskYy>0 THEN 
		CONCAT(itech.riskAssessments.riskYy,'-',itech.riskAssessments.riskMm,'-',itech.riskAssessments.riskDd)
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=12
		AND itech.riskAssessments.riskAnswer=1
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=163288;
		
		/*MIGRATION FOR Rapports hétérosexuelles avec :
		  - personne SIDA/VIH+
		*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1061,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=19 AND itech.riskAssessments.riskAnswer=1 THEN 163289
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=19
		AND itech.riskAssessments.riskAnswer=1;
		
		/*MIGRATION FOR - personne qui s'injecte de la drogue */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1061,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=5 AND itech.riskAssessments.riskAnswer=1 THEN 105
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=5
		AND itech.riskAssessments.riskAnswer=1;
		
		/*MIGRATION FOR - homme bisexuel */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1061,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=6 AND itech.riskAssessments.riskAnswer=1 THEN 163275
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=6
		AND itech.riskAssessments.riskAnswer=1;
		
		/*MIGRATION FOR - bénéficier de sang/dérivé sanguin */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1061,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=31 AND itech.riskAssessments.riskAnswer=1 THEN 1063
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=31
		AND itech.riskAssessments.riskAnswer=1;
	
	/*END OF MIGRATION FOR MODE PROBABLE DE TRANSMISSION DU VIH MENU*/
	
	/*MIGRATION FOR AUTRES FACTEURS DE RISQUE MENU*/
	/*Migration for Histoire ou présence de syphilis*/
	/*Migration for obsgroup*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163292,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=32
		AND (itech.riskAssessments.riskAnswer=1
		OR itech.riskAssessments.riskAnswer=2
		OR itech.riskAssessments.riskAnswer=4);
		
		INSERT INTO itech.obs_concept_group (obs_id,person_id,concept_id,encounter_id,location_id,obs_datetime)
		SELECT openmrs.obs.obs_id,openmrs.obs.person_id,openmrs.obs.concept_id,openmrs.obs.encounter_id,openmrs.obs.location_id,openmrs.obs.obs_datetime
		FROM openmrs.obs
		WHERE openmrs.obs.concept_id=163292;
		/*migration for the concept*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs, 163276,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.riskAssessments.riskID=32 AND itech.riskAssessments.riskAnswer=1 THEN 1065
		WHEN itech.riskAssessments.riskID=32 AND itech.riskAssessments.riskAnswer=2 THEN 1066
		WHEN itech.riskAssessments.riskID=32 AND itech.riskAssessments.riskAnswer=4 THEN 1067
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=163292
		AND itech.riskAssessments.riskID=32
		AND (itech.riskAssessments.riskAnswer=1
		OR itech.riskAssessments.riskAnswer=2
		OR itech.riskAssessments.riskAnswer=4);
		
		/*migration for Victime d'agression sexuelle*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs, 123160,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.riskAssessments.riskID=13 AND itech.riskAssessments.riskAnswer=1 THEN 1065
		WHEN itech.riskAssessments.riskID=13 AND itech.riskAssessments.riskAnswer=2 THEN 1066
		WHEN itech.riskAssessments.riskID=13 AND itech.riskAssessments.riskAnswer=4 THEN 1067
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=163292
		AND itech.riskAssessments.riskID=13
		AND (itech.riskAssessments.riskAnswer=1
		OR itech.riskAssessments.riskAnswer=2
		OR itech.riskAssessments.riskAnswer=4);
		
		/*Migration for Rapports sexuels :
			- ≥ 2 personnes dans les 3 dernières mois
		*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,160581,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=33 AND itech.riskAssessments.riskAnswer=1 THEN 5567
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=33
		AND itech.riskAssessments.riskAnswer=1;
		
		/*- par voie anale*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163278,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=7 AND itech.riskAssessments.riskAnswer=1 THEN 1065
		WHEN itech.riskAssessments.riskID=7 AND itech.riskAssessments.riskAnswer=2 THEN 1066
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=7
		AND (itech.riskAssessments.riskAnswer=1 OR itech.riskAssessments.riskAnswer=2);
		
		/*- avec travailleur/euse de sexe*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,160581,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=20 AND (itech.riskAssessments.riskAnswer=1 OR itech.riskAssessments.riskAnswer=2) THEN 160580
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=20
		AND (itech.riskAssessments.riskAnswer=1 OR itech.riskAssessments.riskAnswer=2);
		
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,160580,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=20 AND itech.riskAssessments.riskAnswer=1 THEN 1065 
		WHEN itech.riskAssessments.riskID=20 AND itech.riskAssessments.riskAnswer=2 THEN 1066
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=20
		AND (itech.riskAssessments.riskAnswer=1 OR itech.riskAssessments.riskAnswer=2);
		
		/* - L'échange de sexe pour argent/choses*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,160581,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=34 AND (itech.riskAssessments.riskAnswer=1 OR itech.riskAssessments.riskAnswer=2) THEN 160579
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=34
		AND (itech.riskAssessments.riskAnswer=1 OR itech.riskAssessments.riskAnswer=2);
		
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,160579,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.riskAssessments.riskID=34 AND itech.riskAssessments.riskAnswer=1 THEN 1065 
		WHEN itech.riskAssessments.riskID=34 AND itech.riskAssessments.riskAnswer=2 THEN 1066
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.riskAssessments ON itech.encounter.patientID=itech.riskAssessments.patientID
		WHERE itech.riskAssessments.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.riskAssessments.visitDateYy,'-',itech.riskAssessments.visitDateMm,'-',itech.riskAssessments.visitDateDd)
		AND itech.riskAssessments.riskID=34
		AND (itech.riskAssessments.riskAnswer=1 OR itech.riskAssessments.riskAnswer=2);
		
	/*END OF MIGRATION FOR AUTRES FACTEURS DE RISQUE MENU*/
	
	/*STARTING MIGRATION FOR COMPTE CD4 MENU*/
		/*Compte CD4 le plus bas*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159375,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.lowestCd4Cnt<>'' THEN itech.vitals.lowestCd4Cnt
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.lowestCd4Cnt<>'';
		/* DATE */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159376,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.lowestCd4CntDd<1 AND itech.vitals.lowestCd4CntMm<1 AND itech.vitals.lowestCd4CntYy>0 
		THEN CONCAT(itech.vitals.lowestCd4CntYy,'-',01,'-',01)
		WHEN itech.vitals.lowestCd4CntDd<1 AND itech.vitals.lowestCd4CntMm>0 AND itech.vitals.lowestCd4CntYy>0
		THEN CONCAT(itech.vitals.lowestCd4CntYy,'-',itech.vitals.lowestCd4CntMm,'-',01)
		WHEN itech.vitals.lowestCd4CntDd>0 AND itech.vitals.lowestCd4CntMm>0 AND itech.vitals.lowestCd4CntYy>0
		THEN CONCAT(itech.vitals.lowestCd4CntYy,'-',itech.vitals.lowestCd4CntMm,'-',itech.vitals.lowestCd4CntDd)
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.lowestCd4Cnt<>''
		AND itech.vitals.lowestCd4CntYy>0;
		/*Non effectué/Inconnu*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1941,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.lowestCd4Cnt<>'' AND itech.vitals.lowestCd4CntNotDone=1 THEN 1066
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.lowestCd4Cnt<>''
		AND itech.vitals.lowestCd4CntNotDone=1;
		/*MIGRATION for Virémie*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_numeric,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163280,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.firstViralLoad<>'' THEN itech.vitals.firstViralLoad
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.firstViralLoad<>'';
		
		/* DATE */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163281,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.firstViralLoadDd<1 AND itech.vitals.firstViralLoadMm<1 AND itech.vitals.firstViralLoadYy>0 
		THEN CONCAT(itech.vitals.firstViralLoadYy,'-',01,'-',01)
		WHEN itech.vitals.firstViralLoadDd<1 AND itech.vitals.firstViralLoadMm>0 AND itech.vitals.firstViralLoadYy>0
		THEN CONCAT(itech.vitals.firstViralLoadYy,'-',itech.vitals.firstViralLoadMm,'-',01)
		WHEN itech.vitals.firstViralLoadDd>0 AND itech.vitals.firstViralLoadMm>0 AND itech.vitals.firstViralLoadYy>0
		THEN CONCAT(itech.vitals.firstViralLoadYy,'-',itech.vitals.firstViralLoadMm,'-',itech.vitals.firstViralLoadDd)
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.firstViralLoad<>''
		AND itech.vitals.firstViralLoadYy>0;
		
	/*END OF MIGRATION FOR COMPTE CD4 MENU*/
	
	/*MIGRATION FOR STATUT TB MENU*/
	
	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1659,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.tbStatus.asymptomaticTb=1 AND (itech.tbStatus.completeTreat=0 OR itech.tbStatus.completeTreat='') 
		AND (itech.tbStatus.currentTreat=0 OR itech.tbStatus.currentTreat='') THEN 1660
		WHEN itech.tbStatus.completeTreat=1 AND (itech.tbStatus.asymptomaticTb=0 OR itech.tbStatus.asymptomaticTb='') 
		AND (itech.tbStatus.currentTreat=0 OR itech.tbStatus.currentTreat='') THEN 1663
		WHEN itech.tbStatus.currentTreat=1 AND (itech.tbStatus.asymptomaticTb=0 OR itech.tbStatus.asymptomaticTb='') 
		AND (itech.tbStatus.completeTreat=0 OR itech.tbStatus.completeTreat='') THEN 1662
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.tbStatus ON itech.encounter.patientID=itech.tbStatus.patientID
		WHERE itech.tbStatus.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.tbStatus.visitDateYy,'-',itech.tbStatus.visitDateMm,'-',itech.tbStatus.visitDateDd)
		AND (itech.tbStatus.asymptomaticTb=1 OR itech.tbStatus.completeTreat=1 OR itech.tbStatus.currentTreat=1);
		/*Migration for Date complété */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,159431,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.tbStatus.completeTreatDd<1 AND itech.tbStatus.completeTreatMm<1 AND itech.tbStatus.completeTreatYy>0 
		THEN CONCAT(itech.tbStatus.completeTreatYy,'-',01,'-',01)
		WHEN itech.tbStatus.completeTreatDd<1 AND itech.tbStatus.completeTreatMm>0 AND itech.tbStatus.completeTreatYy>0
		THEN CONCAT(itech.tbStatus.completeTreatYy,'-',itech.tbStatus.completeTreatMm,'-',01)
		WHEN itech.tbStatus.completeTreatDd>0 AND itech.tbStatus.completeTreatMm>0 AND itech.tbStatus.completeTreatYy>0
		THEN CONCAT(itech.tbStatus.completeTreatYy,'-',itech.tbStatus.completeTreatMm,'-',itech.tbStatus.completeTreatDd)
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.tbStatus ON itech.encounter.patientID=itech.tbStatus.patientID
		WHERE itech.tbStatus.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.tbStatus.visitDateYy,'-',itech.tbStatus.visitDateMm,'-',itech.tbStatus.visitDateDd)
		AND itech.tbStatus.completeTreat=1
		AND itech.tbStatus.completeTreatYy>0;
		/*On Going with james*/
	
	/*END OF MIGRATION FOR STATUT TB MENU */
	
	/*MIGRATION FOR VACCINS MENU*/
	/*MIGRATION FOR Hépatite B*/
	/*concept group */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1421,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.vaccTetanus=1 OR itech.vitals.vaccTetanus=1);
		
		INSERT INTO itech.obs_concept_group (obs_id,person_id,concept_id,encounter_id,location_id,obs_datetime)
		SELECT openmrs.obs.obs_id,openmrs.obs.person_id,openmrs.obs.concept_id,openmrs.obs.encounter_id,openmrs.obs.location_id,openmrs.obs.obs_datetime
		FROM openmrs.obs
		WHERE openmrs.obs.concept_id=1421;
		
		/*migration for the concept*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs, 984,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.vitals.vaccHepB=1 THEN 1685
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.vaccHepB=1
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=1421;
		
		/*migration for MM/AA*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1410,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.vitals.vaccHepB=1 AND itech.vitals.vaccHepBMm<1 AND itech.vitals.vaccHepBYy>0 THEN CONCAT(itech.vitals.vaccHepBYy,'-',01,'-',01)
		WHEN itech.vitals.vaccHepB=1 AND itech.vitals.vaccHepBMm>0 AND itech.vitals.vaccHepBYy>0 THEN CONCAT(itech.vitals.vaccHepBYy,'-',itech.vitals.vaccHepBMm,'-',01)
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.vaccHepB=1
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=1421
		AND itech.vitals.vaccHepBYy>0;
		
		/*migration for Nombre de dose */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_numeric,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1418,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.vitals.vaccHepB=1 AND itech.vitals.hepBdoses>=0 THEN itech.vitals.hepBdoses
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.vaccHepB=1
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=1421
		AND itech.vitals.hepBdoses>=0;
		/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
		/*MIGRATION FOR Tétanos*/ 
		/*concept group */
		/*migration for the concept*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,984,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.vitals.vaccTetanus=1 THEN 1685
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.vaccTetanus=1
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=1421;
		
		/*migration for MM/AA*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1410,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.vitals.vaccTetanus=1 AND itech.vitals.vaccTetanusMm<1 AND itech.vitals.vaccTetanusYy>0 THEN CONCAT(itech.vitals.vaccTetanusYy,'-',01,'-',01)
		WHEN itech.vitals.vaccTetanus=1 AND itech.vitals.vaccTetanusMm>0 AND itech.vitals.vaccTetanusYy>0
		THEN CONCAT(itech.vitals.vaccTetanusYy,'-',itech.vitals.vaccTetanusMm,'-',01)
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.vaccTetanus=1
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=1421
		AND itech.vitals.vaccTetanusYy>0;
		
		/*migration for Nombre de dose */
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_numeric,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1418,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.vitals.vaccTetanus=1 AND itech.vitals.tetDoses>0 THEN itech.vitals.tetDoses
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.vaccTetanus=1
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=1421
		AND itech.vitals.tetDoses>0
		AND itech.vitals.tetDoses<>'';
		
		/*On going*/
		/*Autre preciser*/
	/*END OF MIGRATION FOR VACCINS MENU*/
	/*MIGRATION FOR SYMPTÔMES MENU*/
	  /*migration for Douleur abdominale*/
	  /*concept group */
		/*INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1727,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		INNER JOIN itech.obs ON itech.encounter.encounter_id=itech.obs.encounter_id
		INNER JOIN itech.patient ON itech.obs.person_id=itech.patient.person_id
		WHERE itech.obs.location_id=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND itech.obs.concept_id=7000
		AND itech.obs.value_boolean=1;
		
		INSERT INTO itech.obs_concept_group (obs_id,person_id,concept_id,encounter_id,location_id,obs_datetime)
		SELECT MAX(openmrs.obs.obs_id),openmrs.obs.person_id,openmrs.obs.concept_id,openmrs.obs.encounter_id,openmrs.obs.location_id,openmrs.obs.obs_datetime
		FROM openmrs.obs
		WHERE openmrs.obs.concept_id=1421 GROUP BY openmrs.obs.person_id;*/
		
		/*migration for the concept*/
	/*	INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,obs_group_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs, 984,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,itech.obs_concept_group.obs_id,
		CASE WHEN itech.vitals.vaccHepB=1 THEN 1685
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		INNER JOIN itech.obs_concept_group ON itech.patient_id_itech.id_patient_openmrs=itech.obs_concept_group.person_id
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.vaccHepB=1
		AND itech.encounter_vitals_obs.id=itech.obs_concept_group.encounter_id
		AND itech.encounter.siteCode=itech.obs_concept_group.location_id
		AND itech.obs_concept_group.concept_id=1421; */
		/*On going IMPORTANT */
	/*END OF MIGRATION FOR SYMPTÔMES MENU*/
	/*MIGRATION FOR EXAMEN CLINIQUE*/
		/* Migration for Général*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1119,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalGeneral=1 THEN 159438
		WHEN itech.vitals.physicalGeneral=2 THEN 163293
		WHEN itech.vitals.physicalGeneral=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalGeneral=1 OR itech.vitals.physicalGeneral=2 OR itech.vitals.physicalGeneral=4);
		/*Migration for Peau*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1120,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalSkin=1 THEN 1115
		WHEN itech.vitals.physicalSkin=2 THEN 1116
		WHEN itech.vitals.physicalSkin=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalSkin=1 OR itech.vitals.physicalSkin=2 OR itech.vitals.physicalSkin=4);
		/*Migration for Bouche/Orale*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163308,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalOral=1 THEN 1115
		WHEN itech.vitals.physicalOral=2 THEN 1116
		WHEN itech.vitals.physicalOral=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalOral=1 OR itech.vitals.physicalOral=2 OR itech.vitals.physicalOral=4);
		/*Migration for Oreilles*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163337,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalEarsNose=1 THEN 1115
		WHEN itech.vitals.physicalEarsNose=2 THEN 1116
		WHEN itech.vitals.physicalEarsNose=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalEarsNose=1 OR itech.vitals.physicalEarsNose=2 OR itech.vitals.physicalEarsNose=4);
		/*Migration for Yeux*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163309,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalEyes=1 THEN 1115
		WHEN itech.vitals.physicalEyes=2 THEN 1116
		WHEN itech.vitals.physicalEyes=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalEyes=1 OR itech.vitals.physicalEyes=2 OR itech.vitals.physicalEyes=4);
		/*Migration for Ganglions lymphatiques*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1121,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalLymph=1 THEN 1115
		WHEN itech.vitals.physicalLymph=2 THEN 1116
		WHEN itech.vitals.physicalLymph=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalLymph=1 OR itech.vitals.physicalLymph=2 OR itech.vitals.physicalLymph=4);
		/*Migration for Poumons*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1123,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalLungs=1 THEN 1115
		WHEN itech.vitals.physicalLungs=2 THEN 1116
		WHEN itech.vitals.physicalLungs=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalLungs=1 OR itech.vitals.physicalLungs=2 OR itech.vitals.physicalLungs=4);
		/*Migration for Cardio-vasculaire*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1124,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalCardio=1 THEN 1115
		WHEN itech.vitals.physicalCardio=2 THEN 1116
		WHEN itech.vitals.physicalCardio=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalCardio=1 OR itech.vitals.physicalCardio=2 OR itech.vitals.physicalCardio=4);
		/*Migration for Abdomen*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1125,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalAbdomen=1 THEN 1115
		WHEN itech.vitals.physicalAbdomen=2 THEN 1116
		WHEN itech.vitals.physicalAbdomen=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalAbdomen=1 OR itech.vitals.physicalAbdomen=2 OR itech.vitals.physicalAbdomen=4);
		/*Migration for Urogénital*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1126,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalUro=1 THEN 1115
		WHEN itech.vitals.physicalUro=2 THEN 1116
		WHEN itech.vitals.physicalUro=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalUro=1 OR itech.vitals.physicalUro=2 OR itech.vitals.physicalUro=4);
		/*Migration for Musculo-squeletal*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1128,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalMusculo=1 THEN 1115
		WHEN itech.vitals.physicalMusculo=2 THEN 1116
		WHEN itech.vitals.physicalMusculo=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalMusculo=1 OR itech.vitals.physicalMusculo=2 OR itech.vitals.physicalMusculo=4);
		/*Migration for Neurologique*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1129,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.physicalNeuro=1 THEN 1115
		WHEN itech.vitals.physicalNeuro=2 THEN 1116
		WHEN itech.vitals.physicalNeuro=4 THEN 1118
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND (itech.vitals.physicalNeuro=1 OR itech.vitals.physicalNeuro=2 OR itech.vitals.physicalNeuro=4);
		/*Migration for Description des conclusions anormales*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_text,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1391,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.vitals.clinicalExam<>'' THEN itech.vitals.clinicalExam
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.vitals ON itech.encounter.patientID=itech.vitals.patientID
		WHERE itech.vitals.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.vitals.visitDateYy,'-',itech.vitals.visitDateMm,'-',itech.vitals.visitDateDd)
		AND itech.vitals.clinicalExam<>'';
		
	/*END OF MIGRATION FOR EXAMEN CLINIQUE*/
	
	/*MIGRATION FOR ÉVALUATION TB*/
		/*Migration for Présence de cicatrice BCG*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,160265,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.tbStatus.presenceBCG=1 THEN 1065
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.tbStatus ON itech.encounter.patientID=itech.tbStatus.patientID
		WHERE itech.tbStatus.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.tbStatus.visitDateYy,'-',itech.tbStatus.visitDateMm,'-',itech.tbStatus.visitDateDd)
		AND itech.tbStatus.presenceBCG=1;
		
		/*migration for Prophylaxie à I'INH*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1110,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.tbStatus.propINH=1 THEN 1679
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.tbStatus ON itech.encounter.patientID=itech.tbStatus.patientID
		WHERE itech.tbStatus.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.tbStatus.visitDateYy,'-',itech.tbStatus.visitDateMm,'-',itech.tbStatus.visitDateDd)
		AND itech.tbStatus.propINH=1;
		
		/*Migration for Suspicion de TB selon les symptômes*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,1659,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.tbStatus.suspicionTBwSymptoms=1 THEN 142177
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.tbStatus ON itech.encounter.patientID=itech.tbStatus.patientID
		WHERE itech.tbStatus.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.tbStatus.visitDateYy,'-',itech.tbStatus.visitDateMm,'-',itech.tbStatus.visitDateDd)
		AND itech.tbStatus.suspicionTBwSymptoms=1;
		/*Date d'arrêt de I'INH*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_datetime,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,163284,itech.encounter_vitals_obs.id,
		itech.encounter.visitDate,itech.encounter.siteCode,
		CASE WHEN itech.tbStatus.arretINHMm<0 AND itech.tbStatus.arretINHYy>0 THEN CONCAT(itech.tbStatus.arretINHYy,'-',01,'-',01)
		WHEN itech.tbStatus.arretINHMm>0 AND itech.tbStatus.arretINHYy>0 THEN CONCAT(itech.tbStatus.arretINHYy,'-',itech.tbStatus.arretINHMm,'-',01)
		ELSE NULL
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.tbStatus ON itech.encounter.patientID=itech.tbStatus.patientID
		WHERE itech.tbStatus.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.tbStatus.visitDateYy,'-',itech.tbStatus.visitDateMm,'-',itech.tbStatus.visitDateDd)
		AND itech.tbStatus.arretINHYy>0;
		
	/*END OF MIGRATION FOR ÉVALUATION TB*/
	/*MIGRATION FOR ANTÉCEDENTS MÉDICAUX ET DIAGNOSTICS ACTUELS*/
	  /*Migration for Lymphadénopathie chronique persistante*/
	  INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,5328,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=435
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
	  /*Migration for Candidose, vulvo-vaginale (non chronique)*/
	   INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,298,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=406
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Infections récurrentes des voies respiratoires supérieures*/
		  INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,127794,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=403
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Manifestations cutanéomuqueuses secondaires*/
		  INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,512,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=402
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		
		/*Migration for Ulcere Ulcérations buccales récurrentes (non chronique)*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,111721,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=407
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Zona*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,117543,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=192
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Affections inflammatoires pelviennes*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,902,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=297
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Candidose, buccale (muguet)*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,5334,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=196
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Candidose, vulvo-vaginale chronique (>1 mois)*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,298,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=396
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Infections bactérienne, autre (septicémie incluse)*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,5333,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=408
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Leucoplasie chevelue buccale*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,5337,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=202
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		
		/*Migration for Méningites bactériennes*/
			INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,121255,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=205 
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for M. tuberculosis(TB) pulmonaire Si actif, complétez la section Tuberculose*/
		
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,42,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=409 
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		
		/*Migration for Tuberculose multirésistante Si actif, complétez la section Tuberculose*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,159355,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=715 
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Pneumonie bactérienne*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,5030,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=410
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Cancer cervical invasif*/
				INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,116023,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=218
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Retinite à CMV*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,5035,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=411
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for CMV viscéral (sauf rétine, ou foie, rate, ganglions lymphatiques)*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,142963,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=230
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Coccidiomycoses (extra pulmonaire)*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,120330,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=233
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Méningites à Cryptococcose (extra pulmonaire)*/
		/*INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,5033,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=257
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);*/
		/*Migration for Cryptococcocus (extra pulmonaire)*/
		/* A verifier avec james
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,5033,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=260
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		*/
		/*Migration for Démence liée au VIH*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,1460,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=412
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Salmonella: septicémie (non typhoid)*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,5354,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=433
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Accidents cérébro-vasculaires*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,
		CASE WHEN itech.conditions.conditionActive=1 THEN 130864
		WHEN itech.conditions.conditionActive=2 THEN 132827
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=428
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		
		/*Migration for Anémie*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,
		CASE WHEN itech.conditions.conditionActive=1 THEN 1226
		WHEN itech.conditions.conditionActive=2 THEN 121629
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=303
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Cancer Anal*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,129079,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=306
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		
		/*Migration for Cancer, Autre (Stade IV de l’OMS exclu) préciser*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,116030,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=429
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Coronaropathies*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,119816,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=430
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Diabète*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,
		CASE WHEN itech.conditions.conditionActive=1 THEN 142474
		WHEN itech.conditions.conditionActive=2 THEN 142473
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=315
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Hépatite B*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,111759,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=320
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Hépatite C*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,
		CASE WHEN itech.conditions.conditionActive=1 THEN 149743
		WHEN itech.conditions.conditionActive=2 THEN 145347
		END,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=323
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Hyperlipidémie*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,117441,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=326
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
	/*Migration for Hypertension*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,117339,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=329
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Lipodystrophie*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,135761,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=332
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Malaria, suspecté*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,116128,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=716
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
		/*Migration for Malaria, confirmé*/
		INSERT INTO obs(person_id,concept_id,encounter_id,obs_datetime,location_id,value_coded,creator,date_created,uuid)
		SELECT DISTINCT itech.patient_id_itech.id_patient_openmrs,
		CASE WHEN itech.conditions.conditionActive=1 THEN 6042
		WHEN itech.conditions.conditionActive=2 THEN 6097
		END,itech.encounter_vitals_obs.id,
		CASE WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm<1 
				THEN CONCAT(itech.conditions.conditionYy,'-',01,'-',01)
		WHEN (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2) AND itech.conditions.conditionYy>0 AND itech.conditions.conditionMm>0
			THEN CONCAT(itech.conditions.conditionYy,'-',itech.conditions.conditionMm,'-',01)
		ELSE
		itech.encounter.visitDate
		END,itech.encounter.siteCode,160148,1,itech.encounter.createDate,UUID()
		FROM itech.encounter INNER JOIN itech.patient_id_itech ON itech.encounter.patientID=itech.patient_id_itech.id_patient_isante
		INNER JOIN itech.encounter_vitals_obs ON itech.encounter.encounter_id=itech.encounter_vitals_obs.encounter_id
		INNER JOIN itech.conditions ON itech.encounter.patientID=itech.conditions.patientID
		WHERE itech.conditions.siteCode=itech.encounter.siteCode
		AND itech.encounter.patientID=itech.encounter_vitals_obs.patient_id
		AND itech.encounter.siteCode=itech.encounter_vitals_obs.siteCode
		AND itech.encounter.encounterType=1
		AND DATE(itech.encounter.visitDate)=CONCAT(itech.conditions.visitDateYy,'-',itech.conditions.visitDateMm,'-',itech.conditions.visitDateDd)
		AND itech.conditions.conditionID=335
		AND (itech.conditions.conditionActive=1 OR itech.conditions.conditionActive=2);
	/*END OF MIGRATION FOR ANTÉCEDENTS MÉDICAUX ET DIAGNOSTICS ACTUELS*/
	
	
	
	
	
	
	
	
