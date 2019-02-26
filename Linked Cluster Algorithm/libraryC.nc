
configuration libraryC
{
  provides interface library;
}
implementation
{
  components libraryP;
  
  library = libraryP;
}
