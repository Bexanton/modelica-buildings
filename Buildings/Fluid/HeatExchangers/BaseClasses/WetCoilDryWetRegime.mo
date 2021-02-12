within Buildings.Fluid.HeatExchangers.BaseClasses;
model WetCoilDryWetRegime
  "This model represents the switching algorithm of the TK-fuzzy model for cooling coil applicaiton"
  input Real Qfac;
  replaceable package Medium2 = Modelica.Media.Interfaces.PartialMedium
    "Medium 2 in the component"
    annotation (choicesAllMatching = true);

  parameter Modelica.SIunits.MassFlowRate mWat_flow_nominal(min=0)
    "Nominal mass flow rate for water"
    annotation(Dialog(group = "Nominal condition"));
  parameter Modelica.SIunits.MassFlowRate mAir_flow_nominal(min=0)
    "Nominal mass flow rate for air"
    annotation(Dialog(group = "Nominal condition"));

  input Buildings.Fluid.Types.HeatExchangerFlowRegime cfg=
    Buildings.Fluid.Types.HeatExchangerFlowRegime.CounterFlow;

  // -- Water
  Modelica.Blocks.Interfaces.RealInput UAWat(
    final quantity="ThermalConductance",
    final unit="W/K")
    "Product of heat transfer coefficient times area for \"water\" side"
    annotation (Placement(transformation(extent={{-160,100},{-140,120}}),
        iconTransformation(extent={{-160,100},{-140,120}})));
  Modelica.Blocks.Interfaces.RealInput mWat_flow(
    quantity="MassFlowRate",
    min = 0,
    final unit="kg/s")
    "Mass flow rate for water"
    annotation (Placement(transformation(extent={{-160,80},{-140,100}}),
        iconTransformation(extent={{-160,80},{-140,100}})));
  Modelica.Blocks.Interfaces.RealInput cpWat(
    final quantity="SpecificHeatCapacity",
    final unit="J/(kg.K)")
    "Inlet water temperature"
    annotation (Placement(transformation(extent={{-160,60},{-140,80}}),
        iconTransformation(extent={{-160,60},{-140,80}})));
  Modelica.Blocks.Interfaces.RealInput TWatIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    min = 200,
    start = 288.15,
    nominal = 300,
    displayUnit="degC")
    "Inlet water temperature"
    annotation (Placement(transformation(extent={{-160,40},{-140,60}}),
        iconTransformation(extent={{-160,40},{-140,60}})));
  // -- Air
  Modelica.Blocks.Interfaces.RealInput UAAir(
    final quantity="ThermalConductance",
    final unit="W/K")
    "Product of heat transfer coefficient times area for air side"
    annotation (Placement(transformation(extent={{-160,-120},{-140,-100}}),
        iconTransformation(extent={{-160,-120},{-140,-100}})));
  Modelica.Blocks.Interfaces.RealInput mAir_flow(
    quantity="MassFlowRate",
    min = 0,
    final unit="kg/s")
    "Mass flow rate for air"
    annotation (Placement(transformation(extent={{-160,-100},{-140,-80}}),
        iconTransformation(extent={{-160,-100},{-140,-80}})));
  Modelica.Blocks.Interfaces.RealInput cpAir(
    final quantity="SpecificHeatCapacity",
    final unit="J/(kg.K)")
    "Inlet specific heat capacity (at constant pressure)"
    annotation (Placement(
        transformation(extent={{-160,-80},{-140,-60}}), iconTransformation(
          extent={{-160,-80},{-140,-60}})));
  Modelica.Blocks.Interfaces.RealInput TAirIn(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    min = 200,
    start = 288.15,
    nominal = 300,
    displayUnit="degC")
    "Inlet air temperature"
    annotation (Placement(transformation(extent={{-160,-60},{-140,-40}}),
        iconTransformation(extent={{-160,-60},{-140,-40}})));
  Modelica.Blocks.Interfaces.RealInput hAirIn(
    final quantity="SpecificEnergy",
    final unit="J/kg")
    "Inlet air enthalpy"
    annotation (
      Placement(transformation(extent={{-160,-40},{-140,-20}}),
        iconTransformation(extent={{-160,-40},{-140,-20}})));
  Modelica.Blocks.Interfaces.RealInput pAir(
    final quantity="Pressure",
    final unit="Pa",
    displayUnit="bar",
    min=70000,
    nominal = 1e5)
    "Inlet air absolute pressure"
    annotation (Placement(transformation(extent={{-160,-20},{-140,0}}),
        iconTransformation(extent={{-160,-20},{-140,0}})));
  Modelica.Blocks.Interfaces.RealInput wAirIn(
    min=0,
    max=1,
    unit="1")
    "Humidity ratio of water at inlet (kg water/kg moist air)"
    annotation (
      Placement(transformation(extent={{-160,0},{-140,20}}), iconTransformation(
          extent={{-160,0},{-140,20}})));

  Modelica.Blocks.Interfaces.RealOutput QTot_flow(
    final quantity="Power",
    final unit="W")
    "Total heat transfer from water into air, negative for cooling"
    annotation (
      Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={150,-20})));
  Modelica.Blocks.Interfaces.RealOutput QSen_flow(
    final quantity="Power",
    final unit="W")
    "Sensible heat transfer from water into air, negative for cooling"
    annotation (
      Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={150,-60})));
  Modelica.SIunits.HeatFlowRate QLat_flow  "Latent heat transfer rate";

  Modelica.Blocks.Interfaces.RealOutput mCon_flow(
    quantity="MassFlowRate",
    final unit="kg/s")
    "Mass flow of the condensate, negative for dehumidification"
    annotation (
      Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={150,-100})));
  Buildings.Fluid.HeatExchangers.BaseClasses.WetCoilDryRegime fullydry(
    UAWat=UAWat,
    mWat_flow=mWat_flow,
    cpWat=cpWat,
    TWatIn=TWatIn,
    UAAir=UAAir,
    mAir_flow=mAir_flow,
    mWatNonZer_flow=mWatNonZer_flow,
    mAirNonZer_flow=mAirNonZer_flow,
    cpAir=cpAir,
    TAirIn=TAirIn,
    final cfg=cfg,
    mAir_flow_nominal=mAir_flow_nominal,
    mWat_flow_nominal=mWat_flow_nominal);

  Buildings.Fluid.HeatExchangers.BaseClasses.WetCoilWetRegime fullywet(
    UAWat=UAWat,
    mWat_flow=mWat_flow,
    cpWat=cpWat,
    TWatIn=TWatIn,
    UAAir=UAAir,
    mAir_flow=mAir_flow,
    mWatNonZer_flow=mWatNonZer_flow,
    mAirNonZer_flow=mAirNonZer_flow,
    cpAir=cpAir,
    TAirIn=TAirIn,
    final cfg=cfg,
    mAir_flow_nominal=mAir_flow_nominal,
    mWat_flow_nominal=mWat_flow_nominal,
    pAir=pAir,
    wAirIn=wAirIn);

protected
  Modelica.SIunits.MassFlowRate mAirNonZer_flow(min=Modelica.Constants.eps)=
    Buildings.Utilities.Math.Functions.smoothMax(
      x1=mAir_flow,
      x2=1E-3       *mAir_flow_nominal,
      deltaX=0.25E-3*mAir_flow_nominal)
    "Mass flow rate of air";
  Modelica.SIunits.MassFlowRate mWatNonZer_flow(min=Modelica.Constants.eps)=
    Buildings.Utilities.Math.Functions.smoothMax(
      x1=mWat_flow,
      x2=1E-3       *mWat_flow_nominal,
      deltaX=0.25E-3*mWat_flow_nominal)
    "Mass flow rate of water";

  Modelica.SIunits.Temperature TAirInDewPoi
    "Dew point temperature of incoming air";

  Buildings.Utilities.Psychrometrics.pW_X pWIn(X_w=wAirIn,p_in=pAir);
  Buildings.Utilities.Psychrometrics.TDewPoi_pW TDewIn(p_w=pWIn.p_w);

  //-- parameters for fuzzy logics
  Real mu_FW(final unit="1", min=0, max=1), mu_FD(unit="1",min=0, max=1)
    "membership functions for Fully-Wet and Fully-Dry conditions";
  Real w_FW(final unit="1", min=0, max=1),  w_FD(unit="1",min=0, max=1)
    "normailized weight functions for Fully-Wet and Fully-Dry conditions";
  Real dryFra(final unit="1", min=0, max=1)
    "dry fraction, e.g., 0.3 means condensation occurs at 30% HX length from air inlet";

equation

  TAirInDewPoi=TDewIn.T;

  mu_FW= Buildings.Utilities.Math.Functions.spliceFunction(
  pos=0,neg=1,x=fullywet.TSurAirIn-TAirInDewPoi,deltax=max(abs(fullydry.TSurAirOut- fullywet.TSurAirIn),1e-3));
  mu_FD= Buildings.Utilities.Math.Functions.spliceFunction(
  pos=1,neg=0,x=fullydry.TSurAirOut-TAirInDewPoi,deltax=max(abs(fullydry.TSurAirOut- fullywet.TSurAirIn),1e-3));

  w_FW=mu_FW/(mu_FW+mu_FD);
  w_FD=mu_FD/(mu_FW+mu_FD);

  QTot_flow= -(w_FW*fullywet.QTot_flow+w_FD*fullydry.QTot_flow)*Qfac;
  QSen_flow= -(w_FW*fullywet.QSen_flow+w_FD*fullydry.QTot_flow)*Qfac;
  dryFra= w_FD;

  QLat_flow=QTot_flow-QSen_flow;
  mCon_flow=QLat_flow/Buildings.Utilities.Psychrometrics.Constants.h_fg*Qfac;
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-140,-120},
            {140,120}}), graphics={
        Rectangle(
          extent={{-140,120},{140,-120}},
          lineColor={0,0,0},
          lineThickness=0.5,
          pattern=LinePattern.Dot,
          fillColor={236,236,236},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{20,40},{100,-40}},
          lineColor={28,108,200},
          fillColor={170,227,255},
          fillPattern=FillPattern.Forward),
        Text(
          extent={{24,36},{96,2}},
          textStyle={TextStyle.Bold},
          pattern=LinePattern.None,
          textString="WET",
          lineColor={0,0,0}),
        Line(
          points={{20,0},{120,0}},
          color={28,108,200},
          thickness=1,
          pattern=LinePattern.Dash),
        Ellipse(
          extent={{72,0},{66,-6}},
          lineColor={28,108,200},
          fillColor={170,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{82,-4},{76,-10}},
          lineColor={28,108,200},
          fillColor={170,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{96,0},{88,-8}},
          lineColor={28,108,200},
          fillColor={170,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{64,-4},{58,-10}},
          lineColor={28,108,200},
          fillColor={170,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{54,0},{48,-6}},
          lineColor={28,108,200},
          fillColor={170,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{42,-4},{36,-10}},
          lineColor={28,108,200},
          fillColor={170,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{32,0},{24,-8}},
          lineColor={28,108,200},
          fillColor={170,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,40},{20,-40}},
          lineColor={28,108,200},
          fillColor={255,213,170},
          fillPattern=FillPattern.Forward),
        Text(
          extent={{-16,-4},{56,-38}},
          textStyle={TextStyle.Bold},
          textString="CALCS",
          pattern=LinePattern.None),
        Line(
          points={{-80,0},{20,0}},
          color={28,108,200},
          thickness=1,
          pattern=LinePattern.Dash),
        Text(
          extent={{-56,36},{16,2}},
          textStyle={TextStyle.Bold},
          textString="DRY",
          pattern=LinePattern.None),
        Text(
          extent={{-22,60},{58,40}},
          lineColor={28,108,200},
          fillColor={170,170,255},
          fillPattern=FillPattern.Forward,
          textString="Water",
          textStyle={TextStyle.Italic}),
        Text(
          extent={{-20,-40},{60,-60}},
          lineColor={28,108,200},
          fillColor={170,170,255},
          fillPattern=FillPattern.Forward,
          textString="Air",
          textStyle={TextStyle.Italic}),
        Text(
          extent={{-116,-104},{-116,-116}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="hA"),
        Text(
          extent={{-116,116},{-116,104}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="hA"),
        Text(
          extent={{-116,96},{-116,84}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="masFlo"),
        Text(
          extent={{-116,76},{-116,64}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="cp"),
        Text(
          extent={{-116,56},{-116,44}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="T_in"),
        Text(
          extent={{-116,-84},{-116,-96}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="masFlo"),
        Text(
          extent={{-116,-64},{-116,-76}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="cp"),
        Text(
          extent={{-116,-44},{-116,-56}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="T_in"),
        Text(
          extent={{-116,-24},{-116,-36}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="h_in"),
        Text(
          extent={{-116,-4},{-116,-16}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="p_in"),
        Text(
          extent={{-116,16},{-116,4}},
          lineColor={28,108,200},
          horizontalAlignment=TextAlignment.Left,
          textString="w_in"),
        Text(
          extent={{120,-12},{120,-24}},
          lineColor={28,108,200},
          textString="QTot_flow"),
        Text(
          extent={{104,-94},{104,-106}},
          lineColor={28,108,200},
          textString="mCon_flow"),
        Text(
          extent={{118,-52},{118,-64}},
          lineColor={28,108,200},
          textString="QSen")}),                                  Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-140,-120},{140,120}}),
        graphics={Text(
          extent={{-100,120},{-20,80}},
          lineColor={28,108,200},
          fillColor={170,227,255},
          fillPattern=FillPattern.Forward,
          horizontalAlignment=TextAlignment.Left,
          textString="Note: please see text file for explicit
connections; there are too many
connections to show graphically here")}),
    Documentation(revisions="<html>
<ul>
<li>Jan 21, 2021, by Donghun Kim:<br>First implementation of the fuzzy model. See <a href=\"https://github.com/lbl-srg/modelica-buildings/issues/622\">issue 622</a> for more information. </li>
</ul>
</html>", info="<html>
<p>The switching criteria for (counter-flow) cooling coil modes are as follows.</p>
<p>R1: If the coil surface temperature at the air inlet is lower than the dew-point temperature at the inlet to the coil, then the cooling coil surface is fully-wet.</p>
<p>R2: If the surface temperature at the air outlet section is higher than the dew-point temperature of the air at the inlet, then the cooling coil surface is fully-dry.</p>
<p>At each point of a simulation time step, the fuzzy-modeling approach determines the weights for R1 and R2 respectively (namely &mu;<sub>FW</sub> and &mu;<sub>FD</sub>) from the dew-point and coil surface temperatures. </p>
<p>It calculates total and sensible heat transfer rates according to the weights as follows. </p>
<p>Q<sub>tot</sub>=&mu;<sub>FD</sub> Q<sub>tot,FD</sub>+&mu;<sub>FW</sub> Q<sub>tot,FW</sub></p>
<p>Q<sub>sen</sub>=&mu;<sub>FD</sub> Q<sub>sen,FD</sub>+&mu;<sub>FW</sub> Q<sub>sen,FW</sub></p>
<p>The fuzzy-modeling ensures &mu;<sub>FW</sub> + &mu;<sub>FD</sub> = 1, &mu;<sub>FW</sub> &gt;=0, &mu;<sub>FD</sub> &gt;=0, which means the fuzzy model outcomes of Qsen and Qtot are always convex combinations of heat transfer rates for fully-dry and fully-wet modes and therefore are always bounded by them. </p>
<p>The modeling approach also results in n-th order differentiable model depending on the selection of the underlying membership functions. This cooling coil model is once continuously differentiable even at the transition (or mode-switching) points.</p>
</html>"));
end WetCoilDryWetRegime;
