%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt0X_.....
%
% Hensikten med programmet er å ....
% Følgende sensorer brukes:
% - Lyssensor
% - ...
% - ...
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
clear; close all
online = true;
filename = 'P02_Filtrering.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT

if online
    
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);
    [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);

    % sensorer
    myColorSensor = colorSensor(mylego);
    
else
    % Dersom online=false lastes datafil.
    load(filename)
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

while ~JoyMainSwitch
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    if online
        if k==1
            tic
            Tid(1) = 0;
            Lys(1) = double(readLightIntensity(myColorSensor,'reflected'));
        else
            Tid(k) = toc;
            Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
        end
       
        % Bruk filen joytest.m til å finne koden for de andre 
        % knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);

    else
        if k==numel(Tid)
            JoyMainSwitch=1;
        end

        % simulerer EV3-Matlab kommunikasjon i online=false
        pause(0.01)

    end
    %--------------------------------------------------------------




    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER

    % La Temp(k) tilsvare Lys(k)
    Temp(k) = Lys(k);
    
    if k==1
        % Initialverdier
        Ts(1) = 0.01;
        Temp_FIR(1) = Temp(1);
        Temp_IIR(1) = 2;
    % Testverdier for M og alpha
        M = 500;
        a = 0.5;

    else
        if(k < M)
            M = k;
        end

        Temp_FIR(k) = (1/M) * sum(Temp(k+1-M:k));
    end
    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA

    % aktiver fig1
    figure(fig1)

    subplot(2,2,1)
    plot(Tid(1:k),Lys(1:k));
    title('Lys reflektert')
    xlabel('Tid [sek]')

    subplot(2,2,2)
    plot(Tid(1:k),Avstand(1:k));
    title('Avstand')
    xlabel('Tid [sek]')

    subplot(2,2,3)
    plot(Tid(1:k),VinkelPosMotorB(1:k));
    title('Vinkelposisjon motor B')
    xlabel('Tid [sek]')

    subplot(2,2,4)
    plot(Tid(1:k),PowerB(1:k));
    title('Power B')
    xlabel('Tid [sek]')

    % tegn nå (viktig kommando)
    drawnow
    %--------------------------------------------------------------

    % Oppdaterer tellevariabel
    k=k+1;
end






