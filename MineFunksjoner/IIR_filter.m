function[FilteredValue] = IIR_filter(OldFilteredValue, Measurement, alfa)
FilteredValue= (1-alfa) * OldFilteredValue + (alfa * Measurement);
end