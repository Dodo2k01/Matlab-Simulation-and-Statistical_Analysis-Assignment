function patterns = pokerCounts(U)
V = floor(10 * U);
patterns = zeros(1,7);
    for i = 1:5:10000
        v = [V(i), V(i+1), V(i+2), V(i+3), V(i+4)];
        uniques = unique(v);         % x: unique values, ic: index map
        %5 nums the same
        if length(uniques) == 1
            patterns(7) = patterns(7) + 1;
        %4 of a kind or full house
        elseif length(uniques) == 2
            N = histcounts(v);
            %full house
            if any(N == 3) && any(N ==2)
                patterns(5) = patterns(5) + 1;
            %4 of a kind
            else 
                patterns(6) = patterns(6) + 1;
            end
        %3 of a kind or 2 pair
        elseif length(uniques) == 3
            % 3 of a kind
            N = histcounts(v);
            if any(N == 3)
                patterns(4) = patterns(4) + 1;
            %no 3 count thus 2 pair
            else
                patterns(3) = patterns(3) + 1;
            end
        %one pair
        elseif length(uniques) == 4
            patterns(2) = patterns(2) + 1;
        else
            patterns(1) = patterns(1) + 1;
        end
    end
end

