within Buildings.RoomsBeta.Examples.TestConditionalConstructions;
model OnlyExteriorWallNoWindow "Test model for room model"
  extends Modelica.Icons.Example;
  extends BaseClasses.PartialTestModel(
   nConExt=1,
   nConExtWin=0,
   nConPar=0,
   nConBou=0,
   nSurBou=0,
   roo(
    datConExt(layers={matLayExt}, each A=10,
           each til=Buildings.HeatTransfer.Types.Tilt.Floor, each azi=Buildings.HeatTransfer.Types.Azimuth.W)));
   annotation(Commands(file="OnlyExteriorWallNoWindow.mos" "run"),
   Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{
            200,160}}), graphics),
    experiment(
      StopTime=172800,
      Tolerance=1e-05,
      Algorithm="Radau"));
end OnlyExteriorWallNoWindow;
