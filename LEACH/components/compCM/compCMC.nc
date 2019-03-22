
configuration compCMC
{
  provides interface compCM;
}
implementation
{
  components compCMP;
  
  compCM = compCMP;
}
