
configuration Library_AggregationC
{
  provides interface Library_Aggregation;
}
implementation
{
  components Library_AggregationP;
  
  Library_Aggregation = Library_AggregationP;
}
