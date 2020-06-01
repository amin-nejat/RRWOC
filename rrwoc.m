function [bhat,P,inlier_set,q]=rrwoc(x,y,delta,nu,k,max_iter)
% x     - source
% y     - target
% delta - probability of success
% nu    - margin
% k     - expected number of outliers (for assessing randomized iterations)
warning('off');
y=[y ones(size(y,1),1)];
[n,d]=size(y);
[m,~]=size(x);

iter=ceil(log(1-delta)/log(1-(prod(m-k:-1:m-k-d+1)/(prod(m:-1:m-d+1)*prod(n:-1:n-d+1)))));
sbest = 0;
inlier = [];
for q = 1: min(max_iter, iter)
    if mod(q, 1000) == 0
        disp([num2str(q) '/' num2str(iter) '-- best score: ' num2str(sbest)]);
    end
    
    CX = randperm(size(x,1)); CX = CX(1:d);
    CY = randperm(size(y,1)); CY = CY(1:d);
    
    b = linsolve(y(CY,:),x(CX,:));
    xhat = y*b;
    D = pdist2(x,xhat);
    s = sum(any(min(D, [], 2) <= nu, 2));
    if s > sbest
        sbest = s;
        P = zeros(size(D));
        [P_tmp,~] = munkres(D(any(min(D,[],2)<=nu,2),:));
        P(any(min(D, [], 2) <= nu, 2), :) = P_tmp;
        inlier = find(sum(P.*D, 2) <= nu);
        Pinlier = P;
    end
    if sbest >= m-k
        break;
    end
end
disp(['Algorithm reached an inlier set after ' num2str(q) ' iterations']);

bhat=linsolve(Pinlier(inlier,:)*y,x(inlier,:));
inlier_set = inlier;


end