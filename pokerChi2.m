function [R,critval,reject] = pokerChi2(patterns,alpha)
    %expected values for different bins
    all_different = 0.3024;
    one_pair = 0.5040;
    two_pair = 0.1080;
    three_of_a_kind = 0.072;
    full_house = 0.009;
    four_of_a_kind = 0.0045;
    five_of_a_kind = 0.0001;
    total = sum(patterns);

    expected_val = total * [all_different, one_pair, two_pair, three_of_a_kind, full_house, four_of_a_kind, five_of_a_kind];
    % disp(expected_val)
    % disp(patterns)

    R = sum(((patterns - expected_val).^2)./expected_val);
    critval = chi2inv(1-alpha, length(patterns) - 1);
    reject = R > critval;
end
