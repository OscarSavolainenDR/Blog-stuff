function [data_in] = exp_time_adjust(data_in,t_exp,f_exp)
    % Last edit: 27/06/2020; Oscar Savolainen.
    % This function multiplies the data coming in by the relevant experienced
    % time changes. E.g. if experienced time in VR speeds up by a factor of f_exp = 5
    % at time step t_exp = 500, then the incoming data, from time step 500 onwards, 
    % is multiplied by 5.
    data_in(t_exp:end) = data_in(t_exp:end) .* f_exp;
end

