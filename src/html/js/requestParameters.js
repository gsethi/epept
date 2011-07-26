var RequestParameters = Class.create({
    parameterMap: new Hash(),

    initialize: function() {
        //alert("RequestParameters");
        var paramMap = this.parameterMap;

        var queryString = decodeURI(window.location.search.substring(1));
        if (queryString) {
            function addParameterPair(param) {
                var eqPos = param.indexOf("=");
                var key = param.substr(0, eqPos);
                var val = param.substr(eqPos+1, param.length);

                var existingVal = paramMap.get(key);
                if (existingVal == null) {
                    paramMap.set(key, val);
                } else {
                    if (existingVal.push) {
                        existingVal.push(val);
                    } else {
                        var vals = new Array();
                        vals.push(existingVal);
                        vals.push(val);
                        paramMap.set(key, vals);
                    }
                }
            }

            if (queryString.indexOf("&") > 0) {
                var params = $A(queryString.split("&"));
                params.each(addParameterPair);
            } else {
                addParameterPair(queryString);
            }
        }
    },

    getParameterMap: function() {
        return this.parameterMap;
    },

    getNames: function() {
        return this.parameterMap.keys();
    },

    getParameter: function(name) {
        return this.parameterMap.get(name);
    }
});

var RequestParams = {
    rp : null,

    getResourceUri : function () {
        if (!rp) rp = new RequestParameters();
        return rp.getParameter("URI");
    }
}
