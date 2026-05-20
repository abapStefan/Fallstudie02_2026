@EndUserText.label: 'Orders Analytics'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI.chart: [{
  chartType: #DONUT,
  dimensions: [ 'Status' ],
  measures: [ 'Amount' ]
}]
define view entity Z02_Q_ORDERS_ANALYTICS
  as select from Z02_C_ORDERS_ANALYTICS
{
  key OrderId,
      CustomerId,
      OrderDate,
      Status,
      MaterialId,

      @Semantics.amount.currencyCode: 'Currency'
      Amount,

      Currency
}
