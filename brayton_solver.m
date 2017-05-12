%% Define constants.
clc; clear; close all;

% Compressor constants.
compressor_inlet_area = 0.5; % m^2
compressor_stages = 14;
compressor_total_pressure_ratio = 40;
compressor_interstage_pressure_ratio = (compressor_total_pressure_ratio)^(1/compressor_stages);
compressor_efficiency = 0.97;

% Combustor constants.
calorific_value = 43360; % kJ/kg
combustor_fuel_mdot = @(fuelRate) (500 + 55*fuelRate)*(1/3600); % kg/s

% Turbine constants.
turbine_stages = 4;
turbine_efficiency = 0.94;

% Nozzle constants.
nozzle_exit_area = 0.3*compressor_inlet_area;
nozzle_efficiency = 0.92;

% Afterburner constants.
afterburner_fuel_mdot = @(fuelRate) (-400 + 110*fuelRate)*(1/3600); % kg/s

% Miscellaneous constants.
number_of_states = 20;
plane_velocity = 500/3; % m/s
altitude = NaN; % m

% Create an array of handle objects for all the states of the cycle.
state(number_of_states,1) = State;

%% Compute compressor values.

% Define State 1 values.
state(1).temperature = 245.95; % K
state(1).pressure = 44.034; % kPa
state(1).find_thermodynamic_properties(state(1).temperature, 'T');
state(1).massFlowRate = state(1).density*compressor_inlet_area*plane_velocity; % kg/s


% State at state 2 and iterate through the stages of the compressor.
for i = 2:(compressor_stages+1)

    % First, go through the current stage isentropically.
    
    % Use Pr2 = Pr1(P2/P1) and interpolateAir to find isentropic values.
    pressureIsentropic = (state(i-1).pressure)*(compressor_interstage_pressure_ratio);
    relativePressureIsentropic = (state(i-1).relativePressure)*(compressor_interstage_pressure_ratio);
    isentropicProperties = interpolateAir(relativePressureIsentropic, 'pr');
   
    % Then, use efficiency to calculate properties at real state.
    state(i).massFlowRate = state(1).massFlowRate;
    state(i).pressure = pressureIsentropic;
    state(i).enthalpy = compressor_efficiency*(isentropicProperties.h - state(i-1).enthalpy) + state(i-1).enthalpy;
    find_thermodynamic_properties(state(i), state(i).enthalpy, 'h');
end

%% Compute combustor values.

% Perform a mass balance on the combustor.
state(16).massFlowRate = state(1).massFlowRate + combustor_fuel_mdot(state(1).massFlowRate);

% Pressure stays constant through combustor.
state(16).pressure = state(15).pressure;

% Compute the rate of heat transfer coming into the combustor.
qDotIn = calorific_value*combustor_fuel_mdot(state(15).massFlowRate);

% Find enthalpy after combustor using energy balance (1st law of thermo).
state(16).enthalpy = (state(15).massFlowRate*state(15).enthalpy + qDotIn)/(state(16).massFlowRate);

% Interpolate all other thermodynamic values at this state.
find_thermodynamic_properties(state(16), state(16).enthalpy, 'h');

%% Compute turbine values.

% First, calculate a few variables in order to solve the turbine.

% The backwork ratio of a turbine is 1, so find the values after turbine.
state(20).enthalpy = state(16).enthalpy - (state(15).enthalpy - state(1).enthalpy);
find_thermodynamic_properties(state(20), state(20).enthalpy, 'h');

% Find the pressure ratio across the turbine using P2 = P1(Pr2/Pr1).
state(20).pressure = state(16).pressure*(state(20).relativePressure/state(16).relativePressure);
turbinePressureRatio = state(20).pressure/state(16).pressure;
turbineInterstagePressureRatio = (turbinePressureRatio)^(1/turbine_stages);

% Start at state 17 and iterate through the turbine stages.
for i = 17:(16+compressor_stages)
    % First, go through the current stage isentropically.
    pressureIsentropic = state(i-1).pressure*turbineInterstagePressureRatio;
    relativePressureIsentropic = state(i-1).relativePressure*turbineInterstagePressureRatio;
    isentropicProperties = interpolateAir(relativePressureIsentropic, 'pr');
    
    % Then, find the values at the 'real' stage using efficiency.
    state(i).pressure = pressureIsentropic;
    state(i).enthalpy = state(i-1).enthalpy - (turbine_efficiency)*(state(i-1).enthalpy - isentropicProperties.h);
    find_thermodynamic_properties(state(i), state(i).enthalpy, 'h');
end
