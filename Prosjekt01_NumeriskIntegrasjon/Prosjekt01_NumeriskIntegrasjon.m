%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt01_NumeriskIntegrasjon
%
% Hensikten med programmet er å numerisk integrere lyssignalet
% Følgende sensorer brukes:
% - Lyssensor
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

% intialisering av variabler
JoyMainSwitch=0;
k=1;
shouldAddBias = false;


while ~JoyMainSwitch
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
   
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

        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);
        JoyForover(k) = JoyAxes(2);

    else
        %avslutter programmer med joystick
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
        y(k) = EulerForward(y(k-1), Flow(k-1),Ts(k));

        if Flow(k) > 0
            shouldAddBias = true;
        end

        if shouldAddBias
            Flow(k) = Flow(k) + Offset;
        end
    end   
    %--------------------------------------------------------------

    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA

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

    % Oppdaterer tellevariabel
    if (k > 100 && ~online)
        break
    end
    k=k+1;

end





