/**
 * Copyright 2013-2020 the original author or authors from the JHipster project.
 * 
 * This file is part of the JHipster project, see http://www.jhipster.tech/
 * for more information.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.github.jhipster.jdl.resource

import io.github.jhipster.jdl.jdl.JdlDomainModel
import io.github.jhipster.jdl.jdl.JdlEntity
import io.github.jhipster.jdl.jdl.JdlFieldType
import io.github.jhipster.jdl.jdl.JdlNumericTypes
import io.github.jhipster.jdl.jdl.JdlPackage
import org.eclipse.xtext.resource.DerivedStateAwareResource
import org.eclipse.xtext.resource.IDerivedStateComputer

/**
 * @author Serano Colameo - Initial contribution and API
 */
class JdlDerivedStateComputer implements IDerivedStateComputer {

	val BUILT_IN_ENTITIES = #{
		'User' -> #[
			'firstName' -> stringType,
			'lastName' -> stringType,
			'login' -> stringType,
			'email' -> stringType,
			'imageUrl' -> stringType,
			'authorities' -> stringType
		],
		'Authority' -> #[
			'name' -> stringType
		]
	}
	static val factory = JdlPackage.eINSTANCE.jdlFactory

	override discardDerivedState(DerivedStateAwareResource resource) {
		// nothing to do here
	}

	override installDerivedState(DerivedStateAwareResource resource, boolean preLinkingPhase) {
		if (!preLinkingPhase && !resource.builtInTypesAlreadyDefined) {
			val model = resource.model
			if (model !== null) {
				model.fullFileName = resource.URI.toFileString
				model.name = resource.modelName
				BUILT_IN_ENTITIES.forEach[name, fieldDecls|
					model.features += factory.createJdlEntity => [ entity |
						entity.name = name
						entity.fieldDefinition = factory.createJdlEntityFieldDefinition
						fieldDecls.forEach[entity.addField(key, value)]
					]
				]
			}
		}
	}

	def protected String getModelName(DerivedStateAwareResource resource) {
		return try {
			resource.URI.trimFileExtension.lastSegment
		} catch (Exception exception) {
			null
		}
	}

	def boolType() {
		factory.createJdlBooleanFieldType => [
			it.element = factory.createJdlBooleanType
			it.element.element = 'Boolean'
		]
	}

	def stringType() {
		factory.createJdlStringFieldType => [
			it.element = factory.createJdlStringType
			it.element.element = 'String'
		]
	}

	def numType() {
		factory.createJdlNumericFieldType => [
			it.element = JdlNumericTypes.INTEGER
		]
	}

	def private void addField(JdlEntity entiy, String name, JdlFieldType type) {
		entiy.fieldDefinition.fields.add(
			factory.createJdlEntityField => [
				it.name = name
				it.type = type
			]
		)
	}

	def private getModel(DerivedStateAwareResource resource) {
		try {
			resource.contents.filter(JdlDomainModel).last
		} catch (Exception exception) {
			null
		}
	}

	def private builtInTypesAlreadyDefined(DerivedStateAwareResource resource) {
		try {
			resource.contents.filter(JdlEntity).findFirst[
				BUILT_IN_ENTITIES.containsKey(name)
			] !== null
		} catch (Exception ex) {
			false
		}
	}
}
