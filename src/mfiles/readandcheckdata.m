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

function [A,header,H] = readandcheckdata(filename,File,Mode)

if strcmp(Mode,'PV'); %permutations
    lf = length(File);
    if (lf>=4&strcmpi(File(end-3:end),'.csv')) %COMMA SEPARATED
        raw = csvimport(filename,'delimiter',',','uniformOutput',false,'noHeader',true,'outputAsChar',true);
        [R,C] = size(raw); if ~(R>10);  error(['File contains too few rows (i.e. permutations values)']); end
        A = cellfun(@csvfun,raw); %convert to double
        H = cell(1,C); p = 0; for c = 1:C; if isempty(str2num(raw{1,c}))&~isempty(raw{1,c}); H{c} = raw{1,c}; p = p + 1; end ; end ; if p>C/2; header = 1; else header = 0; end %determine header or not
    else %TAB DELIMITED
        raw = csvimport(filename,'delimiter','\t','uniformOutput',false,'noHeader',true,'outputAsChar',true);
        [R,C] = size(raw); if ~(R>10);  error(['File contains too few rows (i.e. permutations values)']); end
        A = cellfun(@csvfun,raw); %convert to double
        H = cell(1,C); p = 0; for c = 1:C; if isempty(str2num(raw{1,c}))&~isempty(raw{1,c}); H{c} = raw{1,c}; p = p + 1; end ; end ; if p>C/2; header = 1; else header = 0; end %determine header or not
    end
    if header==1;
        display(['Header row detected']);
        A = A(2:end,:);
    end
elseif strcmp(Mode,'SAM');  %SAM   
    lf = length(File);
    if (lf>=4&strcmpi(File(end-3:end),'.csv')) %COMMA SEPARATED
        raw = csvimport(filename,'delimiter',',','uniformOutput',false,'noHeader',true,'outputAsChar',true);
        [R,C] = size(raw);
        A = cellfun(@csvfun,raw); %convert to double
        H = cell(1,R); p = 0; for r = 1:R; if isempty(str2num(raw{r,1}))&~isempty(raw{r,1}); H{r} = raw{r,1}; p = p + 1; end ; end ; if p>R/2; header = 1; else header = 0; end %determine column or not
    else %TAB DELIMITED
        raw = csvimport(filename,'delimiter','\t','uniformOutput',false,'noHeader',true,'outputAsChar',true);
        [R,C] = size(raw); 
        A = cellfun(@csvfun,raw); %convert to double
        H = cell(1,R); p = 0; for r = 1:R; if isempty(str2num(raw{r,1}))&~isempty(raw{r,1}); H{r} = raw{r,1}; p = p + 1; end ; end ; if p>R/2; header = 1; else header = 0; end %determine column or not
    end
    if header==1;
        display(['Header column detected']);
        A = A(:,2:end);
        H = H(2:end);
    end
elseif strcmp(Mode,'GSEA');  %GSEA
    lf = length(File);
    if (lf>=4&strcmpi(File(end-3:end),'.csv')) %COMMA SEPARATED
        raw = csvimport(filename,'delimiter',',','uniformOutput',false,'noHeader',true,'outputAsChar',true);
        [R,C] = size(raw);
        A = cellfun(@csvfun,raw); %convert to double
        H = cell(1,R); p = 0; for r = 1:R; if isempty(str2num(raw{r,1}))&~isempty(raw{r,1}); H{r} = raw{r,1}; p = p + 1; end ; end ; if p>R/2; header = 1; else header = 0; end %determine column or not
    else %TAB DELIMITED
        raw = csvimport(filename,'delimiter','\t','uniformOutput',false,'noHeader',true,'outputAsChar',true);
        [R,C] = size(raw); 
        A = cellfun(@csvfun,raw); %convert to double
        H = cell(1,R); p = 0; for r = 1:R; if isempty(str2num(raw{r,1}))&~isempty(raw{r,1}); H{r} = raw{r,1}; p = p + 1; end ; end ; if p>R/2; header = 1; else header = 0; end %determine column or not
    end
    if header==1;
        display(['Header column detected']);
        A = A(:,2:end);
        H = H(2:end);
    else
        error(['The first column does not seem to contain gene identifiers, however this is necessary for the coupling with the gene sets']); 
    end
end


function x = xlsfun(x);
if ~isnumeric(x); x = NaN; end
return

function x = csvfun(x);
x = str2num(x); if isempty(x); x = NaN; end
return


