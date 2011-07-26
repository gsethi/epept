function URI = epept_makerequest(file,params,host,addama)

%% JAVA functionalities
L = import('org.apache.commons.httpclient.methods.*');
L = import('org.apache.commons.httpclient.methods.multipart.*');
L = import('org.apache.commons.httpclient.*');
L = import('org.systemsbiology.addama.commons.httpclient.support.*');
L = import('java.io.*');
L = import('java.net.URI');

%% Define host
url = [host addama];

%% Setup client
httpClient = HttpClient();
template = HttpClientTemplate(httpClient);

%% Put parameters in NameValue array
nva = javaArray('org.apache.commons.httpclient.NameValuePair',1);
jsonStr = ['{'];
for n = 1:size(params,1);
    jsonStr = [jsonStr '"' params{n,1} '":"' params{n,2} '",'];
end
jsonStr(end) = '}';
nva(1) = NameValuePair('JSON', jsonStr);

%% Make request by uploading file and parameters
temppost = PostMethod(url);
parameters = temppost.getParams();
if iscell(file);
    
    part = javaArray('org.apache.commons.httpclient.methods.multipart.Part',1);
    
    inputFile = File(file{1});
    filePart1 = FilePart('filename', inputFile);
    
    inputFile2 = File(file{2});
    filePart2 = FilePart('gsfile', inputFile2);
    
    part(1) = filePart1;
    part(2) = filePart2;
    
    multiPartRequest = MultipartRequestEntity(part,parameters);
    temppost.setRequestEntity(multiPartRequest);

    
%     inputFile = File(file{1});
%     filePart = FilePart('filename', inputFile);
%     part = javaArray('org.apache.commons.httpclient.methods.multipart.Part',1);
%     part(1) = filePart;
%     multiPartRequest = MultipartRequestEntity(part,parameters);
%     temppost.setRequestEntity(multiPartRequest);
%         
%     inputFile2 = File(file{2});
%     filePart2 = FilePart('gsfile', inputFile2);
%     part2 = javaArray('org.apache.commons.httpclient.methods.multipart.Part',1);
%     part2(1) = filePart2;
%     multiPartRequest2 = MultipartRequestEntity(part2,parameters);
%     temppost.setRequestEntity(multiPartRequest2);
    
else
    inputFile = File(file);
    filePart = FilePart('filename', inputFile);
    part = javaArray('org.apache.commons.httpclient.methods.multipart.Part',1);
    part(1) = filePart;
    multiPartRequest = MultipartRequestEntity(part,parameters);
    temppost.setRequestEntity(multiPartRequest);
end
temppost.setQueryString(nva);
addamauricapture = AddamaUriCaptureResponseCallback();
temppost
addamauricapture
URI = template.executeMethod(temppost,addamauricapture);

%% Make URI string
URI = [host char(URI)];
display('Request is made...');

