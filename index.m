clear;
format short;

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

Tp = 0.1;
Tsymulacji = 700;
numberOfDataSamples = Tsymulacji / Tp + 1;

regulowany = menu('Czy uklad ma zawierac regulator PID?', 'tak', 'nie');
switch (regulowany)
    case 1
        numerWybranegoWymuszenia = menu('Wybierz wymuszenie i zak³ócenie', 'u(t)=1(t-10) z(t)=0', 'u(t)=1(t-10) z(t)=0.2*1(t-100)', 'u(t)=sin(0.01t)*1(t-10) z(t)=0', 'u(t)=sin(0.01t) z(t)=0.05[1(t)-cos(0.05t)]');
        sim('zRegulatorem',Tsymulacji);
        
        tsdane = getdatasamples(ans.dane,1:numberOfDataSamples);
        wymuszenie = tsdane(:,1);
        odpowiedz = tsdane(:,2);
        zaklocenie = tsdane(:,3);
        sterowanie = tsdane(:,4);
        % [wymuszenie odpowiedz zaklocenie sterowanie]
        
        odpowiedziLubParametry = menu('Co chcesz zrobiæ?' ,'Obejrzeæ odpowiedzi ukladu', 'Odczytac wskaŸniki jakoœci regulacji');
        switch (odpowiedziLubParametry)
            case 1
                plot(ans.dane, '.-')
                xlabel('t(s)');
                ylabel(' ');
                legend('y_r(t)','y(t)','z(t)', 'u(t)');
                [down up] = limits(ans.dane);
                ylim([down up]);
            case 2
                tswskazniki = getdatasamples(ans.wskaznikiJakosciowe,1:numberOfDataSamples);
                e = tswskazniki(:,1);
                Ie = tswskazniki(:,2);
                Ie2 = tswskazniki(:,3);
                ICV2 = tswskazniki(:,4);
                % [e Ie Ie2 ICV2]
                
                %czas regulacji
                eMaksymalne = max(e);
                eGraniczne = 0.05 * eMaksymalne;
                indeksWprowadzeniaWymuszenia = indeksSkoku(wymuszenie);
                indeksWprowadzeniaZaklocenia = indeksSkoku(zaklocenie);
                momentWprowadzeniegoSygnalu = max(indeksWprowadzeniaWymuszenia, indeksWprowadzeniaZaklocenia);
                
                indeksySygnaluUregulowanego = find(e(momentWprowadzeniegoSygnalu:numberOfDataSamples) < eGraniczne);
                if length(indeksySygnaluUregulowanego)>0
                    indeksSygnaluUregulowanego = indeksySygnaluUregulowanego(1);
                else
                    indeksSygnaluUregulowanego = inf;
                end
                tRegulacji = Tp * indeksSygnaluUregulowanego;
                
                %przeregulowanie wyrazone w %
                przeregulowanie = - min(e) / max(e) * 100;
                
                %sredni blad regulacji
                eCumulative = Ie(numberOfDataSamples);
                sredniBladRegulacji = eCumulative / numberOfDataSamples;
                
                %calka kwadratu bledu regulacji
                calkaKwadratuBleduRegulacji = Ie2(numberOfDataSamples);
                
                %energia sterowania
                energiaSterowania = ICV2(numberOfDataSamples);
                
%                 [{['czas regulacji: ' num2str(tRegulacji)];...
%                     ['przeregulowanie: ' num2str(przeregulowanie)];...
%                     ['sredni blad regulacji: ' num2str(sredniBladRegulacji)];...
%                     ['calka kwadratu bledu regulacji: ' num2str(calkaKwadratuBleduRegulacji)];...
%                     ['energia sterowania: ' num2str(energiaSterowania)]}]
                
                msgbox({['czas regulacji: ', num2str(tRegulacji)]...
                    ['przeregulowanie: ',num2str(przeregulowanie),' %']...
                    ['sredni blad regulacji: ',num2str(sredniBladRegulacji)]...
                    ['calka kwadratu bledu regulacji: ',num2str(calkaKwadratuBleduRegulacji)]...
                    ['energia sterowania: ',num2str(energiaSterowania)]...
                    },'parametry jakosciowe')
        end
        
    case 2
        numerWybranegoWymuszenia = menu('Wybierz wymuszenie', 'wymuszenie skokowe u(t)=1(t-10)', 'wymuszenie pulsowe u(t)=1(t-10)-1(t-11)');
        sim('bezRegulatora',Tsymulacji);
        
        tsdane = getdatasamples(ans.dane,1:numberOfDataSamples);
        wymuszenie = tsdane(:,1);
        odpowiedz = tsdane(:,2);
        % [wymuszenie odpowiedz]
        
        plot(ans.dane, '.-')
        xlabel('t(s)');
        ylabel(' ');
        legend('u(t)','y(t)');
        [down up] = limits(ans.dane);
        ylim([down up]);
end



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

function indeks = indeksSkoku(tablica)
dlugosc = length(tablica);
wartoscPoczatkowa = tablica(1);
indeks = 1;
for n=2:dlugosc
    if tablica(n) ~= wartoscPoczatkowa
        indeks = n;
        return;
    end
end
end
