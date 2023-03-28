function [derivative] = Derivation(prevValue, currentValue, timeStep)
% Funskjonen tar in tre integre prevValue, currentValue og timeStep og
% generer den derivertet ved bruk av numerisk derivasjon
derivative = (currentValue - prevValue)/timeStep;
end

