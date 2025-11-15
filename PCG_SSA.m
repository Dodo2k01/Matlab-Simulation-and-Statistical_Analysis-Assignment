function [Z, n] = PCG_SSA(n, a, c)
    % to avoid integer overflow i need to do the operations on unsigned 64
    % bit integers, otherwise i always get 1 for each Z
    n_new = uint32(mod(uint64(a) * uint64(n) + uint64(c), 2^32));

    %get 3 most significatnt digits to get shift amt
    shift_amt = bitshift(n_new, -29); 

    % Right shift state by shift_amt, then mask to get 16-bit output
    Z = bitand(bitshift(n_new, -double(shift_amt)), uint32(intmax('uint16')));

    n = n_new;
end
