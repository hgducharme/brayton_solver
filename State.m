classdef State < handle
    properties
        % Properties that can not be interpolated.
        pressure     % kPa
        massFlowRate % kg/s
        density      % kg/m^3
        
        % Properties that can be interpolated.
        temperature            % K
        enthalpy               % kJ/kg
        internalEnergy         % kJ/kg
        entropy                % kJ/kg*K
        relativePressure
        relativeSpecificVolume 
    end
    
    methods
         function S = State
%             S.temperature = temperature;
%             if nargin > 0
%                 switch lower(flag)
%                     case 't'
%                         S.temperature = knownValue;
%                     case 'h'
%                         S.enthalpy = knownValue;
%                     case 'u'
%                         S.internalEnergy = knownValue;
%                     case 's'
%                         S.entropy = knownValue;
%                     case 'pr'
%                         S.relativePressure = knownValue;
%                     case 'vr'
%                         S.relativeSpecificVolume = knownValue;
%                     otherwise
%                         error('Please input a known thermodynamic property value and its respective flag');
%                 end
%             end
         end
        
        % Input a State property and set all other available properties.
        function find_thermodynamic_properties(S, knownValue, flag)
            properties = interpolateAir(knownValue, flag);
            S.temperature = properties.T;
            S.enthalpy = properties.h;
            S.internalEnergy = properties.u;
            S.entropy = properties.s;
            S.relativePressure = properties.pr;
            S.relativeSpecificVolume = properties.vr;
            
            % Ideal gas law: rho = P/RT
            S.density = (S.pressure*1000*28.97)/(8314*S.temperature);
        end    
    end
end