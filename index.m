clear;
format long;

prompt={'k:','T_1:','T_2:','T_3:','T_4:','T_5:','T_0:'};
name='Input';
numlines=1;
defaultanswer={'1','-1','2','3','5','5','9'}; 
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

answer=inputdlg(prompt,name,numlines,defaultanswer,options);

k=str2num(answer{1,1});
T1=str2num(answer{2,1});
T2=str2num(answer{3,1});
T3=str2num(answer{4,1});
T4=str2num(answer{5,1}); 
T5=str2num(answer{6,1}); 
T0=str2num(answer{7,1});

Tsymulacji = 500;
Tp = 0.1;
numberOfDataSamples = Tsymulacji / Tp + 1;

kLower=1;
kUpper=2;

for numerSymulacji=1:20
    kR = (kLower + kUpper)/2
    sim('zRegulatorem',Tsymulacji);

    x = (0:Tp:Tsymulacji)';
    tsdata = getdatasamples(ans.dane,1:numberOfDataSamples);
    y = tsdata(:,2);
    [PKS,LOCS] = findpeaks(y,x);
    last = length(PKS);

    if PKS(last) < PKS(2)
        kLower = kLower + (kUpper-kLower)/2;
    else
        kUpper = kUpper - (kUpper-kLower)/2;
    end
end
kR
Tosc = LOCS(3) - LOCS(2)

kZN = 0.6*kR
kiZN = 1/(0.5*Tosc)
kdZN = 1/(0.12*Tosc)

plot(ans.dane, '.-')
xlabel('t(s)');
ylabel('y(t)');
legend('Syganl wymuszenia','Syganl odpowiedzi');

[down up] = limits(ans.dane);
ylim([down up]);

function [lower, upper] = limits(dane)
    minimum=min(min(dane));
    maximum=max(max(dane));
    if minimum > 0 & maximum > 0
        lower = 0.9*minimum; 
        upper = 1.1*maximum;
    else
        if minimum < 0 & maximum > 0
            lower = 1.1*minimum; 
            upper = 1.1*maximum;
        else
            lower = 1.1*minimum; 
            upper = 0.9*maximum;
        end
    end
end
