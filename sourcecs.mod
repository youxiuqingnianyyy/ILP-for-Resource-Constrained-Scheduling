# --- Parameters: defaults can be overwritten with .dat file

set Operations    ordered;
set Resources;

param Delay {Operations,Resources} integer >= 0 default 1;
param Before {Operations, Operations} binary default 0;
# Resource type: CPU ASIC FPGA
param alpha {Resources} integer >= 0 default 1;
# Resources each operation need
param E_r {Operations,Resources} binary default 1;
param MaxTime integer >= 0 default 1;

# --- Variable: Tscheduled[op] is time at which op starts

var Tscheduled {op in Operations} integer >= 0;
# Sigma is 1 if operation v starts at time t(0..MaxTime), 0 otherwise;
var sigma {Operations, 0..MaxTime} binary;

var beta {Operations, Resources} binary default 0;
var MaxLatency integer >= 0;
# --- Optimization goal

minimize Latency: MaxLatency;

# No good since nonlinear:   
# max {op in Operations} (Tscheduled[op] + Delay[op]);
# use constraint ComputeLatency instead!
# --- Constraints

# if beta = 1 then
subject to ComputeLatency {op in Operations, r in Resources}:
   beta[op,r] = 1 ==> MaxLatency >= Tscheduled[op] + Delay[op,r];

subject to Feasibility {o1 in Operations, o2 in Operations, r in Resources
                        : Before[o1,o2] }:
   beta[o1,r] = 1 ==>Tscheduled[o1] + Delay[o1,r] <= Tscheduled[o2];

subject to SigmaTauRelation {v in Operations}:
   sum{t in 0..MaxTime} t * sigma[v,t] = Tscheduled[v];

subject to ScheduleEachOperationOnce {v in Operations}:
   sum{t in 0..MaxTime} sigma[v,t] = 1;

#A resource can only be used by one operations 
subject to BoundtoOnlyOneResource {v in Operations}:
   sum{r in Resources} beta[v,r] * E_r[v,r] = 1;
   
subject to ResourceConstraint {r in Resources, t in 0..MaxTime}:
   sum{v in Operations, p in 0..Delay[v,r]-1:E_r[v,r]} (if t-p >=0 then sigma[v,t-p] * beta[v,r]) <= alpha[r];


























