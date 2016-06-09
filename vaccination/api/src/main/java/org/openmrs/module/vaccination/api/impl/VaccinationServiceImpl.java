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
package org.openmrs.module.vaccination.api.impl;

import java.util.List;

import org.openmrs.api.impl.BaseOpenmrsService;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.module.vaccination.Vaccination;
import org.openmrs.module.vaccination.api.VaccinationService;
import org.openmrs.module.vaccination.api.db.VaccinationDAO;

/**
 * It is a default implementation of {@link VaccinationService}.
 */
public class VaccinationServiceImpl extends BaseOpenmrsService implements VaccinationService {
	
	protected final Log log = LogFactory.getLog(this.getClass());
	
	private VaccinationDAO dao;
	
	/**
     * @param dao the dao to set
     */
    public void setDao(VaccinationDAO dao) {
	    this.dao = dao;
    }
    
    /**
     * @return the dao
     */
    public VaccinationDAO getDao() {
	    return dao;
    }
    @Override
	public List<Vaccination> getAllVaccinationType() {
		// TODO Auto-generated method stub
		return dao.getAllVaccinationType();
	}

	@Override
	public Vaccination getVaccinationType(Integer vaccinationTypeId) {
		// TODO Auto-generated method stub
		return dao.getVaccinationType(vaccinationTypeId);
	}

	@Override
	public Vaccination saveVaccinationType(Vaccination vaccinationType) {
		// TODO Auto-generated method stub
		return dao.saveVaccinationType(vaccinationType);
	}
	public void purgeVaccinationType(Vaccination vaccinationType){
		dao.purgeVaccinationType(vaccinationType);
	}

}