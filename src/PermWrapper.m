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

try
%% Start   
    display(['EPEPT version 2.1']);
    display(['Started: ' datestr(now)]);
    warning('on');
    warning('off','MATLAB:log:logOfZero');
    warning('off','MATLAB:RandStream:ActivatingLegacyGenerators');
    warning('off','MATLAB:xlsread:ActiveX');
    addpath([pwd '/mfiles']);

%% Parse json
    display(' ');
    display('Processing json file...');
    fid = fopen([pwd '/inputs/perm.json']);
    json = fscanf(fid,'%s');
    fclose(fid);
    [data json] = parse_json(json);
    Mode = upper(data{1}.mode);                                         display(['Mode                               : ' Mode]);
    File = data{1}.file;                                                display(['File                               : ' File]);
    method = upper(data{1}.method);                                     display(['Method                             : ' method]);
    ci_flag = lower(data{1}.ci_chk);                                    display(['Confidence Interval                : ' ci_flag]);
    alpha = str2num(data{1}.ci);
    if alpha>99|alpha<10;alpha = 95;else;alpha = round(alpha);end
    alpha = 1-(alpha/100);  if strcmp(ci_flag,'true');                  display(['Alpha                              : ' num2str(alpha)]);           end
    oopt_flag = lower(data{1}.oopt_chk);                                display(['Order Preserving Transform         : ' oopt_flag]);
    cc_flag = lower(data{1}.cc_chk);                                    display(['Convergence criteria               : ' cc_flag]);
    randomseed = str2num(data{1}.rseed);                                display(['Random Seed                        : ' num2str(randomseed)]);
    if strcmpi(Mode,'SAM')|strcmp(Mode,'GSEA');
        resptype = data{1}.resptype;                                    display(['Response Type                      : ' resptype]);
        nperms = round(str2num(data{1}.nperms)); 
        if strcmpi(Mode,'SAM');
            if nperms>1000;nperms = 1000;else;nperms = round(nperms);end
        elseif strcmpi(Mode,'GSEA');
            if nperms>10000|nperms<1000;nperms = 1000;else;nperms = round(nperms);end
        end
                                                                        display(['Number of permutations             : ' num2str(nperms)]);
    end
    if strcmp(Mode,'GSEA');
        GSfile = data{1}.gsfile;                                        display(['Gene Set File                      : ' GSfile]);
        if ~strcmpi(GSfile,'geneset.gmt');
            movefile([pwd '/inputs/' GSfile],[pwd '/inputs/geneset.gmt']);
        end
        gsa_method = lower(data{1}.gsa_method);                         display(['GSEA Statistic                     : ' gsa_method]);
    end

        
    
%% Open file and check data
    display(' ');
    display('Loading matrix file...');
    filename = [pwd '/inputs/' File];
    
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
    
    filenameout = [pwd '/outputs/Pvalues_' File];
    filenameout_labels = [pwd '/outputs/labels_' File];
    plotnameout = [pwd '/outputs/plot.eps'];
    WriteOutputMakePlot(filenameout,plotnameout,filenameout_labels,P,Pci,Pcc,length(P),ci_flag,cc_flag,header,H);
    
%% Exit
    display(' ');
    display('Exiting normally...');
    display(['Finished: ' datestr(now)]);
    filetime = [pwd '/logs/timeout.txt'];
    fid = fopen(filetime,'w+');
    fprintf(fid,datestr(now,'mm/dd/yyyy HH:MM:SS'));
    fclose(fid);
    exit();

catch

    L = lasterror;
    display(L.message);
    display('Exiting because of error...');
    display(['Finished: ' datestr(now)]);
    filenameout = [pwd '/logs/error.log'];
    fid = fopen(filenameout,'w');
    fprintf(fid,L.message);
    fclose(fid);
    filetime = [pwd '/logs/timeout.txt'];
    fid = fopen(filetime,'w+');
    fprintf(fid,datestr(now,'mm/dd/yyyy HH:MM:SS'));
    fclose(fid);
    exit(-10);

end



