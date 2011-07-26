function P = epept_getoutput(URI,file);

%% JAVA functionalities
L = import('org.apache.commons.httpclient.methods.*');
L = import('org.apache.commons.httpclient.*');
L = import('org.systemsbiology.addama.commons.httpclient.support.*');

%% Get output
httpClient = HttpClient();
template = HttpClientTemplate(httpClient);
url_status_o = [URI '/outputs/dir'];
Method_o = GetMethod(url_status_o);
jsonResponse = JsonResponseCallback;
O = template.executeMethod(Method_o,jsonResponse);
str = []; n = -1;
while isempty(strmatch('Pvalues',str))
    n = n + 1;
    str = O.get('files').get(n).get('name');
end
if isdir(file);
    if ~(strcmp(file(end),'\')|strcmp(file(end),'/'))
        file = [file '\' O.get('files').get(n).get('name')];
    else
        file = [file O.get('files').get(n).get('name')];
    end
end

[output,status] = urlwrite([O.get('host-url') O.get('files').get(n).get('uri')],file)
display('Output saved...');
if status&nargout==1;
    P = importdata(output);
end
