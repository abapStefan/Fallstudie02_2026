CLASS zcl_02_data_loader DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_02_DATA_LOADER IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
*
*    DATA(filler) = NEW lcl_fill_tables( ).
*
   DELETE FROM z02orders_d.
   DELETE FROM z02customers_d.
*   DELETE FROM z02orders where Order_Id = 'O000013'.
*    DELETE FROM z02status.
*    DELETE FROM z02materials.
*    DELETE FROM z02customers.
*
*    filler->fill_customers( ).
*    filler->fill_status( ).
*    filler->fill_materials( ).
*    filler->fill_orders( ).

    out->write( 'data_loader finished!' ).

  ENDMETHOD.
ENDCLASS.
