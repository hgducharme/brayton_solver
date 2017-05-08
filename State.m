classdef State
    properties
        temperature
        pressure
        enthalpy
        internalEnergy
        entropy
        relativePressure
        relativeSpecificVolume
        mass_flow_rate
    end
    methods
        function S = State(temperature)
            S.temperature = temperature;
        end
        
        function interpolate_all_properties(S)
            [T, h, u, s, pr, vr] = thermodynamicInterpolator(S.temperature);
            S.temperature = T;
            S.enthalpy = h;
            S.internalEnergy = u;
            S.entropy = s;
            S.relativePressure = pr;
            S.relativeSpecificVolume = vr;
        end    
    end
end