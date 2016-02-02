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

# For use in sortDomStructure and processViewNode to queue views
childrenQueue = []

module.exports = class DomDependencyManager

  constructor: (views={}, viewInstances={}) ->
    @viewInstances = viewInstances
    @views         = []
    @topLevelViews = Object.keys(views)
    @sortDomStructure views

  # TODO: Potentially add a method to register new views with potential relationships

  processDependencies: (view) ->
    for childName, childView of view.childViews
      @bindChildListeners(view.parentView, childName)
    @

  bindChildListeners: (parentName, childName) ->
    return @ unless @viewInstances[parentName]

    @viewInstances[childName]
      .listenTo @viewInstances[parentName], 'postRender', () ->
        @refreshEl().render()
      .listenTo @viewInstances[parentName], 'removed', () ->
        @remove()

  processViewNode: (viewName, children) ->
    @views.push(viewName)
    if children
      childrenQueue.push(children)
      @processDependencies(parentView: viewName, childViews : children)

  sortDomStructure: (views) ->
    # return an array of view names, sorted
    # such that a descendant view never appears
    # before any of its ancestors
    i = 0
    childrenQueue = []
    for name, childNames of views
      @processViewNode(name, childNames)
    next = childrenQueue[i]
    while(next)
      for childName, children of next
        @processViewNode(childName, children)
      i++
      next = childrenQueue[i]
    @
