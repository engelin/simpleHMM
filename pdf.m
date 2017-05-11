function p = pdf(m, v, x)

p = (2 * pi * prod(v)) ^ -0.5 * exp(-0.5 * (x-m) ./ v * (x-m)');
