function translate(interUri) {
                //var interUri = get_parameter("URI");
                Ext.Ajax.request({
                        url: interUri + "/structured?_dc=" + Math.random(),
                        method: "get",
                        success: function(o) {
                                var json = Ext.util.JSON.decode(o.responseText);
                                window.location = "http://informatics.systemsbiology.net/EPEPT/index.html?URI=" + json.inputs["uri-uuid"]
                                }
                });             
}

