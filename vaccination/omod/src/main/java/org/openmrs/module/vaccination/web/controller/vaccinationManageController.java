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
package org.openmrs.module.vaccination.web.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
//import javax.servlet.ServletException;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.APIException;
import org.openmrs.Encounter;
import org.openmrs.api.EncounterService;
import org.openmrs.api.context.Context;
import org.openmrs.messagesource.MessageSourceService;
import org.openmrs.module.vaccination.Vaccination;
import org.openmrs.module.vaccination.api.VaccinationService;
import org.openmrs.web.WebConstants;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.context.request.WebRequest;

/**
 * The main controller.
 */
@Controller
public class  vaccinationManageController {
	
	protected final Log log = LogFactory.getLog(getClass());
	
	@RequestMapping(value = "/module/vaccination/manage", method = RequestMethod.GET)
	public void manage(ModelMap model) {
		model.addAttribute("user", Context.getAuthenticatedUser());
	}
	
	@RequestMapping(value ="/module/vaccination/addVaccinationType", method = RequestMethod.GET)
	 @ModelAttribute
	 public void create(ModelMap model) {
	   model.addAttribute("vaccinationType",new Vaccination());
	  // model.addAttribute("listPersons", this.myfirstModuleService.getAllmyFirstModules());
	 }
	
	@RequestMapping(value = "/module/vaccination/addVaccinationType.form", method = RequestMethod.POST)
	public String submitVaccinationType(WebRequest request, HttpSession httpSession, ModelMap model,
			@RequestParam(required = false, value = "action") String action,
			@ModelAttribute("vaccinationType") Vaccination vaccinationType, BindingResult errors){
		MessageSourceService mss = Context.getMessageSourceService();
		VaccinationService vaccinationTypeService = Context.getService(VaccinationService.class);
		if(!Context.isAuthenticated()){
			errors.reject("vaccinationType.auth.required");
		}
		else if(mss.getMessage("vaccinationType.purgeVaccinationType").equals(action))
			{
				try{
					vaccinationTypeService.purgeVaccinationType(vaccinationType);
					httpSession.setAttribute(WebConstants.OPENMRS_MSG_ATTR, "vaccinationType.delete.success");
					return "redirect:addVaccinationType.list";
				}
				catch(Exception ex){
					httpSession.setAttribute(WebConstants.OPENMRS_ERROR_ATTR, "vaccinationType.delete.failure");
					log.error("Failed to delete vaccinationType", ex);
					return ("redirect:addVaccinationType.form?vaccinationTypeId=" + request.getParameter("vaccinationTypeId"));
				}
			}
		else
		{
			vaccinationTypeService.saveVaccinationType(vaccinationType);
			httpSession.setAttribute(WebConstants.OPENMRS_MSG_ATTR, "vaccinationType.saved");
			
		}
		return "redirect:vaccinationTypeList.form";
	}
	@RequestMapping(value ="/module/vaccination/encounterList", method = RequestMethod.GET)
	public Map<String, Object> findCountAndEncounters(String phrase, boolean includeVoided, Integer start, Integer length,
            boolean getMatchCount) throws APIException {
        //Map to return
        Map<String, Object> resultsMap = new HashMap<String, Object>();
        Vector<Object> objectList = new Vector<Object>();
        try {
            EncounterService es = Context.getEncounterService();
            int encounterCount = 0;
            if (getMatchCount)
                encounterCount += es.getCountOfEncounters(phrase, includeVoided);
 
            //If we have any matches, fetch them or if this is not the first ajax call
            //for displaying the results on the first page, the getMatchCount is expected to be zero
            if (encounterCount > 0 || !getMatchCount)
              // objectList = findBatchOfEncounters(phrase, includeVoided, start, length);
             //objectList = findEncounters(phrase, includeVoided, start, length);
            resultsMap.put("count", encounterCount);
            resultsMap.put("objectList", objectList);
        }
        catch (Exception e) {
            objectList.clear();
            objectList.add("Error while searching for encounters");
            resultsMap.put("count", 0);
            resultsMap.put("objectList", objectList);
 
            //you can opt to pass in a new phrase which will tell the core search widget to rerun the
            //search but for your new phrase and this will lead to ignoring the results you send back
            resultsMap.put("searchAgain", "newphrase");
        }
        return resultsMap;
    }
	
	//@SuppressWarnings({ "rawtypes", "unchecked" })
	@RequestMapping(value = "/module/vaccination/vaccinationTypeList.form", method = RequestMethod.GET)
	public void listVaccinationType(WebRequest request, HttpSession httpSession, ModelMap model,
			@ModelAttribute("vaccinationType") Vaccination vaccinationType, BindingResult errors){
		List<Vaccination> listVaccType = null;
		VaccinationService vaccinationTypeService = Context.getService(VaccinationService.class);
		if(!Context.isAuthenticated()){
			errors.reject("vaccinationType.auth.required");
		}
		else
		{
			
			listVaccType=vaccinationTypeService.getAllVaccinationType();
			
		}
		model.put("listVaccType", listVaccType);
	}
	
	
	
	public void showForm()
	{
		
	}
}
