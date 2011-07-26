function Status = epept_checkstatus(URI)

%% JAVA functionalities
L = import('org.apache.commons.httpclient.methods.*');
L = import('org.apache.commons.httpclient.*');
L = import('org.systemsbiology.addama.commons.httpclient.support.*');

%% Check status
httpClient = HttpClient();
template = HttpClientTemplate(httpClient);
jsonResponse = JsonResponseCallback;
url_status_c = [URI '/status/completed'];
url_status_e = [URI '/status/error'];    
Method_c = GetMethod(url_status_c);
Method_e = GetMethod(url_status_e);
Complete = template.executeMethod(Method_c,jsonResponse);
Error = template.executeMethod(Method_e,jsonResponse);
if length(Complete)==0&length(Error)==0;
    Status = 0;
elseif length(Complete)>0&length(Error)==0;
    Status = 1; %Complete
elseif length(Complete)==0&length(Error)>0;
    Status = -1; %Error
else
    error('???')
end
% pause(1);
display('Checking status...');