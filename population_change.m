function [pop] = population_change(t,figure_cutoff)
    % Last edit: 27/06/2020; Oscar Savolainen.
    % A function estimating the size of the human population at each year from today (2020) into the future.
    % This is based on an extrapolation of growth trends from Worldmeter estimates: approximate 13% reduction in
    % growth every 5 years. This function assumes year-on-year growth reduces by 2.46% every year (5th root of 13%),
    % and 2020 starts with 7.794 billion people and a year-on-year growth of 1.10%.
    pop = 7.794e12;
    for k = 2:length(t)
        pop(k) = pop(k-1) * (1+(1.1*(1-0.0246)^(k-1))/100);
    end
    figure, hold on
    line(t(1:figure_cutoff),pop(1:figure_cutoff)); title('Estimate of human population over time')% xlim([0 500])
end
