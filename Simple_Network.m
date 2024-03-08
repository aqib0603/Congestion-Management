hours = 8760;           % Simulation for a Year
line_capacity = 15.5;   % In MVA
%%                      #### Initializing OpenDSS ####
[DSSStart,DSSObj,DSSText] = DSSStartup;

if DSSStart == 1
    DSSCircuit = DSSObj.ActiveCircuit;
    DSSSolution = DSSCircuit.Solution;
    ControlQueue = DSSCircuit.CtrlQueue;
    DSSObj.AllowForms = 0;
%%                              #### Sart ####
    DSSText.Command = 'Clear';
    DSSText.Command = 'Compile (F:\Congestion_Management\Simple_Network.dss)'; % Change directory to your specified disk                           
    
    DSSText.Command = 'Set ControlMode = time';
    DSSText.Command = 'Reset';
%     DSSText.Command = 'Set Mode = Yearly Number = ' + string(hours); % This line should be activated for normal operation
    DSSText.Command = 'Set Mode=yearly number=1';  % Uncomment this line when implementing Auto VAR compensation 
%%                          ####Creating Problem ####
    % Increasing the Load with factor
    
    Dgrowth = 2;
    DSSText.Command = "Set Loadmult= " + string(Dgrowth);
    
    % Adding VAR into the line to increase congestion
    DSSCircuit.Loads.Name = 'loadC';
    DSSCircuit.Loads.kvar = 5000;
%%                      #### Implementing Solution ####
    
    
    % 1) Distributed Generation (Addition of New Generator)
    DSSText.Command = 'new generator.gen1 bus1=C phases=3 kV=33 kW=7000 kvar=0 model=1 status=fixed';
    DSSCircuit.Generators.Name = 'gen1';
    Ggrowth = 1;
    DSSCircuit.Generators.kW = DSSCircuit.Generators.kW * Ggrowth;
    
    % 2) VAR Compensation 
    DSSText.Command = 'new load.capacitor bus1=C phases=3 kV=33 kW=0 kvar=0 model=1';

    ijk = 0;
    for i = 0 : hours
    
        DSSSolution.Solve
        DSSCircuit.SetActiveElement('line.lineA-B');
        powerarray = DSSCircuit.ActiveCktElement.Powers;
        kVAphaseA = sqrt(powerarray(1)^2 + powerarray(2)^2);
        useofAB = (3 * kVAphaseA) / (line_capacity * 1000);
  
        if ijk == 0 || ijk > 5
         ijk = 0;
         if useofAB > 1
             DSSCircuit.Loads.Name = 'capacitor';
             DSSCircuit.Loads.kvar = -7000;
            
         elseif useofAB < 0.7
             DSSCircuit.Loads.Name = 'capacitor';
             DSSCircuit.Loads.kvar = 0;
         end
        else 
         DSSCircuit.Loads.Name = 'capacitor';
             if DSSCircuit.Loads.kvar == -7000
                ijk = ijk + 1;
             end
        end
    end


%     DSSSolution.Solve % Uncomment for single operation

    %DSSText.Command='Export Monitors SS_HV_P'; % For exporing monitors
    DSSText.Command='Export Meters';
%%                             #### Meters ####
    
    DSSCircuit.Meters.Name = 'GSP';
    EMvalues = DSSCircuit.Meters.RegisterValues;
    fprintf('Energy Meter at Transformer')
    fprintf('Net Energy Imported (+) / Exported (-) from/to GSP: %.5f kWh\n', EMvalues(1)/1000 )
    fprintf('Reactive Power-h Imported (+) / Exported (-) from/to GSP: %.5f kvarh\n', EMvalues(2)/1000 )
    fprintf('Max Real Power: %.5f kW\n', EMvalues (3) / 1000)
    fprintf('Max Complex Power: %.5f kVA\n', EMvalues(4) / 1000)
    fprintf('Power Losses: %.5f kWh\n', EMvalues (13) / 1000)
    fprintf('Reactive Losses (+ is inductive): %.5f kvarh\n\n', EMvalues(14) / 1000)

    DSSCircuit.Meters.Name = 'mloadB';
    EMvalues = DSSCircuit.Meters.RegisterValues;
    fprintf('Energy Meter at Load B\n')
    fprintf('Net Energy Imported (+) / Exported (-) from/to GSP: %.5f kWh\n', EMvalues(1)/1000 )
    fprintf('Reactive Power-h Imported (+) / Exported (-) from/to GSP: %.5f kvarh\n\n', EMvalues(2)/1000 )
    
    DSSCircuit.Meters.Name = 'mloadC';
    EMvalues = DSSCircuit.Meters.RegisterValues;
    fprintf('Energy Meter at Load C\n')
    fprintf('Net Energy Imported (+) / Exported (-) from/to GSP: %.5f kWh\n', EMvalues(1)/1000 )
    fprintf('Reactive Power-h Imported (+) / Exported (-) from/to GSP: %.5f kvarh\n', EMvalues(2)/1000 )
    
%%                             #### Monitors ####
    
    DSSMon=DSSCircuit.Monitors;
    
    DSSMon.name='LineA-B_A';
    P1_A_B_A = ExtractMonitorData(DSSMon, 1, 1000);
    P2_A_B_A = ExtractMonitorData(DSSMon, 3, 1000);
    P3_A_B_A = ExtractMonitorData(DSSMon, 5, 1000);
    P_A_B_A = P1_A_B_A + P2_A_B_A + P3_A_B_A;
    Q1_A_B_A = ExtractMonitorData(DSSMon, 2, 1000);
    Q2_A_B_A = ExtractMonitorData(DSSMon, 4, 1000);
    Q3_A_B_A = ExtractMonitorData(DSSMon, 6, 1000);
    Q_A_B_A = Q1_A_B_A + Q2_A_B_A + Q3_A_B_A;
    S_A_B_A = sqrt(P_A_B_A.^2 + Q_A_B_A.^2);
    
    

    DSSMon.name='LineA-B_B';
    P1_A_B_B = ExtractMonitorData(DSSMon, 1, 1000);
    P2_A_B_B = ExtractMonitorData(DSSMon, 3, 1000);
    P3_A_B_B = ExtractMonitorData(DSSMon, 5, 1000);
    P_A_B_B  = P1_A_B_A + P2_A_B_A + P3_A_B_A;
    Q1_A_B_B = ExtractMonitorData(DSSMon, 2, 1000);
    Q2_A_B_B = ExtractMonitorData(DSSMon, 4, 1000);
    Q3_A_B_B = ExtractMonitorData(DSSMon, 6, 1000);
    Q_A_B_B = Q1_A_B_B + Q2_A_B_B + Q3_A_B_B;
    S_A_B_B = sqrt(P_A_B_B.^2 + Q_A_B_B.^2);

    Use_LineA_B = 100*max(S_A_B_A, S_A_B_B) / line_capacity;

    t = ExtractMonitorData(DSSMon,0, 3600);

    plot(t, Use_LineA_B,'B');
    title('Line Congestion');
    ylabel('Use of Line A-B (%)');
    xlabel('Time [hr]');
    xlim([0,  hours])
    ylim([0, 160])
    grid on
    
else
    Error ='DSS Did Not Start';
    disp(Error)
end


