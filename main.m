%% VR Hypothesis script

close all
clearvars
show_figures = 1;
figure_cutoff = 1000;

humanity_integral_limit = 2e8; % Year at which we die, limit of integral 
t = 0:humanity_integral_limit;

% Limits of simulation
WL = 1;
WH = 20;

%% Probability of humanity's survival:
value_at_which_survival_stabilises = 0.001;%0.00001; % Value at which our chances of survival stabilise
% survival_stabilisation_percentage = 0.01; % Once the survival value gets within X of Theta, survival gets estimated with a rectangle, since it's much cheaper to compute.
% survival_stabilisation_year = 1e3; % Year at which our chances stabilise
decay_exponent_mean = -3;% -10^(-log(value_at_which_survival_stabilises*0.1)/survival_stabilisation_year); % exponential decay value, derived from getting within 10% of theta
decay_exponent_sigma = 1; % uncertainty around prediction

points_sigma = 30; % Resolution of 2D map
spread = 3; % number of stds considered on either side of mean
survival = population_survival_2D_exponent_model(t,decay_exponent_mean,decay_exponent_sigma,spread,points_sigma,value_at_which_survival_stabilises,show_figures,figure_cutoff);
xlabel('Time (years)')
ylabel(['Estimated probability of',newline,'humanity surviving past year {\itt}'])
% zlabel('Likelihood of survivial')


%% Human population over time
population = population_change(t,figure_cutoff);
xlabel('Time (years)')
ylabel('Estimated popuation')
xlim([0 figure_cutoff])

ff = population(1:figure_cutoff).*survival(1:figure_cutoff);
val = min([ff(WL:WH)]);
figure, hold on
line(t(1:figure_cutoff), ff,'LineWidth',2,'Color','k')
area([WL WH],[val val],'LineWidth',2)
legend('Estimated population','Minimum population between {\itW\_L} and {\itW\_H}','Location','SouthEast')
xlim([1 100])
title(['Estimated Population, and Minimum',newline,'Expected Value between {\itW\_L} and {\itW\_H}'])
xlabel('Time (years)')
ylabel('Estimated Population')
%% Relative time speed
t_exp_VR = 450;
f_exp_VR = 3;
experienced_time_speed_in_VR(1:t_exp_VR-1) = 1; % how quicky the average human experiences time relative to humans in 2020. This may increase as a funciton of time, if we change from purely biological substrate.
experienced_time_speed_in_VR(t_exp_VR:figure_cutoff) = f_exp_VR;

t_exp_BL = 500;
f_exp_BL = 1;
experienced_time_speed_in_BL(1:t_exp_BL-1) = 1; % how quicky the average human experiences time relative to humans in 2020. This may increase as a funciton of time, if we change from purely biological substrate.
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
% title('Experienced time in BL and VR')
%% Total exp time
total_exp_time = survival .* population;
[total_exp_time] = exp_time_adjust(total_exp_time,t_exp_BL,f_exp_BL);
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
f = gauss_distribution(t, T_u, T_o);
VR_invention_timeline = cumsum(f);
figure, line(t(1:figure_cutoff),f(1:figure_cutoff),'LineWidth',2); xlabel('Time (years)'); ylabel('p\_Inv(t)'); title('Distribution of estimated year humanity invents VRs')
xlim([0 600])
% figure, line(t,VR_invention_timeline,'LineWidth',2); xlabel('Time (years)'); ylabel('FInv(t)'); xlim([0 500]); title('Cumulative distribution of year we invent VRs')
figure, area(t(1:figure_cutoff),VR_invention_timeline(1:figure_cutoff),'LineWidth',2); xlabel('Time (years)'); ylabel('F\_Inv(t)'); title('Cumulative distribution of estimated year humanity invents VRs')
xlim([0 600])
clear f


%% How much time one would choose to spend in an ancestor-simulation:
spend_VR_percentage = 0.8; % how much awake time the average person chooses to spend in VR. Should be a function that varies over time.
spend_human_VR_percentage = 0.0001; % how much VR time the average person chooses to spend in a human-type simulation. Should be a function that varies over time.
choice_of_individual = 0.01;
choice_of_individual = choice_of_individual/val;
percentage_of_awake_time_in_human_sim_indivdual = spend_VR_percentage * spend_human_VR_percentage * choice_of_individual;
% figure, line(t(1:figure_cutoff),percentage_of_awake_time_in_human_sim_indivdual(1:figure_cutoff),'LineWidth',2); xlabel('Time (years)'); ylabel('Pv(t)'); xlim([0 figure_cutoff]); title('Proportion of awake time spent in human-sim VRs, as a specific individual between WL and WH')


%% Integral
% close all
human_civ_VR_experience = total_exp_time .* VR_invention_timeline .* percentage_of_awake_time_in_human_sim_indivdual;
pre_civ_VR_not_VR_experience = (1-VR_invention_timeline(1:figure_cutoff)); %survival .*
[pre_civ_VR_not_VR_experience] = exp_time_adjust(pre_civ_VR_not_VR_experience,t_exp_BL,f_exp_BL);
try
pre_civ_VR_not_VR_experience(WH+1:end) = 0; catch; end
try
pre_civ_VR_not_VR_experience(1:WL-1) = 0; catch; end
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

p_in_VR = sum(human_civ_VR_experience)/(sum(pre_civ_VR_not_VR_experience(WL:WH))+sum(human_civ_VR_experience))


