function [x1,x2] = vad(x)

% normalize to [-1,1]
x = double(x);
x = x / max(abs(x));

% constants setup: for 8KHz only
FrameLen = 256;
FrameInc = 80;

amp1 = 10;
amp2 = 2;
zcr1 = 10;
zcr2 = 5;

maxsilence = 8;  %  8*10ms =  80ms
minlen  = 15;    % 15*10ms = 150ms
status  = 0;
count   = 0;
silence = 0;

% zero crossing rate
tmp1  = enframe(x(1:end-1), FrameLen, FrameInc);
tmp2  = enframe(x(2:end)  , FrameLen, FrameInc);
signs = (tmp1.*tmp2)<0;
diffs = (tmp1 -tmp2)>0.02;
zcr   = sum(signs.*diffs, 2);

% short time energy in abs
amp = sum(abs(enframe(filter([1 -0.9375], 1, x), FrameLen, FrameInc)), 2);

% adjust energy threshold
amp1 = min(amp1, max(amp)/4);
amp2 = min(amp2, max(amp)/8);

% start endpoint detection
x1 = 0; 
x2 = 0;
for n=1:length(zcr)
   goto = 0;
   switch status
   case {0,1}                   % 0 = silence, 1 = maybe start
      if amp(n) > amp1          % in voice
         x1 = max(n-count-1,1);
         status  = 2;
         silence = 0;
         count   = count + 1;
      elseif amp(n) > amp2 | ... % maybe start
             zcr(n) > zcr2
         status = 1;
         count  = count + 1;
      else                       % in silence
         status  = 0;
         count   = 0;
      end
   case 2,                       % 2 = voice segment
      if amp(n) > amp2 | ...     % remain in voiced
         zcr(n) > zcr2
         count = count + 1;
      else                       % voice is about to end
         silence = silence+1;
         if silence < maxsilence % silence not long enough, voice not ended
            count  = count + 1;
         elseif count < minlen   % voice too short, recognize as noise
            status  = 0;
            silence = 0;
            count   = 0;
         else                    % voice ended
            status  = 3;
         end
      end
   case 3,
      break;
   end
end   

count = count-silence/2;
x2 = x1 + count -1;
