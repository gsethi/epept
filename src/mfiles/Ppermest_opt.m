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

function [P,Pci,k,kci] = Ppermest_opt(x0,y,alpha,method,Nexcmax,Z)
%
% Estimation of P-value based on scheme in Section 2.4 of the paper
% Input:    x0      test statistic
%           y       permutation values
%           alpha   confidence level (default: 0.05);
%           method  Method for GPD approximation {'ML' (default), 'MOM', 'PWM'}
%           Nexcmax Number of initial exceedances (default: 250)
%           Z       argument of the power transformation
% Output:   p       Estimate of the P-value
%           pci     Estimate of the confidence bounds
%           k       Estimated shape parameter
%           kci     Estimated confidence bounds on the shape parameter
%
% Theo Knijnenburg
% Institute for Systems Biology
%
% May 7 2009
y = sort(y,'descend');
N = length(y);
M = sum(y>=x0);
Nexcmax = min(Nexcmax,N/4); %limiting Nexcmax to a quarter of the distribution, assuming that the tail is smaller than a quarter

if nargout==4;
    if M>=10;
        [P,Pci] = Pecdfp(N,M,alpha);
        k = 1;
        kci = [];
    else
        Nexcvec = fliplr(10:10:Nexcmax);
        LNV = length(Nexcvec);
        p = 1;
        P = NaN;
        Pci = [NaN NaN];
        k = NaN;
        kci = [NaN NaN];
        while isnan(P)&p<=LNV;
            Nexc = Nexcvec(p);
            switch method
                case 'ML'
                    [P,Pci,k,kci] = Pgpd_opt(y,x0,N,Nexc,alpha,Z);
                case 'MOM'
                    [P,Pci,k,kci] = PgpdMOM_opt(y,x0,N,Nexc,alpha,Z);
                case 'PWM'
                    [P,Pci,k,kci] = PgpdPWM_opt(y,x0,N,Nexc,alpha,Z);
            end
            p = p + 1;
        end
    end
else
    if M>=10;
        [P] = Pecdfp(N,M);
        Pci = [];
        k = 1;
    else
        Nexcvec = fliplr(10:10:Nexcmax);
        LNV = length(Nexcvec);
        p = 1;
        P = NaN;
        Pci = [];
        k = NaN;
        while isnan(P)&p<=LNV;
            Nexc = Nexcvec(p);
            switch method
                case 'ML'
                    [P,Pci,k] = Pgpd_opt(y,x0,N,Nexc,alpha,Z);
                case 'MOM'
                    [P,Pci,k] = PgpdMOM_opt(y,x0,N,Nexc,alpha,Z);
                case 'PWM'
                    [P,Pci,k] = PgpdPWM_opt(y,x0,N,Nexc,alpha,Z);
            end
            p = p + 1;
        end
    end
end
