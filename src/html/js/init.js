Ext.onReady(initPage);
Ext.onReady(loadTheoBanner);

function initPage() {
    Ext.QuickTips.init();
    var action = '/addama-rest/primary-repo/path/RobotForms/EPEPT/form_entry/html';
    var uploadFormComponent = null;
    var uploadForm = Permutation_pvalue.html.FormExt;
    uploadForm.init(action, function() {
        uploadFormComponent = uploadForm.getUploadFileFormComponent();
    });
    new Ext.Panel({
        title: "EPEPT Inputs " + "<a href='http://code.google.com/p/epept/wiki/Manual' target='_blank'>Help</a>",
        id: 'inputPanelId',
        deferredRender:false,
        renderTo: "input-panel",
        width:600,
        header: true,
        items: [uploadFormComponent]
    });
    new Ext.Panel({
        title: "Status and Results",
        border: true,
        id: 'outputPanelId',
        deferredRender:false,
        renderTo: "output-panel",
        width:900,
        header: true
    });

    loadResults();
}

function loadTheoBanner() {
    new Ext.Panel({
        id: 'header',
        border: true,
        deferredRender:false,
        items: [
            { title:"<a href='http://shmulevich.systemsbiology.net/' target='_blank'>Informatics@Shmulevich Lab</a>&nbsp;&nbsp;&nbsp;<a href='http://www.systemsbiology.org' target='_blank'>Institute for Systems Biology</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href='./index.html'>HTML Input Form</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href='http://code.google.com/p/epept/wiki/Manual' target='_blank'>Manual</a> &nbsp;&nbsp&nbsp;&nbsp;<a href='http://code.google.com/p/epept/wiki/WebServiceClients' target='_blank'>Source and Web Service Client Examples</a>"  }
        ],
        renderTo: 'theo-banner'
    });
}

function loadPreviousInputs(inputs) {
    var mode = inputs.mode;
    var uri = inputs.uri;
    if (mode == undefined){
        mode = 'Permutation Values';
    }
    $("results_filename").innerHTML = "<b>Previous Inputs</b> <br>Data File:<a href=' " + uri + '/' + inputs.filename + "' target='_blank'>" + "&nbsp;" + inputs.filename + "</a>" ;
    var method = inputs.method;
    $("results_method").innerHTML = "Mode: " + mode + "<br>Method name: " + method;
    var oopt = false;
    if (inputs.oopt_chk == 'on') {
        oopt = true;
    }
    var oopt_cb = new Ext.form.Checkbox({
        boxLabel: "Enable 'Optimal Order Preserving Transformation (OOPT)'",
        name: 'oopt_prev_chk',
        id: 'oopt_prev_chk',
        checked: oopt,
        renderTo: 'results_oopt'
    });
    oopt_cb.render();
    var ci = false;
    if (inputs.ci_chk == 'on') {
        ci = true;
        $("results_lower_bound").innerHTML = " Confidence Interval: " + inputs["ci"] + "%<br>";
    } else {
        $("results_lower_bound").innerHTML = " Confidence Interval Not Enabled<br>";

    }
    var eci = new Ext.form.Checkbox({
        boxLabel: "Enable Confidence Interval",
    name: 'ci_prev_chk',
        id: 'ci_prev_chk',
        checked: ci,
        renderTo: "results_ci"
    });
    eci.render();
    var cc = false;
    if (inputs.cc_chk == 'on') {
        cc = true;
    }
    var ecc = new Ext.form.Checkbox({
        boxLabel: "Enable Convergence Criteria",
    name: 'cc_prev_chk',
        id: 'cc_prev_chk',
        checked: cc,
        renderTo: "results_cc"
    });
    ecc.render();
    $("results_cc").insert("Random Seed: " + inputs.rseed );
    $("results_cc").insert("<br>Email: " + inputs.mail_address );
    if (inputs.mode == 'SAM' || inputs.mode == 'GSEA'){
        $("results_cc").insert("<br>RespType: " + inputs.resptype );
    $("results_cc").insert("<br>NPerms: " + inputs.nperms );
    if (inputs.mode == 'GSEA'){
            $("results_cc").insert("<br>GSFile: " + "<a href=' " + uri + '/' + inputs.gsfile + "' target='_blank'>" + "&nbsp;" + inputs.gsfile + "</a>");
            $("results_cc").insert("<br>GSAMethod: " + inputs.gsa_method );
        }
    }
}

function loadResults() {
    var startTime = new Date();
    var resultsUri = get_parameter("URI");
    if (resultsUri) {
        Ext.Ajax.request({
            url: resultsUri + "/structured",
            method: "get",
            params: {
                "_dc": Ext.id()
            },
            success: function(o) {
                var json = Ext.util.JSON.decode(o.responseText);
                var inputs = null;
                if (json) {
                    inputs = json.inputs;
                    loadPreviousInputs(inputs);
                }
                if (json.status) {
                    var now = new Date();
                    $("status").innerHTML = "<h3>Status: <font color='green'>EPEPT Running...</font></h3>Submitted: " + inputs["submitted"] + "<br>" + "Time now: " + now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds();

                    var updater = new Ext.Updater("status");
                    updater.startAutoRefresh(3, json.status.uri + "/structured", { "_dc": Ext.id() });
                    mgr.on("update", onUpdate);
            }
        }
    });
  }
}

function onUpdate(el, o) {
                var jsonStatus = Ext.util.JSON.decode(o.responseText);
                var now = new Date();
                $(el).innerHTML = "<h3>Status: <font color='green'>EPEPT Running...</font></h3>Submitted: " + inputs["submitted"] + "<br>" + "Time now: " + now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds();

                var timeCompleted = "";
                if (jsonStatus.error != null || jsonStatus.completed != null) {
                                    updater.stop();
                    Ext.Ajax.request({
                            url: resultsUri + "/logs/timeout.txt",
                            method: "get",
                            params: { "_dc": Ext.id() },
                             success: function(o) {
                                timeCompleted = o.responseText;
                                if (jsonStatus.error){
                                    $(el).innerHTML = "<h3>Status: Error</h3>Submitted on:" + inputs["submitted"] + " ended:" + timeCompleted + "<br>Msg:" + jsonStatus.error["message"];
                                            showErrors(resultsUri, inputs["mode"]);
                                }else{
                                    $(el).innerHTML = "<h3>Status: Completed</h3>Submitted on:" + inputs["submitted"] + " ended:" + timeCompleted;
                                                    showOutputs(resultsUri);
                                }
                        }
                    });
                }else if (jsonStatus.completed){
                updater.stop();
                $(el).innerHTML = "<h3>Status: Completed</h3>Submitted on:" + inputs["submitted"] + " ended:" + timeCompleted;
                showOutputs(resultsUri);
               }else if (jsonStatus.running) {
                                $(el).innerHTML = "<h3>Status: <font color='green'>Robot Running...</font></h3>Processing since: " + jsonStatus.inputs["submitted"];
                            } else if (jsonStatus.pending) {
                                $(el).innerHTML = "<h3>Status: <font color='blue'>Robot Pending...</font></h3>Submitted at: " + jsonStatus.inputs["submitted"];
                            }
}

function showOutputs(resultsUri) {
    if (resultsUri) {
        Ext.Ajax.request({
            url: resultsUri + "/structured",
            method: "get",
            params: {
                "_dc": Ext.id()
            },
            success: function(o) {
                var json = Ext.util.JSON.decode(o.responseText);
                if (json) {
                    var inputs = json.inputs;
                    var outputs = json.outputs;
                    var xls = false;
                    var xlsx = false;
                    var inputFile = inputs.filename;
                    if (outputs) {
                        var extensionIndex = inputFile.indexOf(".tsv");
                        if (extensionIndex == -1){
                           extensionIndex = inputFile.indexOf(".csv");
                        }
                     if (extensionIndex == -1){
                           extensionIndex = inputFile.indexOf(".txt");
                        }
                        if (extensionIndex == -1){
                           extensionIndex = inputFile.indexOf(".xlsx");
                           if (extensionIndex != -1){
                             xlsx = true;
                           }
                        }
                        if (extensionIndex == -1){
                           xls = true;
                           extensionIndex = inputFile.indexOf(".xls");
                        }
                        var outfileName = inputFile.substring(0, extensionIndex);
                        if (xls){
                           outfileName = outfileName + "_xls_";
                        }
                        if (xlsx){
                           outfileName = outfileName + "_xlsx_";
                        }
                        outfileName = outfileName + ".txt";
                        var fileUri = "/Pvalues_" + outfileName;
                        var labelsUri = "/labels_" + outfileName;
                        var uri = outputs.uri;
                        var fileout = uri + fileUri;
                        var labelsout = uri + labelsUri;
                        var filepng = uri + "/plot.png";
                        var fileeps = uri + "/plot.eps";
                        $("imageContent").innerHTML = "<a href='" + fileeps + "'>Save Histogram as EPS format</a> "
                                + "&nbsp; <a href='" + filepng + "'><img src='" + filepng + "' title='Histogram" + "' width='15%' heigth='15%'></a><br><br>";
                        $("downloadLink").innerHTML = "<a href='" + fileout + "'>P-Values Result (right click to save)</a>";
                        showResults(fileout, labelsout);
                    }
                }
            }
        });
    }
}

function showErrors(resultsUri, mode) {
    var mymode = mode;
    $("resultsContent").innerHTML = "";
    $("stdoutContent").innerHTML = "";
    $("stderrContent").innerHTML = "";
    $("logs").style.display = "";
    if (resultsUri) {
        Ext.Ajax.request({
            url: resultsUri + "/structured",
            method: "get",
            params: { "_dc": Ext.id() },
            success: function(o) {
                $("log_messages").innerHTML = "There were errors, here are the log outputs. Please email jlin@systemsbiology.org if you need more help<br><br>";
                var json = Ext.util.JSON.decode(o.responseText);
                if (json) {
                    var logs = json.logs;
                    if (logs) {
                        showLog(logs["error.log"], "stdoutContent");
                        showLog(logs["stderr.txt"], "stderrContent");
            if (mymode == 'SAM'){
                $("samlog").innerHTML = "<a href=' " + resultsUri + "/logs/samR.log'"  + ">" + "&nbsp;samR.log"  + "</a>";
            }
            if (mymode == 'GSEA'){
                var gsalogs = "";
                if (logs["gseaR1.log"] != null){
                    gsalogs  = gsalogs + "<a href=' " + resultsUri + "/logs/gseaR1.log'"  + ">" + "&nbsp;gseaR1.log"  + "</a>";
                }
                if (logs["gseaR2.log"] != null){
                                        gsalogs  = gsalogs + "<br><a href=' " + resultsUri + "/logs/gseaR2.log'"  + ">" + "&nbsp;gseaR2.log"  + "</a>";
                                }
                if (logs["gseaR3.log"] != null){
                                        gsalogs  = gsalogs + "<br><a href=' " + resultsUri + "/logs/gseaR3.log'"  + ">" + "&nbsp;gseaR3.log"  + "</a>";
                                }
                                $("gsealog").innerHTML = gsalogs;
                        }
                    }
                }
            }
        });
    }
}

function showResults(uri, labelsuri) {
//    Ext.Ajax.request({
//        method: "get",
//        url: uri,
//        params: {
//            "_dc": Ext.id()
//        },
//        success: function(o) {
//            var responseData = o.responseText;
//        }
//    });

    Ext.Ajax.request({
        method: "get",
        url: labelsuri,
        params: {
            "_dc": Ext.id()
        },
        success: function(ol) {
            var labelData = ol.responseText;
            var myForm = new Ext.form.FormPanel({
                        renderTo:"resultspanel",
                        title:"EPEPT Results",
                        width:425,
                        frame:true,
                        labelSeparator: "",
                        autoScroll:true,
                        items: [
                            new Ext.form.TextArea({
                                        id: "aliasId",
                                        fieldLabel: labelData,
                                        value: responseData,
                                        labelSeparator: "",
                                        height: 80,
                                        width: 1600,
                                        listeners: {
                                            render: function(c) {
                                                Ext.QuickTips.register({
                                                            target: c,
                                                            title: '',
                                                            text: labelData
                                                        });
                                            }
                                        }
                                    })
                         ]});
        }
    });
}

function showLog(log, textArea) {
    if (log && log.uri) {
        Ext.Ajax.request({
            url: log.uri,
            method: "get",
            params: { "_dc": Ext.id() },
            success: function(o) {
                $(textArea).innerHTML = o.responseText;
            }
        });
    } else {
        $(textArea).innerHTML = "Unable to display log, refresh page to retry getting logs";
    }
}