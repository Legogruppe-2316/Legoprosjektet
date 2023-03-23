%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt03_NumeriskDerivasjon
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
filename = 'PO2_FiltreringData.mat';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT

if online
    
    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    selected_joystick = 1;
    if ~ismac && isunix
        selected_joystick = 2;
    end

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


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                        INITAL VALUES 
alfaIIR = 0.03;
intialSpeed = 1;
intialIIRSpeed = 0;
nominalTimeStep = 0;

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
    Avstand(k) = Lys(k);

    if k==1
        Ts(1) = nominalTimeStep;
        Speed(1) = intialSpeed;
        SpeedIIR(1) = intialIIRSpeed;
        AvstandIIR(1) = Avstand(1);

    else
        Ts(k) = Tid(k) - Tid(k-1);
        Speed(k) = Derivation(Avstand(k-1), Avstand(k), Ts(k));
        AvstandIIR(k) = IIR_filter(AvstandIIR(k-1),Avstand(k), alfaIIR);
        SpeedIIR(k) = Derivation(AvstandIIR(k-1), AvstandIIR(k), Ts(k));
    end
    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA

    % aktiver fig1
    figure(fig1)


    subplot(2,1, 1)
    plot(Tid(1:k),Avstand(1:k), 'b');
    title('IIR-filter av Avstand(t)')
    %hold on;
    plot(Tid(1:k),AvstandIIR(1:k), 'r');
    xlabel('Tid [sek]')

    %subplot(3,1, 2)
    %plot(Tid(1:k),Speed(1:k), 'r');
    %title('Fart(t) Rådata')
    %xlabel('Tid [sek]')

    subplot(2,1,2)
    plot(Tid(1:k), SpeedIIR(1:k), 'g');
    title('IIR-filter av Fart(t)')
    xlabel('Tid [sek]')

    %subplot(2,2,4)
    %plot(Tid(1:k), AvstandIIR(1:k));
    %title('AvstandIIR(t)')
    %xlabel('Tid [sek]')


    % tegn nå (viktig kommando)
    drawnow
    %--------------------------------------------------------------
    % Oppdaterer tellevariabel
    k=k+1;
end






