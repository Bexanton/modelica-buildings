within Buildings.ThermalZones.EnergyPlus;
model Schedule
  "Block to write to an EnergyPlus schedule"
  extends Buildings.ThermalZones.EnergyPlus.BaseClasses.PartialEnergyPlusObject;
  parameter String name
    "Name of schedule";
  parameter Buildings.ThermalZones.EnergyPlus.Types.Units unit
    "Unit of variable as used in Modelica"
    annotation (choicesAllMatching=true);
  Modelica.Blocks.Interfaces.RealInput u
    "Continuous input signal to be written to EnergyPlus"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Interfaces.RealOutput y
    "Value written to EnergyPlus (use for direct dependency of Actuators and Schedules)"
    annotation (Placement(transformation(extent={{100,-20},{140,20}}),iconTransformation(extent={{100,-20},{140,20}})));
protected
  constant Integer nParOut = 0 "Number of parameter values retrieved from EnergyPlus";
  constant Integer nOut = 0 "Number of outputs";
  constant Integer nDer = 0 "Number of derivatives";
  constant Integer nY = nOut + nDer + 1 "Size of output vector of exchange function";

  final parameter Real dummy(
    fixed=false)
    "Dummy value to force initialization before call to exchange";

  final parameter String unitString = Buildings.ThermalZones.EnergyPlus.BaseClasses.getUnitAsString(unit) "Unit as a string";
  Buildings.ThermalZones.EnergyPlus.BaseClasses.FMUZoneClass adapter=Buildings.ThermalZones.EnergyPlus.BaseClasses.FMUZoneClass(
    objectType=2,
    modelicaNameBuilding=modelicaNameBuilding,
    modelicaInstanceName=modelicaInstanceName,
    idfName=idfName,
    weaName=weaName,
    epName=name,
    usePrecompiledFMU=usePrecompiledFMU,
    fmuName=fmuName,
    buildingsLibraryRoot=Buildings.ThermalZones.EnergyPlus.BaseClasses.buildingsLibraryRoot,
    logLevel=logLevel,
    jsonName = "schedules",
    jsonKeysValues=
        "        \"name\": \"" + name + "\",
        \"unit\": \"" + unitString + "\",
        \"fmiName\": \"" + name + "_" + modelicaInstanceName + "\"",
    parOutNames = fill("", 0),
    parOutUnits = fill("", 0),
    nParOut = nParOut,
    inpNames = {modelicaInstanceName},
    inpUnits = {unitString},
    nInp = 1,
    outNames = fill("", 0),
    outUnits = fill("", 0),
    nOut = nOut,
    derivatives_structure = fill( fill(0, 2), 0),
    nDer = nDer,
    derivatives_delta = fill(0, 0))
    "Class to communicate with EnergyPlus";

  Real yEP[nY] "Output of exchange function";

initial equation
  assert(
    not usePrecompiledFMU,
    "Use of pre-compiled FMU is not supported for block Schedule.");
  {dummy} = Buildings.ThermalZones.EnergyPlus.BaseClasses.zoneInitialize(
    adapter=adapter,
    startTime=startTime,
    nParOut=nParOut);

equation
  yEP = Buildings.ThermalZones.EnergyPlus.BaseClasses.zoneExchange(
    adapter = adapter,
    initialCall = initial(),
    nY = nY,
    u = {u, round(time, 1E-3)},
    dummy = dummy);

  y = yEP[1];

  annotation (
    defaultComponentName="sch",
    Icon(
      graphics={
        Line(
          points={{-58,56},{-58,-24},{62,-24},{62,56},{32,56},{32,-24},{-28,-24},{-28,56},{-58,56},{-58,36},{62,36},{62,16},{-58,16},{-58,-4},{62,-4},{62,-24},{-58,-24},{-58,56},{62,56},{62,-24}}),
        Line(
          points={{2,56},{2,-24}}),
        Rectangle(
          fillColor={255,215,136},
          fillPattern=FillPattern.Solid,
          extent={{-58,36},{-28,56}}),
        Rectangle(
          fillColor={255,215,136},
          fillPattern=FillPattern.Solid,
          extent={{-58,16},{-28,36}}),
        Rectangle(
          fillColor={255,215,136},
          fillPattern=FillPattern.Solid,
          extent={{-58,-4},{-28,16}}),
        Rectangle(
          fillColor={255,215,136},
          fillPattern=FillPattern.Solid,
          extent={{-58,-24},{-28,-4}})}),
    Documentation(
      info="<html>
<p>
Block that writes to a schedule object in EnergyPlus.
</p>
<p>
This model writes at every EnergyPlus zone time step the value of the input <code>u</code>
to an EnergyPlus schedule with name <code>name</code>.
For example, if EnergyPlus has 6 time steps per hour, as specified in the idf-file with
the entry <code>Timestep,6;</code> and the input <code>u</code> to this block is
</p>
<table summary=\"example for input\" border=\"1\" cellspacing=\"0\" cellpadding=\"2\" style=\"border-collapse:collapse;\">
<tr><th>Model time (min)</th>       <th>Input u</th>   </tr>
<tr><td>0...5</td>                  <td>0</td>         </tr>
<tr><td>5...15</td>                 <td>1</td>         </tr>
<tr><td>15...20</td>                <td>2</td>         </tr>
<tr><td>20</td>                     <td>3</td>         </tr>
</table>
<p>
then EnergyPlus will receive the inputs
</p>
<table summary=\"example for input\" border=\"1\" cellspacing=\"0\" cellpadding=\"2\" style=\"border-collapse:collapse;\">
<tr><th>Model time (min)</th>  <th>Input u</th>  </tr>
<tr><td> 0</td>                <td>0</td>        </tr>
<tr><td>10</td>                <td>1</td>        </tr>
<tr><td>20</td>                <td>3</td>        </tr>
</table>
<p>
The parameter <code>unit</code> specifies the unit of the signal <code>u</code>.
This unit is then converted internally to the units required by EnergyPlus before
the value is sent to EnergyPlus.
See <a href=\"modelica://Buildings.ThermalZones.EnergyPlus.Types.Units\">Buildings.ThermalZones.EnergyPlus.Types.Units</a>
for the supported units.
If the value of the parameter <code>unit</code> is left at its default value of
<code>Buildings.ThermalZones.EnergyPlus.Types.Units.unspecified</code>, then
the simulation will stop with an error.
</p>
<h4>Usage</h4>
<p>
To use an schedule, set up the schedule in the EnergyPlus idf file.
For example, an entry may be
</p>
<pre>
Schedule:Compact,
  INTERMITTENT,            !- Name
  Fraction,                !- Schedule Type Limits Name
  Through: 12/31,          !- Field 1
  For: WeekDays,           !- Field 2
  Until: 8:00,0.0,         !- Field 3
  Until: 18:00,1.00,       !- Field 5
  Until: 24:00,0.0,        !- Field 7
  For: AllOtherDays,       !- Field 9
  Until: 24:00,0.0;        !- Field 10
</pre>
<p>
Next, instantiate the actuator in Modelica. For the above
<code>Schedule:Compact</code>, the Modelica instantiation would be
</p>
<pre>
  Buildings.ThermalZones.EnergyPlus.Schedule schInt(
    name = \"INTERMITTENT\",
    unit = Buildings.ThermalZones.EnergyPlus.Types.Units.Normalized)
    \"Block that writes to the EnergyPlus schedule INTERMITTENT\";
</pre>
<p>
The entry <code>units=Buildings.ThermalZones.EnergyPlus.Types.Units.Normalized</code>
will cause the value to be sent to EnergyPlus without any unit conversion.
</p>
</html>",
      revisions="<html>
<ul>
<li>
November 8, 2019, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end Schedule;
