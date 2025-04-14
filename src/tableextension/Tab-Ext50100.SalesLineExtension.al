tableextension 50100 "Sales Line Extension" extends "Sales Line"
{
    fields
    {
        field(50100; "Custom Field"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Delivery Notes';

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
    }
}
