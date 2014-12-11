var selection = storeSelection(window.getSelection());
var selectionRange = restoreSelection(selection);
console.log( selectionRange.startContainer.offsetLeft ); //undefined


function makeXPath (node, currentPath) {
  /* this should suffice in HTML documents for selectable nodes, XML with namespaces needs more code */
  currentPath = currentPath || '';
  switch (node.nodeType) {
    case 3:
    case 4:
      return makeXPath(node.parentNode, 'text()[' + (document.evaluate('preceding-sibling::text()', node, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null).snapshotLength + 1) + ']');
    case 1:
      return makeXPath(node.parentNode, node.nodeName + '[' + (document.evaluate('preceding-sibling::' + node.nodeName, node, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null).snapshotLength + 1) + ']' + (currentPath ? '/' + currentPath : ''));
    case 9:
      return '/' + currentPath;
    default:
      return '';
  }
}

function storeSelection () {
  if (typeof window.getSelection != 'undefined') {
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    if (range != null) {
        var selectObj = {
            'startXPath': makeXPath(range.startContainer),
            'startOffset': range.startOffset,
            'endXPath': makeXPath(range.endContainer),
            'endOffset': range.endOffset
        }
//	  var selectionContents   = range.extractContents();
//	    var span                = document.createElement("span");
//
//	    span.appendChild(selectionContents);
//
//	    span.setAttribute("class","uiWebviewHighlight");
//	    span.style.backgroundColor  = "black";
//	    span.style.color            = "white";
//
//	    range.insertNode(span);
		
        return JSON.stringify(selectObj);

    }
  }
}

function restoreSelection (selectionObject) {
  var selectionDetails = selectionObject;
    console.log(selectionObject);
  if (selectionDetails != null) {
      selectionDetails = JSON.parse(selectionObject);
      console.log(selectionDetails);
    if (typeof window.getSelection != 'undefined') {
      var range = document.createRange();
        console.log(document.evaluate(selectionDetails.startXPath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue);
      range.setStart(document.evaluate(selectionDetails.startXPath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue, Number(selectionDetails.startOffset));
      range.setEnd(document.evaluate(selectionDetails.endXPath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue, Number(selectionDetails.endOffset));
    var selectionContents   = range.extractContents();
	    var span                = document.createElement("span");

	    span.appendChild(selectionContents);

	    span.setAttribute("class","uiWebviewHighlight");
	    span.style.backgroundColor  = "black";
	    span.style.color            = "white";

	    range.insertNode(span);  
	return range;
    }
  }
}