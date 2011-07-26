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

function [Phat,Phatci] = gpdPval(x0,parmhat,cov,alpha)
%
% Computing P-value estimates for fitted data
% Input:    x0          test statistic compensated by exceedances threshold t
%           parmhat     estimated shape and scale parameter
%           cov         covariance matrix of the intervals
%           alpha       confidence level
% Output:   Phat        estimated P-value
%           Phatci      Confidence bounds on the P-value
%
% Theo Knijnenburg
% Institute for Systems Biology
%
% Dec 15 2008

Phat = gpdcdf(x0,parmhat(1),parmhat(2));

if nargin>2&nargout==2;

    if nargin==3;
        alpha = 0.05;
    end

    if size(cov,1)~=2 %Bootstrap applied in gpdfit
        vec = find(~isnan(cov(:,1)));
        if length(vec)>.5*size(cov,1); %If less than 50% NaNs
            Phatci = prctile(gpdcdfs(x0,cov(vec,1),cov(vec,2)),100*[alpha/2 1-alpha/2]);
        else
            Phatci = [NaN NaN];
        end
    else
        if all(isnan(cov(:))) %k==1 (boundary maximum) in gpdfit
            Phatci = [NaN NaN];
        else %generated confidence levels from 10,000 samples
            [V,D] = eig(cov); V = real(V); D = real(D);
            Q = real([randn(10000,2)*sqrt(D)*V' + repmat(parmhat,10000,1)]);
            Phatci = real(prctile(gpdcdfs(x0,Q(:,1),Q(:,2)),100*[alpha/2 1-alpha/2]));
        end
    end

end


