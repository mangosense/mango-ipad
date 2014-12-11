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

function restoreSelection () {
      var selection = window.getSelection();
      selection.removeAllRanges();
      var range = document.createRange();
      range.setStart(document.evaluate(selectionDetails[0], document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue, Number(selectionDetails[1]));
      range.setEnd(document.evaluate(selectionDetails[2], document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue, Number(selectionDetails[3]));
      selection.addRange(range);
  }
}

function getSelection() {
   var selection = window.getSelection();
   var range = selection.getRangeAt(0);
   var selectObj = { 
      'startXPath': makeXPath(range.startContainer), 
      'startOffset': range.startOffset, 
      'endXPath': makeXPath(range.endContainer), 
      'endOffset': range.endOffset 
   }
       alert(JSON.stringify(selectObj));
    alert('selection called');
   return JSON.stringify(selectObj);
}