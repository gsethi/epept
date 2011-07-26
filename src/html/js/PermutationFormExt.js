Ext.namespace('Permutation_pvalue.html');

Permutation_pvalue.html.FormExt = function() {
    Ext.QuickTips.init();
    Ext.form.Field.prototype.msgTarget = 'side';

//override
Ext.override(Ext.form.CheckboxGroup, {
  getNames: function() {
    var n = [];
    this.items.each(function(item) {
      if (item.getValue()) {
        n.push(item.getName());
      }
    });
    return n;
  },
  getValues: function() {
    var v = [];
    this.items.each(function(item) {
      if (item.getValue()) {
        v.push(item.getRawValue());
      }
    });
    return v;
  },
  setValues: function(v) {
    var r = new RegExp('(' + v.join('|') + ')');
    this.items.each(function(item) {
      item.setValue(r.test(item.getRawValue()));
    });
  }
});

Ext.override(Ext.form.RadioGroup, {
  getName: function() {
    return this.items.first().getName();
  },
  getValue: function() {
    var v;
    this.items.each(function(item) {
      v = item.getRawValue();
      return !item.getValue();
    });
    return v;
  },
  setValue: function(v) {
    this.items.each(function(item) {
      item.setValue(item.getRawValue() == v);
    });
  }
});

    // private variables
    var uploadFileFormComponent = null;
    // private functions
    function returnEmptyFormPanel() {
        return new Ext.form.FormPanel({
            id: 'uploadFileFormBlank',
            title: 'Upload',
            border: false
        });
    }
    function validateInputs() {
        try {
	    var pass = true;
	    var msg = "";	
            var file = $("filename").value;
            if (!file) {
                msg = "Data matrix file is required for all EPEPT modes";
                pass = false;
            }
	    var val = uploadFileFormComponent.getForm().getValues()["mode"];
	    if (val == 'GSEA'){
	    	var gseafile = $("gsfile").value;
		if (!gseafile){
			pass = false;
			msg = "<br>GSEA mode requires a gene expression file";
		}
	    }
            var lb = Ext.getCmp("ciId").getValue();
            if (lb && isNaN(lb)) {
                msg = "<br>Confidence Interval % Must Be A Number and between 1 .. 99";
                pass = false;
            }
            var lower = parseFloat(lb);
            if (lower < 10 || lower > 99){
                msg = "<br>Confidence Interval % Must Be Between 10 .. 99";
                pass = false;
            }
	    if (pass == false){
	    			Ext.Msg.show({
                                                        title      : 'Validation Error',
                                                        msg        : msg,
                                                        width      : 300,
                                                        icon       : Ext.MessageBox.ERROR
                                             });
		return false;
	    }
		   		Ext.Msg.show({
                                                        title      : 'EPEPT Submission',
                                                        msg        : "EPEPT is processing, once data files are uploaded, this web page will refresh itself until the EPEPT completes or encounters an error. An email with a results URI will be sent to " + $("mail_address").value + " if an valid address was entered.",
                                                        width      : 300,
                                                        icon       : Ext.MessageBox.INFO
                                             });
         
            return true;
        } catch (e) {
            alert(e);
            return false;
        }
    }

    function resetPrivateVariables() {
        uploadFileFormComponent = null;
    }

    // public
    return {
        // public properties
        getUploadFileFormComponent: function() {
	    if (uploadFileFormComponent) {
                return uploadFileFormComponent;
            } else {
                return returnEmptyFormPanel();
            }
        },
        // public methods
        init: function(newResourceUri, callbackFcn) {
            resetPrivateVariables();
            Ext.QuickTips.init();
            var fileTypeData = [
                ['ML', 'Maximum Likelihood'],
                ['MOM', 'Method of Moments'],
                ['PWM', 'Probability Weighted Moments']
            ];
            var fileTypeStore = new Ext.data.SimpleStore({
                fields: ['key', 'desc'],
                data : fileTypeData
            });
            var comboFileType = new Ext.form.ComboBox({
                store: fileTypeStore,
                name: 'method_combo',
                id: 'method_combo',
                fieldLabel: 'Method Name',
                displayField:'desc',
                valueField:'key',
                value:'PWM',
                typeAhead: true,
                mode: 'local',
                triggerAction: 'all',
                forceSelection:true,
                selectOnFocus:true
            });
	var oopt_chkbx = new Ext.form.Checkbox({
                                fieldLabel: "Enable OOPT",
                                name: 'oopt_chk',
                                id: 'oopt_chkid',
                                disabled: false,
                                value: false,
                                allowBlank: true,
                                listeners: {
                                    check: function (obj, chk) {
                                        if (chk) {
                                            Ext.getCmp("method_combo").setValue("Probability Weighted Moments");
                                            Ext.getCmp("method").setValue("PWM");
                                        }
                                    },
                                render: function(c) {
                                    Ext.QuickTips.register({
                                        target: c,
                                        title: '',
                                        text: 'Enable Optimal Order Preserving Transformation'
                                    });
                                }
                                }
                            });
	uploadFileFormComponent = new Ext.form.FormPanel({
                id: 'uploadFileForm',
                url: newResourceUri,
                method: 'POST',
                standardSubmit: true,
                fileUpload : true,
                buttonAlign: 'left',                                
                border: true,
                buttons: [
                    {
                        id: 'show-button',
                        name: 'show-button',
                        text: 'Execute',
                        listeners: {click: //uploadFile handler
                                function() {
                                    if (!validateInputs()) {
                                        $("status").innerHTML = "<h3>Status: Failed validation</h3>" + new Date();
                                        return false;
                                    }
                                    $("status").innerHTML = "<h3>Status: Begin Execution - uploading file </h3>" + new Date();
                                    $("stdout").innerHTML = "";
                                    var O = Ext.getCmp('uploadFileForm');
                                    $("show-button").disabled = true;
                                    if (O.getForm().isValid()) {
                                        if (O.url){
						O.getForm().getEl().dom.action = O.url;
					}
                                        if (O.baseParams) {
                                            for (var i in O.baseParams) {
                                                O.add(
                                                {  xtype:"hidden",
                                                    name:i,
                                                    value:O.baseParams[i]
                                                });
                                            }
                                            O.doLayout();
                                        }
                                        O.getForm().submit();
                                        callbackFcn();
                                    }
                                }
                        }
                    }],
                items: [
                    new Ext.form.FieldSet({
                        autoHeight: true,
                        autoWidth: true,
                        border: false,
                        items: [
		{
            xtype: 'radiogroup',
            fieldLabel: 'Mode',
	    margin: '8px',
	    width: 350,	
	    columns: 1,
	    id: 'mode',
	    padding: 0,
            items: [
                {boxLabel: 'Permutation Values', name: 'mode', inputValue: 'PV', checked:true,
		listeners: {
                check: function(c){
                        var val = uploadFileFormComponent.getForm().getValues()["mode"];
			if (val == 'PV'){
				Ext.getCmp("sam_gsea_fieldset").collapse();
				Ext.getCmp("gsea_fieldset").collapse();
			}
			if (val == 'SAM'){
                                        Ext.getCmp("sam_gsea_fieldset").expand();
					Ext.getCmp("gsea_fieldset").collapse();
                                }
                        if (val == 'GSEA'){
                                        Ext.getCmp("gsea_fieldset").expand();
					Ext.getCmp("sam_gsea_fieldset").expand();
                        }}                                
		}},
                {boxLabel: 'SAM', name: 'mode', inputValue: 'SAM'},
                {boxLabel: 'GSEA', name: 'mode', inputValue: 'GSEA'}
                ]},
                new Ext.form.TextField({
                                fieldLabel: 'Data File',
                                defaultAutoCreate : {tag:"input", enctype:"multipart/form-data", type:"file", size: "30", autocomplete: "off"},
                                name: 'filename',
                                id: 'filename',
                                allowBlank: false,
				listeners: {
                                render: function(c) {
                                    Ext.QuickTips.register({
                                        target: c,
                                        title: '',
                                        text: 'Required: Data file with permutation values or for SAM/GSEA gene expression values'
                                    });
                                }}
                            }),
 {
            xtype: 'radiogroup',
            fieldLabel: 'Method',
            margin: '8px',
            width: 350,
            columns: 1,
            id: 'method',
            padding: 0,
            items: [
                {boxLabel: 'Probability Weighted Moments', name: 'method', inputValue: 'PWM', checked:true,
                listeners: {
                check: function(c){
                        var val = uploadFileFormComponent.getForm().getValues()["mode"];
                        if (val == 'PV'){
                                Ext.getCmp("sam_gsea_fieldset").collapse();
                                Ext.getCmp("gsea_fieldset").collapse();
                        }
                        if (val == 'SAM'){
                                        Ext.getCmp("sam_gsea_fieldset").expand();
                                        Ext.getCmp("gsea_fieldset").collapse();
                                }
                        if (val == 'GSEA'){
                                        Ext.getCmp("gsea_fieldset").expand();
                                        Ext.getCmp("sam_gsea_fieldset").expand();
                        }}
                }},
                {boxLabel: 'Maximum Likelihood', name: 'method', inputValue: 'ML'},
                {boxLabel: 'Method of Moments', name: 'method', inputValue: 'MOM'}
                ]},
                new Ext.form.TextField({
                                fieldLabel: 'Data File',
                                defaultAutoCreate : {tag:"input", enctype:"multipart/form-data", type:"file", size: "25", autocomplete: "off"},
                                name: 'filename',
                                id: 'filename',
                                allowBlank: false,
                                listeners: {
                                render: function(c) {
                                    Ext.QuickTips.register({
                                        target: c,
                                        title: '',
                                        text: 'Required: Data file with permutation values or for SAM/GSEA gene expression values'
                                    });
                                }}
                            }),
            {xtype: 'fieldset',
            title: 'Confidence Interval Parameters',
            id: 'ci_fieldset',
            collapsed: false,
            collapsible: false,
            autoHeight: true,
            items: [
                            new Ext.form.Checkbox({
                                fieldLabel: "Enable Interval",
                                name: 'ci_chk',
                                id: 'ci_chkid',
                                checked: true,
                                allowBlank: true,
                                listeners: {
                                    check: function (obj, chk) {
                                        if (!chk) {
                                            Ext.getCmp("ciId").setValue("");
                                        } else {
                                            Ext.getCmp("ciId").setValue("95");
                                        }
                                    }
                                }
                            }),
                            new Ext.Slider({
                                fieldLabel: 'Interval Slider',
                                name: 'ci_slider',
                                id: 'ci_slider',
                                isFormField: true,
                                width: 214,
                                value: 95,
                                minValue: 10,
                                maxValue: 99,
                                plugins: new Ext.ux.SliderTip(),
                                listeners: {
                                    dragend:
                                            function() {
                                            Ext.getCmp("ciId").setValue(this.getValue());
                                            },
                                    change:
                                            function() {
                                            Ext.getCmp("ciId").setValue(this.getValue());
                                            }
                                }
                            }),
                            new Ext.form.TextField({
                                fieldLabel: "Confidence %",
                                defaultAutoCreate : {tag:"input", type:"text", size: "10", autocomplete: "off"},
                                name: 'ci',
                                id: 'ciId',
                                value: '95'
                            })
			    ]},
                            oopt_chkbx,
                            new Ext.form.Checkbox({
                                fieldLabel: "Enable Convergence Criteria",
                                name: 'cc_chk',
                                id: 'cc_chk',
                                value: false,
                                allowBlank: true,
                                listeners: {
                                    check: function (obj, chk) {
                                        if (chk) {
					Ext.getCmp("method").setValue('PWM');
                                        }
                                    },
				    render: function(c) {
                                    Ext.QuickTips.register({
                                        target: c,
                                        title: '',
                                        text: 'Determines whether the convergence criteria should be applied or not. If this box is checked at least 10,000 permutation values should be reported. Sets method to Probabiliy Weighted Moments'
                                    });
                                }
                                }
                            }),			
        new Ext.form.TextField({
                                name: 'rseed',
                                id: 'rseed',
                                fieldLabel: 'Random seed',
                                value: 0,
                                listeners: {
                                render: function(c) {
                                    Ext.QuickTips.register({
                                        target: c,
                                        title: '',
                                        text: 'Numerical value between 1 and 1000000. 0 (default) uses arbitrary random seed'
                                    });
                                }
                                }
                            }),
 	new Ext.form.TextField({
                                name: 'mail_address',
                                id: 'mail_address',
                                fieldLabel: 'Email',
                                value: "",
                                listeners: {
                                render: function(c) {
                                    Ext.QuickTips.register({
                                        target: c,
                                        title: '',
                                        text: 'Enter email address for system to notify you when EPEPT completes. A results URL in the email includes information your EPEPT parameters and links to output files. Your email address is completely confidential and will not be used/shared anywhere else. This browser will also automatically refresh itself while checking for new job status - browser caching must be disabled'
                                    });
                                }
                                }
                            }),
	 {
            xtype: 'fieldset',
            title: 'SAM/GSEA Parameters',
	    id: 'sam_gsea_fieldset',
	    collapsed: true,
	    collapsible: true,		
            autoHeight: true,
            defaultType: 'radio', // each item will be a radio button
            items: [
		{
                fieldLabel: 'Response Type',
                boxLabel: 'Quantitative',
		name: 'resptype',
                inputValue: 'Quantitative'
            }, {
                fieldLabel: '',
                labelSeparator: '',
		checked: true,
                boxLabel: 'Two class unpaired',
		name: 'resptype',
                inputValue: 'Two class unpaired'
            }, 
	    {
                fieldLabel: '',
                labelSeparator: '',
                boxLabel: 'Two class paired',
		name: 'resptype',
                inputValue: 'Two class paired'
            }, 
	    {
                fieldLabel: '',
                labelSeparator: '',
                boxLabel: 'Survival',
		name: 'resptype',
                inputValue: 'Survival'
            }, 
	    {
                fieldLabel: '',
                labelSeparator: '',
                boxLabel: 'Multiclass',
                id: 'resptype',
		name: 'resptype',
                inputValue: 'Multiclass'
            }, 
	 new Ext.form.TextField({
                                name: 'nperms',
                                id: 'nperms',
				fieldLabel: 'NPerms',
                                value: 1000,
				listeners: {
                                render: function(c) {
                                    Ext.QuickTips.register({
                                        target: c,
                                        title: '',
                                        text: 'Nperms indicates the number of permutations to be performed. For SAM: maximum allowed number of permutations is 1,000. For GSEA: maximum allowed number of permutations is 10,000.'
                                    });
                                },
				change: function(t,n,o){
					var max = 10000;
					if (uploadFileFormComponent.getForm().getValues()["mode"] == 'SAM'){
						max = 1000;
					}
					if (parseInt(n) < 100 || parseInt(n) > max){
						Ext.Msg.show({
       							title      : 'Warning',
       							msg        : "Value must be between 100 and " + max + " Resetting back to older value",
       							width      : 300,
       							buttons    : Ext.MessageBox.YES,
       							icon       : Ext.MessageBox.ERROR
    						});
						Ext.getCmp("nperms").setValue(o);
					}
				}
				}
                            })
		]},
 		{
            xtype: 'fieldset',
            title: 'GSEA Parameters',
            id: 'gsea_fieldset',
            collapsed: true,
            collapsible: true,
            items: [
                new Ext.form.TextField({
                                fieldLabel: 'Geneset File',
                                defaultAutoCreate : {tag:"input", enctype:"multipart/form-data", type:"file", size: "25", autocomplete: "off"},
                                name: 'gsfile',
                                id: 'gsfile',
                                allowBlank: true,
				listeners: {
				render: function(c) {
                                    Ext.QuickTips.register({
                                        target: c,
                                        title: '',
                                        text: 'Data file with gene set annotation in Gene Matrix Transposed file format (*.gmt)'
                                    });
                                }}
                            }),
		{
            xtype: 'radiogroup',
            fieldLabel: 'GSEA statistic',
            items: [
                {boxLabel: 'maxmean', name: 'gsa_method', inputValue: 'maxmean', checked:true},
                {boxLabel: 'mean', name: 'gsa_method', inputValue: 'mean'},
                {boxLabel: 'absmean', name: 'gsa_method', inputValue: 'absmean'}
            	]
        	}
		]},
                new Ext.form.TextField({
                                name: 'REDIRECT_TO',
                                id: 'REDIRECT_TO',
                                value: "/EPEPT/index.html",
                                hidden: true
                            })
                        ]
                    })
                ]
            }); //end uploadFileComponent
            callbackFcn();
        }//end of init
    };
}();
