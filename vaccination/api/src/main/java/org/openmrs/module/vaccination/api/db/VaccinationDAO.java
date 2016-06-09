/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.vaccination.api.db;

import java.util.List;

import org.openmrs.module.vaccination.Vaccination;
import org.openmrs.module.vaccination.api.VaccinationService;

/**
 *  Database methods for {@link VaccinationService}.
 */
public interface VaccinationDAO {
	
	/*
	 * Add DAO methods here
	 */
	List<Vaccination> getAllVaccinationType();
	Vaccination getVaccinationType(Integer vaccinationTypeId);
	Vaccination saveVaccinationType(Vaccination vaccinationType);
	void purgeVaccinationType(Vaccination vaccinationType);
}