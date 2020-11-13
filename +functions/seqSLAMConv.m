% Approximated SeqSLAM using convolutions
%
% DD ... input distance matrix
% n ... approx. seq length (n ~ past+1+future)
%
% nepe, 2018
function DDD = seqSLAMConv(DD, n)

    % setup possible velocities
%     v = 1;
%     v = 0.8:0.1:1.2;
    v = 0.5:0.1:1.5; 

    % compute and apply filter masks
    T = zeros(size(DD,1), size(DD,2), numel(v));
    supVal = 0; %abs(max(DD(:))) * 1.1;
    prevFilter = [];
    idx = 1;
    for i = 1:numel(v)
        H =  getFilter(n,v(i));
        if ~isSame(H, prevFilter)
            T(:,:,idx) = imfilter(DD, H, supVal, 'same');
            
            % weight to account for boundaries
            W = imfilter(ones(size(DD)), H, 0, 'same');
            T(:,:,idx) = T(:,:,idx) ./ W;
            
            idx = idx+1;
            prevFilter = H;
        end
    end

    T(:,:,idx:end) = [];
    
    DDD = max(T,[],3);
    
end

% Generate a [~v*n, n] mask H with a line of 1 with slope v. Dimensions of
% H are odd, the line goes through the center element.
% n ... number of ones
% v ... slope
function H = getFilter(n,v)
    assert(v>0);
    assert(v>=0.5);

    nh = floor(n/2);
    
    % get bottom right part
    x = 1:nh;
    y = round(x*v);
    hh = max(y);
    wh = max(x);
    
    idx = sub2ind([hh,wh], y, x);
    Hh = zeros(hh,wh);
    Hh(idx) = 1;
    
    % combine: top-left is Hh, centre is 1, bottom-right is Hh
    H = [Hh, zeros(hh, wh+1);
        zeros(1,wh), 1, zeros(1,wh);
        zeros(hh,wh+1), Hh];
    
    % don't use future
%     H(nh+11:end, nh+1:end) = 0;
    
end

% Are matrices X and Y identical?
function r = isSame(X,Y)
    if size(X,1) == size(Y,1) && size(X,2) == size(Y,2) && sum(X(:)==Y(:)) == numel(X)
       r=1;
    else
       r=0;
    end
end