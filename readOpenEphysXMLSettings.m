function recSettings = readOpenEphysXMLSettings(fname)

readXMLSettings=parseXML(fname);
readXMLSettings=readXMLSettings.Children(~cellfun(@(fieldNames) ...
    contains(fieldNames,'#text'), {readXMLSettings.Children.Name})); %remove fluff

for fieldNum=1:numel(readXMLSettings)
    if ~isempty(readXMLSettings(fieldNum).Attributes)
        recSettings.(lower(readXMLSettings(fieldNum).Name))=readXMLSettings(fieldNum).Attributes;
    else
        keepFields=~cellfun(@(fieldNames) contains(fieldNames,'#text'),...
            {readXMLSettings(fieldNum).Children.Name});
        switch readXMLSettings(fieldNum).Name
            case 'INFO'
                recSettings.setupInfo=struct;
                for subFieldNum=find(keepFields)
                    recSettings.setupinfo.(lower(readXMLSettings(fieldNum).Children(subFieldNum).Name))=...
                        readXMLSettings(fieldNum).Children(subFieldNum).Children.Data;
                end
            case 'SIGNALCHAIN'
                sourceTypeNameIdx=contains(...
                    {readXMLSettings(fieldNum).Children(2).Attributes.Name},'libraryName');
                sourceType=readXMLSettings(...
                    fieldNum).Children(2).Attributes(sourceTypeNameIdx).Value;
                switch sourceType
                    case 'Rhythm FPGA'
                        recSettings.signals=struct;
                        % then dive in Processors
                        for subFieldNum=find(keepFields)
                            if isempty(readXMLSettings(fieldNum).Children(subFieldNum).Children)
                                pluginTypeNameIdx=contains(...
                                    {readXMLSettings(fieldNum).Children(subFieldNum).Attributes.Name},'pluginName');
                                pluginType=readXMLSettings(...
                                    fieldNum).Children(subFieldNum).Attributes(pluginTypeNameIdx).Value;
                                pluginType(isspace(pluginType)) = [];
                                %                                 recSettings.signals.(pluginType)=struct;
                                
                                switch pluginType
                                    case 'RhythmFPGA'
                                        recSettings.signals.channelInfo=struct;
                                        channelInfo=...
                                            readXMLSettings(fieldNum).Children(...
                                            subFieldNum).Children(2).Children;
                                        channelIdx=~cellfun(@(fieldNames) contains(fieldNames,'#text'),{channelInfo.Name});
                                        channelInfo=[channelInfo(channelIdx).Attributes];
                                        channelNumber={channelInfo(contains({channelInfo.Name},'number')).Value}';
                                        channelName={channelInfo(contains({channelInfo.Name},'name')).Value}';
                                        channelGain={channelInfo(contains({channelInfo.Name},'gain')).Value}';
                                        recSettings.signals.channelInfo=table(channelNumber,channelName,channelGain);
                                    case 'ChannelMap' %TBD
                                        recSettings.signals.channelMap=struct;
                                        %                                     case % add more if needed
                                end
                            end
                        end
                end
        end
    end
end
    
    