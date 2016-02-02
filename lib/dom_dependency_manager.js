/**
 * Copyright 2016 Skytap Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/
(function() {
  var DomDependencyManager, childrenQueue;

  childrenQueue = [];

  module.exports = DomDependencyManager = (function() {
    function DomDependencyManager(views, viewInstances) {
      if (views == null) {
        views = {};
      }
      if (viewInstances == null) {
        viewInstances = {};
      }
      this.viewInstances = viewInstances;
      this.views = [];
      this.topLevelViews = Object.keys(views);
      this.sortDomStructure(views);
    }

    DomDependencyManager.prototype.processDependencies = function(view) {
      var childName, childView, ref;
      ref = view.childViews;
      for (childName in ref) {
        childView = ref[childName];
        this.bindChildListeners(view.parentView, childName);
      }
      return this;
    };

    DomDependencyManager.prototype.bindChildListeners = function(parentName, childName) {
      if (!this.viewInstances[parentName]) {
        return this;
      }
      return this.viewInstances[childName].listenTo(this.viewInstances[parentName], 'postRender', function() {
        return this.refreshEl().render();
      }).listenTo(this.viewInstances[parentName], 'removed', function() {
        return this.remove();
      });
    };

    DomDependencyManager.prototype.processViewNode = function(viewName, children) {
      this.views.push(viewName);
      if (children) {
        childrenQueue.push(children);
        return this.processDependencies({
          parentView: viewName,
          childViews: children
        });
      }
    };

    DomDependencyManager.prototype.sortDomStructure = function(views) {
      var childName, childNames, children, i, name, next;
      i = 0;
      childrenQueue = [];
      for (name in views) {
        childNames = views[name];
        this.processViewNode(name, childNames);
      }
      next = childrenQueue[i];
      while (next) {
        for (childName in next) {
          children = next[childName];
          this.processViewNode(childName, children);
        }
        i++;
        next = childrenQueue[i];
      }
      return this;
    };

    return DomDependencyManager;

  })();

}).call(this);
