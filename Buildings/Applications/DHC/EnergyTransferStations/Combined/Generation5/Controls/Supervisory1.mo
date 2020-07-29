within Buildings.Applications.DHC.EnergyTransferStations.Combined.Generation5.Controls;
model Supervisory1 "Supervisory controller"
  extends BaseClasses.PartialSupervisory;

  parameter Modelica.SIunits.TemperatureDifference dTHys(min=0) = 1
    "Temperature hysteresis (absolute value)";
  parameter Modelica.SIunits.TemperatureDifference dTDea(min=0) = 0.5
    "Temperature dead band (absolute value)";
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController controllerType=
    Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Type of controller";
  parameter Real kHot(min=0)=0.1
    "Gain of controller on hot side";
  parameter Real kCol(min=0)=0.2
    "Gain of controller on cold side";
  parameter Modelica.SIunits.Time Ti(
    min=Buildings.Controls.OBC.CDL.Constants.small)=300
    "Time constant of integrator block (hot and cold side)"
    annotation (Dialog(enable=
      controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PI or
      controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  parameter Modelica.SIunits.Temperature THeaWatSupSetMin=THeaWatSupSetMin(
      displayUnit="degC")
    "Minimum value of heating water supply temperature set-point";
  parameter Modelica.SIunits.Temperature TChiWatSupSetMax=TChiWatSupSetMax(
      displayUnit="degC")
    "Maximum value of chilled water supply temperature set-point";

  SideHot1 conHotSid(
    final nSouAmb=nSouAmb,
    final dTHys=dTHys,
    final dTDea=dTDea,
    final controllerType=controllerType,
    final k=kHot,
    final Ti=Ti)
    "Hot side controller"
    annotation (Placement(transformation(extent={{-10,40},{10,60}})));
  SideCold1 conColSid(
    final nSouAmb=nSouAmb,
    final dTHys=dTHys,
    final dTDea=dTDea,
    final controllerType=controllerType,
    final k=kCol,
    final Ti=Ti)
    "Cold side controller"
    annotation (Placement(transformation(extent={{-10,-60},{10,-40}})));
  Buildings.Controls.OBC.CDL.Continuous.Max max1[nSouAmb]
    "Maximum of output control signals"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Reset resTSup(final THeaWatSupSetMin=THeaWatSupSetMin, final TChiWatSupSetMax=
       TChiWatSupSetMax) "Supply temperature reset"
    annotation (Placement(transformation(extent={{-80,-110},{-60,-90}})));
  RejectionMode rejMod(
    final dTDea=dTDea)
    "Rejection mode selection"
    annotation (Placement(transformation(extent={{40,80},{60,100}})));
equation
  connect(conHotSid.yAmb, max1.u1)
    annotation (Line(points={{12,49},{28,49},{28,6},{38,6}}, color={0,0,127}));
  connect(conColSid.yAmb, max1.u2) annotation (Line(points={{12,-51},{28,-51},{28,
          -6},{38,-6}}, color={0,0,127}));
  connect(resTSup.THeaWatSupSet, conHotSid.TSet) annotation (Line(points={{-58,-95},
          {-28,-95},{-28,50},{-12,50}}, color={0,0,127}));
  connect(resTSup.TChiWatSupSet, conColSid.TSet) annotation (Line(points={{-58,
          -105},{-20,-105},{-20,-50},{-12,-50}},
                                           color={0,0,127}));
  connect(conHotSid.e, rejMod.dTHeaWat) annotation (Line(points={{12,52},{16,52},
          {16,87},{38,87}}, color={0,0,127}));
  connect(conColSid.e, rejMod.dTChiWat) annotation (Line(points={{12,-48},{20,-48},
          {20,83},{38,83}}, color={0,0,127}));
  connect(rejMod.yHeaRej, conHotSid.uRej) annotation (Line(points={{62,95},{70,95},
          {70,68},{-20,68},{-20,54},{-12,54}}, color={255,0,255}));
  connect(rejMod.yColRej, conColSid.uRej) annotation (Line(points={{62,85},{80,85},
          {80,-20},{-20,-20},{-20,-46},{-12,-46}}, color={255,0,255}));
  connect(conHotSid.yDem, rejMod.uHea) annotation (Line(points={{12,56},{26,56},
          {26,96.8},{38,96.8}}, color={255,0,255}));
  connect(conColSid.yDem, rejMod.uCoo) annotation (Line(points={{12,-44},{32,-44},
          {32,93},{38,93}}, color={255,0,255}));
  connect(max1.y, yAmb)
    annotation (Line(points={{62,0},{140,0}}, color={0,0,127}));
  connect(conHotSid.yIsoAmb, yIsoCon) annotation (Line(points={{12,44},{40,44},{
          40,40},{140,40}}, color={0,0,127}));
  connect(conColSid.yIsoAmb, yIsoEva) annotation (Line(points={{12,-56},{100,-56},
          {100,20},{140,20}}, color={0,0,127}));
  connect(conHotSid.yDem, yHea) annotation (Line(points={{12,56},{100,56},{100,100},
          {140,100}}, color={255,0,255}));
  connect(conColSid.yDem, yCoo) annotation (Line(points={{12,-44},{90,-44},{90,80},
          {140,80}}, color={255,0,255}));
  connect(uHea, conHotSid.uHeaCoo) annotation (Line(points={{-140,110},{-40,110},
          {-40,58},{-12,58}}, color={255,0,255}));
  connect(uCoo, conColSid.uHeaCoo) annotation (Line(points={{-140,90},{-60,90},{
          -60,-42},{-12,-42}}, color={255,0,255}));
  connect(uCoo, resTSup.uCoo) annotation (Line(points={{-140,90},{-100,90},{-100,
          -97},{-82,-97}}, color={255,0,255}));
  connect(uHea, resTSup.uHea) annotation (Line(points={{-140,110},{-96,110},{-96,
          -92},{-82,-92}}, color={255,0,255}));
  connect(THeaWatSupPreSet, resTSup.THeaWatSupPreSet) annotation (Line(points={{
          -140,40},{-106,40},{-106,-103},{-82,-103}}, color={0,0,127}));
  connect(TChiWatSupPreSet, resTSup.TChiWatSupPreSet) annotation (Line(points={{
          -140,-40},{-112,-40},{-112,-108},{-82,-108}}, color={0,0,127}));
  connect(TChiWatTop, conColSid.TTop) annotation (Line(points={{-140,-60},{-40,-60},
          {-40,-54},{-12,-54}}, color={0,0,127}));
  connect(TChiWatBot, conColSid.TBot) annotation (Line(points={{-140,-80},{-16,-80},
          {-16,-58},{-12,-58}}, color={0,0,127}));
  connect(THeaWatTop, conHotSid.TTop) annotation (Line(points={{-140,20},{-20,20},
          {-20,46},{-12,46}}, color={0,0,127}));
  connect(THeaWatBot, conHotSid.TBot) annotation (Line(points={{-140,0},{-16,0},
          {-16,42},{-12,42}}, color={0,0,127}));
  connect(resTSup.THeaWatSupSet, THeaWatSupSet) annotation (Line(points={{-58,-95},
          {108,-95},{108,-40},{140,-40}}, color={0,0,127}));
  connect(resTSup.TChiWatSupSet, TChiWatSupSet) annotation (Line(points={{-58,-105},
          {114,-105},{114,-60},{140,-60}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-120,-120},{120,
            120}})),
        defaultComponentName="conSup",
Documentation(
revisions="<html>
<ul>
<li>
July xx, 2020, by Antoine Gautier:<br/>
First implementation
</li>
</ul>
</html>", info="<html>
<p>
This block implements the supervisory control functions of the ETS.
</p>
<ul>
<li>
It provides the tank demand signals to enable the chiller system, 
based on the logic described in
<a href=\"modelica://Buildings.Applications.DHC.EnergyTransferStations.Combined.Generation5.Controls.BaseClasses.SideHotCold\">
Buildings.Applications.DHC.EnergyTransferStations.Combined.Generation5.Controls.BaseClasses.SideHotCold</a>.
</li>
<li>
It resets the heating water and chilled water supply temperature
based on the logic described in
<a href=\"modelica://Buildings.Applications.DHC.EnergyTransferStations.Combined.Generation5.Controls.Reset\">
Buildings.Applications.DHC.EnergyTransferStations.Combined.Generation5.Controls.Reset</a>.
Note that this resetting logic is meant to operate the chiller at low lift.
The chilled water supply temperature may be reset down by
<a href=\"modelica://Buildings.Applications.DHC.EnergyTransferStations.Combined.Generation5.Controls.Chiller\">
Buildings.Applications.DHC.EnergyTransferStations.Combined.Generation5.Controls.Chiller</a>
to maintain the heating water supply temperature set point. 
This second resetting logic is required for the heating function of the unit, 
but it has a negative impact on the lift.
</li>
<li>
It controls the systems serving as ambient sources based on the logic described in
<a href=\"modelica://Buildings.Applications.DHC.EnergyTransferStations.Combined.Generation5.Controls.BaseClasses.SideHotCold\">
Buildings.Applications.DHC.EnergyTransferStations.Combined.Generation5.Controls.BaseClasses.SideHotCold</a>.
The systems are controlled based on the
maximum of the control signals yielded by the hot side and cold side controllers.
</li>
</ul>
</html>"));
end Supervisory1;
