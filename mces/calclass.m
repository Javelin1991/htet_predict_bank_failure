function [crate] = calclass(output,y)

class = sign(output');
result = (y == class);
crate = sum(result);