%% VR Hypothesis script

%  Last edit: 27/06/2020; Oscar Savolainen.

close all
clearvars
show_figures = 1;
figure_cutoff = 1000; % how many time steps in figures, the figures de facto have time steps from 1 to figure_cutoff.

humanity_integral_limit = 2e8; % Year at which humanity definitively ends or computer runs out of memory, limit of integral. In blog is y. Is a positive value.
t = 0:humanity_integral_limit;

% Temporal limits of simulation
WL = 1;
WH = 20;

%% Probability of humanity's survival:
value_at_which_survival_stabilises = 0.001;%0.00001; % In blog is Theta. Value at which humanity's chances of survival stabilise. Value between 0 and 1. E.g. no matter what, we have a 0.1% of making it to the end of the integral date (y).
decay_exponent_mean = -3;% exponential decay value, can be derived from getting within e.g. 10% of theta, % -10^(-log(value_at_which_survival_stabilises*0.1)/survival_stabilisation_year); 
decay_exponent_sigma = 1; % uncertainty around prediction of decay_exponent_mean, gives width of 2D surface

points_sigma = 30; % Resolution of 2D map, more points means more samples from the log-normal distribution of scenarios are considered.
spread = 3; % number of standrard deviations considered on either side of decay_exponent_mean (since Gaussians go forever, and there's no point simulating values basically equal to zero on the extreme wings).
survival = population_survival_2D_exponent_model(t,decay_exponent_mean,decay_exponent_sigma,spread,points_sigma,value_at_which_survival_stabilises,show_figures,figure_cutoff);
xlabel('Time (years)')
ylabel(['Estimated probability of',newline,'humanity surviving past year {\itt}'])


%% Human population over time
population = population_change(t,figure_cutoff);
xlabel('Time (years)')
ylabel('Estimated popuation')
xlim([0 figure_cutoff])

ff = population(1:figure_cutoff).*survival(1:figure_cutoff); % for plotting figures
val = min([ff(WL:WH)]); % used in normalising choice_of_individual (in blog called f)
figure, hold on
line(t(1:figure_cutoff), ff,'LineWidth',2,'Color','k')
area([WL WH],[val val],'LineWidth',2)
legend('Estimated population','Minimum population between {\itW\_L} and {\itW\_H}','Location','SouthEast')
xlim([1 100])
title(['Estimated Population, and Minimum',newline,'Expected Value between {\itW\_L} and {\itW\_H}'])
xlabel('Time (years)')
ylabel('Estimated Population')

%% Relative time speed
t_exp_VR = 450; % date in which time speed in VR changes relative to in the Base Layer
f_exp_VR = 3; %  factor by which time speeds up in VR relative to the Base Layer at date t_exp_VR
experienced_time_speed_in_VR(1:t_exp_VR-1) = 1; % these step functions could be changed to some cumulative probability distribution
experienced_time_speed_in_VR(t_exp_VR:figure_cutoff) = f_exp_VR;

t_exp_BL = 500; % date in which time speed in Base Layer changes relative to today (2020) in the Base Layer.
f_exp_BL = 1; % factor by which time speeds up in Base Layer relative to the Base Layer today (2020) at date t_exp_BL
experienced_time_speed_in_BL(1:t_exp_BL-1) = 1; % these step functions could be changed to some cumulative probability distribution
experienced_time_speed_in_BL(t_exp_BL:figure_cutoff) = f_exp_BL;

figure, subplot(2,1,1)
line(t(1:figure_cutoff),experienced_time_speed_in_BL(1:figure_cutoff))
title('Experienced time in BL relative to today')
xlabel('Time (years')
ylabel('Estimated sped of time')
ylim([0 8])
subplot(2,1,2)
line(t(1:figure_cutoff),experienced_time_speed_in_VR(1:figure_cutoff))
title('Experienced time in VR relative to BL')
xlabel('Time (years')
ylabel('Estimated sped of time')
ylim([0 8])

%% Total exp time
total_exp_time = survival .* population;
[total_exp_time] = exp_time_adjust(total_exp_time,t_exp_BL,f_exp_BL); % adjusting experienced time by speed offsets
[total_exp_time] = exp_time_adjust(total_exp_time,t_exp_VR,f_exp_VR);
clear survival
figure, hold on
area(t(1:figure_cutoff),total_exp_time(1:figure_cutoff))
line(t(1:figure_cutoff),total_exp_time(1:figure_cutoff),'LineWidth',2,'Color','k')
title(['Estimated total amount of experienced years, per year, of all of humanity',newline,'on average, relative to today''s speed of experienced time:',newline,'{\ittotal\_exp\_time}'])
ylabel(['Estimated total amount of',newline,'experienced time (experienced years)'])
xlabel('Time (years)')

%% Probability of inventing VRs:
T_u = 200; % Mean year we invent VRs.
T_o = 60; % Std of year we invent VR.
f = gauss_distribution(t, T_u, T_o); % Normal distribution
VR_invention_timeline = cumsum(f); % Cumulative normal distribution
figure, line(t(1:figure_cutoff),f(1:figure_cutoff),'LineWidth',2); xlabel('Time (years)'); ylabel('p\_Inv(t)'); title('Distribution of estimated year humanity invents VRs')
xlim([0 600])
% figure, line(t,VR_invention_timeline,'LineWidth',2); xlabel('Time (years)'); ylabel('FInv(t)'); xlim([0 500]); title('Cumulative distribution of year we invent VRs')
figure, area(t(1:figure_cutoff),VR_invention_timeline(1:figure_cutoff),'LineWidth',2); xlabel('Time (years)'); ylabel('F\_Inv(t)'); title('Cumulative distribution of estimated year humanity invents VRs')
xlim([0 600])
clear f


%% How much time one would choose to spend in a Pre-VR Human Civilisation Themed (PVRHCT) VR, as a specific individual between WL and WH
spend_VR_percentage = 0.8; % In blog this is h. How much awake time the average person chooses to spend in any VR. Could be a function that varies over time, as a function of f_exp_VR, or something else.
spend_human_VR_percentage = 0.0001; % In blog this is g. How much VR time the average person chooses to spend in a PVRHCT VR. Could also be a function that varies over time, as a function of f_exp_VR, or something else. Some people may be more likely to choose to experience PVRHCT VRs than others.
choice_of_individual = 0.01; % In blog this is f. How likely it is for the average person entering a PVRHCT VR to choose you as an avatar relative to all those available in a PVRHCT VR (which is presumably the human population alive between WL and WH).
choice_of_individual = choice_of_individual/val; % Normalisation of choice_of_individual by the presumed pool of available avatars.
percentage_of_awake_time_in_human_sim_indivdual = spend_VR_percentage * spend_human_VR_percentage * choice_of_individual;
% figure, line(t(1:figure_cutoff),percentage_of_awake_time_in_human_sim_indivdual(1:figure_cutoff),'LineWidth',2); xlabel('Time (years)'); ylabel('Pv(t)'); xlim([0 figure_cutoff]); title('Proportion of awake time spent in human-sim VRs, as a specific individual between WL and WH')


%% Integral
% close all
human_civ_VR_experience = total_exp_time .* VR_invention_timeline .* percentage_of_awake_time_in_human_sim_indivdual; % the amount of experienced time, in years, we expect humans to have in human-civilisation pre-VR themed VRs, experiencing the life of a specific individual between moments W_L and W_H, at any given year t.
pre_civ_VR_not_VR_experience = (1-VR_invention_timeline(1:figure_cutoff)); % the experienced time the average human is in pre-VR human civilisation, within the time period given by W_L and W_H
[pre_civ_VR_not_VR_experience] = exp_time_adjust(pre_civ_VR_not_VR_experience,t_exp_BL,f_exp_BL);
try
pre_civ_VR_not_VR_experience(WH+1:end) = 0; catch; end % bound between WL and WH
try
pre_civ_VR_not_VR_experience(1:WL-1) = 0; catch; end  % bound between WL and WH
clear population

figure, hold on
% area(t(1:cutoff),all_human_experience(1:cutoff))
area(t(1:figure_cutoff),pre_civ_VR_not_VR_experience(1:figure_cutoff)+human_civ_VR_experience(1:figure_cutoff))
area(t(1:figure_cutoff),human_civ_VR_experience(1:figure_cutoff))
% legend('All human experience in VR, but not Pre-VR-human-civ-themed','All human experience without VRs','All pre-VR-human-civ VR experience')
legend('Non-VR like PVRHCT experience, but in the BL, as an individual between W\_L and W\_H','Actual PVRHCT VR experience, as an individual between W\_L and W\_H (may have to zoom in at the bottom)','Location','NorthEast')
xlabel('Time (years)'); 


figure, hold on
% area(t(1:cutoff),all_human_experience(1:cutoff))
area(t(1:figure_cutoff),pre_civ_VR_not_VR_experience(1:figure_cutoff)+human_civ_VR_experience(1:figure_cutoff))
% legend('All human experience in VR, but not Pre-VR-human-civ-themed','All human experience without VRs','All pre-VR-human-civ VR experience')
title(['Estimated amount of BL-based like-PVRHCT experienced time,',newline,' as an individual between W\_L and W\_H:',newline, '{\ittotal\_pre\_VR\_experience}'])
xlabel('Time (years)'); 
xlim([0 WH+10])
ylabel(['Estimated experienced',newline,'time per year in Non-VR'])


figure, hold on
% area(t(1:cutoff),all_human_experience(1:cutoff))
area(t(1:figure_cutoff),human_civ_VR_experience(1:figure_cutoff))
% legend('All human experience in VR, but not Pre-VR-human-civ-themed','All human experience without VRs','All pre-VR-human-civ VR experience')
title(['Estimated amount of VR-based PVRHCT experienced time for',newline,'all of humanity, as an individual between W\_L and W\_H:',newline,'{\ittotal\_human\_civ\_individual\_VR\_experience}'])
xlabel('Time (years)'); 
ylabel(['Estimated total experienced time',newline,'per year in specific PVRHCT-VR'])

%% Final probability of being in a VR
p_in_VR = sum(human_civ_VR_experience)/(sum(pre_civ_VR_not_VR_experience(WL:WH))+sum(human_civ_VR_experience))


