// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function changeSwitch(x)
{
	if(!document.getElementById('analyzer_switch_type')) return;
	
  var y=document.getElementById('analyzer_switch_type').value
  var z=document.getElementById('analyzer_switch_network_flag').value
  if(y == 0 && z != "false") {
    document.getElementById('analyzer_port_nbr').disabled=true;
    document.getElementById('analyzer_baud_rate').disabled=true;
    document.getElementById('analyzer_bidirectional_flag').disabled=true;
    document.getElementById('edit_switches').disabled=true;
    document.getElementById('schedule_edit').disabled=true;
    document.getElementById('disabled_messages').innerHTML="You need to set the switch type below";
  } else {
    document.getElementById('analyzer_port_nbr').disabled=false;
    document.getElementById('analyzer_baud_rate').disabled=false;
    document.getElementById('analyzer_bidirectional_flag').disabled=false;
    if (x == "load") {
      document.getElementById('disabled_messages').innerHTML="";
    } else {
      document.getElementById('disabled_messages').innerHTML="You need to save your changes";
    }
  }
}

function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

function ToggleDetails(id) {
  var element = document.getElementById(id);
  Effect.toggle(element, 'blind');
}
function getElementsByClass( node, searchClass, tag ) {
  var classElements = new Array();
  var els = node.getElementsByTagName(tag);
  var elsLen = els.length;
  var pattern = new RegExp("\\b"+searchClass+"\\b");
  for (i = 0, j = 0; i < elsLen; i++) {
    if ( pattern.test(els[i].className) ) {
      classElements[j] = els[i];
      j++;
    }
  }
  return classElements;
}

function toggleClass ( searchClass ) {
  var elements = getElementsByClass( document, searchClass, 'tr');
  for (i=0; i < elements.length; i++) {
    Element.toggle(elements[i])
  }
  var elements = getElementsByClass( document, searchClass, 'a');
  var re = new RegExp("zoom_in.png");
  for (i=0; i < elements.length; i++) {
    if(elements[i].innerHTML.match(re)) {
      elements[i].innerHTML = "<img width=30 border=0 src=/images/zoom_out.png>"
    } else {
      elements[i].innerHTML = "<img width=30 border=0 src=/images/zoom_in.png>"
    }
  }
}

function isEmpty(elem, helperMsg){
  if(elem.value.length == 0){
    alert(helperMsg);
    elem.focus(); // set the focus to this input
    return true;
  }
  return false;
}

function isNumeric(elem, helperMsg){
  var numericExpression = /^[0-9]+$/;
  if(elem.value.match(numericExpression)){
    return true;
  }else{
    alert(helperMsg);
    elem.focus();
    return false;
  }
}

function isAlphabet(elem, helperMsg){
  var alphaExp = /^[a-zA-Z]+$/;
  if(elem.value.match(alphaExp)){
    return true;
  }else{
    alert(helperMsg);
    elem.focus();
    return false;
  }
}

function isAlphanumeric(elem, helperMsg){
  var alphaExp = /^[0-9a-zA-Z]+$/;
  if(elem.value.match(alphaExp)){
    return true;
  }else{
    alert(helperMsg);
    elem.focus();
    return false;
  }
}

function lengthRestriction(elem, min, max){
  var uInput = elem.value;
  if(uInput.length >= min && uInput.length <= max){
    return true;
  }else{
    alert("Please enter between " +min+ " and " +max+ " characters");
    elem.focus();
    return false;
  }
}

function madeSelection(elem, helperMsg){
  if(elem.value == "Please Choose"){
    alert(helperMsg);
    elem.focus();
    return false;
  }else{
    return true;
  }
}

function emailValidator(elem, helperMsg){
  var emailExp = /^[\w\-\.\+]+\@[a-zA-Z0-9\.\-]+\.[a-zA-z0-9]{2,4}$/;
  if(elem.value.match(emailExp)){
    return true;
  }else{
    alert(helperMsg);
    elem.focus();
    return false;
  }
}
