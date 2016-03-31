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
package org.openmrs.module.reporting.dataset.definition.evaluator;

import org.openmrs.module.reporting.dataset.DataSet;
import org.openmrs.module.reporting.dataset.definition.DataSetDefinition;
import org.openmrs.module.reporting.definition.evaluator.DefinitionEvaluator;
import org.openmrs.module.reporting.evaluation.EvaluationContext;
import org.openmrs.module.reporting.evaluation.EvaluationException;

/**
 * Implementations of this interface can evaluate a particular subclass of {@link DataSetDefinition} and produce
 * a {@link DataSet}. 
 * This is one of three interfaces that work together to define and evaluate an OpenMRS DataSet. 
 * An implementation of {@link DataSetEvaluator} transforms one or more implementations of {@link DataSetDefinition}
 * to produce a specific type of {@link DataSet}.
 * @see DataSetDefinition
 * @see DataSet
 */
public interface DataSetEvaluator extends DefinitionEvaluator<DataSetDefinition> {
	
	/**
	 * Evaluate a DataSet for the given EvaluationContext
	 * 
	 * @param dataSetDefinition
	 * @param inputCohortencounter_datetime
	 * @return the evaluated <code>DataSet</code>
	 */
	public DataSet evaluate(DataSetDefinition dataSetDefinition, EvaluationContext evalContext) throws EvaluationException;
}
