package org.openmrs.module.vaccination.web.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.openmrs.api.context.Context;
import org.openmrs.module.vaccination.api.VaccinationService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@SuppressWarnings("serial")
public class VaccinationTypeListController extends HttpServlet{
	@RequestMapping(value = "/module/vaccination/vaccinationTypeList.form", method = RequestMethod.GET)
	protected void vaccinationTypeL(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		VaccinationService vaccinationTypeService = Context.getService(VaccinationService.class);
		vaccinationTypeService.getAllVaccinationType();
		request.setAttribute("listVaccType", vaccinationTypeService.getAllVaccinationType());
		getServletContext().getRequestDispatcher("/module/vaccination/vaccinationTypeList.jsp").forward(request, response);
	}

}
