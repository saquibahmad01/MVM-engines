%% First Section
clear;
dimension = 64;
input_sample_freq = 1e6; % Input Sampling Frequency is 1 MHz
sample_time = 1 / input_sample_freq; % 1us

time = [0:dimension-1] * sample_time;
A = double(rand(dimension,dimension));
x = double(rand(dimension,1));


xt.time = time;
xt.signals.values = x;
xt.signals.dimensions = 1;

for i = 1:dimension
   At(i).time = time;
   At(i).signals.values = A(i,:)';
   At(i).signals.dimensions = 1;
end

y_matlab = A*x;

%% Configure simulation time based on the architectural parameters 
interleaving_factor = 16; % enter the interleaving factor 

feedforward_latency = 16; % enter the feedforward latency of your design

iteration_bound = dimension; % enter the iteration bound of the algorithm (number of accumulations needed)

system_latency = 1 + (iteration_bound*16); % caculate the system latency of your design based on the loop latency, iteration bound, and feedforward latency

simulation_stop_time = sample_time * (dimension + feedforward_latency/interleaving_factor);


%% Configure Simulink models
% %List all the % parameters of a block
load_system('Q5/From Workspace');
list = get_param('Q5/From Workspace','ObjectParameters')

% Set the value of a parameter in a block
BlockName = 'Q5';
set_param([BlockName '/From Workspace'],'VariableName','At(1)')
set_param([BlockName '/To Workspace'],'VariableName','yt1')
set_param([BlockName '/To Workspace'],'SaveFormat',['Structure With Time'])
for i=1:(dimension-1)
    set_param([BlockName '/From Workspace' num2str(i)],'VariableName',['At(' num2str(i+1) ')'])
    set_param([BlockName '/To Workspace' num2str(i)],'VariableName',['yt' num2str(i+1)])
    set_param([BlockName '/To Workspace' num2str(i)],'SaveFormat',['Structure With Time'])
end
set_param([BlockName '/From Workspace64'],'VariableName','xt')

%% Verify the results 
% index = system_latency +1;
index = system_latency+1;

y_simulink = zeros(1,dimension);

for i = 1:dimension
   varname = strcat('yt',num2str(i));
   mydata(:,i) = out.get(varname).signals.values;
end

for i = 1:interleaving_factor:dimension
    for j = 0: (interleaving_factor-1)
        y_simulink(i+j) = mydata(index+j, i+j);
    end
end


y_simulink = y_simulink';

MSE = norm(y_matlab-y_simulink)^2/norm(y_matlab)^2
