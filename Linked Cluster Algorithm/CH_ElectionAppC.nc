
configuration CH_ElectionAppC
{
  provides interface CH_Election;
}
implementation
{
  components CH_ElectionC;
  
  CH_Election = CH_ElectionC;
}
