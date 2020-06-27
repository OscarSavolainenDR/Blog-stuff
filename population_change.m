function [pop] = population_change(t,figure_cutoff)
    pop = 7.794e12;
    for k = 2:length(t)
        pop(k) = pop(k-1) * (1+(1.1*(1-0.0246)^(k-1))/100);
    %     pop2(k) = 7.794* ((1+(1.1*(0.976)^(k-1))/100))^(k-1);
    end
    figure, hold on
    line(t(1:figure_cutoff),pop(1:figure_cutoff)); title('Estimate of human population over time')% xlim([0 500])
end
