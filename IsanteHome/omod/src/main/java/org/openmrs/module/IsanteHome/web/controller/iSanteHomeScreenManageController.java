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
package org.openmrs.module.IsanteHome.web.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Location;
import org.openmrs.api.LocationService;
import org.openmrs.api.context.Context;
import org.openmrs.api.db.LocationDAO;
//import org.openmrs.module.iSanteHomeScreen.web.controller.List;
//import org.openmrs.module.iSanteHomeScreen.web.controller.Person;
//import org.openmrs.module.iSanteHomeScreen.web.controller.Session;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;







import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.ModelAndView;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Repository;

/**
 * The main controller.
 */
@Controller
public class  iSanteHomeScreenManageController {
	
	  private static final Logger logger = LoggerFactory.getLogger(LocationDAO.class);
	  
	    private SessionFactory sessionFactory;

		//private LocationService locationService;
	     
	    public void setSessionFactory(SessionFactory sf){
	        this.sessionFactory = sf;
	    }
	
	protected final Log log = LogFactory.getLog(getClass());
	
	@RequestMapping(value = "/module/IsanteHome/manage", method = RequestMethod.GET)
	public void manage(ModelMap model) {
		model.addAttribute("user", Context.getAuthenticatedUser());
	}
	
	@RequestMapping(value = "/module/IsanteHome/iSantePlus", method = RequestMethod.GET)
	@ModelAttribute
	public Location getLocation(@RequestParam(required=false, value="locationId") Location location)
	{
		return location;
	}

	
	@SuppressWarnings("unchecked")
	public List<Location> listLocations() {
        Session session = this.sessionFactory.getCurrentSession();
		List<Location> locatList = session.createQuery("select name from Location").list();
       /* for(Location l : locationList){
            logger.info("Location List::"+l);
        }*/
        return locatList;
    }
	
	//@RequestMapping(value = "/module/IsanteHome/iSantePlusHome", method = RequestMethod.GET)
	public List<Location> show(LocationDAO location){
	List<Location> locationList = location.getAllLocations(false);
	//model.put("locations", locationList);
	return locationList;
	}
	@RequestMapping(value = "/module/IsanteHome/iSantePlusHome.form", method = RequestMethod.GET)
	public void listLocation(WebRequest request, HttpSession httpSession, ModelMap model,
			@ModelAttribute("location") Location location, BindingResult errors){
		List<Location> locatList = null;
		LocationService locationService = Context.getService(LocationService.class);
		if(!Context.isAuthenticated()){
			errors.reject("location.auth.required");
		}
		else
		{
			
			locatList=locationService.getAllLocations();
			
		}
		model.put("locationList", locatList);
	}
	
	
	public void showForm()
	{
		
	}
	
	
}
