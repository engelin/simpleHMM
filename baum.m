function hmm = baum(hmm, samples)

mix = hmm.mix;			% gaussian mixture
N    = length(mix);		% number of HMM states
K    = length(samples);	% number of speech samples
SIZE = size(samples(1).data,2); % order of speech parameter

% calculate alpha, beta for multi observation
disp('calculate speech parameters...');
for k = 1:K
    fprintf('%d ',k)
	param(k) = getparam(hmm, samples(k).data);
end
fprintf('\n')

% reestimate transition probability matrix A: trans
disp('reestimate transition probability matrix A...')
for i = 1:N-1
	denom = 0;
	for k = 1:K
		tmp   = param(k).ksai(:,i,:);
		denom = denom + sum(tmp(:));
	end
	for j = i:i+1
		nom = 0;
		for k = 1:K
			tmp = param(k).ksai(:,i,j);
			nom = nom   + sum(tmp(:));
		end
		hmm.trans(i,j) = nom / denom;
	end
end

% reestimate gaussian mixture
disp('reestimate gaussian mixture...')
for l = 1:N
for j = 1:hmm.M(l)
	fprintf('%d,%d ',l,j)
	% calculate mean and variance for each pdf
	nommean = zeros(1,SIZE); 
	nomvar  = zeros(1,SIZE); 
	denom   = 0;
	for k = 1:K
		T = size(samples(k).data,1);
		for t = 1:T
			x	    = samples(k).data(t,:);
			nommean = nommean + param(k).gama(t,l,j) * x;
			nomvar  = nomvar  + param(k).gama(t,l,j) * (x-mix(l).mean(j,:)).^2;
			denom   = denom   + param(k).gama(t,l,j);
		end
	end
	hmm.mix(l).mean(j,:) = nommean / denom;
	hmm.mix(l).var (j,:) = nomvar  / denom;

	% calculate the weights of each pdf
	nom   = 0;
	denom = 0;
	for k = 1:K
		tmp = param(k).gama(:,l,j);    nom   = nom   + sum(tmp(:));
		tmp = param(k).gama(:,l,:);    denom = denom + sum(tmp(:));
	end
	hmm.mix(l).weight(j) = nom/denom;
end
fprintf('\n')
end
