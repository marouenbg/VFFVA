%%
function convertProblem(model,coupled,name);
%model  : COBRA model in Matlab format
%coupled: 0 not coupled
%         1 coupled
%name   : string name of model
if coupled
    Eind = find(model.csense=='E');
    %Less than
    A = model.A(Eind,:);
    Lind = find(model.csense=='L');
    %Treating the Greater than case
    Gind = find(model.csense=='G');
    Gineq = -model.A(Gind,:);
    bineq = -model.b(Gind);
    Aineq = [Gineq;model.A(Lind,:)];
    bineq = [bineq;model.b(Lind)];
    [Contain OK]=BuildMPS(Aineq, bineq, A, model.b(Eind), model.c, model.lb, model.ub, name);
    OK=SaveMPS([name '.mps'], Contain);
else
   [Contain OK]=BuildMPS([], [], model.S, model.b, model.c, model.lb, model.ub, name)
    OK=SaveMPS([name '.mps'], Contain); 
end





