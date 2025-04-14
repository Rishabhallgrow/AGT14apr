pageextension 50100 "Sales Line Page Extension" extends "Sales Order Subform"
{
    layout
    {
        addafter("No.")
        {
            field("Custom Field"; Rec."Custom Field")
            {
                ApplicationArea = All;
                NotBlank = true;
            }
        }
    }
}
