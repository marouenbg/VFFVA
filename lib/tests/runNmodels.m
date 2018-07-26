function runNmodels(model)
    cpxControl.PARALLELMODE = 1;
    cpxControl.THREADS = 1;
    cpxControl.AUXROOTTHREADS = 2;
    resMat = zeros(3,5);
    cores=[2 4 8 16 32];
    for i=1:length(cores);
        fprintf('running on %d cores\n',cores(i));
        for j=1:3
            parpool(cores(i));
            tic;[a,b]=fastFVA(model,90,'max','cplex',[],'S',cpxControl);
            minMax=[a b];
            save('MinMaxFFVA.mat','minMax');c=toc;
            resMat(j,i)=c;
            delete(gcp('nocreate'))
        end
    end
    fprintf('Analysis results\n')
    for i=1:length(cores)
        fprintf('%d %f %f\n',cores(i),mean(resMat(:,i)),std(resMat(:,i)));
    end
end