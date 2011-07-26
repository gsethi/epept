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

function [Pcm,Pad,W2,A2] = gpdgoft(p,k);

%Goodness of fit test for the generalized pareto distribution (gpd)
%P-value of the null hypothesis that the data comes from (or can be modeled with) the fitted gpd.
%Small p-values indicate a bad fit
%
% INPUT:    p    =  cdf values for data fitted to the gpd (from gpcdf)
%           k    =  estimated shape parameter of the gpd (from gpfit)
% OUTPUT:   Pcm  =  P-value using Cramer-von Mises statistic 
%           Pad  =  P-value using Anderson-Darling statistic (this gives
%                   more weight to observations in the tail of the distribution)
%           W2   =  Cramer-von Mises statistic 
%           A2   =  Anderson-Darling statistic 
% 
% Goodness-of-Fit Tests for the Generalized Pareto Distribution
% Author(s): V. Choulakian and M. A. Stephens
% Source: Technometrics, Vol. 43, No. 4 (Nov., 2001), pp. 478-484
% Published by: American Statistical Association and American Society for Quality
% Stable URL: http://www.jstor.org/stable/1270819
%
% Theo Knijnenburg
% Institute for Systems Biology
%
% Dec 15 2008

p = sort(p);
p = p(:)';
n = length(p);
i = 1:n;

%Cramer-von Mises statistic
W2 = sum((p-((2*i-1)./(2*n))).^2) + 1/(12*n);
%Anderson Darling statistic
A2 = -n -(1/n)*((2*i-1)*(log(p) + log(1-p(n+1-i)))');

%Load Table 2 from Choulakian 2001
load choulakian2001Table

k = max(.5,k);
Pcm = max(min(interp1(interp1(ktable,W2table,k,'linear','extrap'),ptable,W2,'linear','extrap'),1),0);
Pad = max(min(interp1(interp1(ktable,A2table,k,'linear','extrap'),ptable,A2,'linear','extrap'),1),0);
