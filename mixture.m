function prob = mixture(mix, x)

prob = 0;
for j = 1:mix.M
	m = mix.mean(j,:);
	v = mix.var (j,:);
	w = mix.weight(j);
	prob = prob + w * pdf(m, v, x);
end

% prevent from overflow in viterbi.m when calling log(prob)
if prob==0, prob=realmin; end
