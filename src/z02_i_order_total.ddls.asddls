@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gesamtsumme'
@Metadata.ignorePropagatedAnnotations: false
define view entity Z02_I_ORDER_TOTAL
//with parameters cust_id : z02_customer_id
 as select from Z02_I_ORDERS as orders
inner join z02customers as customer on customer.customer_id = orders.CustomerId 
// association [1..1] to ZR_02CUSTOMERS as _Customers on $projection.Id = _Customers.CustomerID

{
    key customer.customer_id as Id,
    concat_with_space( customer.first_name, customer.last_name, 1 ) as Name,

    count( distinct orders.OrderId ) as TotalOrders,

    @Semantics.amount.currencyCode : 'currency'
//    sum(orders.Amount) as Total,
    sum(
        case orders.Status 
          when 'COMPLETED' then cast( orders.Amount as abap.dec(15,2) )
          else cast( 0 as abap.dec(15,2) )
        end
      )                          as TotalRevenue,
    orders.Currency as currency
}

group by
    customer.customer_id,
    orders.Currency,
    customer.first_name,
    customer.last_name
    
