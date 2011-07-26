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

function [P_opt,Pci_opt,k_opt,kci_opt,Z_opt] = Ppermest_opt_loop(x0,y,alpha,method,Nexcmax)
%
% Estimation of P-value based on scheme in Section 2.4 of the paper
% With loop to optimize power transformation
% Input:    x0      test statistic
%           y       permutation values
%           alpha   confidence level (default: 0.05);
%           method  Method for GPD approximation {'ML' (default), 'MOM', 'PWM'}
%           Nexcmax Number of initial exceedances (default: 250)
% Output:   P_opt   Optimized estimate of the P-value
%           Pci_opt Optimized estimate of its confidence bounds
%           k_opt   Optimized estimate of the shape parameter
%           kci_opt Optimized estimate of its confidence bounds
%           Z_opt   Optimal transformation coefficient
%           
%
% Theo Knijnenburg
% Institute for Systems Biology
%
% May 8 2009

beta = 0.6824;
S = 25;
iss = .1;  %inital step size;
max_isnan_counts = 5;
c_max = 100;

switch method
    case 'ML'
        range = [-1 .5];
    case 'MOM'
        range = [-.25 .5];
    case 'PWM'
        range = [-.5 .5];
end

%% lots of code to find the power transforms that cover the whole range of possible shape parameters
Z = 1;
[P,dummy,k] = Ppermest_opt(x0,y,beta,method,Nexcmax,Z);
if ~(k>=range(1)&k<=range(2))&k~=1 %outside range and not 1 (1=ecdf approach)
    c = 0;
    while ~(k>=range(1)&k<=range(2))
        Z = abs(2*randn+1);
        [P,dummy,k] = Ppermest_opt(x0,y,beta,method,Nexcmax,Z);
        c = c + 1; if c>c_max; k = 1; Z = []; break; end
    end
end
if k~=1;
    k_low = k;
    Z_up = Z;
    isnan_counts = 0;
    while k_low>=range(1)&isnan_counts<=max_isnan_counts
        Z_up = Z_up + iss;
        [P,dummy,k_low] = Ppermest_opt(x0,y,beta,method,Nexcmax,Z_up);
        if isnan(k_low);isnan_counts = isnan_counts + 1; elseif k_low>=range(1); Z_u = Z_up;end
    end
    k_high = k;
    Z_down = Z;
    isnan_counts = 0;
    while k_high<=range(2)&isnan_counts<=max_isnan_counts
        Z_down = Z_down - iss;
        [P,dummy,k_high] = Ppermest_opt(x0,y,beta,method,Nexcmax,Z_down);
        if isnan(k_high);isnan_counts = isnan_counts + 1; elseif k_high<=range(2); Z_d = Z_down;end
    end
end

%% Compute kci for all power transformations
if k==1; %ecdf approach
    [P_opt,Pci_opt,k_opt,kci_opt] = Ppermest_opt(x0,y,alpha,method,Nexcmax,1);
    Z_opt = [];
else
    Zvec = linspace(Z_down,Z_up,S);
    P = ones(S,1); Pci = ones(S,2);
    k = ones(S,1); kci = ones(S,2);
    for s = 1:S;
        [P(s),Pci(s,:),k(s),kci(s,:)] = Ppermest_opt(x0,y,beta,method,Nexcmax,Zvec(s));
    end
    PciInterval = abs(log10(Pci(:,2))-log10(Pci(:,1)));
    PciInterval(isnan(PciInterval)) = Inf;
    PciInterval(~(k>=range(1)&k<=range(2))) = Inf;
    if all(isinf(PciInterval)|isnan(PciInterval))
        [P_opt,Pci_opt,k_opt,kci_opt] = Ppermest_opt(x0,y,alpha,method,Nexcmax,1);
        Z_opt = 1;
    else
        [i,j] = min(PciInterval);
        [P_opt,Pci_opt,k_opt,kci_opt] = Ppermest_opt(x0,y,alpha,method,Nexcmax,Zvec(j));
        Z_opt = Zvec(j);
    end
end






