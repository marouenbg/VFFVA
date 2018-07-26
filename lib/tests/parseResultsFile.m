function [schedueletime,iterationstime]=parseResultsFile(scheduleList,n)
    if nargin <1
        scheduleList={'static','guided','dynamicC50'};
        n=16;
    end
    schedueletime=zeros(n,3);
    iterationstime=zeros(n,3);
    k=0;
    for scheduele=scheduleList
        k=k+1;
        fileID=fopen([scheduele{1} '.out']);
        C=fgets(fileID);
        while isempty(strfind(C,'Thread'))
            C=fgets(fileID);
        end
        j=0;
        while isempty(strfind(C,'FVA'))
            j=j+1;
            resStr = strsplit(C,{'did','iterations','in'})
            timeRes = str2double(resStr{4}(1:end-2))
            schedueletime(j,k)=timeRes;
            iterations = str2double(resStr{2})
            iterationstime(j,k)=iterations;
            C=fgets(fileID);
        end
        fclose(fileID);
    end
end