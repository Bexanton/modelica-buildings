within Buildings.ThermalZones.EnergyPlus.BaseClasses;
function zoneExchange
  "Exchange the values with the EnergyPlus thermal zone"
  extends Modelica.Icons.Function;
  input Buildings.ThermalZones.EnergyPlus.BaseClasses.FMUZoneClass adapter
    "External object";
  input Boolean initialCall
    "Set to true if initial() is true, false otherwise";
  input Integer nY "Size of output y";
  input Real u[:] "Input values. First all inputs, then the current model time";
  input Real dummy
    "Dummy value (used to force Modelica tools to call initialize())";
  output Real y[nY] "Output values. First all outputs, then all derivatives, then next event time";

external "C" SpawnInputOutputExchange(
  adapter,
  initialCall,
  u,
  dummy,
  y)
  annotation (
    Include="#include <EnergyPlusWrapper.c>",
    IncludeDirectory="modelica://Buildings/Resources/C-Sources",
    Library={"ModelicaBuildingsEnergyPlus", "fmilib_shared"});

  annotation (
    Documentation(
      info="<html>
<p>
External function that exchanges data with EnergyPlus for the current thermal zone.
</p>
</html>",
      revisions="<html>
<ul><li>
February 14, 2018, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end zoneExchange;
