# Copyright 2016 Skytap Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

should               = require 'should'
DomDependencyManager = require '../../../src/dom_dependency_manager'

describe 'lib/dom_dependency_manager.coffee', ->
  describe 'constructor', ->
    it 'should store view structure and instances', ->
      viewStructure =
        'a' :
          'b' : null
      instances = { i: "instances" }
      domManager = new DomDependencyManager(viewStructure, instances)
      domManager.views.should.eql(['a','b'])
      domManager.viewInstances.should.eql(instances)

  describe 'sortDomStructure', ->
    [
        viewStructure :
          'projectsList' :
            'pagination' :
              'resultsCount' : null
            'sorting' : null
        expected : ['projectsList', 'pagination', 'sorting', 'resultsCount']
      ,
        viewStructure :
          'a' :
            'b' :
              'd' :
                'h' : null
                'i' : null
            'c' :
              'e' : null
              'f' : null
              'g' : null
              'b' : null
        expected : ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'b', 'h', 'i']
      ,
        viewStructure :
          'a' :
            'b' : null
        expected : ['a','b']
      ,
        viewStructure :
          'a' : null
        expected : ['a']
    ].forEach (testCase) ->
      it 'should sort parents before children', ->
        domManager = new DomDependencyManager()
        domManager.sortDomStructure(testCase.viewStructure).views.should.eql(testCase.expected)
