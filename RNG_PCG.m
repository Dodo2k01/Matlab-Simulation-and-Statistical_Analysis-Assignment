function U = RNG_PCG(num, a, c, seed)
    n = seed;
    U = zeros(1, num);
    for i = 1:num
        [Z, n] = PCG_SSA(n, a, c); % generate next numbers
        U(i) = double(Z) / double(intmax('uint16'));  % Normalize 16-bit integer to [0,1)
    end
end
