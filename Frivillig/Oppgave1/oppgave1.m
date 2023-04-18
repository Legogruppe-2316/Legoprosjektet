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
filename = 'automatiskKjoring2.mat';
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

    if k==1
            referanseVerdi = Lys(1);
            e(1) = referanseVerdi - Lys(1);
            Ts(1) = nominalTimeStep;

            %  Verdier for Ki, kp og kd
            % Lader + full lysstyrke uten grafer:
            % Ki = 1, Kp = 2.0, Kd = 0.8, u_initial = 15

            % Constants
            Ki = 1;
            Kp = 2.0;
            Kd = 0.8;
            u_initial = 15;

            P(1) = 0;
            I(1) = 0;
            D(1) = 0;
            u(1) = 0;
            e_f(1) = 0;
        else
            Ts(k) = Tid(k) - Tid(k-1);
            e(k) = referanseVerdi - Lys(k);

            % PID regulator
            P(k) = Kp * e(k);
            e_f(k) = IIR_filter(e_f(k-1),e(k), alfaIIR);
            D(k) = Kd * Derivation(e_f(k-1), e_f(k), Ts(k));

            currentValue = EulerForward(I(k-1), Ki * e(k-1), Ts(k));
            if (currentValue > 100)
                I(k) = I(k-1);

            elseif (currentValue < -100)
                I(k) = I(k-1);
            
            else
                I(k) = currentValue;
            end

            u(k) = u_initial + P(k) + I(k) + D(k);
    end

    if online     
        kraftA = u_initial - u(k);
        kraftD = u_initial + u(k);
    
        powerA(k) = max(min(kraftA, 100), -100);
        powerD(k) = max(min(kraftD, 100), -100);
    
        myFirstMotor.Speed= powerA(k);
        mySecondMotor.Speed= powerD(k); 

        if k==1
            IAE(1) = 0;
            TV_a(1) = 0;
            TV_b(1) = 0;
            MAE(1) = 0; 
        else
            IAE(k) = EulerForward(IAE(k-1), abs(e(k-1)), Ts(k));
            MAE(k) =   MAE(k-1) + (1/k) * abs(e(k));
            TV_a(k) = TV_a(k-1) + abs(powerA(k) - powerA(k - 1));
            TV_b(k) = TV_b(k-1) + abs(powerD(k)- powerD(k -1)); 
        end
    end

    % Offline modus
    if ~online
        if k==1
            IAE(1) = 0;
            TV_a(1) = 0;
            TV_b(1) = 0;
            MAE(1) = 0; 
        else
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
   %{
    figure(fig1)
    
    subplot(3,3,1);
    plot(Tid(1:k), P(1:k),'b');
    title('Proporsjonalvirkning P(k)')

    subplot(3,3,2);
    plot(Tid(1:k), I(1:k),'b');
    title('Integralvirkning I(k)')

    subplot(3,3,3);
    plot(Tid(1:k), D(1:k),'b');
    title('Derivatvirkning D(k)')

    subplot(3,3,4);
    plot(Tid(1:k), MAE(1:k));
    title('MAE(k)');

    subplot(3,3,5);
    plot(Tid(1:k), IAE(1:k));
    title('IAE(k)');

    subplot(3,3,6);
    plot(Tid(1:k), TV_a(1:k), 'b');
    hold on;
    plot(Tid(1:k), TV_b(1:k), 'r');
    title('TV_a(k) og TV_b(k)');
    legend('TV_a(k)', 'TV_b(k)');

    subplot(3,3,7);
    plot(Tid(1:k), powerA(1:k), 'b');
    hold on;
    plot(Tid(1:k), powerD(1:k), 'r');
    title('powerA(k) og powerD(k)');
    legend('powerA(k)', 'powerB(k)');

    referansevektor = repmat(referanseVerdi,1,length(Lys));
    subplot(3,3,8);
    plot(Tid(1:k), referansevektor(1:k));   
    hold on;
    plot(Tid(1:k), Lys(1:k));
    title('Referanse(k) og Lys(k)');
    legend('Referanse(k)','Lys(k)');

    % tegn nå (viktig kommando)
    drawnow
   %}

    %--------------------------------------------------------------
    % Oppdaterer tellevariabel
    k=k+1;
end


stop(myFirstMotor)
stop(mySecondMotor)






