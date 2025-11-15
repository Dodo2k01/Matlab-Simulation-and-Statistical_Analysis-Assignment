%1a 
seed = 19;
a = 846793005;
c = 294755497;
num = 10000;

U = RNG_PCG(num, a, c, seed);

%verification for debugging purposes
x = 1:num;
plot(x, U, '.');
xlabel('Index');
ylabel('Random value (U)');
title('PCG Random Numbers, 1D Plot');
ylim([0 1]);

%1b poker test 
patterns = pokerCounts(U);
alpha001 = 0.01;
alpha005 = 0.05;
[R001, critval001, reject001] = pokerChi2(patterns, alpha001)
[R005, critval005, reject005] = pokerChi2(patterns, alpha005);
