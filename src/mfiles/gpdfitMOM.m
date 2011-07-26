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

function [parmhat,cov] = gpdfitMOM(z)
%
% Fitting the generalized pareto distribution using method of moments
% Input:    z       exceedances
% Output:   parmhat estimated shape and scale parameter
%          
% Code based on:
% Hosking and Wallis, Technometrics, 1987
% Grimshaw, Technometrics, 1993
% Matlab gpfit.m
%
% Theo Knijnenburg
% Institute for Systems Biology
%
% Dec 23 2008

xbar = mean(z);
n = length(z);
s2 = var(z);
a = .5*xbar*(xbar^2/s2 +1);
k = .5*(xbar^2/s2 -1);

parmhat(1) = a;
parmhat(2) = k;

cov(1,1) = 2*a^2*(1+6*k+12*k^2);
cov(2,1) = a*(1+2*k)*(1+4*k+12*k^2);
cov(1,2) = cov(2,1);
cov(2,2) = (1+2*k)^2*(1+k+6*k^2);
cov = (cov*(1+k)^2)/(n*(1+2*k)*(1+3*k)*(1+4*k));
