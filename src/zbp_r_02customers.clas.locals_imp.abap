" --- Handler for the ORDERS entity ---
CLASS lhc_orders DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateOrderData FOR VALIDATE ON SAVE
      IMPORTING keys FOR Orders~validateOrderData.
    METHODS calculateAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Orders~calculateAmount.
    METHODS validateMatIdAndQuantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR Orders~validateMatIdAndQuantity.


ENDCLASS.

CLASS lhc_orders IMPLEMENTATION.

  METHOD validateOrderData.

    " 1. FETCH DATA: Retrieve the OrderId and CustomerId for the records currently being processed.
    " We use 'IN LOCAL MODE' to bypass authorization checks during internal validation.
    READ ENTITIES OF zr_02customers IN LOCAL MODE
         ENTITY Orders
         FIELDS ( OrderId CustomerId )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_orders).

    " 2. FETCH PARENT LINKS: In RAP Child entities, the UI needs a technical path back to the Root.
    " We read the 'link' between Order and Customer to ensure we have the correct Parent TKY.
    READ ENTITIES OF zr_02customers IN LOCAL MODE
         ENTITY Orders BY \_Customers
         FROM CORRESPONDING #( lt_orders )
         LINK DATA(lt_links).

    LOOP AT lt_orders INTO DATA(ls_order).
      " 3. STATE MANAGEMENT: Reset the state area for this specific validation.
      " This clears old error messages from the UI so they don't persist after the user fixes the input.
      APPEND VALUE #( %tky = ls_order-%tky
                      %state_area = 'VALIDATE_ORDER_ID' ) TO reported-orders.

      " 4. LOOKUP PARENT KEY: Extract the parent's total key (%tky) from the link table.
      " Using 'KEY id' ensures we use the secondary index for performance as per compiler warnings.
*    DATA(ls_parent_key) = VALUE #( lt_links[ source-%tky = ls_order-%tky ]-target-%tky OPTIONAL ).
      DATA(ls_parent_key) = VALUE #( lt_links[ KEY id source-%tky = ls_order-%tky ]-target-%tky OPTIONAL ).

      " 5. BUSINESS LOGIC: Validate OrderID format (Must be 'O' followed by 6 digits).
      IF ls_order-OrderId IS NOT INITIAL.
        IF NOT matches( val = ls_order-OrderId pcre = '^O[0-9]{6}$' ).

          " 6. FAILED: Block the save/activation process.
          APPEND VALUE #( %tky = ls_order-%tky ) TO failed-orders.

          " 7. REPORTED: Send the error message to the UI.
          APPEND VALUE #(
              %tky          = ls_order-%tky
              %state_area   = 'VALIDATE_ORDER_ID'
              " %PATH is CRITICAL: Without the parent %tky, the UI cannot map the message
              " to the child instance and will result in infinite loading/hangs.
              %path         = VALUE #( Customers-%tky = ls_parent_key )
              %msg          = new_message( id       = 'Z02_ERRORTEXTS'
                                           number   = '004'
                                           severity = if_abap_behv_message=>severity-error
                                           v1       = ls_order-OrderId )
             " %ELEMENT: Links the error message directly to the 'OrderId' input field.
              %element-OrderId = if_abap_behv=>mk-on
          ) TO reported-orders.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD calculateAmount.

    " --- STEP 1: READ DATA FROM DRAFT ---
    " We read the 'Orders' entity in 'LOCAL MODE' to bypass authorization checks.
    " We need MaterialId and Quantity to perform the calculation.
    " 'keys' contains the technical IDs (%tky) of the rows that were just changed.
    READ ENTITIES OF zr_02customers IN LOCAL MODE
      ENTITY Orders
        FIELDS ( MaterialId Quantity )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    " --- STEP 2: PREPARE DATA FOR UPDATE ---
    " 'lt_update' is a special table type that holds the changes we want to write back.
    DATA lt_update TYPE TABLE FOR UPDATE zr_02ordes.


    LOOP AT lt_orders INTO DATA(ls_order).
      " Business Logic: Only calculate if we have the Material and a positive Quantity
      IF ls_order-MaterialId IS NOT INITIAL AND ls_order-Quantity > 0.

        " Fetch the master data (Price/Currency) for the selected Material.
        SELECT SINGLE FROM Z02_I_Materials
          FIELDS Price, Currency
          WHERE MaterialId = @ls_order-MaterialId
          INTO @DATA(ls_material_info).

        IF sy-subrc = 0.
          " Calculation success: add to update list.
          IF ls_order-OrderDate IS INITIAL.
            "set System Date for OrderDate
            APPEND VALUE #(
                            %tky      = ls_order-%tky
                            OrderDate = cl_abap_context_info=>get_system_date( )
                            Amount    = ls_order-Quantity * ls_material_info-Price
                            Currency  = ls_material_info-Currency
                            " %control tells RAP which specific fields we are changing.
                            %control  = VALUE #( OrderDate   = if_abap_behv=>mk-on
                                                 Amount   = if_abap_behv=>mk-on
                                                 Currency = if_abap_behv=>mk-on )
                           ) TO lt_update.
          ELSE.
            APPEND VALUE #(
                              %tky      = ls_order-%tky
                              Amount    = ls_order-Quantity * ls_material_info-Price
                              Currency  = ls_material_info-Currency
                              " %control tells RAP which specific fields we are changing.
                              %control  = VALUE #( Amount   = if_abap_behv=>mk-on
                                                   Currency = if_abap_behv=>mk-on )
                           ) TO lt_update.
          ENDIF.
        ENDIF.
      ELSE.
        " FALLBACK: If the user cleared the Material or Quantity,
        " we should reset the Amount to 0 so the UI doesn't show old data.
        APPEND VALUE #(
            %tky      = ls_order-%tky
            Amount    = 0
            %control  = VALUE #( Amount = if_abap_behv=>mk-on )
        ) TO lt_update.
      ENDIF.
    ENDLOOP.

    " --- STEP 3: UPDATE THE DATABASE DRAFT ---
    IF lt_update IS NOT INITIAL.
      " We 'MODIFY' the entities in 'LOCAL MODE'.
      " This updates the Draft table (z02orders_d) immediately
      MODIFY ENTITIES OF zr_02customers IN LOCAL MODE
        ENTITY Orders
          UPDATE FROM lt_update

        REPORTED DATA(lt_reported_modify)
        FAILED DATA(lt_failed_modify).

      " --- STEP 4: ERROR & MESSAGE HANDLING ---
      " To avoid 'Field Unknown' errors (singular vs plural aliases),
      " we map the entire structures back to the global variables.
      " DEEP ensures that all nested components (like orders or customers) are moved.
      reported-orders = CORRESPONDING #( DEEP lt_reported_modify-orders ).
*      failed-orders  = CORRESPONDING #( DEEP lt_failed_modify-orders ).
    ENDIF.

  ENDMETHOD.


  METHOD validateMatIdAndQuantity.

    DATA failed_record LIKE LINE OF failed-Orders.
    DATA reported_record LIKE LINE OF reported-Orders.

    READ ENTITIES OF zr_02customers IN LOCAL MODE
        ENTITY Orders
             FIELDS ( MaterialId Quantity )
       WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    LOOP AT orders INTO DATA(order).

      "------- Quantity prüfen.
      IF not order-Quantity > 0.

        failed_record-%tky = order-%tky.

        APPEND failed_record TO failed-orders.

        reported_record-%tky = order-%tky.
        reported_record-%msg =
             new_message(
                 id =  'Z02_ERRORTEXTS'
                 number = '005'
                 severity = if_abap_behv_message=>severity-error
                         ).

        APPEND reported_record TO reported-orders.

      ENDIF.

      "----------- Status prüfen.
      IF order-Status is initial.

        failed_record-%tky = order-%tky.

        APPEND failed_record TO failed-orders.

        reported_record-%tky = order-%tky.
        reported_record-%msg =
             new_message(
                 id =  'Z02_ERRORTEXTS'
                 number = '007'
                 severity = if_abap_behv_message=>severity-error
                         ).

        APPEND reported_record TO reported-orders.

      ENDIF.

    ENDLOOP.

    DATA exists TYPE abap_bool.

    exists = abap_false.

    LOOP AT orders INTO DATA(Order1).
      SELECT SINGLE FROM z02_i_materials
       FIELDS @abap_true
       WHERE MaterialId = @order1-MaterialId
       INTO @exists.

      IF exists = abap_false.   " Der Material ID does not exist

        failed_record-%tky = Order1-%tky.

        APPEND failed_record TO failed-orders.

        reported_record-%tky = Order1-%tky.
        reported_record-%msg =
        new_message(
             id =  'Z02_ERRORTEXTS'
             number = '006'
             severity = if_abap_behv_message=>severity-error
             v1 = order1-MaterialId        ).

        APPEND reported_record TO reported-orders.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.


CLASS lhc_zr_02customers DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Customers
        RESULT result,
      CheckCharacterFields FOR VALIDATE ON SAVE
        IMPORTING keys FOR Customers~CheckCharacterFields,
      validateCustomerID FOR VALIDATE ON SAVE
        IMPORTING keys FOR Customers~validateCustomerID,
      earlynumbering_create FOR NUMBERING
        IMPORTING entities FOR CREATE Customers,
      earlynumbering_cba_Orders FOR NUMBERING
        IMPORTING entities FOR CREATE Customers\_Orders.



ENDCLASS.

CLASS lhc_zr_02customers IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD CheckCharacterFields.

    DATA failed_record LIKE LINE OF failed-Customers.
    DATA reported_record LIKE LINE OF reported-Customers.

    READ ENTITIES OF zr_02customers IN LOCAL MODE
        ENTITY Customers
             FIELDS ( FirstName LastName PhoneNumber PostalCode Street City Country )
       WITH CORRESPONDING #( keys )
        RESULT DATA(customs).

    LOOP AT customs INTO DATA(custom).

      IF custom-FirstName IS INITIAL
        OR custom-LastName IS INITIAL
        OR custom-PhoneNumber IS INITIAL
        OR custom-PostalCode IS INITIAL
        OR custom-Street IS INITIAL
        OR custom-City IS INITIAL .

        failed_record-%tky = custom-%tky.

        APPEND failed_record TO failed-Customers.

        reported_record-%tky = custom-%tky.
        reported_record-%msg =
             new_message(
                 id =  'Z02_ERRORTEXTS'
                 number = '001'
                 severity = if_abap_behv_message=>severity-error
                         ).

        APPEND reported_record TO reported-customers.

      ENDIF.

    ENDLOOP.

    DATA exists TYPE abap_bool.

    exists = abap_false.

    LOOP AT customs INTO DATA(custom1).
      SELECT SINGLE FROM i_country
       FIELDS @abap_true
       WHERE Country = @custom-country
       INTO @exists.

      IF exists = abap_false.   " Der CurrencyCode ist nicht gültig

        failed_record-%tky = custom-%tky.

        APPEND failed_record TO failed-Customers.

        reported_record-%tky = custom-%tky.
        reported_record-%msg =
        new_message(
             id =  'Z02_ERRORTEXTS'
             number = '002'
             severity = if_abap_behv_message=>severity-error
             v1 = custom-country        ).

        APPEND reported_record TO reported-customers.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateCustomerID.

    READ ENTITIES OF zr_02customers IN LOCAL MODE
         ENTITY Customers
         FIELDS ( CustomerID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_customers).

    LOOP AT lt_customers INTO DATA(ls_customer).

      " Clean up old messages for this record
      APPEND VALUE #( %tky = ls_customer-%tky
                      %state_area = 'VALIDATE_CUSTOMER_ID' ) TO reported-customers.

      " Validation when field is NOT EMPTY
      IF ls_customer-CustomerID IS NOT INITIAL.
        " Validate: Starts with C, then exactly 5 digits
        IF NOT matches( val = ls_customer-CustomerID pcre = '^C[0-9]{5}$' ).

          " 1. Mark as failed
          APPEND VALUE #( %tky = ls_customer-%tky ) TO failed-customers.

          " 2. Report the error with field link
          APPEND VALUE #( %tky = ls_customer-%tky
                          %state_area = 'VALIDATE_CUSTOMER_ID'
                          %msg = new_message( id       = 'Z02_ERRORTEXTS'
                                              number   = '003'
                                              severity = if_abap_behv_message=>severity-error
                                              v1       = ls_customer-CustomerID )
*                          %element-customerid = if_abap_behv=>mk-on
                          ) TO reported-customers.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create.



    LOOP AT entities INTO DATA(entity).

      DATA lv_Max TYPE n LENGTH 5.

      SELECT MAX( CAST( substring( CustomerID, 2, 5 ) AS NUMC( 5 ) ) )  FROM zr_02customers INTO @lv_Max.
      lv_Max = lv_Max + 1.

      APPEND VALUE #( %cid = entity-%cid
                      %is_draft = entity-%is_draft
                      %key-CustomerID = 'C' && lv_max  ) TO mapped-customers.

    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Orders.

    LOOP AT entities INTO DATA(entity).

      DATA lv_Max TYPE n LENGTH 6.

      SELECT
      MAX(
        CAST(
            substring( OrderID, 2, 6 )
        AS NUMC( 6 ) ) )
      FROM zr_02ordes INTO @lv_Max.

      lv_Max = lv_Max + 1.

      mapped-orders = VALUE #( BASE mapped-orders
        FOR ls_child IN entity-%target (
            %cid      = ls_child-%cid
            %is_draft = entity-%is_draft
            %key-OrderID = 'O' && lv_max
            )
        ).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
