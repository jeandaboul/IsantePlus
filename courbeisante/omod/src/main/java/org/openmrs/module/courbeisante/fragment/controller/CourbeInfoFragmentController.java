package org.openmrs.module.courbeisante.fragment.controller;
import java.util.Calendar;
import java.util.Date;

import org.openmrs.api.EncounterService;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentModel;

public class CourbeInfoFragmentController {
	 @SuppressWarnings("deprecation")
	public void controller(FragmentModel model, @SpringBean("encounterService") EncounterService service) {
	        Calendar cal = Calendar.getInstance();
	        cal.set(Calendar.HOUR_OF_DAY, 0);
	        cal.set(Calendar.MINUTE, 0);
	        cal.set(Calendar.SECOND, 0);
	        cal.set(Calendar.MILLISECOND, 0);
	        Date startOfDay = cal.getTime();
	 
	        cal.add(Calendar.DAY_OF_MONTH, 1);
	        cal.add(Calendar.MILLISECOND, -1);
	        Date endOfDay = cal.getTime();
	 
	        model.addAttribute("encounters", service.getEncounters(null, null, startOfDay, endOfDay, null, null, null, false));
	    }
	 
	}
