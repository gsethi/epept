function makedata(N,M,file)

rand('seed',prod(fix(clock)))
randn('seed',prod(fix(clock)))
Nvec = 1:M;
A = zeros(N+1,length(Nvec));

for n = 1:length(Nvec);
    fprintf(1,'.');
    Pgoal = 10^-Nvec(n);                            %P_perm (correct P-value)
    x0 = finv(1-Pgoal,5,10);                        %original statistic x0
    y = frnd(5,10,N,1);                             %permutation values
    A(1,n) = x0;
    A(2:N+1,n) = y;
end

str = [];
for n = 1:length(Nvec)-1;
    str = [str '%4.3e\t'];
end
str = [str '%4.3e\n'];

fid = fopen(file,'w');
fprintf(fid,str,A');
fclose(fid);
display('Permutation values saved...');