// codeunit 50101 SalesLineEventSubscriber
// {
//     [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', "Qty. to Ship", false, false)]
//     local procedure HandleQtyToShipValidation(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
//     var
//         TrackingSpec: Record "Tracking Specification" temporary;
//         ReservEntry: Record "Reservation Entry";
//         ItemTrackingMgt: Codeunit "Item Tracking Management";
//     begin
//         // Check if Qty. to Ship has changed
//         if Rec."Qty. to Ship" <> xRec."Qty. to Ship" then begin
//             // Retrieve existing reservation entries
//             ReservEntry.SetRange("Source Type", 2); // 2 corresponds to Sales Line
//             ReservEntry.SetRange("Source Subtype", 0); // Assuming 0 for standard sales line
//             ReservEntry.SetRange("Source ID", Rec."Document No.");
//             ReservEntry.SetRange("Source Ref. No.", Rec."Line No.");
//             if ReservEntry.FindFirst() then begin
//                 // Create tracking specification from reservation entry
//                 ItemTrackingMgt.CreateTrackingSpecification(ReservEntry, TrackingSpec);
//                 TrackingSpec.Init();
//                 TrackingSpec."Quantity (Base)" := Rec."Qty. to Ship";
//                 TrackingSpec."Qty. to Invoice (Base)" := Rec."Qty. to Ship";
//                 TrackingSpec.Insert();
//                 // Ensure data flows to the Item Tracking Lines
//                 PAGE.Run(PAGE::"Item Tracking Lines", TrackingSpec);
//             end;
//         end;
//     end;
// }
