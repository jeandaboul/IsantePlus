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
package org.openmrs.module.reporting.data.encounter.persister;

import org.openmrs.annotation.Handler;
import org.openmrs.module.reporting.data.encounter.definition.EncounterDataDefinition;
import org.openmrs.module.reporting.definition.persister.SerializedDefinitionPersister;

/**
 * This class returns EncounterData that have been Serialized to the database
 * This class is annotated as a Handler that supports all EncounterData classes
 * Specifying no order on this indicates that this is the default means of Persisting 
 * an PersonQuery.  To override this behavior, any additional EncounterDataPersister
 * should specify the order field on the Handler annotation.
 */
@Handler(supports={EncounterDataDefinition.class})
public class SerializedEncounterDataPersister extends SerializedDefinitionPersister<EncounterDataDefinition> {

	protected SerializedEncounterDataPersister() { }

	/**
	 * @see SerializedDefinitionPersister#getBaseClass()
	 */
	@Override
	public Class<EncounterDataDefinition> getBaseClass() {
		return EncounterDataDefinition.class;
	}
}
