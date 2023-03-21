function [derivative] = Derivation(prevValue, currentValue, timeStep)
%DERIVATION Summary of this function goes here
%   Detailed explanation goes here
derivative = (currentValue - prevValue)/timeStep;
end

