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
filename = 'kjoringGard.mat';
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
        else
            Tid(k) = toc;
            Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));
        end
       
        % Bruk filen joytest.m til å finne koden for de andre 
        % knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);
        JoyTwist(k) = JoyAxes(3);
        JoyPowerScale(k) = JoyAxes(4);
        %disp(JoyPowerScale);
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

    if (Lys(k) >= 60)
        break;
    end
    
    if online

        powerScale = (JoyPowerScale(k) + 100) / 200;
        twistSpeed = powerScale*JoyTwist(k);
        forwardSpeed = powerScale*JoyForover(k);
         
        kraftA = forwardSpeed + twistSpeed;
        kraftD = forwardSpeed - twistSpeed;
    
        powerA(k) = max(min(kraftA, 100), -100);
        powerD(k) = max(min(kraftD, 100), -100);
    
        myFirstMotor.Speed= powerA(k);
        mySecondMotor.Speed= powerD(k);
        
        
    
    
    
        if k==1
            referanseVerdi = Lys(1);
            e(1) = referanseVerdi - Lys(1);
            Ts(1) = nominalTimeStep;
            IAE(1) = 0;
            TV_a(1) = 0;
            TV_b(1) = 0;
            MAE(1) = 0;
        else
            Ts(k) = Tid(k) - Tid(k-1);
    
            e(k) = referanseVerdi - Lys(k);
            IAE(k) = EulerForward(IAE(k-1), abs(e(k-1)), Ts(k));
            
            MAE(k) =   MAE(k-1) + (1/k) * abs(e(k));
    
            TV_a(k) = TV_a(k-1) + abs(powerA(k) - powerA(k - 1));
            TV_b(k) = TV_b(k-1) + abs(powerD(k)- powerD(k -1));
        end
    end
    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA

    % aktiver fig1
    %figure(fig1)

    % tegn nå (viktig kommando)
    %drawnow

    %--------------------------------------------------------------
    % Oppdaterer tellevariabel
    k=k+1;
end
stop(myFirstMotor)
stop(mySecondMotor)






