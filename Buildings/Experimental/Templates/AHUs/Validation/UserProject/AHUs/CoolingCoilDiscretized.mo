within Buildings.Experimental.Templates.AHUs.Validation.UserProject.AHUs;
model CoolingCoilDiscretized
  extends Templates.AHUs.Main.VAVSingleDuct(redeclare Coils.WaterBased coiCoo(
        redeclare
        Buildings.Experimental.Templates.AHUs.Coils.HeatExchangers.Discretized
        coi), redeclare record RecordCoiCoo = Coils.Data.WaterBased (redeclare
          Buildings.Experimental.Templates.AHUs.Coils.HeatExchangers.Data.Discretized
          datHex));

  annotation (
    defaultComponentName="ahu");
end CoolingCoilDiscretized;
