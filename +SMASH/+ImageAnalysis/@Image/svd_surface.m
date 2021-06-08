function zg=svd_surface(object,x,y,z,varargin)
% svdsfit() calls svdfit() to fit a surface to data using SVD and linear
% least squares for chi-squared minimization
% zg is the surface fit result loaded onto the 2D grid specified by xg,yg
% The fit is based on the z data supplied at the 2D points x,y
% sigmaz is the standard deviations of the z data
% The basis functions are specified by varargin [e.g., the varargin pair
% ('polynomial',2) specifies a 2nd-order polynomial]
% varargin pair ('tol',val) sets the round-off tolerance (default is the
% machine precision eps times the number of data points
% varargin ('suppress') suppresses output

% See Numerical Recipes in C, 2nd Edition, pp. 676-678 (Solution to General
% Linear Least Squares by Use of Singular Value Decomposition
if size(x,1)==1 && size(x,2)>1
    x=x';
end
if size(y,1)==1 && size(y,2)>1
    y=y';
end
if size(z,1)==1 && size(z,2)>1
    z=z';
end
xg = object.Grid1;
yg = object.Grid2;

sigmaz = ones(size(z))*0.08;

%tol_epslengthz=eps*length(z); % Round-off tolerance based on the machine precision eps (suggested by N. R. in C)
tol_eps=eps; % Often must use this smaller tolerance to match Matlab sftool.m results (perhaps sftool.m doesn't apply a tolerance?)
tol=1e-99;
for i=1:length(varargin)
    if strcmp(varargin{i},'tol')
        tol=varargin{i+1};
    elseif strcmp(varargin{i},'sigma')
        sigma=varargin{i+1};
        sigmaz = ones(size(z))*sigma;
        
    elseif strcmp(varargin{i},'gaussian')
        func='gaussian';
        z=log(z);
        param_3_or_5=varargin{i+1};
        if param_3_or_5==3
            nbf=3;
            pd=cell(1,nbf);
            bf=zeros(length(z),nbf);
            bf(:,1)=1; pd{1}='log(a)';
            bf(:,2)=-x.^2; pd{2}='-1/(2sx^2)';
            bf(:,nbf)=-y.^2; pd{nbf}='-1/(2sy^2)';
        elseif param_3_or_5==5
            nbf=5;
            pd=cell(1,nbf);
            bf=zeros(length(z),nbf);
            bf(:,1)=1; pd{1}='log(a)-x0^2/2/sx^2-y0^2/2/sy^2';
            bf(:,2)=x; pd{2}='x0/sx^2';
            bf(:,3)=y; pd{3}='y0/sy^2';
            bf(:,4)=-x.^2; pd{4}='1/2/sx^2';
            bf(:,nbf)=-y.^2; pd{nbf}='1/2/sy^2';
        end
    elseif strcmp(varargin{i},'polynomial')
        func='polynomial';
        poly_order=varargin{i+1};
        if poly_order~=0 && poly_order~=1 && poly_order~=2 && ...
                poly_order~=3 && poly_order~=4 && poly_order~=5
            error('input for polynomial order must be 0, 1, 2, 3, 4, or 5')
        end
        if poly_order==0
            nbf=1;
            pd=cell(1,nbf);
            bf=zeros(length(z),nbf);
            bf(:,nbf)=x.^0; pd{nbf}='p00';
        elseif poly_order==1
            nbf=3;
            pd=cell(1,nbf);
            bf=zeros(length(z),nbf);
            bf(:,1)=x.^0; pd{1}='p00';
            bf(:,2)=x.^1; pd{2}='p10';
            bf(:,nbf)=y.^1; pd{nbf}='p01';
        elseif poly_order==2
            nbf=6;
            pd=cell(1,nbf);
            bf=zeros(length(z),nbf);
            bf(:,1)=x.^0; pd{1}='p00';
            bf(:,2)=x.^1; pd{2}='p10';
            bf(:,3)=y.^1; pd{3}='p01';
            bf(:,4)=x.^2; pd{4}='p20';
            bf(:,5)=x.*y; pd{5}='p11';
            bf(:,nbf)=y.^2; pd{nbf}='p02';
        elseif poly_order==3
            nbf=10;
            pd=cell(1,nbf);
            bf=zeros(length(z),nbf);
            bf(:,1)=x.^0; pd{1}='p00';
            bf(:,2)=x.^1; pd{2}='p10';
            bf(:,3)=y.^1; pd{3}='p01';
            bf(:,4)=x.^2; pd{4}='p20';
            bf(:,5)=x.*y; pd{5}='p11';
            bf(:,6)=y.^2; pd{6}='p02';
            bf(:,7)=x.^3; pd{7}='p30';
            bf(:,8)=x.^2.*y; pd{8}='p21';
            bf(:,9)=x.*y.^2; pd{9}='p12';
            bf(:,nbf)=y.^3; pd{nbf}='p03';
        elseif poly_order==4
            nbf=15;
            pd=cell(1,nbf);
            bf=zeros(length(z),nbf);
            bf(:,1)=x.^0; pd{1}='p00';
            bf(:,2)=x.^1; pd{2}='p10';
            bf(:,3)=y.^1; pd{3}='p01';
            bf(:,4)=x.^2; pd{4}='p20';
            bf(:,5)=x.*y; pd{5}='p11';
            bf(:,6)=y.^2; pd{6}='p02';
            bf(:,7)=x.^3; pd{7}='p30';
            bf(:,8)=x.^2.*y; pd{8}='p21';
            bf(:,9)=x.*y.^2; pd{9}='p12';
            bf(:,10)=y.^3; pd{10}='p03';
            bf(:,11)=x.^4; pd{11}='p40';
            bf(:,12)=x.^3.*y; pd{12}='p31';
            bf(:,13)=x.^2.*y.^2; pd{13}='p22';
            bf(:,14)=x.*y.^3; pd{14}='p13';
            bf(:,nbf)=y.^4; pd{nbf}='p04';
        elseif poly_order==5
            nbf=21;
            pd=cell(1,nbf);
            bf=zeros(length(z),nbf);
            bf(:,1)=x.^0; pd{1}='p00';
            bf(:,2)=x.^1; pd{2}='p10';
            bf(:,3)=y.^1; pd{3}='p01';
            bf(:,4)=x.^2; pd{4}='p20';
            bf(:,5)=x.*y; pd{5}='p11';
            bf(:,6)=y.^2; pd{6}='p02';
            bf(:,7)=x.^3; pd{7}='p30';
            bf(:,8)=x.^2.*y; pd{8}='p21';
            bf(:,9)=x.*y.^2; pd{9}='p12';
            bf(:,10)=y.^3; pd{10}='p03';
            bf(:,11)=x.^4; pd{11}='p40';
            bf(:,12)=x.^3.*y; pd{12}='p31';
            bf(:,13)=x.^2.*y.^2; pd{13}='p22';
            bf(:,14)=x.*y.^3; pd{14}='p13';
            bf(:,15)=y.^4; pd{15}='p04';
            bf(:,16)=x.^5; pd{16}='p50';
            bf(:,17)=x.^4.*y; pd{17}='p41';
            bf(:,18)=x.^3.*y.^2; pd{18}='p32';
            bf(:,19)=x.^2.*y.^3; pd{19}='p23';
            bf(:,20)=x.*y.^4; pd{20}='p14';
            bf(:,nbf)=y.^5; pd{nbf}='p05';
        end
    end
end

[a,~,~,~]=svd_fit(z,bf,sigmaz,'tol',tol,'no suppress');

if strcmp(func,'polynomial')
    zg=zeros(length(yg),length(xg));
    for i=1:length(yg)
        for j=1:length(xg)
            if poly_order==0
                zg(i,j)=a(nbf);
            elseif poly_order==1
                zg(i,j)=a(1)...
                    +a(2)*xg(j)^1.0...
                    +a(nbf)*yg(i)^1.0;
            elseif poly_order==2
                zg(i,j)=a(1)...
                    +a(2)*xg(j)^1.0...
                    +a(3)*yg(i)^1.0...
                    +a(4)*xg(j)^2.0...
                    +a(5)*xg(j)*yg(i)...
                    +a(nbf)*yg(i)^2.0;
            elseif poly_order==3
                zg(i,j)=a(1)...
                    +a(2)*xg(j)^1.0...
                    +a(3)*yg(i)^1.0...
                    +a(4)*xg(j)^2.0...
                    +a(5)*xg(j)*yg(i)...
                    +a(6)*yg(i)^2.0...
                    +a(7)*xg(j)^3.0...
                    +a(8)*xg(j)^2.0*yg(i)...
                    +a(9)*xg(j)*yg(i)^2.0...
                    +a(nbf)*yg(i)^3.0;
            elseif poly_order==4
                zg(i,j)=a(1)...
                    +a(2)*xg(j)^1.0...
                    +a(3)*yg(i)^1.0...
                    +a(4)*xg(j)^2.0...
                    +a(5)*xg(j)*yg(i)...
                    +a(6)*yg(i)^2.0...
                    +a(7)*xg(j)^3.0...
                    +a(8)*xg(j)^2.0*yg(i)...
                    +a(9)*xg(j)*yg(i)^2.0...
                    +a(10)*yg(i)^3.0...
                    +a(11)*xg(j)^4.0...
                    +a(12)*xg(j)^3.0*yg(i)...
                    +a(13)*xg(j)^2.0*yg(i)^2.0...
                    +a(14)*xg(j)*yg(i)^3.0...
                    +a(nbf)*yg(i)^4.0;
            elseif poly_order==5
                zg(i,j)=a(1)...
                    +a(2)*xg(j)^1.0...
                    +a(3)*yg(i)^1.0...
                    +a(4)*xg(j)^2.0...
                    +a(5)*xg(j)*yg(i)...
                    +a(6)*yg(i)^2.0...
                    +a(7)*xg(j)^3.0...
                    +a(8)*xg(j)^2.0*yg(i)...
                    +a(9)*xg(j)*yg(i)^2.0...
                    +a(10)*yg(i)^3.0...
                    +a(11)*xg(j)^4.0...
                    +a(12)*xg(j)^3.0*yg(i)...
                    +a(13)*xg(j)^2.0*yg(i)^2.0...
                    +a(14)*xg(j)*yg(i)^3.0...
                    +a(15)*yg(i)^4.0...
                    +a(16)*xg(j)^5.0...
                    +a(17)*xg(j)^4.0*yg(i)...
                    +a(18)*xg(j)^3.0*yg(i)^2.0...
                    +a(19)*xg(j)^2.0*yg(i)^3.0...
                    +a(20)*xg(j)*yg(i)^4.0...
                    +a(nbf)*yg(i)^5.0;
            end
        end
    end
    zgp=zeros(size(z));
    for i=1:length(z)
        if poly_order==0
            zgp(i)=a(nbf)*bf(i,nbf);
        elseif poly_order==1
            zgp(i)=a(1)*bf(i,1)...
                +a(2)*bf(i,2)...
                +a(nbf)*bf(i,nbf);
        elseif poly_order==2
            zgp(i)=a(1)*bf(i,1)...
                +a(2)*bf(i,2)...
                +a(3)*bf(i,3)...
                +a(4)*bf(i,4)...
                +a(5)*bf(i,5)...
                +a(nbf)*bf(i,nbf);
        elseif poly_order==3
            zgp(i)=a(1)*bf(i,1)...
                +a(2)*bf(i,2)...
                +a(3)*bf(i,3)...
                +a(4)*bf(i,4)...
                +a(5)*bf(i,5)...
                +a(6)*bf(i,6)...
                +a(7)*bf(i,7)...
                +a(8)*bf(i,8)...
                +a(9)*bf(i,9)...
                +a(nbf)*bf(i,nbf);
        elseif poly_order==4
            zgp(i)=a(1)*bf(i,1)...
                +a(2)*bf(i,2)...
                +a(3)*bf(i,3)...
                +a(4)*bf(i,4)...
                +a(5)*bf(i,5)...
                +a(6)*bf(i,6)...
                +a(7)*bf(i,7)...
                +a(8)*bf(i,8)...
                +a(9)*bf(i,9)...
                +a(10)*bf(i,10)...
                +a(11)*bf(i,11)...
                +a(12)*bf(i,12)...
                +a(13)*bf(i,13)...
                +a(14)*bf(i,14)...
                +a(nbf)*bf(i,nbf);
        elseif poly_order==5
            zgp(i)=a(1)*bf(i,1)...
                +a(2)*bf(i,2)...
                +a(3)*bf(i,3)...
                +a(4)*bf(i,4)...
                +a(5)*bf(i,5)...
                +a(6)*bf(i,6)...
                +a(7)*bf(i,7)...
                +a(8)*bf(i,8)...
                +a(9)*bf(i,9)...
                +a(10)*bf(i,10)...
                +a(11)*bf(i,11)...
                +a(12)*bf(i,12)...
                +a(13)*bf(i,13)...
                +a(14)*bf(i,14)...
                +a(15)*bf(i,15)...
                +a(16)*bf(i,16)...
                +a(17)*bf(i,17)...
                +a(18)*bf(i,18)...
                +a(19)*bf(i,19)...
                +a(20)*bf(i,20)...
                +a(nbf)*bf(i,nbf);
        end
    end
elseif strcmp(func,'gaussian')
    zg=zeros(length(yg),length(xg));
    for i=1:length(yg)
        for j=1:length(xg)
            if param_3_or_5==3
                zg(i,j)=a(1)...
                    -a(2)*xg(j)^2.0...
                    -a(nbf)*yg(i)^2.0;
            elseif param_3_or_5==5
                zg(i,j)=a(1)...
                    +a(2)*xg(j)...
                    +a(3)*yg(i)...
                    -a(4)*xg(j)^2.0...
                    -a(nbf)*yg(i)^2.0;
            end
        end
    end
    zgp=zeros(size(z));
    for i=1:length(z)
        if param_3_or_5==3
            zgp(i)=a(1)*bf(i,1)...
                +a(2)*bf(i,2)...
                +a(nbf)*bf(i,nbf);
        elseif param_3_or_5==5
            zgp(i)=a(1)*bf(i,1)...
                +a(2)*bf(i,2)...
                +a(3)*bf(i,3)...
                +a(4)*bf(i,4)...
                +a(nbf)*bf(i,nbf);
        end
    end
    zg=exp(zg);
    z=exp(z);
    if param_3_or_5==5
        g_sigma_x=1/sqrt(2*a(4));
        g_sigma_y=1/sqrt(2*a(5));
        g_x0=a(2)*g_sigma_x^2;
        g_y0=a(3)*g_sigma_y^2;
        g_a=exp(a(1)+g_x0^2/2/g_sigma_x^2+g_y0^2/2/g_sigma_y^2);
    end
end



    function [a,sigmaa,covara,chisq]=svd_fit(y,bf,sigmay,varargin)
        % y is dependent column vector data [size is length(y) by 1]
        % bf column vectors are basis functions [size is length(y) by number of
        % basis functions]
        % sigmay column vector is standard deviations of y [size is length(y) by 1]
        % varargin pair ('tol',val) sets the round-off tolerance (default is the
        % machine precision eps times the number of data points
        % varargin ('suppress') suppresses output
        
        % See Numerical Recipes in C, 2nd Edition, pp. 676-678 (Solution to General
        % Linear Least Squares by Use of Singular Value Decomposition
        
        toll=eps*length(y); % Round-off tolerance based on the machine precision eps
        for ii=1:length(varargin)
            if strcmp(varargin{ii},'tol')
                toll=varargin{ii+1};
            end
        end
        A=zeros(size(bf));
        b=zeros(size(y));
        for ii=1:length(y)
            for jj=1:size(bf,2)
                A(ii,jj)=bf(ii,jj)/sigmay(ii);
            end
            b(ii)=y(ii)/sigmay(ii);
        end
        
        [U,W,V]=svd(A,'econ');
        w=diag(W);
        thresh=toll*max(w);
        for jj=1:length(w)
            if w(jj)<thresh
                w(jj)=0.0;
                warning(['w(',int2str(jj),')=0.0; check tolerance value (tol=',...
                    num2str(toll),')'])
            end
        end
        
        a=zeros(size(bf,2),1);
        sigmaasq=zeros(size(a));
        for jj=1:size(bf,2)
            if w(jj)>0
                a=a+(U(:,jj)'*b/w(jj))*V(:,jj);
                sigmaasq=sigmaasq+(V(:,jj)/w(jj)).^2;
            end
        end
        sigmaa=sqrt(sigmaasq);
        
        covara=zeros([size(V,1),size(V,1)]);
        for jj=1:size(V,1)
            for kk=1:size(V,1)
                for ii=1:size(V,2)
                    if w(ii)>0
                        covara(jj,kk)=covara(jj,kk)+V(jj,ii)*V(kk,ii)/w(ii)^2;
                    end
                end
            end
        end
        
        chisq=norm(A*a-b)^2;
        
    end


end
