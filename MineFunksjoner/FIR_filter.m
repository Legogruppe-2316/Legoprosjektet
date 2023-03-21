function [FilteredValue] = FIR_filter(Measurements, M)
FilteredValue = (1/M) * sum(Measurements());
end