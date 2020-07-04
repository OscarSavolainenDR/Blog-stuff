function [pop] = population_change_UN_median_prediction(t,figure_cutoff)
    
    % Last edit: 04/07/2020; Oscar Savolainen.
    
    % Function that returns an estimate, pop, of the total human population as a
    % function of time, based on the median UN forecast.
    % Input t is a vector representing time in years
    % Input figure_cutoff gives the right-hand cutoff for the figures, to save on memory.
    %
    % The UN data is available at
    % https://population.un.org/wpp/Download/Probabilistic/Population/.
    % The median prediction was used. Since the prediction ends at 2100, we
    % fit a cubic model to the prediction. When the cubic fit reached an
    % inflection point, we set the population beyond that point to be equal
    % to the value at the inflection point.
    %
    % The code for the cubic fit and inflection point calculation is given
    % at the bottom of the function.
    pop = 1.391.*t(1:84).^3 - 678.2.*t(1:84).^2 + 8.392e4.*t(1:84) + 7.785e6; % create the interpolated, cubic estimate
    pop(84:length(t)) = pop(84); % set all total population values beyond the inflection point (t=84) as equal to the inflection point's value, so that the population stabilises.
    
    figure, hold on
    line(t(1:figure_cutoff),pop(1:figure_cutoff)); title('Estimate of human population over time')% xlim([0 500])
    
    %% Code to do the analysis
    %{
    % First, import data from the UN data excel spreadsheet into
    % vector pop_UN_estimate, which will have 17 values like variable t below.
    t_UN = 0:5:80; % the estimate was done in 5 year steps. t(1) = 2020.

    % Second, fit a cubic model to that estimate
    t_interp = 0:400; % this range was big enough to pick up on the inflection point
    f=fit(t_UN',pop_UN_estimate','poly3'); % cubic fit, as specified by 'pol3'
    pop = f.p1.*t_interp.^3 + f.p2.*t_interp.^2 + f.p3.*t_interp + f.p4; % create the interpolated, cubic estimate
    
    % Third, find the inflection point in the cubic fit, where the
    % population starts decreasing. Set all values of the population to the
    % right of the inflection point as equal to the value of the population
    % at the inflection point, modelling that the population stabilises at
    % that value.
    d_pop = diff(pop); % get the delta-sampled version of the estimate
    first_inflection_point = find(diff(d_pop<0)); % find inflection points, where the delta-sampled version changes sign from positive to negative
    first_inflection_point = first_inflection_point(1)+1; % take first inflection point, the vector was all called first_inflection_point because I was loathe to use a different name for some reason
    pop(first_inflection_point:end) = pop(first_inflection_point); % set all total population values beyond the inflection point as equal to the inflection point's value, so that the population stabilises.
    %}
end
