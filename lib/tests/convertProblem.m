function convertProblem(model,coupled,name);
% converts a COBRA model to an MPS format. If the model is simple, then it uses the
% S matrix and b RHS, if the model is coupled it uses A first, if A is not
% available and C is available, it combines C and S to form A as in
% COBRATOOLBOX's buildLPproblemFromModel() function.
%
% INPUT:
%    model  : COBRA model in Matlab format
%    coupled: 0 not coupled (S matrix)
%             1 coupled (A matrix or S and C matrices)
%    name   : string name of model
%
% OUTPUT:
%    Model as an MPS file written in the same folder (.mps)
%
% .. Author:
%       - Marouen Ben Guebila

if coupled
    if isfield(model,'A')
        fprintf('Solving for Av <= b \n')
        Eind = find(model.csense=='E');
        %Less than
        Lind = find(model.csense=='L');
        %Treating the Greater than case
        Gind = find(model.csense=='G');
        Gineq = -model.A(Gind,:);
        bineq = -model.b(Gind);
        Aineqcomb = [Gineq;model.A(Lind,:)];
        bineqcomb = [bineq;model.b(Lind)];
        %Equality
        A = model.A(Eind,:);
        b = model.b(Eind);
        c = model.c;
    elseif isfield(model,'C') 
        fprintf('Solving for Cv <= d \n')
        Eind = find(model.csense=='E');
        %Less than
        Lind = find(model.dsense=='L');
        %Treating the Greater than case
        Gind = find(model.dsense=='G');
        Gineq = -model.C(Gind,:);
        bineq = -model.d(Gind);
        Aineqcomb = [Gineq;model.C(Lind,:)];
        bineqcomb = [bineq;model.d(Lind)];
        %Equality
        A = model.S(Eind,:);
        b = model.b(Eind);
        c = model.c;
    end
    [Contain OK]=BuildMPS(Aineqcomb, bineqcomb, A, b, c, model.lb, model.ub, name);
    if OK==1
        fprintf('build MPS OK\n')
    else
        fprintf('build MPS not OK\n')
    end
    OK=SaveMPS([name '.mps'], Contain);
    if OK==1
        fprintf('save MPS OK\n')
    else
        fprintf('save MPS not OK\n')
    end
else
    [Contain OK]=BuildMPS([], [], model.S, model.b, model.c, model.lb, model.ub, name)
    if OK==1
        fprintf('build MPS OK\n')
    else
        fprintf('build MPS not OK\n')
    end
    OK=SaveMPS([name '.mps'], Contain); 
    if OK==1
        fprintf('save MPS OK\n')
    else
        fprintf('save MPS not OK\n')
    end
end





