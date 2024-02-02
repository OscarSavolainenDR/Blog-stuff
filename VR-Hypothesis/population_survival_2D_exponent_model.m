function [P] = population_survival_2D_exponent_model(t,s_u,s_o,spread,points_sigma,theta,show_figures,figure_cutoff)
     % Last edit: 27/06/2020; Oscar Savolainen.
     % Function that produces a 2D map of decaying exponentials that are used to model humanity's chance of avoiding extinction.
     % Each decay exponential is weighted using a log-normal distribution. They are then summed together to give the average weighted
     % scenario. The final scenario is then weighted with a theta offset.

    s = logspace(s_u-s_o*spread,s_u+s_o*spread,points_sigma); % log normal scale of decaying exponents
    x = 1:length(s);
    y = normpdf(x,length(s)/2,s_o*points_sigma/(2*spread)); % log-normal distribution
    P = 0;
    for i = 1:numel(s) % iterate through s (decaying exponential) scenarios
        p(i,1:figure_cutoff) = exp(-s(i)*(1:figure_cutoff)) * y(i);
        P = (exp(-s(i)*t) * y(i)) + P;
    end
    P = (1-theta) * P + theta; % theta offset
    
    if show_figures ==1
        figure,line(x,y); title('Probability distribution across s on a logarithmic scale')
        figure
        h=gca;
        surf(t(1:figure_cutoff),s,p(:,1:figure_cutoff))
        set(h,'yscale','log')
        xlabel('Time (years)')
        ylabel('{\its}')
        zlabel('Likelihood of survivial')
        title(['2D surface estimating humanity’s likelihood of survival',newline,'over time and for different s scenarios'])
    %     figure, plot(p(:,T)); title('Probability distribution at T')
        figure, line(t(1:figure_cutoff),P(1:figure_cutoff)); title('Final survival function: integral across {\its} of 2D function, offset by {\it\Theta}') % integrated across s
        
    end
end
