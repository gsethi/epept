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

function [parmhat,cov] = gpdfit(z)
%
% Fitting the generalized pareto distribution using ML
% Input:    z       exceedances
% Output:   parmhat estimated shape and scale parameter
%           cov     covariance matrix of the parameters
%
% Code based on:
% Hosking and Wallis, Technometrics, 1987
% Grimshaw, Technometrics, 1993
% Matlab gpfit.m
%
% Theo Knijnenburg
% Institute for Systems Biology
%
% Dec 11 2008

%Initial fit is the exponentional (exp(-z))
parmhat = [1 0];

%Options for optimization statisitics
options = statset;
options.MaxFunEvals = 2500;
options.MaxIter = 1000;
options.TolBnd = 1e-10;
options.TolFun = 1e-10;
options.TolX = 1e-10;
options.Display = 'off';

[parmhat,L,err,output] = fminsearch(@nll,parmhat,options,z);

c = 0;
while err==0&c<10; %Has not occurred in the practical cases analyzed so far
    %display('Maximum number of function evaluations or iterations was reached. Relaxing tolerances...');
    options.TolBnd = options.TolBnd*10;
    options.TolFun = options.TolFun*10;
    options.TolX = options.TolX*10;
    [parmhat,L,err,output] = fminsearch(@nll,parmhat,options,z);
    c = c + 1;
end

if abs(parmhat(2)-1)<options.TolBnd; %k==1 (boundary maximum)
    parmhat = [NaN NaN];
end

if nargout>1; %Compute confidence intervals
    if all(isnan(parmhat)); %k==1 (boundary maximum)
           cov = NaN*ones(2);
    elseif parmhat(2)<.5; %k<.5  All practical cases analyzed so far
        cov = asym_var(parmhat,length(z));
    else %.5<k<1
        cov = bootstrp(100,@gpdfit,z);
    end
end

function L = nll(parmhat,z);

a = parmhat(1);
k = parmhat(2);
n = length(z);
m = max(z);

if k>1
    L = -Inf;
elseif a < max(0,k*m); %Constrained space A in Grimshaw
    L = -Inf;
else
    if abs(k)<eps %k==0;
        L = -n*log(a)-1/a*sum(z);
    else
        L = -n*log(a) + (1/k-1)*sum(log(1-k*z/a));
    end
end

L = -L;

return

function cov = asym_var(parmhat,n);

a = parmhat(1);
k = parmhat(2);

cov(1,1) = 2*a^2/(1-k);
cov(2,1) = a*(1-k);
cov(1,2) = cov(2,1);
cov(2,2) = (1-k)^2;
cov = cov/n;

return



