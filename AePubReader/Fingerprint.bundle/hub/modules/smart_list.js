//
//  Copyright 2013 Fingerprint Digital, Inc. All rights reserved.
//

var FPSmartList = {};

FPSmartList.create = function(p, s, x, y, w, h, funcs)
{
    // in web environment, be wider so scroll bar doesn't overlap content - ok if scroll bar is off size of screen, it still works
    var outerW = w;
    if (window["gWebGame"]) {
        outerW += 10;
    }

    var d = div({parent: p, x: x, y: y, w: outerW, h: h, color: "#ffffff"});
    d.funcs = funcs;
    d.w = w;
    d.s = s;
    d.idName = "id";
    d.bInUpdate = false;
    d.bFirstUpdate = true;
    d.content = div({parent: d, x: 0, y: 0, w: w}); // let height be natural height

    // to be sure list hasn't changed
    d.list_id = GUID();

    // for iScroll scrolling
    d.id = null;
    d.iscroll = null;

    // for browser scrolling
    $(d).css("overflow", undefined);
    $(d).css("overflow-x", "hidden");
    $(d).css("overflow-y", "scroll");

    d.loading = label({parent: d, x: 0, y: 0, w: w, h: h, string: i18n('_LOADING'), size: 16, center: true, vCenter: true, color: "#808080"});
    d.bScrolling = false;
    d.oldPos = {};
    return d;
}

FPSmartList.update = function(list, update)
{
    if (list.bInUpdate) {
        // don't have 2 updates going at once... delay it
        function delay()
        {
            // TODO: this is happening way more than expected - need to revisit, but for now, remove the console log to prevent console flooding
//            console.log("DELAYED UPDATE");
            FPSmartList.update(list, update);
        }
        setTimeout(delay, 1000);
        return;
    }
    list.bInUpdate = true;

    if (list.loading) {
        $(list.loading).remove();
        list.loading = null;
    }

    var transitionTime = 400;
    var count;
    var i;
    var o;

    // build indices of current and update elements
    var current = $(list.content).children();

    var updateObj = {};
    count = update.length;
    for (i=0; i<count; i++) {
        o = update[i];
        if (o[list.idName] === undefined) {
            // supply id for items that client doesn't intend to add/remove or update
            o[list.idName] = GUID();
        }

        var q = {};
        q[list.idName] = o[list.idName];
        q.data = JSON.stringify(o);
        updateObj[o[list.idName]] = q;
    }

    var currentObj = {};
    count = current.length;
    for (i=0; i<count; i++) {
        o = current[i];
        currentObj[o.info[list.idName]] = o;
    }

    var justUpdate = {};

    // anything currently in the list that isn't in the update OR has changed should be removed
    var removeCount = 0;
    var didRemoveCount = 0;
    count = current.length;
    for (var i=0; i<count; i++) {
        var co = current[i];
        var uo = updateObj[co.info[list.idName]];
        if (uo === undefined || uo.data !== co.info.data) {
            justUpdate[co.info[list.idName]] = true;
            if (!updateObj[co.info[list.idName]]) {
                removeCount++;
                $(co).slideUp(transitionTime, function() {$(this).remove(); next();});
                delete currentObj[co.info[list.idName]];
            } else {
                co.bRefill = true;
            }
        }
    }

    if (removeCount == 0) {
        next();
    }

    function next()
    {
        // wait until all removes are done, then continue
        didRemoveCount++;
        if (didRemoveCount < removeCount) {
            return;
        }

        var addCount = 0;
        var didAddCount = 0;

        // at this point, everything left in the list should stay there, but the order might have change
        var insertionPoint = null;
        count = update.length;
        for (var i=0; i<count; i++) {

            var uo = update[i];
            var bNew = false;

            e = currentObj[uo[list.idName]];
            if (e === undefined || e.bRefill) {

                if (e === undefined) {
                    e = div({parent: list, w: list.w, h: "auto"});
                    $(e).css("position", "relative");
                } else {
                    $(e).empty();
                    delete e.bRefill;
                }

                // find best func
                var funcsLen = list.funcs.length;

                var useT = uo.t;
                if (useT === undefined) {
                    useT = list.defaultT;
                }
                for (var j=0; j<funcsLen; j++) {
                    if (list.funcs[j][useT]) {
                        list.funcs[j][useT](e, uo, list.w, list.s);
                        break;
                    }
                }
                if (j == funcsLen) {
                    console.log("ERROR: no list func available for type: " + useT);
                }
                e.info = updateObj[uo[list.idName]];
                bNew = !justUpdate[uo[list.idName]];
            }

            if (insertionPoint) {
                if (!($(e).prev().is(insertionPoint))) {
                    $(e).insertAfter(insertionPoint);
                } else {
//                    console.log("already in place (1)");
                }
            } else {
                if ($(e).index() != 0) {
                    $(list.content).prepend(e);
                } else {
//                    console.log("already in place (2)");
                }
            }
            insertionPoint = e;

            if (bNew && !list.bFirstUpdate) {
                addCount++;
                $(e).hide();
                $(e).slideDown(transitionTime, function() {next2();});
            }
        }

        if (addCount == 0) {
            next2();
        }

        function next2()
        {
            // wait until all adds are done, then continue
            didAddCount++;
            if (didAddCount < addCount) {
                return;
            }

            // update the iscroll
            if (!window["gWebGame"]) {
                var oldY;
                if (list.iscroll)
                {
                    oldY = list.iscroll.y;
                    list.iscroll.destroy();
                }
                list.id = "smart_list_" + GUID();


                list.iscroll = new iScroll(list.id, {vScroll: true, bounce: false,
                    onScrollStart:
                        function(e){
                            list.bScrolling = false;
                            if (window["FPNative"]){
                                list.oldPos = {x:e.touches[0].clientX, y:e.touches[0].clientY};
                            }else{
                                list.oldPos = {x:e.clientX, y:e.clientY};
                            }
                        },
                    onScrollMove:
                        function(e){
                            var newPos, oldPos = list.oldPos;
                            if (window["FPNative"]){
                                newPos = {x:e.touches[0].clientX, y:e.touches[0].clientY};
                            }else{
                                newPos = {x:e.clientX, y:e.clientY};
                            }
                            if (Math.abs(newPos.x-oldPos.x)>5*gScaleX || Math.abs(newPos.y-oldPos.y)>5*gScaleY){
                                list.bScrolling = true;
                            }
                        }});
                if (oldY) {
                    list.iscroll.scrollTo(0, oldY, 0, false);
                }
            }

            // for browser scrolling
            $(list).css("overflow", undefined);
            $(list).css("overflow-x", "hidden");
            $(list).css("overflow-y", "scroll");

            if (list.bFirstUpdate && update.length > 0) {
                list.bFirstUpdate = false;
            }

            // done with update
            list.bInUpdate = false;
        }
    }
}

// helper function for list updates driven by web request replies
// list - the smart list object
// list_id - id of the expected list, if it's not a match, then ignore the update
// r - the web request reply
// rName - property of r that has the list data, if request was successful
// idName - property of list elements to use as unique list item id, if not supplied "id" will be used
// defaultT - default type for list items, if not provided, "t" property on list items will be used
// prependItems - list items to prepend to the update (e.g. stuff that's always at the top of the list) - can be null

FPSmartList.smartUpdate = function(list, list_id, r, rName, idName, defaultT, prependItems)
{
    if (list.list_id === list_id) {
        var data = [];
        if (r && r.bSuccess && r[rName]) {
            data = r[rName];
        }
        if (idName) {
            list.idName = idName;
        }
        if (defaultT) {
            list.defaultT = defaultT;
        }
        if (prependItems) {
            data = prependItems.concat(data);
        }
        FPSmartList.update(list, data);
    }
}

// way to create a list that is a list of lists - and don't do initial update until every section has provided
// data at least once
FPSmartList.addSection = function(list, idName, setOnEachItem)
{
    // when adding first section
    if (list.sections === undefined) {
        list.sections = [];
        list.readyCount = 0;
    }

    // create section
    var sectionIndex = list.sections.length;
    list.sections.push(null);

    // data ready to add to the list
    function update(a)
    {
        // set list item type, id, and other provided attributes on each item
        var count = a?a.length:0;
        for (var i=0; i<count; i++) {
            a[i].id = a[i][idName];
            for (var k in setOnEachItem) {
                a[i][k] = setOnEachItem[k];
            }
        }

        // note if we're seeing data for this section for the first time
        if (list.sections[sectionIndex] === null) {
            list.readyCount++;
        }

        // record data for section
        list.sections[sectionIndex] = a;

        // if we have received data at least once for all sections, we can update the smart list
        if (list.readyCount === list.sections.length) {
            var all = [];
            all = all.concat.apply(all, list.sections);
            FPSmartList.update(list, all);
        }
    }

    var section = {};
    section.update = update;
    return section;
}

// for sections that are driven by typical server responses
FPSmartList.addResponseSection = function(list, idName, setOnEachItem, dataName, filterFunc, onUpdated)
{
    var section = FPSmartList.addSection(list, idName, setOnEachItem);

    function updateResponse(r)
    {
        var a = r.bSuccess ? r[dataName] : [];
        if (onUpdated){
            onUpdated(r[dataName]);
        }
        if (filterFunc) {
            filterFunc(a, section.update);
        } else {
            section.update(a);
        }
    }

    section.updateResponse = updateResponse;
    return section;
}

// for sections that are driven by cached-backed server requests with local delete support
FPSmartList.addEditListSection = function(list, idName, setOnEachItem, dataName, filterFunc, action, data, cacheName, cacheScope, onUpdated)
{
    var section = FPSmartList.addResponseSection(list, idName, setOnEachItem, dataName, filterFunc, onUpdated);
    // hook up cached request to it
    function refresh()
    {
        FPWebRequestForEditList(action, data, section.updateResponse, null, cacheName, cacheScope, dataName, idName)
    }
    section.refresh = refresh;
    section.refresh();
    return section;
}
