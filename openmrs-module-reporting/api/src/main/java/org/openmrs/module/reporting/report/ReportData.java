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
package org.openmrs.module.reporting.report;

import org.openmrs.module.reporting.dataset.DataSet;
import org.openmrs.module.reporting.evaluation.Evaluated;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.report.definition.ReportDefinition;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Report Data obtained from evaluating a ReportDefinition with a given EvaluationContext.
 */
public class ReportData implements Evaluated<ReportDefinition> {
	
	//***** PROPERTIES *****
	
	private ReportDefinition definition;
	private EvaluationContext context;
	private Map<String, DataSet> dataSets;
	
	//***** CONSTRUCTORS *****
	
	public ReportData() { }

	/**
	 * Default Constructor which creates an empty ReportData for the given definition and context
	 */
	public ReportData(ReportDefinition definition, EvaluationContext context) {
		this.definition = definition;
		this.context = context;
	}

	//***** PROPERTY ACCESS *****

	/**
	 * @return the dataSets
	 */
	public Map<String, DataSet> getDataSets() {
		if (dataSets == null) {
			dataSets = new LinkedHashMap<String, DataSet>();
		}
		return dataSets;
	}

	/**
	 * @param dataSets the dataSets to set
	 */
	public void setDataSets(Map<String, DataSet> dataSets) {
		this.dataSets = dataSets;
	}

	/**
	 * @return the definition
	 */
	public ReportDefinition getDefinition() {
		return definition;
	}

	/**
	 * @param definition the definition to set
	 */
	public void setDefinition(ReportDefinition definition) {
		this.definition = definition;
	}

	/**
	 * @return the context
	 */
	public EvaluationContext getContext() {
		return context;
	}

	/**
	 * @param context the context to set
	 */
	public void setContext(EvaluationContext context) {
		this.context = context;
	}
}
