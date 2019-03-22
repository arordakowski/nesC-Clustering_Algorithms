
configuration compSensorC
{
  provides interface compSensor;
}
implementation
{
  components compSensorP;
  compSensor = compSensorP;
}
