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

function WriteOutputMakePlot(filenameout,plotnameout,filenameout_labels,P,Pci,Pcc,C,ci_flag,cc_flag,header,H)

%% Make sure extension is a .txt
i = max(strfind(filenameout,'.'));
if isempty(i); i = length(filenameout)+1;end
filenameout = [filenameout(1:i-1) '.txt'];

%% Make sure extension is a .txt
i = max(strfind(filenameout_labels,'.'));
if isempty(i); i = length(filenameout_labels)+1;end
filenameout_labels = [filenameout_labels(1:i-1) '.txt'];


%% Write to output file
str = [];
for n = 1:C-1;
    str = [str '%4.3e\t'];
end
str = [str '%4.3e\n'];

str2 = [];
for n = 1:C-1;
    str2 = [str2 '%1.0g\t'];
end
str2 = [str2 '%1.0g\n'];

fid = fopen(filenameout,'w');
if header==1;
    hstr = [];
    for n = 1:C-1;
        hstr = [hstr H{n} '\t'];
    end
    hstr = [hstr H{C} '\n'];
    fprintf(fid,hstr);
end
if strcmp(ci_flag,'true')&strcmp(cc_flag,'true');
    fprintf(fid,str,[P' Pci']);
    fprintf(fid,str2,[Pcc']);
elseif strcmp(ci_flag,'true');
    fprintf(fid,str,[P' Pci']);
elseif strcmp(cc_flag,'true');
    fprintf(fid,str,[P' Pcc']);
else
    fprintf(fid,str,[P']);
end
fclose(fid);

fid = fopen(filenameout_labels,'w');
if header==1;
    fprintf(fid,'Header<br>\n');
end
fprintf(fid,'P-values<br>\n');
if strcmp(ci_flag,'true')
    fprintf(fid,'Lower bound<br>\n');
    fprintf(fid,'Upper bound<br>\n');
end
if strcmp(cc_flag,'true');
    fprintf(fid,'Converged?<br>\n');
end
fclose(fid);
    

%% Make plot
if strcmp(ci_flag,'true');
    plotPval(plotnameout,header,H,P,Pci)
else
    plotPval(plotnameout,header,H,P)
end