function loadheader() {
    Ext.get('addama-banner').update("");
    var sharePanel = new Ext.Panel({
        title: "<left>Addama Web Automation</left>&nbsp;&nbsp;<right><a href='http://informatics.systemsbiology.net' target='_blank'>Research Informatics</a>&nbsp;&nbsp;&nbsp;<a href='http://www.systemsbiology.org' target='_blank'>Systems Biology</a></right>",
        id: 'header',
        border: true,
        deferredRender:false,
        items: [{title:"<a href='/addama-html/browse_repo.html'>Addama JCR Browse</a> <a href='/addama-html/search1.html'>Search</a>", html: null}], 
        renderTo: 'addama-banner'
    });
}
function loadTheoBanner() {
    
    Ext.get("theo-banner").update("");
    var sharePanel = new Ext.Panel({
        title: "<left>EPEPT - Addama Service</left>&nbsp;&nbsp;<right><a href='http://informatics.systemsbiology.net' target='_blank'>Research Informatics</a>&nbsp;&nbsp;&nbsp;<a href='http://www.systemsbiology.org' target='_blank'>Systems Biology</a></right>",
        id: 'header',
        border: true,
        deferredRender:false,
        items: [{title:"<a HREF='./index.html'>HTML Input Form</a> &nbsp;&nbsp;<a href='permcomp_info.html'>Manual</a> &nbsp;&nbsp&nbsp;&nbsp;<a href='perm_downloads.html'>Source and Web Service Client Examples</a>", html: null}
        ],
        renderTo: 'theo-banner'
    });
}
function getEPEPTContact(){
    return "Theo Knijnenburg, Jake Lin, Hector Rovira, John Boyle, Ilya Shmulevich<br>"
                    + "Institute for Systems Biology<br>"
                    + "401 Terry Ave North<br>"
                    + "Seattle, WA 98109-5234, US<br>"
                    + "Phone: (206) 732-1200<br>"
                    + "Fax: (206) 732-1299<br>"
                    + "Contact: <a href='mailto:jlin@systemsbiology.net'>Email Jake Lin</a><br>";
}
function showErrorAlert(message) {
    $("error-div").innerHTML = "";
    $("error-div").innerHTML = "<center><b><font color='red'>" + message + "</font></b></center>";
}
function showSuccessAlert(message) {
    $("error-div").innerHTML = "";
    $("error-div").innerHTML = "<center><b><font color='orange'>" + message + "</font></b></center>";
}
