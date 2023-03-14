%% EulerForward(IntValueOld, FunctionValue, TimeStep)
% IntValueOld = initialvalue of integral, or the previous integral value
% (k-1)
% FunctionValue = value of the function to be integrated at (k-1) 
% TimeStep = the current value of delta t

function [IntValueNew] =EulerForward(IntValueOld, FunctionValue, TimeStep)
    IntValueNew = IntValueOld + TimeStep * FunctionValue;
end