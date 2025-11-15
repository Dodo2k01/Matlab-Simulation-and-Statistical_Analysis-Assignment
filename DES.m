% DES
 % Discrete event simulation

 % Optional inputs
 %      ND  number of productions
 %      MI  maintenance interval in minutes
 %      MT  maintenance time in minutes
 %      POB payout boundary in minutes
 %      POF payout fast
 %      POS payout slow
 %      CH  costs per hour
 % 
 % Outputs
 %      avgWaitingTime  The average waiting time of customers in the queue (so arrival to finish)
 %      avgQueueLength  The average queue length 
 %      profit          The profit
function [avgWaitingTime, avgQueueLength, profit] = DES(ND, MI, MT, POB, POF, POS, CH)
        % Initialize DES
    if((nargin<1)|isempty(ND))
        ND=50000; % default number of productions
    end
    if((nargin<2)|isempty(MI))
        MI = 200 * 60; % maintenance interval in minutes
    end
    if((nargin<3)|isempty(MT))
        MT = 20 * 60; % maintenance time in minutes
    end
    if((nargin<4)|isempty(POB))
        POB = 24 * 60; % payout boundary in minutes
    end
    if((nargin<5)|isempty(POF))
        POF = 25; % payout fast
    end
    if((nargin<6)|isempty(POS))
        POS = 10; % payout slow
    end
    if((nargin<7)|isempty(CH))
        CH = 1000; % costs per hour
    end
    nMachines = 3;

    %machine states and stats
    machineStatuses = zeros(1, nMachines);
    machineCurrentProductId = zeros(1, nMachines);
    queueRemainingServiceTimes = [inf, inf, inf];
    nQueue = 0;

    %productId is the key to all the HashMaps
    Arrivals = containers.Map('KeyType', 'double', 'ValueType', 'double');
    Departures = containers.Map('KeyType', 'double', 'ValueType', 'double');
    queueProductIDs = [];
    startIdx = 1; %for the queue
    endIdx = 0; %for the queue
    queueServiceTimes = containers.Map('KeyType', 'double', 'ValueType', 'double');

    %next event time trackers
    globalClock = 0;
    tDepartureEvent = [inf, inf, inf];
    tMaintenanceJob = [MI, MI, MI]; % start or end time of the next maintanance job
    tIdle = zeros(1, nMachines);
    
    %statistical counters
    numServed=0;
    areaQueue=0;
    areaBusy=0;
    iter = 0;

    %special case when product is taken out from a machine for maintenance
    isTaken = false;

    %set up before the loop
    tArrivalEvent = arrival();
    productId = 0;

    while numServed < ND
        prevTime = globalClock;
        %determine next event
        if(isTaken == true)
            tArrivalEvent = globalClock;
        end
        [tDepartureEvent_min, machineDeparture] = min(tDepartureEvent);
        [tMaintenanceJob_min, machineMaintenance] = min(tMaintenanceJob);
        [tNext, idx] = min([tArrivalEvent, tDepartureEvent_min, tMaintenanceJob_min]);
        globalClock = tNext;
        % fprintf('Time is: %.3f\n', globalClock);
        deltaT = globalClock - prevTime;
        %updating waiting time 
        areaQueue = areaQueue + deltaT * nQueue;
        %updating total busy time and machine busy time and remaining t for products 
        for i = 1:nMachines
            if machineStatuses(i) == 1
                areaBusy = areaBusy + deltaT;
            elseif machineStatuses(i) == 0
                tIdle(i) = tIdle(i) + deltaT;
            end
            if queueRemainingServiceTimes(i)~=inf %this one is just for the case when a product stops being served when a machine goes into maintenance
                queueRemainingServiceTimes(i) = queueRemainingServiceTimes(i) - deltaT;
            end
        end
        %arrival case
        if idx == 1
            %new product being created
            if isTaken == false
                productId = productId + 1;
                Arrivals(productId) = globalClock;
                if Departures.isKey(productId)
                    error('Product %d already departed at %.3f but trying to arrive at %.3f', productId, Departures(productId), globalClock);
                end
                queueServiceTimes(productId) = service();
                endIdx = endIdx + 1;
                queueProductIDs(endIdx) = productId;
                nQueue = nQueue + 1;
                fprintf('New arrival at the queue!\n')
            else
                isTaken = false;
            end

            if any(machineStatuses == 0) && startIdx <= endIdx
                [~, idleMachine] = max(tIdle);
                tIdle(idleMachine) = 0;
                machineStatuses(idleMachine) = 1;
                firstItem = queueProductIDs(startIdx);
                startIdx = startIdx + 1;
                tDepartureEvent(idleMachine) = globalClock + queueServiceTimes(firstItem);
                machineCurrentProductId(idleMachine) = firstItem;
                queueRemainingServiceTimes(idleMachine) = queueServiceTimes(firstItem);
                nQueue = nQueue - 1;
            end
            tArrivalEvent = globalClock + arrival();
        end

        %departure case
        if idx == 2
            departingProductId = machineCurrentProductId(machineDeparture);
            if departingProductId == 0
                error('Machine %d has no product but triggered departure event at t=%.3f', machineDeparture, globalClock);
            end
            tDepartureEvent(machineDeparture) = inf;
            Departures(departingProductId) = globalClock;
            numServed = numServed + 1;
            machineStatuses(machineDeparture) = 0;
            machineCurrentProductId(machineDeparture) = 0;
            queueRemainingServiceTimes(machineDeparture) = inf;
            fprintf('Item Id: %d departed from machine number: %d at time %.3f\n', departingProductId, machineDeparture, globalClock);
            
            if endIdx>=startIdx
                [~, idleMachine] = max(tIdle);
                tIdle(idleMachine) = 0;
                machineStatuses(idleMachine) = 1;
                firstItem = queueProductIDs(startIdx);
                startIdx = startIdx + 1;
                tDepartureEvent(idleMachine) = globalClock + queueServiceTimes(firstItem);
                machineCurrentProductId(idleMachine) = firstItem;
                queueRemainingServiceTimes(idleMachine) = queueServiceTimes(firstItem);
                nQueue = nQueue - 1;
            end
        end


        %maintenance event
        if idx == 3
            %case when machine finishes being serviced
            if machineStatuses(machineMaintenance) == 2
                fprintf('Machine %d ended being serviced at t = %.3f\n', machineMaintenance, globalClock);
                machineStatuses(machineMaintenance) = 0;
                tMaintenanceJob(machineMaintenance) = globalClock + MI;
                
                if endIdx >= startIdx
                    [~, idleMachine] = max(tIdle);
                    tIdle(idleMachine) = 0;
                    machineStatuses(idleMachine) = 1;
                    firstItem = queueProductIDs(startIdx);
                    startIdx = startIdx + 1;
                    nQueue = nQueue - 1;
                    tDepartureEvent(idleMachine) = globalClock + queueServiceTimes(firstItem);
                    machineCurrentProductId(idleMachine) = firstItem;
                    queueRemainingServiceTimes(idleMachine) = queueServiceTimes(firstItem);
                end
            else % machine status must be == 1
                fprintf('Machine %d started being serviced at t = %.3f\n', machineMaintenance, globalClock);
                pid = machineCurrentProductId(machineMaintenance);
                remServiceTime = queueRemainingServiceTimes(machineMaintenance);
                
                %product back at front of queue
                for i = endIdx:-1:startIdx
                    queueProductIDs(i+1) = queueProductIDs(i);
                end
                queueProductIDs(startIdx) = pid;
                endIdx = endIdx + 1;
                nQueue = nQueue + 1;
                queueServiceTimes(pid) = remServiceTime;
                
                % reset machine state
                machineCurrentProductId(machineMaintenance) = 0;
                tDepartureEvent(machineMaintenance) = inf;
                machineStatuses(machineMaintenance) = 2;
                tMaintenanceJob(machineMaintenance) = globalClock + MT;
            end
        end

        fprintf('Current n queue: %d\n', nQueue);
        % fprintf('Current iter: %d\n', iter);
    end
    keysDepartures = Departures.keys;
    totalWaitingTime = 0;
    for i = 1:numel(keysDepartures)
        k = keysDepartures{i};
        if Arrivals.isKey(k) && Departures.isKey(k)
            fprintf('DepartureTime = %.3f and ArrivalTime = %.3f\n', Departures(k), Arrivals(k));
            totalWaitingTime = totalWaitingTime + (Departures(k) - Arrivals(k));
        else
            fprintf('Missing key for productId %d\n', k);
        end
    end
    avgWaitingTime = totalWaitingTime / numel(keysDepartures);
    avgQueueLength = areaQueue / globalClock;
    profit = 0;
    for i = 1:numel(keysDepartures)
        k = keysDepartures{i};
        if Arrivals.isKey(k) && Departures.isKey(k)
            waitingTime = Departures(k) - Arrivals(k);
            if waitingTime <= POB
                profit = profit + POF;
            else
                profit = profit + POS;
            end
        else
            fprintf('Missing key for productId %d\n', k);
        end

    end
    profit = profit - (CH * areaBusy / 60);
    fprintf('Global Clock: %.3f', globalClock);
end