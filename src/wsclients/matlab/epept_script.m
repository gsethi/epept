%% Initialize
clear all
clear java
clear import

%% JAVA functionalities
javaaddpath('U:\matlab\PermutationsWebsite\ClientExamples\Matlab\commons-httpclient-support-1.2.1-SNAPSHOT-jar-with-dependencies.jar'); %location of jar file
L = import('org.apache.commons.httpclient.methods.*');
L = import('org.apache.commons.httpclient.methods.multipart.*');
L = import('org.apache.commons.httpclient.*');
L = import('org.systemsbiology.addama.commons.httpclient.support.*');
L = import('java.io.*');
L = import('java.net.URI');

%% Define host
host = 'http://informatics.systemsbiology.net';
addama = '/addama-rest/primary-repo/path/RobotForms/EPEPT/form_entry';

%% Choose file with permutation values and set parameters
mode = 'PV';
nperms = 1000;

switch mode
    case 'PV' %permutations
        file_in = 'U:\matlab\PermutationsWebsite\ClientExamples\Matlab\mymatrix.tsv'; %location of file with permutation values
        % makedata(1e4,5,file_in);
    case 'SAM' %sam
        file_in = 'U:\matlab\PermutationsWebsite\datasets\makeyeastdata\yeastdata_small.txt'; %location of file with expression data
    case 'GSEA' %gsea
        %location of file with expression data + %location of gene set file
        file_in = {'U:\matlab\PermutationsWebsite\datasets\makeyeastdata\yeastdata.txt','U:\matlab\PermutationsWebsite\datasets\makeyeastdata\GO_small2.gmt'};
end

params = cell(0,2); p = 0;
p = p + 1;
params{p,1} = 'mode';
params{p,2} =  mode;
p = p + 1;
params{p,1} = 'method';
params{p,2} = 'pwm';
p = p + 1;
params{p,1} = 'ci_chk';
params{p,2} = 'true';
p = p + 1;
params{p,1} = 'ci';
params{p,2} = '95';
p = p + 1;
params{p,1} = 'oopt_chk';
params{p,2} = 'false';
p = p + 1;
params{p,1} = 'cc_chk';
params{p,2} = 'false';
p = p + 1;
params{p,1} = 'rseed';
params{p,2} = '5884689';
p = p + 1;
params{p,1} = 'mail_address';
params{p,2} = 'tknijnenburg@systemsbiology.org';
if strcmp(mode,'SAM')|strcmp(mode,'GSEA');
    p = p + 1;
    params{p,1} = 'resptype';
    params{p,2} = 'Two class unpaired';
    p = p + 1;
    params{p,1} = 'nperms';
    params{p,2} = num2str(nperms);
end
if strcmp(mode,'GSEA');
    p = p + 1;
    params{p,1} = 'gsa_method';
    params{p,2} = 'maxmean';
end


%% Choose outputfile or directory
file_out = 'U:\matlab\PermutationsWebsite\ClientExamples\Matlab\'; %name or directory of the output file containing the P-values

%% Make request
URI = epept_makerequest(file_in,params,host,addama);

%% Check status (loop until status is completed/ready)
Status = epept_checkstatus(URI);
while ~Status
    Status = epept_checkstatus(URI);
    pause(1);
end

%% Get outputs
P = epept_getoutput(URI,file_out)