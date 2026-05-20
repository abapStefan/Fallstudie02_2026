@EndUserText.label: 'Orders by Status'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI.presentationVariant: [
  {
    visualizations: [ { type: #AS_CHART } ]
  }
]

@UI.chart: [
  {
    qualifier: 'StatusChart',
    chartType: #DONUT,
    dimensions: [ 'Status' ],
    measures: [ 'NumberOfOrders' ]
  }
]

define view entity Z02_R_ORDERS_STATUS
  as select from Z02_I_ORDERS as Orders
{
  @UI.lineItem: [ { position: 10 } ]
  key Orders.Status as Status,

  @UI.lineItem: [ { position: 20 } ]
  count( * ) as NumberOfOrders
}
group by
  Orders.Status
