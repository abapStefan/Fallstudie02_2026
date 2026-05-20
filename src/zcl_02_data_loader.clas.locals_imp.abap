*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_fill_tables DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS fill_Customers.
    METHODS fill_Status.
    METHODS fill_Materials.
    METHODS fill_Orders.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_fill_tables IMPLEMENTATION.

  METHOD fill_orders.
    DATA: lt_orders    TYPE TABLE OF z02orders,
          lv_timestamp TYPE timestampl.

    GET TIME STAMP FIELD lv_timestamp.

    " Clear existing data for a clean start
    " DELETE FROM z02orders.

    " Populate the 5 orders directly based on your updated DB fields
    lt_orders = VALUE #(
      ( order_id   = 'O000001'
        customer_id   = 'C00001'
        order_date = '20260202'
        material_id = 'M001'
        quantity = 5
        amount = '500'
        currency = 'EUR'
        status = 'COMPLETED' )

        ( order_id   = 'O000002'
        customer_id   = 'C00002'
        order_date = '20260305'
        material_id = 'M002'
        quantity = 50
        amount = '1000'
        currency = 'EUR'
        status = 'CANCELED' )

        ( order_id   = 'O000003'
        customer_id   = 'C00003'
        order_date = '20260505'
        material_id = 'M001'
        quantity = 10
        amount = '1500'
        currency = 'EUR'
        status = 'NEW' )

        ( order_id   = 'O000004'
        customer_id   = 'C00004'
        order_date = '20251209'
        material_id = 'M003'
        quantity = 30
        amount = '2000'
        currency = 'EUR'
        status = 'COMPLETED' )

        ( order_id   = 'O000005'
        customer_id   = 'C00003'
        order_date = '20240505'
        material_id = 'M004'
        quantity = 20
        amount = '730'
        currency = 'EUR'
        status = 'COMPLETED' )

        ( order_id   = 'O000006'
        customer_id   = 'C00002'
        order_date = '20260504'
        material_id = 'M002'
        quantity = 5
        amount = '90.35'
        currency = 'EUR'
        status = 'PENDING' )

        ( order_id   = 'O000007'
        customer_id   = 'C00001'
        order_date = '19901123'
        material_id = 'M004'
        quantity = 25
        amount = '860.50'
        currency = 'EUR'
        status = 'COMPLETED' )

        ( order_id   = 'O000008'
        customer_id   = 'C00005'
        order_date = '20140806'
        material_id = 'M001'
        quantity = 100
        amount = '1200'
        currency = 'EUR'
        status = 'CANCELED' )

        ( order_id   = 'O000009'
        customer_id   = 'C00004'
        order_date = '20260405'
        material_id = 'M003'
        quantity = 40
        amount = '1600'
        currency = 'EUR'
        status = 'COMPLETED' )

        ( order_id   = 'O000010'
        customer_id   = 'C00003'
        order_date = '20260501'
        material_id = 'M001'
        quantity = 50
        amount = '970'
        currency = 'EUR'
        status = 'COMPLETED' )

        ( order_id   = 'O000011'
        customer_id   = 'C00001'
        order_date = '20260504'
        material_id = 'M003'
        quantity = 25
        amount = '1000'
        currency = 'EUR'
        status = 'CANCELED' )

        ( order_id   = 'O000012'
        customer_id   = 'C00001'
        order_date = '20260505'
        material_id = 'M002'
        quantity = 15
        amount = '100'
        currency = 'EUR'
        status = 'COMPLETED' )

        ).

    " Fill technical client and administrative data
    LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<fs_orders>).
      <fs_orders>-client        = sy-mandt.

      " Admin data from /lrn/s_admin
      <fs_orders>-created_by            = sy-uname.
      <fs_orders>-created_at            = lv_timestamp.
      <fs_orders>-local_last_changed_by = sy-uname.
      <fs_orders>-last_changed_at       = lv_timestamp.
      <fs_orders>-local_last_changed_at = lv_timestamp.
    ENDLOOP.

    INSERT z02orders FROM TABLE @lt_orders.

  ENDMETHOD.

  METHOD fill_status.

    DATA: lt_status    TYPE TABLE OF z02status,
          lv_timestamp TYPE timestampl.

    GET TIME STAMP FIELD lv_timestamp.

    " Clear existing data for a clean start
    " DELETE FROM z02status.

    " Populate the 5 status directly based on your updated DB fields
    lt_status = VALUE #(
      ( status   = 'NEW' )
      ( status   = 'PENDING' )
      ( status   = 'COMPLETED' )
      ( status   = 'CANCELED' )
      ).

    " Fill technical client and administrative data
    LOOP AT lt_status ASSIGNING FIELD-SYMBOL(<fs_status>).
      <fs_status>-client        = sy-mandt.

      " Admin data from /lrn/s_admin
      <fs_status>-created_by            = sy-uname.
      <fs_status>-created_at            = lv_timestamp.
      <fs_status>-local_last_changed_by = sy-uname.
      <fs_status>-last_changed_at       = lv_timestamp.
      <fs_status>-local_last_changed_at = lv_timestamp.
    ENDLOOP.

    INSERT z02status FROM TABLE @lt_status.


  ENDMETHOD.

  METHOD fill_customers.
    DATA: lt_customers TYPE TABLE OF z02customers,
          lv_timestamp TYPE timestampl.

    GET TIME STAMP FIELD lv_timestamp.

    " Clear existing data for a clean start
    " DELETE FROM z02customers.

    " Populate the 5 customers directly based on your updated DB fields
    lt_customers = VALUE #(
      ( customer_id   = 'C00001'
        first_name    = 'Melinda'
        last_name     = 'Vauter'
        phone_number  = '+49 885 727 4672'
        street        = 'Elbchaussee 25'
        postal_code   = '20249'
        city          = 'Hamburg'
        country       = 'DE'
        notes         = 'Hettinger, Hilll and McLaughlin' )

      ( customer_id   = 'C00002'
        first_name    = 'Miof mela'
        last_name     = 'Cornely'
        phone_number  = '+49 107 431 0055'
        street        = 'Alexanderplatz 10'
        postal_code   = '12683'
        city          = 'Berlin'
        country       = 'DE'
        notes         = 'Howe Group' )

      ( customer_id   = 'C00003'
        first_name    = 'Buddie'
        last_name     = 'Adelman'
        phone_number  = '+49 369 719 8413'
        street        = 'Engelbertstraße 38'
        postal_code   = '41468'
        city          = 'Neuss'
        country       = 'DE'
        notes         = 'Grant LLC' )

      ( customer_id   = 'C00004'
        first_name    = 'Kendra'
        last_name     = 'Bleythin'
        phone_number  = '+49 578 852 6047'
        street        = 'Schönhauser Allee 145'
        postal_code   = '12559'
        city          = 'Berlin'
        country       = 'DE'
        notes         = 'Wolf-Roob' )

      ( customer_id   = 'C00005'
        first_name    = 'Janene'
        last_name     = 'Redmond'
        phone_number  = '+49 694 829 8823'
        street        = 'Zwickauer Straße 98'
        postal_code   = '09116'
        city          = 'Chemnitz'
        country       = 'DE'
        notes         = 'Kuhlman Inc' )
    ).

    " Fill technical client and administrative data
    LOOP AT lt_customers ASSIGNING FIELD-SYMBOL(<fs_customer>).
      <fs_customer>-client        = sy-mandt.

      " Admin data from /lrn/s_admin
      <fs_customer>-created_by            = sy-uname.
      <fs_customer>-created_at            = lv_timestamp.
      <fs_customer>-local_last_changed_by = sy-uname.
      <fs_customer>-last_changed_at       = lv_timestamp.
      <fs_customer>-local_last_changed_at = lv_timestamp.
    ENDLOOP.

    " Insert into database
    INSERT z02customers FROM TABLE @lt_customers.

  ENDMETHOD.

  METHOD fill_materials.

    DATA: lt_materials    TYPE TABLE OF z02materials,
          lv_timestamp TYPE timestampl.

    GET TIME STAMP FIELD lv_timestamp.

    " Clear existing data for a clean start
    " DELETE FROM z02status.

    " Populate the 5 status directly based on your updated DB fields
    lt_materials = VALUE #(
      ( material_id = 'M001' material_name   = 'Note Book' price = '1249.99' currency = 'EUR' )
      ( material_id = 'M002' material_name   = 'Mouse'     price = '19.99'    currency = 'EUR' )
      ( material_id = 'M003' material_name   = 'Keyboard'  price = '39.99'    currency = 'EUR' )
      ( material_id = 'M004' material_name   = 'Monitor'  price = '139.99'    currency = 'EUR' )
          ).

    " Fill technical client and administrative data
    LOOP AT lt_materials ASSIGNING FIELD-SYMBOL(<fs_materials>).
      <fs_materials>-client        = sy-mandt.

      " Admin data from /lrn/s_admin
      <fs_materials>-created_by            = sy-uname.
      <fs_materials>-created_at            = lv_timestamp.
      <fs_materials>-local_last_changed_by = sy-uname.
      <fs_materials>-last_changed_at       = lv_timestamp.
      <fs_materials>-local_last_changed_at = lv_timestamp.
    ENDLOOP.

    INSERT z02materials FROM TABLE @lt_materials.


  ENDMETHOD.

ENDCLASS.
