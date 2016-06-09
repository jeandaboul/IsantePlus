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
package org.openmrs.module.vaccination.api.db.hibernate;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.openmrs.module.vaccination.Vaccination;
import org.openmrs.module.vaccination.api.db.VaccinationDAO;

/**
 * It is a default implementation of  {@link VaccinationDAO}.
 */
public class HibernateVaccinationDAO implements VaccinationDAO {
	protected final Log log = LogFactory.getLog(this.getClass());
	
	private SessionFactory sessionFactory;
	
	/**
     * @param sessionFactory the sessionFactory to set
     */
    public void setSessionFactory(SessionFactory sessionFactory) {
	    this.sessionFactory = sessionFactory;
    }
    
	/**
     * @return the sessionFactory
     */
    public SessionFactory getSessionFactory() {
	    return sessionFactory;
    }
    
    @SuppressWarnings("unchecked")
   	@Override
   	public List<Vaccination> getAllVaccinationType() {
   		// TODO Auto-generated method stub
    	String requette="from Vaccination";
    	Session session = sessionFactory.getCurrentSession();
		Query query = session.createQuery(requette);
		List<Vaccination> fiches = query.list();
		return fiches;
   		//return sessionFactory.getCurrentSession().createCriteria(Vaccination.class).list();
   	}
    
   	@Override
   	public Vaccination getVaccinationType(Integer vaccinationTypeId) {
   		// TODO Auto-generated method stub
   		return (Vaccination)
   		sessionFactory.getCurrentSession().get(Vaccination.class, vaccinationTypeId);
   	}

   	@Override
   	public Vaccination saveVaccinationType(Vaccination vaccinationType) {
   		// TODO Auto-generated method stub
   		sessionFactory.getCurrentSession().save(vaccinationType);
   		return vaccinationType;
   	}

   	@Override
   	public void purgeVaccinationType(Vaccination vaccinationType) {
   		// TODO Auto-generated method stub
   		sessionFactory.getCurrentSession().delete(vaccinationType);
   	}
}