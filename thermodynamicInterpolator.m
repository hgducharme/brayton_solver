function [ temperature, enthalpy, internalEnergy, entropy, relativePressure, relativeSpecificVolume ] = thermodynamicInterpolator( temperature )
%THERMODYNAMIC_INTERPOLATE Interpolates thermodynamic properties of air.
%  thermodynamic_interpolate uses Table A-22 (Ideal Gas Properties of Air)
%  from the textbook: Fundamentals of Engineering Thermodynamics (2006) by
%  Moran and Sharpio.
%  Inputs: temperature; the known temperature of the air in Kelvin.
%  Outputs: temperature            [K]
%           enthalpy               [KJ/Kg]
%           internalEnergy         [KJ/Kg]
%           entropy                [KJ/Kg*K]
%           relativePressure
%           relativeSpecificVolume

%% Prepare for interpolation.
% Load Table A-22 as a .csv file, get rid of the headers.
thermodynamicProperties = csvread('air_thermodynamic_properties.csv', 2, 0);
numberOfProperties = size(thermodynamicProperties,2);
temperatureColumn = thermodynamicProperties(:, 1);

% Make sure the input temperature is in the range of the tables.
minTemperature = min(temperatureColumn);
maxTemperature = max(temperatureColumn);
if (temperature < minTemperature) || (temperature > maxTemperature)
    error('Temperature must be a value between %d K and %d K.', minTemperature, maxTemperature);
end

% Define the output array.
output = zeros(1, numberOfProperties);
output(1,1) = temperature;

%% Find the location of given temperature on Table A-22.

% Find the temperature in the data closest to given temeprature.
[~,index] = min(abs(temperatureColumn-temperature));
closestTemperature = temperatureColumn(index);

% Define interval where interpolation is going to take place.
lowTemperature = 0;
highTemperature = 0;
lowIndex = 0;
highIndex = 0;

% Is the closest temperature above or below given temperature?
if temperature > closestTemperature
    lowTemperature = closestTemperature;
    highTemperature = temperatureColumn(index+1);

    lowIndex = index;
    highIndex = index + 1;
elseif temperature < closestTemperature
    lowTemperature = temperatureColumn(index-1);
    highTemperature = closestTemperature;

    lowIndex = index + 1;
    highIndex = index;
    
% If the temperature given is equal to a temperature on the table, don't
% interpolate.
elseif temperature == closestTemperature
    temperature = thermodynamicProperties(index,1);
    enthalpy = thermodynamicProperties(index,2);
    internalEnergy = thermodynamicProperties(index,3);
    entropy = thermodynamicProperties(index,4);
    relativePressure = thermodynamicProperties(index,5);
    relativeSpecificVolume = thermodynamicProperties(index,6);
    return
else
    error('Something went wrong finding the interpolation interval');
end

%% Perform interpolation: ((dy)/(dx))*(x - x0) + y0
for property = 2:numberOfProperties

    % Get the current property's column of data.
    propertyColumn = thermodynamicProperties(:, property);

    % Find y0 and y1.
    lowPropertyValue = propertyColumn(lowIndex);
    highPropertyValue = propertyColumn(highIndex);

    % Find delta y and delta x.
    changeInProperty = highPropertyValue - lowPropertyValue;
    changeInTemperature = highTemperature - lowTemperature;

    % Use interpolation formula.
    interpolatedValue = (changeInProperty/changeInTemperature)*(temperature - lowTemperature) + lowPropertyValue;
    output(1, property) = interpolatedValue;
end
 

%% Output values.

temperature = output(1);
enthalpy = output(2);
internalEnergy = output(3);
entropy = output(4);
relativePressure = output(5);
relativeSpecificVolume = output(6);

end