%% Define constants.
clc; clear; close all;

% Compressor
compressor_inlet_area = 0.5; % m^2
compressor_stages = 14;
compressor_total_pressure_ratio = 40;
compressor_interstage_pressure_ratio = (compressor_total_pressure_ratio)^(1/compressor_stages);
compressor_efficiency = 0.97;

% Combustor
calorific_value = 43360; % kJ/kg
combustor_fuel_mdot = @(fuelRate) (500 + 55*fuelRate)*(1/3600); % kg/s

% Turbine
turbine_stages = 4;
turbine_efficiency = 0.94;

% Nozzle
nozzle_exit_area = 0.3*compressor_inlet_area;
nozzle_efficiency = 0.92;

% Afterburner
afterburner_fuel_mdot = @(fuelRate) (-400 + 110*fuelRate)*(1/3600); % kg/s

% Miscellaneous
number_of_states = 20;
plane_velocity = 500/3; % m/s

% Create an array of all the states of the cycle.
states(1:number_of_states) = State;

%% Compute compressor values.

state(1).temperature = 245.95; % K
state(1).pressure = 44.034; % kPa
state(1).mass_flow_rate = (1225/12); % kg/s
interpolate_all_properties(state(1))
