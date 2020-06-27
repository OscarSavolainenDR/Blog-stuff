function [P] = population_survival_2D_exponent_model(t,s_u,s_o,spread,points_sigma,theta,show_figures,figure_cutoff)

    s = logspace(s_u-s_o*spread,s_u+s_o*spread,points_sigma);
    x = 1:length(s);
    y = normpdf(x,length(s)/2,s_o*points_sigma/(2*spread));
    P = 0;
    for i = 1:numel(s)
        p(i,1:figure_cutoff) = exp(-s(i)*(1:figure_cutoff)) * y(i);
        P = (exp(-s(i)*t) * y(i)) + P;
    end
    P = (1-theta) * P + theta;
    
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
