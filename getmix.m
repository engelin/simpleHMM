function mix = getmix(vector, M)

[mean esq nn] = kmeans(vector,M);

% calculate variance, in diagonal
for j = 1:M
	ind = find(j==mean);
	tmp = vector(ind,:);
	var(j,:) = std(tmp);
end

% get number of vectors for each pdf, and convert into weights
weight = zeros(M,1);
for j = 1:M
	weight(j) = sum(find(j==mean));
end
weight = weight/sum(weight);

% return gaussian mixture
mix.M      = M;
mix.mean   = esq;		% M*SIZE
mix.var    = var.^2;	% M*SIZE
mix.weight = weight;	% M*1
