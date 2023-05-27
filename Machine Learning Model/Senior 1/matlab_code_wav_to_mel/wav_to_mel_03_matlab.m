path = 'C:\Users\Ayah Abdel-Ghani\Desktop\Coughing Dataset\researchersilenceremoveddataset\coughvid-clean-silence-removed\wavs-silence-removed-NO-JSON\';
destination='C:\Users\Ayah Abdel-Ghani\Desktop\Coughing Dataset\researchersilenceremoveddataset\coughvid-clean-silence-removed\Matlab_generated_mels\';
files = dir(path);
for fileIndex=1:length(files)
    if (files(fileIndex).isdir == 0)
        if (~isempty(strfind(files(fileIndex).name,'wav')))
            disp(fileIndex);
            fullfile(path,files(fileIndex).name)
            str = files(fileIndex).name;
            newName = regexprep(str,'.wav','');
            [data,fs] = wavread(fullfile(path,files(fileIndex).name));
            window=hamming(512);
            noverlap=256;
            nfft=1024;
            [S,F,T,P]=spectrogram(data,window,noverlap,nfft,fs,'yaxis');
            h = pcolor(T,F,10*log10(P));
            set(h,'EdgeColor','none');
%             surf(T,F,10*log10(P),'edgecolor','none'); 
            axis tight;
            saveas(gcf,strcat(destination,newName),'png');
            close all force; 
        end
    end
end