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
package org.openmrs.module.reporting.data.encounter.service;

import org.openmrs.module.reporting.data.encounter.EvaluatedEncounterData;
import org.openmrs.module.reporting.data.encounter.definition.EncounterDataDefinition;
import org.openmrs.module.reporting.definition.service.DefinitionService;
import org.openmrs.module.reporting.evaluation.Definition;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.EvaluationException;
import org.openmrs.module.reporting.evaluation.parameter.Mapped;

/**
 * API for evaluating a EncounterDataDefinition across a set of Encounters
 */
public interface EncounterDataService extends DefinitionService<EncounterDataDefinition> {
	
	/**
	 * @see DefinitionService#evaluate(Definition, EvaluationContext)
	 */
	public EvaluatedEncounterData evaluate(EncounterDataDefinition definition, EvaluationContext context) throws EvaluationException;
	
	/**
	 * @see DefinitionService#evaluate(Mapped, EvaluationContext)
	 */
	public EvaluatedEncounterData evaluate(Mapped<? extends EncounterDataDefinition> mappedDefinition, EvaluationContext context) throws EvaluationException;
}
