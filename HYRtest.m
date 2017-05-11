%% TEST %%
testNum = randi(10, 1, 1);
fname = sprintf('num%dset7.wav', testNum);

x = wavread(fname);
%figure(1); subplot(2, 1, 1); plot(x); title('num1set1.wav');

x = filter([1 -0.9375], 1, x);
%subplot(2, 1, 2); plot(x); title('num1set1.wav filtering');

m = melcepst(x, 16000, 'M', 12, 24, 256, 80);
%figure(2); plot([0:120], m); title('num1set1.wav MFCCs');

for j = 1:10
    pout(j) = viterbi(hmm{j}, m);
end
[dist, num] = max(pout);

fprintf('word number %d is recognized as %d\n', testNum, num)
