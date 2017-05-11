function param = getparam(hmm, O)

T = size(O,1);	% length of observation, in frames

init  = hmm.init;	% initial probability
trans = hmm.trans;	% transition probability
mix   = hmm.mix;	% gaussian mixture
N     = hmm.N;		% number of HMM states

% for given observation O, calculate forward probability alpha
alpha = zeros(T,N);

% alpha for t=1
x = O(1,:);
for i = 1:N
	alpha(1,i) = init(i) * mixture(mix(i),x);	
end

% scale alpha for t=1
c    = zeros(T,1);
c(1) = 1/sum(alpha(1,:));		
alpha(1,:) = c(1) * alpha(1,:);

% alpha and scaling for t=2:T
for t = 2:T
	for i = 1:N
		temp = 0;
		for j = 1:N
			temp = temp + alpha(t-1,j) * trans(j,i);
		end
		alpha(t,i) = temp * mixture(mix(i),O(t,:));
	end
	c(t) = 1/sum(alpha(t,:));
	alpha(t,:) = c(t)*alpha(t,:);
end

% for given observation O, calculate backward probability beta
beta = zeros(T,N);

% beta and scaling for t=T
for l = 1:N
	beta(T,l) = c(T);	
end

% beta and scaling for t=T-1:1
for t = T-1:-1:1
	x = O(t+1,:);
	for i = 1:N
	for j = 1:N
		beta(t,i) = beta(t,i) + beta(t+1,j) * mixture(mix(j),x) * trans(i,j);
	end
	end
	beta(t,:) = c(t) * beta(t,:);
end

% ksai
ksai = zeros(T-1,N,N);
for t = 1:T-1
	denom = sum(alpha(t,:).*beta(t,:));
	for i = 1:N-1
	for j = i:i+1
		nom = alpha(t,i) * trans(i,j) * mixture(mix(j),O(t+1,:)) * beta(t+1,j);
		ksai(t,i,j) = c(t) * nom/denom;
	end
	end
end

% gama
gama = zeros(T,N,max(hmm.M));
for t = 1:T
	pab = zeros(N,1);
	for l = 1:N
		pab(l) = alpha(t,l) * beta(t,l);
	end
	x = O(t,:);
	for l = 1:N
		prob = zeros(mix(l).M,1);
		for j = 1:mix(l).M
			m = mix(l).mean(j,:);
			v = mix(l).var (j,:);
			prob(j) = mix(l).weight(j) * pdf(m, v, x);
		end
		tmp  = pab(l)/sum(pab);
		for j = 1:mix(l).M
			gama(t,l,j) = tmp * prob(j)/sum(prob);
		end
	end
end

param.c     = c;
param.alpha = alpha;
param.beta  = beta;
param.ksai  = ksai;
param.gama  = gama;
