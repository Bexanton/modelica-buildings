within Buildings.Fluid.HeatExchangers.CoolingTowers.Validation;
model MerkelEnergyPlus
  "Validation with EnergyPlus model for Merkel's cooling tower"
  extends Modelica.Icons.Example;

  package MediumAir = Buildings.Media.Air "Air medium model";
  package MediumWat = Buildings.Media.Water "Water medium model";

  parameter Modelica.SIunits.Density denAir=
    MediumAir.density(
      MediumAir.setState_pTX(MediumAir.p_default, MediumAir.T_default, MediumAir.X_default))
      "Default density of air";
  parameter Modelica.SIunits.Density denWat=
    MediumWat.density(
      MediumWat.setState_pTX(MediumWat.p_default, MediumWat.T_default, MediumWat.X_default))
      "Default density of water";

  // Cooling tower parameters
  parameter Modelica.SIunits.PressureDifference dp_nominal = 6000
    "Nominal pressure difference of cooling tower";
  parameter Modelica.SIunits.VolumeFlowRate vAir_flow_nominal = 0.56054
    "Nominal volumetric flow rate of air (medium 1)";
  parameter Modelica.SIunits.VolumeFlowRate vWat_flow_nominal = 0.00109181
    "Nominal volumetric flow rate of water (medium 2)";
  parameter Modelica.SIunits.MassFlowRate mAir_flow_nominal=
    vAir_flow_nominal * denAir
    "Nominal mass flow rate of air (medium 1)";
  parameter Modelica.SIunits.MassFlowRate mWat_flow_nominal=
    vWat_flow_nominal * denWat
    "Nominal mass flow rate of water (medium 2)";
  parameter Modelica.SIunits.Temperature TAirInWB_nominal = 20.59+273.15
    "Nominal outdoor wetbulb temperature";
  parameter Modelica.SIunits.Temperature TWatIn_nominal = 34.16+273.15
    "Nominal water inlet temperature";
  parameter Modelica.SIunits.Temperature TAirOutWB_nominal = 26+273.15
    "Nominal air outlet wetbulb temperature";
  parameter Modelica.SIunits.Temperature TWatOut_nominal = 21+273.15
    "Nominal water outlet temperature";
  parameter Modelica.SIunits.Temperature TWatOut_initial = 33.019+273.15
    "Nominal water inlet temperature";
  parameter Modelica.SIunits.HeatFlowRate Q_flow_nominal = 20286.37455
    "Nominal heat transfer, positive";
  parameter Modelica.SIunits.ThermalConductance UA_nominal = 2011.28668
    "Nominal heat transfer, positive";
  parameter Modelica.SIunits.Power PFan_nominal = 213.00693
    "Nominal fan power";

  parameter Real r_VEnePlu[:] = {0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,
    0.65,0.7,0.75,0.8,0.85,0.9,0.95,1}
    "Fan control signal";
  parameter Real r_PEnePlu[:] = {0,0.005913403484561,0.014533379334138,
    0.026641366223909,0.043018802829049,0.064447127824737,0.091707779886148,
    0.125582197688459,0.166851819906848,0.21629808521649,0.274702432292564,
    0.342846299810245,0.421511126444711,0.511478350871139,0.613529411764704,
    0.728445747800585,0.857008797653957,1}
    "Fan power output as a function of the signal";

  Merkel tow(
    redeclare package Medium = MediumWat,
    dp_nominal=dp_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=TWatOut_initial,
    m1_flow_nominal=mAir_flow_nominal,
    m2_flow_nominal=mWat_flow_nominal,
    TAirInWB_nominal=TAirInWB_nominal,
    TWatIn_nominal=TWatIn_nominal,
    TAirOutWB_nominal=TAirOutWB_nominal,
    TWatOut_nominal=TWatOut_nominal,
    Q_flow_nominal=Q_flow_nominal,
    PFan_nominal=PFan_nominal,
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
    yMin=0.01,
    fraFreCon=0.1,
    fanRelPow(r_V=r_VEnePlu, r_P=r_PEnePlu),
    UACor(FRAirMin=0.2),
    UA_nominal=UA_nominal)
    "Merkel-theory based cooling tower"
    annotation (Placement(transformation(extent={{40,-60},{60,-40}})));

  Sources.MassFlowSource_T souWat(
    redeclare package Medium = MediumWat,
    use_m_flow_in=true,
    T=328.15,
    nPorts=1,
    use_T_in=true)
    "Water source to the cooling tower"
    annotation (Placement(transformation(extent={{-20,-60},{0,-40}})));

  Sources.Boundary_pT sinWat(redeclare package Medium = MediumWat,nPorts=1)
    "Water sink from the cooling tower"
    annotation (Placement(transformation(extent={{100,-60},{80,-40}})));

  Modelica.Blocks.Sources.CombiTimeTable datRea(
    tableOnFile=true,
    fileName=ModelicaServices.ExternalReferences.loadResource(
      "modelica://Buildings//Resources/Data/Fluid/HeatExchangers/CoolingTowers/Validation/MerkelEnergyPlus/modelica.csv"),
    columns=2:16,
    tableName="modelica",
    smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments)
    "Reader for \"CoolingTower_VariableSpeed_Merkel.idf\" energy plus example results"
    annotation (Placement(transformation(extent={{-100,40},{-80,60}})));

  Controls.OBC.UnitConversions.From_degC TEntWat
    "Block that converts entering water temperature"
    annotation (Placement(transformation(extent={{-60,-56},{-40,-36}})));

  Controls.OBC.UnitConversions.From_degC TAirWB
    "Block that converts entering air wetbulb temperature"
    annotation (Placement(transformation(extent={{-60,0},{-40,20}})));

  Modelica.Blocks.Sources.RealExpression TLvg_EP(y=datRea.y[4])
    "EnergyPlus results: cooling tower leaving water temperature"
    annotation (Placement(transformation(extent={{80,40},{100,60}})));

  Modelica.Blocks.Sources.RealExpression Q_flow_EP(y=-1*datRea.y[6])
    "EnergyPlus results: cooling tower heat flow rate"
    annotation (Placement(transformation(extent={{80,20},{100,40}})));

  Modelica.Blocks.Sources.RealExpression PFan_EP(y=datRea.y[7])
    "EnergyPlus results: fan power consumption"
    annotation (Placement(transformation(extent={{80,0},{100,20}})));

equation
  connect(tow.TAir, TAirWB.y)
    annotation (Line(points={{38,-46},{20,-46},{20,10},{-38,10}},
      color={0,0,127}));
  connect(souWat.ports[1], tow.port_a)
    annotation (Line(points={{0,-50},{40,-50}}, color={0,127,255}));
  connect(tow.port_b, sinWat.ports[1])
    annotation (Line(points={{60,-50},{80,-50}}, color={0,127,255}));
  connect(TEntWat.y, souWat.T_in)
    annotation (Line(points={{-38,-46},{-22,-46}},color={0,0,127}));
  connect(datRea.y[2], TAirWB.u)
    annotation (Line(points={{-79,50},{-70,50},{-70,10},{-62,10}},
      color={0,0,127}));
  connect(TEntWat.u, datRea.y[3])
    annotation (Line(points={{-62,-46},{-70,-46},{-70,50},{-79,50}},
       color={0,0,127}));
  connect(souWat.m_flow_in, datRea.y[5])
    annotation (Line(points={{-22,-42},{-30,-42},{-30,-20},{-70,-20},
      {-70,50},{-79,50}}, color={0,0,127}));
  connect(tow.y, datRea.y[9])
    annotation (Line(points={{38,-42},{30,-42},{30,50},
          {-79,50}}, color={0,0,127}));

  annotation (Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false,
        extent={{-120,-100},{120,100}})),
    __Dymola_Commands(file=
        "modelica://Buildings/Resources/Scripts/Dymola/Fluid/HeatExchangers/CoolingTowers/Validation/MerkelEnergyPlus.mos"
        "Simulate and plot"),
    experiment(
      StartTime=0,
      StopTime=86400,
      Tolerance=1e-06),
    Documentation(info="<html>
<p>
This model validates the model
<a href=\"modelica://Buildings.Fluid.HeatExchangers.CoolingTowers.Merkel\">
Buildings.Fluid.HeatExchangers.CoolingTowers.Merkel</a> by comparing against 
results obtained from EnergyPlus 9.2.
</p>
<p>
The EnergyPlus results were obtained using the example file 
<code>CoolingTower:VariableSpeed</code>, with the cooling tower evaluated as 
the <code>CoolingTower:VariableSpeed:Merkel</code> model from EnergyPlus 9.2. 
</p>
<p>
The difference in results of the cooling tower's leaving water temperature
(<code>tow.TLvg</code> and <code>TLvg.EP</code>)
during the middle and end of the simulation is because the mass flow rate is 
zero. For zero mass flow rate, EnergyPlus assumes a steady state condition,
whereas the Modelica model is a dynamic model and hence the properties at the 
outlet are equal to the state variables of the model.
</p>
</html>", revisions="<html>
<ul>
<li>
December 23, 2019 by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end MerkelEnergyPlus;
