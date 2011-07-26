% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Warranty Disclaimer and Copyright Notice
%
% Copyright (C) 2003-2010 Institute for Systems Biology, Seattle, Washington, USA.
%
% The Institute for Systems Biology and the authors make no representation about the suitability or accuracy of this software for any purpose, and makes no warranties, either express or implied, including merchantability and fitness for a particular purpose or that the use of this software will not infringe any third party patents, copyrights, trademarks, or other rights. The software is provided "as is". The Institute for Systems Biology and the authors disclaim any liability stemming from the use of this software. This software is provided to enhance knowledge and encourage progress in the scientific community.
%
% This is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.
%
% You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Note:
% Options SAM and GSEA are not supported in this stand alone version.

%% Initialize
clear all;
close all;
clc;
display(['EPEPT version 2.1']);
warning('on');
warning('off','MATLAB:log:logOfZero');
warning('off','MATLAB:RandStream:ActivatingLegacyGenerators');
warning('off','MATLAB:xlsread:ActiveX');
addpath([pwd '/mfiles']);

%% Dataset and parameters

%% Choose file with permutation values and set parameters
Mode = 'PV';                                                   % PV
File = 'art_f.tsv';                                            % name (and path) of data file
method = 'MOM';                                                % ML or MOM or PWM
ci_flag = 'true';                                              % confidence interval flag; true or false
ci = 95;                                                       % confidence interval; number between 10 and 99
oopt_flag = 'false';                                           % optimal order preserving transform flag; true or false
cc_flag = 'false';                                             % convergence criteria flag; true or false
randomseed = 1;                                                % number between 1 and 1000000, 0 indicated random value
nperms = 1000;                                                 % number of permutations
filenameout = 'pvalues.txt';                                   % name (and path) of output file
filenameout_labels = 'pvalues_l.txt';                          % name (and path) of output file with labels
plotnameout = 'pvalues.eps';                                   % name (and path) of output plot

%% Preprocessing
alpha = ci;
if alpha>99|alpha<10;alpha = 95;else;alpha = round(alpha);end
alpha = 1-(alpha/100);

%% Open file and check data
display(' ');
display('Loading matrix file...');
filename = File;

if randomseed==0; randomseed = ceil(1e6*rand); end
RandStream.setDefaultStream(RandStream('mt19937ar','seed',randomseed));

[A,header,H] = readandcheckdata(filename,File,Mode);

%% Run P-value estimation
display(' ');
display('Running P-value estimation...');

switch Mode
    case 'PV' %permutations
        [P,Pci,Pcc] = Main(A,method,ci_flag,alpha,oopt_flag,cc_flag,header,H);
    case 'SAM' %sam
        [P,Pci,Pcc] = runsam(A,method,ci_flag,alpha,oopt_flag,cc_flag,header,H,randomseed,nperms);
    case 'GSEA' %gsea
        [P,Pci,Pcc,H] = rungsea(A,method,ci_flag,alpha,oopt_flag,cc_flag,header,H,randomseed,nperms);
end


%% Write output and make plot
display(' ');
display('Writing output...');

WriteOutputMakePlot(filenameout,plotnameout,filenameout_labels,P,Pci,Pcc,length(P),ci_flag,cc_flag,header,H);


