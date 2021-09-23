function [out] = f_variable_distribution_calculation(year_current, l_break_years, l_segments)
    
variable = 0;
for count_break = 1:length(l_break_years)
    if year_current < l_break_years(count_break)
        local_segment = l_segments(count_break, :);
        variable = local_segment(1) * year_current + local_segment(2);
    end
end
if variable == 0
    local_segment = l_segments(length(l_break_years) + 1, :);
    variable = local_segment(1) * year_current + local_segment(2);
end

out = variable;
end