%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt0X_.....
%
% Hensikten med programmet er å ....
% Følgende sensorer brukes:
% - Lyssensor
% - ...
% - ...
%
% Følgende motorer brukes:
% - motor A
% - ...
% - ...
%
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Alltid lurt å rydde workspace opp først
clear; close all
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = true;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename = 'P01_NumeriskIntegrasjon_sinus.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%
% Spesifiser hvilke sensorer og motorer som brukes.
% I Matlab trenger du generelt ikke spesifisere porten de er tilkoplet.
% Unntaket fra dette er dersom bruke 2 like sensorer, hvor du må
% initialisere 2 sensorer med portnummer som argument.
% Eksempel:
 %mySonicSensor_1 = sonicSensor(mylego,3);
% mySonicSensor_2 = sonicSensor(mylego,4);

% For ryddig og oversiktlig kode, kan det være lurt å slette
% de sensorene og motoren som ikke brukes. 

if online
    
    % LEGO EV3 og styrestikke    
    mylego = legoev3('USB');
    selected_joystick = 1;
    if ~ismac && isunix
        selected_joystick = 2;
    end
    disp(selected_joystick)
    joystick = vrjoystick(selected_joystick);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);

else
    % Dersom online=false lastes datafil.
    load(filename)
    online = false;
end

disp('Equipment initialized.')
%----------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,1,0.5*screen(3), 0.5*screen(4)])
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14)
set(0,'defaultTextFontSize',16)
%----------------------------------------------------------------------


% setter skyteknapp til 0, og tellevariabel k=1
JoyMainSwitch=0;
k=1;
shouldAddBias = false;


while ~JoyMainSwitch
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick
    %
    % For ryddig og oversiktlig kode, kan det være lurt å slette
    % de sensorene og motoren som ikke brukes.
   
    if online
        if k==1
            tic
            Tid(1) = 0;
            Lys(1) = double(readLightIntensity(myColorSensor,'reflected'));
        else
            % Leser reflektert lys, og gjør det om til en double datatype
            Tid(k) = toc;
            Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
        end

        % Data fra styrestikke. Utvid selv med andre knapper og akser.
        % Bruk filen joytest.m til å finne koden for de andre 
        % knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);

    else
        % online=false
        % Når k er like stor som antall elementer i datavektoren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k==numel(Tid)
            JoyMainSwitch=1;
        end

        % simulerer EV3-Matlab kommunikasjon i online=false
        pause(0.01)

    end
    %--------------------------------------------------------------




    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER

    % Parametre
    a=0.7;
    
    % Tilordne målinger til variabler'
    Offset = 0;
    if ~online
       Offset = -1.8;
    end
    nullflow = Lys(1); %nullpunkt for reflektert lys
    y(1) = 0; %volum
    Ts(1) = 0;
    Flow(1) = Lys(1) - nullflow;
   
    % Regner ut datavektorene lys, tid, flow og volum

    if(k>=2)
        Ts(k) = Tid(k) - Tid(k-1);
        Flow(k) = (nullflow - Lys(k));
        y(k) = y(k-1) + Ts(k) * Flow(k-1);


        if Flow(k) > 0
            shouldAddBias = true;
        end

        if shouldAddBias
            Flow(k) = Flow(k) + Offset;
        end



    end

    % Andre beregninger som ikke avhenger av initialverdi
    

    % Pådragsberegninger
    %PowerA(k) = a*JoyForover(k);

    %if online
        % Setter powerdata mot EV3
        %motorA.Speed = PowerA(k);
        %start(motorA);
    %end
    %--------------------------------------------------------------




    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    % Denne seksjonen plasseres enten i while-lokka eller rett etterpå.
    % Dette kan enkelt gjøres ved flytte de 5 nederste linjene
    % før "end"-kommandoen nedenfor opp før denne seksjonen.
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

    % aktiver fig1
    figure(fig1)

    subplot(2,2,1)
    plot(Tid(1:k),Flow(1:k));
    title('Flow(t)')
    xlabel('Tid [sek]')

    subplot(2,2,2)
    plot(Tid(1:k),y(1:k));
    title('Volum(t)')
    xlabel('Tid [sek]')

    % tegn nå (viktig kommando)
    drawnow
    %--------------------------------------------------------------

    % For å flytte PLOT DATA etter while-lokken, er det enklest å
    % flytte de neste 5 linjene (til og med "end") over PLOT DATA.
    % For å indentere etterpå, trykk Ctrl-A/Cmd-A og deretter
    % Crtl-I/Cmd-Ixxx
    %
    % Oppdaterer tellevariabel
    if (k > 100 && ~online)
        break
    end
    k=k+1;

end





