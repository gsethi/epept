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

function [P,Pci,Pcc] = Main(A,method,ci_flag,alpha,oopt_flag,cc_flag,header,H)

[R,C] = size(A);
P   = NaN*ones(1,C);
Pci = NaN*ones(2,C);
Pcc = NaN*ones(1,C);

if ~strcmp(oopt_flag,'true')
    
    for c = 1:C;
        x0 = A(1,c);
        y = A(2:R,c);
        y(isnan(y)|isinf(y))=[];
        
        if isnan(x0)|isinf(x0)
            if header==1;
                display(['Column ' num2str(c) ' ' H{c} ': Original statistic is not a numerical value or (-)Inf   =>   column skipped...']);
            else
                display(['Column ' num2str(c) ' : Original statistic is not a numerical value or (-)Inf   =>   column skipped...']);
            end
        elseif length(y)<1000&any([sum(y>x0) sum(y<x0)]<10)
            if header==1;
                display(['Column ' num2str(c) ' ' H{c} ': ' num2str(length(y)) ' permutation values found. At least 1000 permutation values are necessary   =>   column skipped...']);
            else
                display(['Column ' num2str(c) ' : ' num2str(length(y)) ' permutation values found. At least 1000 permutation values are necessary   =>   column skipped...']);
            end
        else
            if header==1;
                display(['Column ' num2str(c) ' ' H{c} ': OK   x0 = ' num2str(x0) '  ' num2str(length(y)) ' permutation values']);
            else
                display(['Column ' num2str(c) ' : OK   x0 = ' num2str(x0) '  ' num2str(length(y)) ' permutation values']);
            end
            
            if sum(y>x0)>length(y)/2; %Go from right-tailed to left-tailed test
                x0 = -x0;
                y = -y;
            end
            
            if strcmp(ci_flag,'true');
                [P(c),Pci(:,c)] = Ppermest(x0,y,alpha,method,250);
            else
                [P(c)] = Ppermest(x0,y,alpha,method,250);
            end
            
            if strcmp(cc_flag,'true');
                if sum(y>=x0)>10;
                    Pcc(c) = 1;
                elseif isnan(P(c))|P(c)==0
                    Pcc(c) = 0;
                else
                    % CV
                    [Pgoal,Pgoal_ci] = Ppermest(x0,y,0.34,method,250);
                    if (diff(log10(Pgoal_ci))/2)/(-log10(Pgoal))<1;
                        % Bootstrap
                        Nbs = 100;
                        Vbs = zeros(Nbs,2);
                        ly = length(y);
                        ly10 = ceil(ly/10);
                        for n = 1:Nbs
                            z = randsample(ly,ly,1);
                            Vbs(n,1) = Ppermest(x0,y(z),0.34,method,250);
                            Vbs(n,2) = Ppermest(x0,y(z(1:ly10)),0.34,method,250);
                        end
                        %boxplot(-log10(Vbs));grid
                        if ranksum(Vbs(~isnan(Vbs(:,1)),1),Vbs(~isnan(Vbs(:,2)),2))>1e-3;
                            Pcc(c) = 1;
                        else
                            Pcc(c) = 0;
                        end
                    else
                        Pcc(c) = 0;
                    end
                end
            end
        end
    end
    
else
    
    for c = 1:C;
        x0 = A(1,c);
        y = A(2:R,c);
        y(isnan(y)|isinf(y))=[];
        
        if isnan(x0)|isinf(x0)
            if header==1;
                display(['Column ' num2str(c) ' ' H{c} ': Original statistic is not a numerical value or (-)Inf   =>   column skipped...']);
            else
                display(['Column ' num2str(c) ' : Original statistic is not a numerical value or (-)Inf   =>   column skipped...']);
            end
        elseif length(y)<1000&any([sum(y>x0) sum(y<x0)]<10)
            if header==1;
                display(['Column ' num2str(c) ' ' H{c} ': ' num2str(length(y)) ' permutation values found. At least 1000 permutation values are necessary   =>   column skipped...']);
            else
                display(['Column ' num2str(c) ' : ' num2str(length(y)) ' permutation values found. At least 1000 permutation values are necessary   =>   column skipped...']);
            end
        else
            if header==1;
                display(['Column ' num2str(c) ' ' H{c} ': OK   x0 = ' num2str(x0) '  ' num2str(length(y)) ' permutation values']);
            else
                display(['Column ' num2str(c) ' : OK   x0 = ' num2str(x0) '  ' num2str(length(y)) ' permutation values']);
            end
            
            if sum(y>x0)>length(y)/2; %Go from right-tailed to left-tailed test
                x0 = -x0;
                y = -y;
            end
            
            if strcmp(ci_flag,'true');
                [P(c),Pci(:,c)] = Ppermest_opt_loop(x0,y,alpha,method,250);
            else
                [P(c)] = Ppermest_opt_loop(x0,y,alpha,method,250);
            end
            
            if strcmp(cc_flag,'true');
                if sum(y>=x0)>10;
                    Pcc(c) = 1;
                elseif isnan(P(c))|P(c)==0
                    Pcc(c) = 0;
                else
                    % CV
                    [Pgoal,Pgoal_ci] = Ppermest_opt_loop(x0,y,0.34,method,250);
                    if (diff(log10(Pgoal_ci))/2)/(-log10(Pgoal))<1;
                        % Bootstrap
                        Nbs = 100;
                        Vbs = zeros(Nbs,2);
                        ly = length(y);
                        ly10 = ceil(ly/10);
                        for n = 1:Nbs
                            z = randsample(ly,ly,1);
                            Vbs(n,1) = Ppermest_opt_loop(x0,y(z),0.34,method,250);
                            Vbs(n,2) = Ppermest_opt_loop(x0,y(z(1:ly10)),0.34,method,250);
                        end
                        %boxplot(-log10(Vbs));grid
                        if ranksum(Vbs(~isnan(Vbs(:,1)),1),Vbs(~isnan(Vbs(:,2)),2))>1e-3;
                            Pcc(c) = 1;
                        else
                            Pcc(c) = 0;
                        end
                    else
                        Pcc(c) = 0;
                    end
                end
            end
        end
    end
    
end

if any(Pci(2,:)<Pci(1,:))&~any(Pci(2,:)>Pci(1,:));
    Pci = flipud(Pci);
end
