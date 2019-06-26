
configuration CH_ElectionAppC
{
  provides interface CH_Election;
}
implementation
{
  components CH_ElectionC;
  components new AMSenderC(AM_LCA);
  CH_ElectionC.AMSend -> AMSenderC;
  
  CH_Election = CH_ElectionC;
}
