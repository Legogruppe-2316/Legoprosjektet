%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt04_ManuellKjøring
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
    myColorSensor = colorSensor(mylego, 1);
    myFirstMotor = motor(mylego,'A');
    mySecondMotor = motor(mylego, 'D');
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
powerScale = 0.2;
intialIIRSpeed = 0;
nominalTimeStep = 0;
referanseVerdi = 0;

while ~JoyMainSwitch
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    if online
        if k==1
            tic
            Tid(1) = 0;
            Lys(1) = double(readLightIntensity(myColorSensor,'reflected'));
            referanseVerdi = Lys(1);
            e(1) = referanseVerdi - Lys(1);
            
        else
            Tid(k) = toc;
            Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
            e(k) = referanseVerdi - Lys(k);
        end
       
        % Bruk filen joytest.m til å finne koden for de andre 
        % knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);
        JoyTwist(k) = JoyAxes(3);
        start(myFirstMotor)
        start(mySecondMotor)

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
    twistSpeed = powerScale*JoyTwist(k);
    forwardSpeed = powerScale*JoyForover(k);


    
    kraftA = forwardSpeed + twistSpeed;
    kraftD = forwardSpeed -twistSpeed;

    myFirstMotor.Speed = max(min(kraftA, 100), -100);
    mySecondMotor.Speed = max(min(kraftD, 100), -100);

    powerA(k)= myFirstMotor.Speed;
    powerD(k)= mySecondMotor.Speed;

    if (Lys(k) >= 60)
        %break;
    end



    if k==1
        Ts(1) = nominalTimeStep;

    else
        Ts(k) = Tid(k) - Tid(k-1);
    end
    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA

    % aktiver fig1
    figure(fig1)


    %subplot(1,3, 1)
    %plot(Tid(1:k),JoyTwist(1:k), 'b');
    %title('Joy Forover(t)')
    %xlabel('Tid [sek]')

    %subplot(1,3,2);
    %plot(Tid(1:k),Lys(1:k),'r');
    %title('Verdier for Lys(k)');
    %xlabel('Tid(s)');

    %subplot(1,3,3);
    %plot(Tid(1:k),e(1:k),'g');
    %title('Verdier for e(k)');
    %xlabel('Tid(s)');

    %gjør referanseverdi til en vektor
    referansevektor = repmat(referanseVerdi,1,length(Lys));
    subplot(3,2,1);
    plot(Tid(1:k),Lys(1:k), 'r');
    title('Referanse og Lys(k)');
    hold on;
    plot(Tid(1:k),referansevektor, 'b');

    
    subplot(3,2,2);
    plot(Tid(1:k), e(1:k),'g');
    title('Avvik e(k)');

    subplot(3,2,3);
    title('PowerA(k) og PowerD(k)');
    plot(Tid(1:k), powerA(1:k), 'b');
    hold on;
    plot(Tid(1:k), powerD(1:k), 'r');
   
    
    

    % tegn nå (viktig kommando)
    drawnow
    %--------------------------------------------------------------
    % Oppdaterer tellevariabel
    k=k+1;
end
stop(myFirstMotor)
stop(mySecondMotor)






