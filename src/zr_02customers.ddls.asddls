@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'Z02CUSTOMERS'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_02CUSTOMERS
  as select from z02customers as Z02RCustomers
  //   composition [0..*] of Z02_I_ORDERS as _Orders
  composition [0..*] of ZR_02ORDES        as _Orders
  association [0..1] to Z02_I_ORDER_TOTAL as _Summary on $projection.CustomerID = _Summary.Id
{
      //@UI.facet: [
      //             { id: 'General',
      //               type: #IDENTIFICATION_REFERENCE,
      //               label: 'Kunde' },
      //
      //             { id: 'Orders',
      //               type: #LINEITEM_REFERENCE,
      //               targetElement: '_Orders',
      //               label: 'Bestellungen'
      //             }
      //           ]
  key customer_id           as CustomerID,
      first_name            as FirstName,
      last_name             as LastName,
      street                as Street,
      postal_code           as PostalCode,
      city                  as City,
      country               as Country,
      phone_number          as PhoneNumber,
      notes                 as Notes,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Summary.Name         as Name,
      _Summary.TotalOrders  as TotalOrders,
      @Semantics.amount.currencyCode: 'Currency'
      _Summary.TotalRevenue as TotalRevenue,
      _Summary.currency     as Currency, // Ensure the currency is available for the revenue sum
      _Summary,
      _Orders
}
