clc;
clear;

load Lateral_Systems;
load Longitudinal_Systems;

T1 = htet_tabulate_lateral_result(SYSTEMS);
T2 = htet_tabulate_longitudinal_result(LONGITUDINAL_SYSTEMS);
