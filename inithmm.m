function hmm = inithmm(samples, M)

K = length(samples);	% number of speech samples
N = length(M);			% number of hmm states
hmm.N = N;
hmm.M = M;

% initial probability
hmm.init    = zeros(N,1);
hmm.init(1) = 1;

% transition probability
hmm.trans=zeros(N,N);
for i=1:N-1
	hmm.trans(i,i)   = 0.5;
	hmm.trans(i,i+1) = 0.5;
end
hmm.trans(N,N) = 1;

% initial cluster of pdfs
% equally segmentation
for k = 1:K
	T = size(samples(k).data,1);
	samples(k).segment=floor([1:T/N:T T+1]);
end

% cluster vectors belong to each states using K-Means
for i = 1:N
	% assemble vectors of the same cluster and state into one vector
	vector = [];
	for k = 1:K
		seg1 = samples(k).segment(i);
		seg2 = samples(k).segment(i+1)-1;
		vector = [vector ; samples(k).data(seg1:seg2,:)];
    end
	mix(i) = getmix(vector, M(i));
end

hmm.mix = mix;
