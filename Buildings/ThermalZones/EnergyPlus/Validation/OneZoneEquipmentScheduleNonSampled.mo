within Buildings.ThermalZones.EnergyPlus.Validation;
model OneZoneEquipmentScheduleNonSampled
  "Validation case with a schedule that is not sampled, e.g., updates only at the EnergyPlus zone time step"
  extends Buildings.ThermalZones.EnergyPlus.Validation.OneZone;

  Buildings.ThermalZones.EnergyPlus.Schedule schInt(
    name="INTERMITTENT",
    unit=Buildings.ThermalZones.EnergyPlus.Types.Units.Normalized,
    samplePeriod=1200)
    "Block that writes to the EnergyPlus schedule INTERMITTENT"
    annotation (Placement(transformation(extent={{-40,70},{-20,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Pulse intLoaFra(
    period=86400,
    startTime=7*3600)
    "Schedule for fraction of internal loads from 7:00 to 19:00"
    annotation (Placement(transformation(extent={{-80,70},{-60,90}})));
equation
  connect(schInt.u, intLoaFra.y)
    annotation (Line(points={{-42,80},{-58,80}}, color={0,0,127}));


  annotation (Documentation(info="<html>
<p>
Simple test case that verifies whether the schedule for the internal loads 
used by EnergyPlus is modified from Modelica.
</p>
</html>", revisions="<html>
<ul><li>
May 21, 2020, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
 __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/ThermalZones/EnergyPlus/Validation/OneZoneEquipmentScheduleNonSampled.mos"
        "Simulate and plot"),
experiment(
      StopTime=172800,
      Tolerance=1e-06));
end OneZoneEquipmentScheduleNonSampled;