codeunit 50121 "SalesReleaseSubscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure OnAfterReleaseSalesDoc(
        var SalesHeader: Record "Sales Header";
        PreviewMode: Boolean;
        var LinesWereModified: Boolean;
        SkipWhseRequestOperations: Boolean)
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        VendorNo: Code[20];
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::Quote;
        PurchHeader.Validate("Buy-from Vendor No.", '01254796');
        PurchHeader.Insert(true);

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine.Type = SalesLine.Type::Item then begin
                    PurchLine.Init();
                    PurchLine."Document Type" := PurchLine."Document Type"::Quote;
                    PurchLine."Document No." := PurchHeader."No.";
                    PurchLine.Type := PurchLine.Type::Item;
                    PurchLine.Validate("No.", SalesLine."No.");
                    PurchLine.Validate(Quantity, SalesLine.Quantity);
                    PurchLine.Insert();
                end;
            until SalesLine.Next() = 0;
    end;
}
