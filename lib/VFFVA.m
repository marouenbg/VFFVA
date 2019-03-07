function [minFlux,maxFlux]=VFFVA(nCores,nThreads,model,scaling,memAff,schedule,nChunk)

%Optional:
%scaling: 0(default) -1 or 1
%memAff: none(default) / socket / core
%model is complete path to model in .mps (offer to convert model from .mat)

if nargin<4
    scaling = 0;
end
if nargin<5
    memAff = 'none';
end
if nargin<6
   schedule='dynamic'; 
end
if nargin<7
    nChunk=50
end

system(['export OMP_SCHEDUELE=' schedule num2str(nChunk)])
system(['mpirun -np' num2str(nCores) '--bind-to ' num2str(memAff) '-x OMP_NUM_THREADS=' num2str(nThreads)...
    './veryfastFVA ' model num2str(scaling)]);

end