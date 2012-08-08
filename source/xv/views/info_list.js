/*jshint bitwise:true, indent:2, curly:true eqeqeq:true, immed:true,
latedef:true, newcap:true, noarg:true, regexp:true, undef:true,
trailing:true white:true*/
/*global XT:true, XM:true, _:true, enyo:true, Globalize:true*/

(function () {

  enyo.kind({
    name: "XV.InfoList",
    kind: "Panels",
    classes: "xt-info-list",
    draggable: false,
    components: [
      { name: "loader", classes: "xt-info-list-loader", content: "Loading content..." },
      { name: "error", classes: "xt-info-list-error", content: "There was an error" },
      { name: "list", kind: "XV.InfoListPrivate" }
    ],
    published: {
      collection: null,
      rowClass: "",
      query: null,
      parameterWidget: null,
      workspace: "XV.Workspace"
    },
    collectionChanged: function () {
      var col = this.getCollection(),
        Klass;

      // Change string to an object if necessary
      if (typeof col === 'string') {
        Klass = XT.getObjectByName(col);
        col = this.collection = new Klass();
      }

      if (!col) {
        this.setIndex(1);
        return;
      }

      // bind the change event to our handler
      col.bind("change", enyo.bind(this, "_collectionChanged", col));
    },
    _collectionChanged: function (collection) {
      this.log();
    },
    _collectionFetchSuccess: function () {
      this.log();
      this.waterfall("onCollectionUpdated");
    },
    _collectionFetchError: function () {
      this.log();
    },
    create: function () {
      this.inherited(arguments);
      this.rowClassChanged();
      this.collectionChanged();
    },
    rowClassChanged: function () {
      // need to pass down some information to the list
      this.$.list.setRowClass(this.getRowClass());
    },
    showingChanged: function () {
      this.inherited(arguments);
      this.log(this.name, this.showing, this);
    },
    fetch: function (options) {
      var that = this,
        col = this.getCollection(),
        query = this.getQuery(),
        success;
      options = options ? _.clone(options) : {};
      success = options.success;
      _.extend(options, {
        success: function (resp, status, xhr) {
          that._collectionFetchSuccess(resp, status, xhr);
          if (success) { success(resp, status, xhr); }
        },
        error: enyo.bind(this, "_collectionFetchError"),
        query: query
      });
      // attempt to fetch (if not already fetching) and handle the
      // various states appropriately
      col.fetch(options);
    }
  });

  enyo.kind({
    name: "XV.InfoListPrivate",
    kind: "List",
    classes: "xt-info-list-private",
    published: {
      rowClass: "",
      isFetching: false,
      isMore: true
    },
    handlers: {
      onSetupItem: "setupRow",
      onCollectionUpdated: "collectionUpdated"
    },
    collectionUpdated: function () {
      var col = this.parent.getCollection(),
        query = this.parent.getQuery(),
        offset = query.rowOffset || 0,
        limit = query.rowLimit || 0,
        count = col.length,
        isMore = limit ?
          (offset + limit <= count) && (this.getCount() !== col.length) : false;
      this.setIsMore(isMore);
      this.setIsFetching(false);

      // take the properties as necessary...
      this.setCount(col.length);
      if (offset) { this.refresh(); } else { this.reset(); }

      // if we updated, let the parent know we want to be
      // visible now
      this.parent.setIndex(2);
    },
    rowClassChanged: function () {
      //this.log(this.owner.name);

      var rowClass = this.getRowClass();
      var component;
      var item;

      if (rowClass) {
        if (XT.getObjectByName(rowClass)) {

          component = {
            name: "item",
            kind: rowClass
          };

          item = this.$.item;
          if (item) {
            this.removeComponent(item);
            item.destroy();
          }

          this.createComponent(component);
        }
      }
    },
    setupRow: function (inSender, inEvent) {
      //this.log(this.owner.name, this.owner.showing, this);

      var col = this.parent.getCollection();
      var row = this.$.item;
      var idx = inEvent.index;
      var mod = col.models[idx];

      // as the rows need to be rendered, we proxy the data to their
      // render function if they have it, otherwise, we skip
      if (row && row.renderModel) {
        row.renderModel(mod);
      }
    }

  });

  enyo.kind({
    name: "XV.InfoListRow",
    classes: "xt-info-list-row",
    published: {
      leftColumn: [],
      rightColumn: []
    },
    events: {
      onInfoListRowTapped: ""
    },
    create: function () {
      this.inherited(arguments);

      var lcs = this.getLeftColumn();
      var rcs = this.getRightColumn();
      var lc;
      var rc;

      lc = this.createComponent({
        name: "leftColumn",
        kind: "XV.InfoListRowColumn",
        structure: lcs
      });

      rc = this.createComponent({
        name: "rightColumn",
        kind: "XV.InfoListRowColumn",
        structure: rcs
      });
    },
    renderModel: function (model) {
      // TEMPORARY IMPLEMENTATION

      //this.log(model);

      var $ = this.$;
      var elem;
      var idx;
      var view;
      var parts;
      var curr;
      var formatter;

      for (elem in $) {
        if ($.hasOwnProperty(elem)) {
          view = $[elem];
          if (view.isLabel) {
            continue;
          }
          if (elem.indexOf('.') > -1) {
            parts = elem.split('.');
            idx = 0;
            curr = model;
            for (; idx < parts.length; ++idx) {
              curr = curr.getValue(parts[idx]);
              if (curr && curr instanceof Date) {
                break;
              } else if (curr && typeof curr === "object") {

              } else if (typeof curr === "string") {
                break;
              } else {
                curr = "";
                break;
              }
            }
            view.setContent(curr);
          } else {
            curr = model.getValue(elem);
          }
          if (view.formatter) {
            formatter = this[view.formatter];

            if (formatter && formatter instanceof Function) {
              curr = formatter(curr, model, view);
            }
          }
          if (curr && curr instanceof Date) {
            curr = Globalize.format(curr, 'd');
          }
          view.setContent(curr || view.placeholder || "");
          if (curr) {
            view.removeClass("empty");
          } else {
            view.addClass("empty");
          }
        }
      }
    },
    tap: function (inSender, inEvent) {
      this.doInfoListRowTapped(inEvent);
    }

  });

  enyo.kind({
    name: "XV.InfoListRowColumn",
    classes: "xt-info-list-row-column",
    published: {
      structure: null
    },
    create: function () {
      this.inherited(arguments);

      var str = this.getStructure();
      var idx = 0;
      var elem;
      var curr = this;
      var ccfa = enyo.bind(this, "createComponentFromArray", this.owner);
      var ccfo = enyo.bind(this, "createComponentFromObject", this.owner);

      for (; idx < str.length; ++idx) {
        elem = str[idx];
        if (elem instanceof Array) {
          curr = ccfa(curr, elem);
        } else if (typeof elem === "object") {
          ccfo(curr, elem);
        }
      }
    },
    createComponentFromArray: function (inOwner, inComponent, inElement) {
      var curr = inComponent;
      var elems = inElement;

      // TODO: this could be handled in much better ways...
      // XXX SH here... I added a slice to fix the bug of the destructiveness
      // of this line of code whenever you re-use list kinds. Basically
      // a band-aid fix.
      var width = elems.slice(0).shift().width;

      var idx = 0;
      var elem;
      var ret;

      if (curr.kind !== "InfoListBasicColumn") {
        ret = curr;

        curr = curr.createComponent({
          kind: "XV.InfoListBasicColumn",
          style: "width:" + width + "px;"
        });
      }

      for (; idx < elems.length; ++idx) {
        elem = elems[idx];
        if (elem instanceof Array) {
          curr = this.createComponentFromArray(inOwner, curr, elem, elems.length);
        } else if (typeof elem === "object") {
          this.createComponentFromObject(inOwner, curr, elem);
        }
      }

      return ret;
    },
    createComponentFromObject: function (inOwner, inComponent, inElement) {
      var curr = inComponent;
      var elem = inElement;

      curr = curr.createComponent({
        kind: "XV.InfoListBasicCell"
      }, elem);

      if (!inOwner.$[elem.name]) {
        inOwner.$[elem.name] = curr;
      }
    }
  });

  enyo.kind({
    name: "XV.InfoListBasicRow",
    classes: "xt-info-list-basic-row"
  });

  enyo.kind({
    name: "XV.InfoListBasicColumn",
    classes: "xt-info-list-basic-column"
  });

  enyo.kind({
    name: "XV.InfoListBasicCell",
    classes: "xt-info-list-basic-cell"
  });

}());
