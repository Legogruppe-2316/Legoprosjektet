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
filename = '752del1.mat';
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

            %if any(Tid >= 5.5)
             %   break;
            %end
        end
       %pause(0.5);
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
        %pause(0.01)

    end
    %--------------------------------------------------------------




    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER

    % La Temp(k) tilsvare Lys(k)
    Temp(k) = Lys(k) + randn;
    % Testverdier for M og alpha
    a = 0.3;
    
    if k==1
    % Initialverdier
        Ts(1) = 0.01;
        Temp_FIR(1) = Temp(1);
        Temp_IIR(1) = Temp(1);
    else
    % Få tak i forrige verdi
        M = 50;
        if(k < M)
            M = k;
            Temp_FIR(k) = (1/M) * sum(Temp(k+1-M:k));
        end
    % Regn ut gjennomsnittlig verdi fra forrige 
        Temp_FIR(k) = (1/M) * sum(Temp(k+1-M:k));
        Temp_IIR(k) = (1-a)* Temp_IIR(k-1) + a * Temp(k);
    end
    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA

    % aktiver fig1
    figure(fig1)

    title('Simulert temperatur');
    xlabel('Tid [sek]');

    subplot(2,1,1)
    plot(Tid(1:k),Temp(1:k), 'r');
    hold on;
    plot(Tid(1:k),Temp_FIR(1:k), 'b');
    plot(Tid(1:k), Temp_IIR(1:k), 'g');

    legend('Temp(k)', 'Temp_FIR(k)', 'Temp_IIR(k)')
    % tegn nå (viktig kommando)
    drawnow
    %--------------------------------------------------------------
    % Oppdaterer tellevariabel
    k=k+1;
end






