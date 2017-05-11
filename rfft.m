function y=rfft(x,n)

if nargin < 2
  y=fft(x);
else
  y=fft(x,n);
end
if size(y,1)==1
  m=length(y);
  y(floor((m+4)/2):m)=[];
else
  m=size(y,1);
  y(floor((m+4)/2):m,:)=[];
end

