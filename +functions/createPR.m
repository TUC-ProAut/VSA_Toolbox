%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of VSA_Toolbox.                                       %
%                                                                         %
% Copyright (C) 2020 Chair of Automation Technology / TU Chemnitz         %
% For more information see https://www.tu-chemnitz.de/etit/proaut/vsa     %
%                                                                         %
% VSA_Toolbox is free software: you can redistribute it and/or modify     %
% it under the terms of the GNU General Public License as published by    %
% the Free Software Foundation, either version 3 of the License, or       %
% (at your option) any later version.                                     %
%                                                                         %
% VSA_Toolbox is distributed in the hope that it will be useful,          %
% but WITHOUT ANY WARRANTY; without even the implied warranty of          %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           %
% GNU General Public License for more details.                            %
%                                                                         %
% You should have received a copy of the GNU General Public License       %
% along with Foobar.  If not, see <http://www.gnu.org/licenses/>.         %
%                                                                         %
% Author: Peer Neubert                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% S ... similarity matrix
% GThard ... ground truth matching matrix: places that MUST be matched;
% must have the same shape as S
% GTsoft ... ground truth places that CAN be matched without harm; must
% have the same shape as S
% removeDiagFlag ... use this if S is created from a single sequence and of
%                    course the similarity on the main diagonal is maximal.
%                    This uses the enlarged main diagonal from GTsoft if
%                    available.
% singleMatchFlag ... use this if only the best match in a row should be
%                     considered as a match
%
% P ... precision values
% R ... recall values corresponding to P values
% bestP ... precision for maximum F1 score
% bestR ... recall for maximum F1 score
% bestF ... maximum F1 score
% V ... visualization at maximum F1 score
function [P, R, V, bestP, bestR, bestF] = createPR(S, GThard, GTsoft, removeDiagFlag, singleMatchFlag, evalAllSValuesFlag)
    if ~exist('evalAllSValuesFlag', 'var')
        evalAllSValuesFlag=0;
    end

    GT = logical(GThard);

    % remove main diagonals
    if removeDiagFlag
        % use enlarged main diagonal from GTsoft if available
        if ~isempty(GTsoft)
            seedIm = zeros(size(GT)); 
            seedIm(1,1) = 1;
            maindiaMask = logical(imreconstruct(seedIm,GTsoft));
            maindiaMask = maindiaMask | maindiaMask'; % expand to both sides of maindiagonal
        else
            maindiaMask = eye(size(GT),'logical');
        end     
        
        % also remove lower triangle
        maindiaMask = logical(max(maindiaMask, tril(ones(size(S)))));
        
        S(maindiaMask) = min(S(:));
        GT(maindiaMask) = 0;
    end

    % remove soft-but-not-hard-entries
    if ~isempty(GTsoft)
        S(GTsoft & ~GThard) = min(S(:));
    end
 
    
    % only keep highest value per column
    if nargin>4 && singleMatchFlag
        [~, hIdx] = max(S);
        hIdxInd = sub2ind(size(S), hIdx,1:size(S,2)); 
        T = min(S(:))*ones(size(S));
        T(hIdxInd) = S(hIdxInd);
        S = T;       
    end
    
    R=[0];
    P=[1];

    startV = max(S(:));
    endV = min(S(:));
    
    bestF = 0;
    bestT = startV;
    bestP = 0;
    bestR = 0;
    
    if evalAllSValuesFlag
        s_vals = (sort(unique(S), 'descend'))';
    else
        s_vals = linspace(startV, endV, 100);
    end
    
    GT_sparse = sparse(GT); % exploit (mostly) sparsity of gt-matrix
    for i=s_vals %linspace(startV, endV, 100)%linspace(startV, endV, 100)%sort(unique(S), 'descend')'%startV:stepV:endV
        B = S>=i;
        
        TP = nnz( GT_sparse & B );
        FN = nnz( GT_sparse & (~B) );
        FP = nnz( (~GT) & B );  
        
        P(end+1) = TP/(TP + FP);
        R(end+1) = TP/(TP + FN);
        
        F = 2 * P(end) * R(end) / (P(end)+R(end));
        
        if F>bestF
            bestF = F;
            bestT = i;
            bestP = P(end);
            bestR = R(end);
        end        
    end

    R(end+1) = 1;
    P(end+1) = 0;
        
    V = visualizePRAtThresh(S,GT,bestT);
end


function V = visualizePRAtThresh(S,GT,t)

    B = S>=t;

    TP = double(GT & B);
    FN = double(GT & (~B));
    FP = double((~GT) & B);

    V = cat(3,full(FP), full(TP), full(FN));
    
end

