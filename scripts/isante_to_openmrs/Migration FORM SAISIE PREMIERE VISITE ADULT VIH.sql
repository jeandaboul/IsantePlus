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
		
	
	/*END OF MIGRATION FOR STATUT TB MENU */
	
	
