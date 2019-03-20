
configuration compCHC
{
  provides interface compCH;
}
implementation
{
  components compCHP;
  
  compCH = compCHP;
}
