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

function [Phat,Phatci,k,kci] = PgpdMOM_opt(y,x0,N,Nexc,alpha,Z)
%
% Computing permutation test P-value of the GPD approximation
%
% Input:    x0         original statistic
%           y          permutation values
%           N          number of permutation values
%           Nexc       number of permutations used to approximate the tail
%           alpha      confidence level
%           Z          argument of the power transformation
% Output:   Phat       estimated P-value
%           Phatci     confidence intervals of the estimated P-value
%           k          Estimated shape parameter
%           kci        Estimated confidence bounds on the shape parameter
%
% Theo Knijnenburg
% Institute for Systems Biology
%
% May 07 2009

% Threshold for AD statistic
Padth = 0.05;

%Defining the tail
z = y(1:Nexc);
t = mean(y(Nexc:Nexc+1));
z = z-t;
z = z.^Z;  %power transformation
frac = Nexc/N;

%Fitting the tail and computing the Pvalue
if nargin==6&nargout==4;
    [parmhat,cov] = gpdfitMOM(z); %make fit
    if ~any(isnan(parmhat)); %check if fit was a succes
        a = parmhat(1);
        k = parmhat(2);
        kci = [k-sqrt(cov(2,2)) k+sqrt(cov(2,2))];
        [Pcm,Pad,W2,A2] = gpdgoft(gpdcdf(z,a,k),k); %goodness-of-fit test
        if Pad>Padth; %check goodness of fit
            [Phat,Phatci] = gpdPval((x0-t).^Z,parmhat,cov,alpha);
            Phat = frac*Phat;
            Phatci = frac*Phatci;
        else
            Phat = NaN;
            Phatci = [NaN NaN];
            k = NaN;
            kci = [NaN NaN];
        end
    else
        Phat = NaN;
        Phatci = [NaN NaN];
        k = NaN;
        kci = [NaN NaN];
    end
else
    [parmhat] = gpdfitMOM(z); %make fit
    if ~any(isnan(parmhat)); %check if fit was a succes
        a = parmhat(1);
        k = parmhat(2);
        [Pcm,Pad,W2,A2] = gpdgoft(gpdcdf(z,a,k),k); %goodness-of-fit test
        if Pad>Padth; %check goodness of fit
            [Phat] = gpdPval((x0-t).^Z,parmhat);
            Phat = frac*Phat;
            Phatci = [];
        else
            Phat = NaN;
            Phatci = [NaN NaN];
            k = NaN;
        end
    else
        Phat = NaN;
        Phatci = [NaN NaN];
        k = NaN;
    end
end