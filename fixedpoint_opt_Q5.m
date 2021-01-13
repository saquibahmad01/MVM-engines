% Open the system
model_name = 'Q5';
system_name1 = 'Subsystem';
system_name2 = 'Subsystem1';
system_name3 = 'Subsystem2';
system_name4 = 'Subsystem3';
MVM_Engine1 = [model_name '/' system_name1];
MVM_Engine2 = [model_name '/' system_name2];
MVM_Engine3 = [model_name '/' system_name3];
MVM_Engine4 = [model_name '/' system_name4];
open_system(model_name);

% Create an object to define constraints and tolerances to meet your design goals
opt = fxpOptimizationOptions('AllowableWordLengths', 8:48, 'UseParallel', false);

% define the stopping criterion in terms of the maximum number of
% iterations
opt.MaxIterations = 100;

% define an absolute tolerance at the output of the system to constrain 
% the differences between the original output values of the system 
% and that based on the optimized fixed-point data types.
tol = 1e-5;
addTolerance(opt, [model_name, '/Conv_Out1'], 1, 'RelTol', tol);
addTolerance(opt, [model_name, '/Conv_Out2'], 1, 'RelTol', tol);
addTolerance(opt, [model_name, '/Conv_Out3'], 1, 'RelTol', tol);
addTolerance(opt, [model_name, '/Conv_Out4'], 1, 'RelTol', tol);
% Use fxpopt function to run the optimization
result = fxpopt(model_name, MVM_Engine1, opt);
result1 = fxpopt(model_name, MVM_Engine2, opt);
result2 = fxpopt(model_name, MVM_Engine3, opt);
result3 = fxpopt(model_name, MVM_Engine4, opt);
% Launch Simulation Data Inspector
explore(result);
explore(result1);
explore(result2);
explore(result3);

