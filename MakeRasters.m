function spikeRasters=MakeRasters(spikeData,pulses,preAlignWindow,postAlignWindow)
%% vargin 
% spikeData, structure with fields
% spikeTimes
% unitsIdx
% selectedUnits

% pulses, structure with fields
% times 
% samplingRate

%% get spike times and convert to binary array
for clusNum=1:size(spikeData.selectedUnits,1)
    %% convert to 1 millisecond bins and plot excerpt
    binSize=1;
    numBin=ceil((max(spikeData.spikeTimes(spikeData.unitsIdx==spikeData.selectedUnits(clusNum)))+1)/...
        (spikeData.samplingRate/1000)/binSize);
    
    [spikeCount,spikeTime]=histcounts(double(spikeData.spikeTimes(spikeData.unitsIdx==spikeData.selectedUnits(clusNum)))/...
        double(spikeData.samplingRate/1000), numBin);
    
    %     foo=spikeData.spikeTimes(spikeData.unitsIdx==spikeData.selectedUnits(clusNum))/30;
    %         figure; bar(spikeTime(1:6000),spikeCount(1:6000),'hist')
    
    
    %% spike density function
    spikeArray = zeros(1,ceil(max(spikeTime))+1);
    spikeArray(ceil(spikeTime(1:end-1)))=spikeCount;
    %     sigma=1;
    %     convSpikeTime = [zeros(1,sigma*3) fullgauss_filtconv(spikeArray,sigma,0)].*1000;
    %     hold on
    % plot([zeros(1,sigma*3) convSpikeTime zeros(1,sigma*3)])
    %     plot( convSpikeTime(1:6000-sigma*3))
    
    %% create rasters aligned to TTL
    %define parameters
%     preAlignWindow=20;
%     postAlignWindow=259;
    TTLtimes=uint32(pulses.times)/(pulses.samplingRate/1000);
    raster=nan(numel(pulses.times),preAlignWindow+postAlignWindow+1);
    for trialNum=1:numel(pulses.times)
        try
            raster(trialNum,:)=spikeArray(...
                TTLtimes(trialNum)-preAlignWindow:...
                TTLtimes(trialNum)+postAlignWindow);
            %smoothed:
            %             spikeRasters(trialNum,:)=convSpikeTime(...
            %                 TTLtimes(trialNum)-preAlignWindow:...
            %                 TTLtimes(trialNum)+postAlignWindow);
        catch
            continue
        end
    end
    spikeRasters{clusNum}=raster(~isnan(sum(raster,2)),:);
    %     figure; imagesc(raster)
end
