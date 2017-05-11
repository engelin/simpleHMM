function [hmm, pout] = train(i, samples, M)

K = length(samples);

hmm = inithmm(samples, M);

X = [-500:0.01:500];
loopNum = 30;
for loop = 1:loopNum
	fprintf('\ntraining loop %d\n\n',loop)
	hmm = baum(hmm, samples);
    norm1(loop, :) = normpdf(X, hmm(1).mix(1, 1).mean(1, 1), hmm(1).mix(1, 1).var(1, 1));
    norm2(loop, :) = normpdf(X, hmm(1).mix(1, 2).mean(1, 1), hmm(1).mix(1, 2).var(1, 1));
    norm3(loop, :) = normpdf(X, hmm(1).mix(1, 3).mean(1, 1), hmm(1).mix(1, 3).var(1, 1));
    norm4(loop, :) = normpdf(X, hmm(1).mix(1, 4).mean(1, 1), hmm(1).mix(1, 4).var(1, 1));

	% calculate total output probability
	pout(loop)=0;
	for k = 1:K
		pout(loop) = pout(loop) + viterbi(hmm, samples(k).data);
	end

	fprintf('total output probability(log)=%d\n', pout(loop))

	% compare two hmms
	if loop>1
		if abs((pout(loop)-pout(loop-1))/pout(loop)) < 5e-5
			fprintf('convergence!\n');
            %figure(i); plot(X, norm');
            figure(i);
            subplot(2, 2, 1); plot(X, norm1'); title(['GaussianMix of State 1: Loop ' num2str(loop)]);
            subplot(2, 2, 2); plot(X, norm2'); title(['GaussianMix of State 2: Loop ' num2str(loop)]);
            subplot(2, 2, 3); plot(X, norm3'); title(['GaussianMix of State 3: Loop ' num2str(loop)]);
            subplot(2, 2, 4); plot(X, norm4'); title(['GaussianMix of State 4: Loop ' num2str(loop)]);
			return
		end
    end    
end

%figure(i); plot(X, norm');
figure(i);
subplot(2, 2, 1); plot(X, norm1'); title('GaussianMix of State 1: Loop 30');
subplot(2, 2, 2); plot(X, norm2'); title('GaussianMix of State 2: Loop 30');
subplot(2, 2, 3); plot(X, norm3'); title('GaussianMix of State 3: Loop 30');
subplot(2, 2, 4); plot(X, norm4'); title('GaussianMix of State 4: Loop 30');

fprintf('convergence not reached for %d iterations, quit', loopNum);