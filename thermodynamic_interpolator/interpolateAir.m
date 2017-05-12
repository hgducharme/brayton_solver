function airValues = interpolateAir( value, flag )
%INTERPOLATE_AIR Interpolates thermodynamic properties of air.
%  air_interpolate uses Table A-22 (Ideal Gas Properties of Air)
%  from the textbook: Fundamentals of Engineering Thermodynamics (2006) by
%  Moran and Sharpio.
%  Inputs: value - a known property value of air in SI units.
%          flag - specifies the property that is known. (e.g. enthalpy,
%          entropy, etc.);
%  Outputs: A stucture containing all other air property values at the
%  given state:
%  T  - temperature             [K]
%  h  - enthalpy                [KJ/Kg]
%  u  - internal energy         [KJ/Kg]
%  s  - entropy                 [KJ/Kg*K]
%  pr - relative pressure
%  vr - relative specific volume
%
%  The output variables are also the various flag options. To specify that
%  the known property value is relative pressure, the flag should be 'pr'.
%  Likewise, to specify the known property value is entropy, the flag
%  should be 's'.

%% Prepare for interpolation - Error check inputs and load the data.
% Load Table A-22 as a .csv file, get rid of the headers, list flag
% options.
airProperties = csvread('air_thermodynamic_properties.csv', 2, 0);
numberOfProperties = size(airProperties,2);

% Get the data column for each property.
temperatureColumn = airProperties(:,1);
enthalpyColumn = airProperties(:,2);
internalEnergyColumn = airProperties(:,3);
entropyColumn = airProperties(:,4);
relativePressureColumn = airProperties(:,5);
relativeVolumeColumn = airProperties(:,6);

% Initalize the air values struct and the data column that is given.
airValues = struct('T' , NaN, 'h', NaN, 'u', NaN, 's', NaN, 'pr', NaN, 'vr', NaN);

% Make sure the flag given is valid.
if isfield(airValues, flag) == 0
    error('Invalid flag specified.');
end

% Find the data column for the given flag.
switch lower(flag)
    case 't'
        flagColumn = temperatureColumn;
    case 'h'
        flagColumn = enthalpyColumn;
    case 'u'
        flagColumn = internalEnergyColumn;
    case 's'
        flagColumn = entropyColumn;
    case 'pr'
        flagColumn = relativePressureColumn;
    case 'vr'
        flagColumn = relativeVolumeColumn;
    otherwise
        error('Something went wrong.');
end

% Check if the input value is in within the range of the property tables.
minFlagValue = min(flagColumn);
maxFlagValue = max(flagColumn);
if (value < minFlagValue) || (value > maxFlagValue)
    switch lower(flag)
        case 't'
            error('Temperature must be a value between %d K and %d K.', minFlagValue, maxFlagValue);
        case 'h'
            error('Enthalpy must be a value between %d [kJ/kg] and %d [kJ/kg].', minFlagValue, maxFlagValue);
        case 'u'
            error('Internal energy must be a value between %d [kJ/kg] and %d [kJ/kg].', minFlagValue, maxFlagValue);
        case 's'
            error('Entropy must be a value between %d [kJ/kg*K] and %d [kJ/kg*K].', minFlagValue, maxFlagValue);
        case 'pr'
            error('Relative pressure must be a value between %d and %d.', minFlagValue, maxFlagValue);
        case 'vr'
            error('Relative specific volume must be a value between %d and %d.', minFlagValue, maxFlagValue);
        otherwise
            error('Something went wrong while trying to throw an error.');
    end
end

airValues.(flag) = value;

%% Find the location of the given value in Table A-22.

% Find the value in the data closest to given value.
[~,index] = min(abs(flagColumn-value));
closestValue = flagColumn(index);

% Define interval where interpolation is going to take place.
lowValue = 0;
highValue = 0;
lowIndex = 0;
highIndex = 0;

% Is the closest temperature above or below given temperature?
if value > closestValue
    lowValue = closestValue;
    highValue = flagColumn(index+1);

    lowIndex = index;
    highIndex = index + 1;
elseif value < closestValue
    lowValue = flagColumn(index-1);
    highValue = closestValue;

    lowIndex = index + 1;
    highIndex = index;
    
% If the value given is equal to a value on the table, don't
% interpolate.
elseif value == closestValue
    airValues.T = airProperties(index,1);
    airValues.h = airProperties(index,2);
    airValues.u = airProperties(index,3);
    airValues.s = airProperties(index,4);
    airValues.pr = airProperties(index,5);
    airValues.vr = airProperties(index,6);
    return
else
    error('Something went wrong finding the interpolation interval');
end

%% Perform interpolation: ((dy)/(dx))*(x - x0) + y0

%
airValueFields = fieldnames(airValues);

for iterProperty = 1:numberOfProperties

    % Get the current property's column of data.
    iterPropertyColumn = airProperties(:, iterProperty);
    if iterPropertyColumn == flagColumn
        continue
    end

    % Find y0 and y1.
    iterLowPropValue = iterPropertyColumn(lowIndex);
    iterHighPropValue = iterPropertyColumn(highIndex);

    % Find delta y and delta x.
    changeInIterProperty = iterHighPropValue - iterLowPropValue;
    changeInKnownProperty = highValue - lowValue;

    % Use interpolation formula.
    interpolatedValue = (changeInIterProperty/changeInKnownProperty)*(value - lowValue) + iterLowPropValue;
    airValues.(airValueFields{iterProperty}) = interpolatedValue;
end

end