function [data_in] = exp_time_adjust(data_in,t_exp,f_exp)
% This function multiplies the data coming in by the relevant expeerienced
% time changes
    data_in(t_exp:end) = data_in(t_exp:end) .* f_exp;
end

