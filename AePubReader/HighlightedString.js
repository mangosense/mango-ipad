/*!
 ------------------------------------------------------------------------ 
 // Search Highlighted String
 ------------------------------------------------------------------------ 
 */
var selectedText = "";

function getHighlightedString() {
    var text        = window.getSelection();
    selectedText    = text.anchorNode.textContent.substr(text.anchorOffset, text.focusOffset - text.anchorOffset);

}

// ...
function stylizeHighlightedString() {
    
    
    var range               = window.getSelection().getRangeAt(0);
    var selectionIdentifier= rangy.saveSelection();
    var selectionContents   = range.extractContents();
    var span                = document.createElement("span");
    var text        = window.getSelection();
    selectedText    = text.anchorNode.textContent.substr(text.anchorOffset, text.focusOffset - text.anchorOffset);
    span.appendChild(selectionContents);
    
    span.setAttribute("class","uiWebviewHighlight");
    span.style.backgroundColor  = "black";
    span.style.color            = "white";
    
    range.insertNode(span);
    return selectionIdentifier;
  
}
function restoreHightlight(identfier){
    var range=rangy.restoreSelection(identfier);
    var span                = document.createElement("span");
    var text        = window.getSelection();
    selectedText    = text.anchorNode.textContent.substr(text.anchorOffset, text.focusOffset - text.anchorOffset);
    span.appendChild(selectionContents);
    
    span.setAttribute("class","uiWebviewHighlight");
    span.style.backgroundColor  = "black";
    span.style.color            = "white";
    
    range.insertNode(span);
    
}
function removeHighlight(){
    var range               = window.getSelection().getRangeAt(0);
    var selectionContents   = range.extractContents();
    var span                = document.createElement("span");
    
    span.appendChild(selectionContents);
    
    span.setAttribute("class","uiWebviewHighlight");
    span.style.backgroundColor  = "white";
    span.style.color            = "black";
    
    range.insertNode(span);
}
function setHightlightText(str){
    var span=document.createElement("span");
    span.appendChild(str);
    span.setAttribute("class","uiWebviewHighlight");
    span.style.backgroundColor="yellow";
    span.style.color="black";
}

// helper function, recursively removes the highlights in elements and their childs
function uiWebview_RemoveAllHighlightsForElement(element) {
    if (element) {
        if (element.nodeType == 1) {
            if (element.getAttribute("class") == "uiWebviewHighlight") {
                var text = element.removeChild(element.firstChild);
                element.parentNode.insertBefore(text,element);
                element.parentNode.removeChild(element);
                return true;
            } else {
                var normalize = false;
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    if (uiWebview_RemoveAllHighlightsForElement(element.childNodes[i])) {
                        normalize = true;
                    }
                }
                if (normalize) {
                    element.normalize();
                }
            }
        }
    }
    return false;
}

// the main entry point to remove the highlights
function uiWebview_RemoveAllHighlights() {
    selectedText = "";
    uiWebview_RemoveAllHighlightsForElement(document.body);
}