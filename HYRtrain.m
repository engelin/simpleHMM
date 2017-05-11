clear all; close all; clc

traindata = cell(1,10);
for i=0:9
    temp = cell(1,6);
    for j=1:6
     fname = sprintf('num%dset%d.wav',i+1,j);
     x = wavread(fname);
     temp{1,j}=x';
   end
   traindata{1,i+1} = temp;
end

hmm = cell(1,10);

%% TRAIN %%
X = [-500:.1:500];
for i = 1:length(traindata)
	sample = [];
	for k = 1:length(traindata{i})
		x = filter([1 -0.9375], 1, traindata{i}{k});
		sample(k).data = melcepst(x,16000,'M',12,24,256,80);
	end
	hmm{i}=train(i, sample, [3 3 3 3]);
    norm1(i, :) = normpdf(X, hmm{i}.mix(1, 1).mean(1, 1), hmm{i}.mix(1, 1).var(1, 1));
    norm2(i, :) = normpdf(X, hmm{i}.mix(1, 2).mean(1, 1), hmm{i}.mix(1, 2).var(1, 1));
    norm3(i, :) = normpdf(X, hmm{i}.mix(1, 3).mean(1, 1), hmm{i}.mix(1, 3).var(1, 1));
    norm4(i, :) = normpdf(X, hmm{i}.mix(1, 4).mean(1, 1), hmm{i}.mix(1, 4).var(1, 1));
end

%figure(1);
%subplot(2, 2, 1); plot(X, norm1'); title('GaussianMix of State 1: Loop 20');
%subplot(2, 2, 2); plot(X, norm2'); title('GaussianMix of State 2: Loop 20');
%subplot(2, 2, 3); plot(X, norm3'); title('GaussianMix of State 3: Loop 20');
%subplot(2, 2, 4); plot(X, norm4'); title('GaussianMix of State 4: Loop 20');
