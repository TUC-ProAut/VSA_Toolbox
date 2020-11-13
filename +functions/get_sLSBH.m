%% sLSBH creation
% Y ... descriptors as m-by-n matrix with m descriptors and n features
% P ... Projection matrix; e.g. P = normc(randn(8192, 2*8192, 'single'));
% s ... sparsity with s = (0,1]
function L = get_sLSBH(Y, s)

  n = round(size(Y,2)*s);

  % random projection 
  Y2 = Y; % (already done)
  
  % sort
  [~, IDX] = sort(Y2,2, 'descend');
  
  % sparsification
  L1 = zeros(size(Y2), 'single');
%   L = zeros(size(Y2), 'single');
  
  for i = 1:size(Y2,1)
    L1(i,IDX(i,1:n)) = 1;
%     L(i,IDX(i,1:floor(n/2))) = 1;
  end
  
  % sort
  [~, IDX] = sort(Y2,2, 'ascend');
  
  % sparsification
  L2 = zeros(size(Y2), 'single');
  
  for i = 1:size(Y2,1)
    L2(i,IDX(i,1:n)) = 1;
%     L(i,IDX(i,1:floor(n/2))) = 1;
  end

  % concat
  L = [L1, L2];

end

