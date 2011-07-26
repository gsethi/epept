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

function p = gpdcdfs(x,a,k)
%
% 1 - CDF of the generalized pareto distribution
% Input:    x       exceedances
%           k       shape parameter
%           a       scale parameter
% Output:   p       probability
%
% FOR VECTOR VERSIONS OF A AND K
%
% Code based on:
% Hosking and Wallis, Technometrics, 1987
%
% Theo Knijnenburg
% Institute for Systems Biology
%
% Dec 11 2008

p = ones(length(a),1);

k0vec = find(abs(k)<eps);
kvec = find(abs(k)>=eps);

if ~isempty(k0vec);
    p(k0vec) = exp(-x./a);
end
p(kvec) = (1-k*x./a).^(1./k);
p(x>a./k&k>0)=0;
