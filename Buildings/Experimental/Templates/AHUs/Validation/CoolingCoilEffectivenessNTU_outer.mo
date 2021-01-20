within Buildings.Experimental.Templates.AHUs.Validation;
model CoolingCoilEffectivenessNTU_outer
  extends NoEquipment_outer(
                      ahu(redeclare Coils.Data.CoolingWater datCoi(
          redeclare
          Buildings.Experimental.Templates.AHUs.Coils.HeatExchangers.Data.EffectivenessNTU
          datHex(T_a1_nominal=278.15)), redeclare Coils.CoolingWater_outer
        coiCoo(redeclare
          Buildings.Experimental.Templates.AHUs.Coils.HeatExchangers.EffectivenessNTU
          coi)));

  Fluid.Sources.Boundary_pT bou2(
    redeclare final package Medium = MediumCoo,
      nPorts=2)
    annotation (Placement(transformation(extent={{-60,-60},{-40,-40}})));
equation
  connect(bou2.ports[1], ahu.port_coiCooSup)
    annotation (Line(points={{-40,-48},{-2,-48},{-2,-20}}, color={0,127,255}));
  connect(bou2.ports[2], ahu.port_coiCooRet)
    annotation (Line(points={{-40,-52},{2,-52},{2,-20}}, color={0,127,255}));
end CoolingCoilEffectivenessNTU_outer;
