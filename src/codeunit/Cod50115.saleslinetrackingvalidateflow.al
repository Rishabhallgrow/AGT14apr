codeunit 50115 "saleslinetrackingvalidateflow"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterValidateEvent, 'Qty. to Ship', false, false)]
    local procedure trackingsoecflow(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        TempResEntry: Record "Reservation Entry" temporary;
        RStatus: Enum "Reservation Status";
        CreateReserveEnt: Codeunit "Create Reserv. Entry";
        users: Record User;
        ResEntry: Record "Reservation Entry";
    begin
        if (Rec."Qty. to Ship" > 0) and (xRec."Qty. to Ship" <> Rec."Qty. to Ship") then begin
            ResEntry.Reset();
            ResEntry.SetRange("Source Type", Database::"Sales Line");
            ResEntry.SetRange("Source Subtype", Rec."Document Type".AsInteger());
            ResEntry.SetRange("Source ID", Rec."Document No.");
            ResEntry.SetRange("Source Ref. No.", Rec."Line No.");

            if ResEntry.FindFirst() then begin
                ResEntry.Validate("Quantity (Base)", Rec."Qty. to Ship (Base)");
                ResEntry.Modify(true);
            end else begin
                TempResEntry.Init();
                TempResEntry."Item No." := Rec."No.";
                TempResEntry."Location Code" := Rec."Location Code";
                TempResEntry.Validate("Quantity (Base)", Rec."Quantity (Base)");
                TempResEntry."Reservation Status" := TempResEntry."Reservation Status"::Reservation;
                TempResEntry.Description := Rec.Description;
                TempResEntry."Creation Date" := Rec."Posting Date";
                TempResEntry."Source Type" := Database::"Sales Line";
                TempResEntry."Source Subtype" := Rec."Document Type".AsInteger();
                TempResEntry."Source ID" := Rec."Document No.";
                TempResEntry."Source Ref. No." := Rec."Line No.";
                TempResEntry."Shipment Date" := Rec."Shipment Date";

                if users.Get(UserSecurityId()) then
                    TempResEntry."Created By" := users."User Name";

                TempResEntry.Validate("Qty. per Unit of Measure", Rec."Qty. per Unit of Measure");
                TempResEntry.Quantity := Rec."Qty. to Ship (Base)";
                TempResEntry."Lot No." := 'AUTOLOT' + '-' + Format(Rec."Line No.");
                TempResEntry."Item Tracking" := TempResEntry."Item Tracking"::"Lot No.";
                TempResEntry.Insert();

                if TempResEntry.FindSet() then
                    repeat
                        CreateReserveEnt.SetDates(0D, TempResEntry."Expiration Date");
                        CreateReserveEnt.CreateReservEntryFor(
                          Database::"Sales Line", Rec."Document Type".AsInteger(),
                          Rec."Document No.", '', 0, Rec."Line No.", Rec."Qty. per Unit of Measure",
                          TempResEntry.Quantity, TempResEntry.Quantity * Rec."Qty. per Unit of Measure", TempResEntry);
                        CreateReserveEnt.CreateEntry(
                          Rec."No.", Rec."Variant Code", Rec."Location Code", '', 0D, 0D, 0, RStatus::Surplus);
                    until TempResEntry.Next() = 0;
            end;
        end;
    end;
}

