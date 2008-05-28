function SVG_supporting_check()
{


var hasSVGSupport = false; // whether the browser supports SVG

//document.write(navigator.appName+"<br>");
//document.write(navigator.appVersion+"<br>");
//document.write(navigator.appCodeName+"<br>");
//document.write(navigator.userAgent+"<br>");


if (navigator.userAgent.indexOf("MSIE") != -1)
{
if (navigator.mimeTypes != null
&& navigator.mimeTypes.length > 0)
{
if (navigator.mimeTypes["image/svg+xml"] != null)
{

hasSVGSupport = true;
}
}



if (!hasSVGSupport)
{

alert('Sorry, your browser cannot support SVG\n the page unavailible');


}
}




}

