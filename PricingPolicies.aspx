<%@ Page Title="Pricing Policies" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="PricingPolicies.aspx.cs" Inherits="Data_and_Web_Coursework.PricingPolicies" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1">Pricing Policy Management</h2>
                <p class="text-muted mb-4">Set dynamic pricing multipliers for weekends, holidays, or special events.
                </p>

                <%-- ── Help Section ── --%>
                    <div class="alert alert-info border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:rgba(13,202,240,.15);cursor:pointer;" onclick="toggleGuide()">
                            <i class="fas fa-question-circle text-info me-2"></i> Pricing Mechanics
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ul class="mb-0 ps-3">
                                <li class="mb-1"><strong>Discount (%)</strong>: Enter exactly the percentage to deduct.
                                    For example, 20 is a 20% discount. 0 is base price.</li>
                                <li class="mb-1"><strong>Policy Date</strong>: This is a reference for when the policy
                                    was created or applies.</li>
                                <li class="mb-0"><strong>Application</strong>: Policies are linked to <a
                                        href="Showtimes.aspx">Showtimes</a> to calculate the final ticket price.</li>
                            </ul>
                        </div>
                    </div>
                    <div class="card mb-4 shadow-sm border-success">
                        <div class="card-header bg-success text-white">Add / Update Policy</div>
                        <div class="card-body">
                            <div class="row g-3">
                                <asp:HiddenField ID="hfPolicyID" runat="server" />
                                <div class="col-md-2">
                                    <label class="form-label">Policy ID</label>
                                    <asp:TextBox ID="txtPolicyID" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Policy Name</label>
                                    <asp:TextBox ID="txtPolicyName" runat="server" CssClass="form-control">
                                    </asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Discount (%)</label>
                                    <asp:TextBox ID="txtMultiplier" runat="server" CssClass="form-control"
                                        TextMode="Number" step="0.01"></asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Date</label>
                                    <asp:TextBox ID="txtDate" runat="server" CssClass="form-control" TextMode="Date">
                                    </asp:TextBox>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label">Description</label>
                                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control"
                                        TextMode="MultiLine" Rows="2"></asp:TextBox>
                                </div>
                                <div class="col-12 mt-3">
                                    <asp:Button ID="btnSave" runat="server" Text="Save Policy"
                                        CssClass="btn btn-success" OnClick="btnSave_Click" />
                                    <asp:Button ID="btnClear" runat="server" Text="Clear Fields"
                                        CssClass="btn btn-secondary ms-2" OnClick="btnClear_Click" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card shadow-sm">
                        <div class="card-body">
                            <asp:GridView ID="gvPolicies" runat="server" CssClass="table table-hover"
                                AutoGenerateColumns="False" OnRowCommand="gvPolicies_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="POLICY_ID" HeaderText="ID" />
                                    <asp:BoundField DataField="POLICY_NAME" HeaderText="Name" />
                                    <asp:TemplateField HeaderText="Discount">
                                        <ItemTemplate>
                                            <%# string.Format("{0:0.##}%", (1.0 - Convert.ToDouble(Eval("MULTIPLIER")))
                                                * 100) %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="POLICY_DATE" HeaderText="Date"
                                        DataFormatString="{0:d}" />
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditPolicy"
                                                CommandArgument='<%# Eval("POLICY_ID") %>'
                                                CssClass="btn btn-sm btn-outline-warning">Edit</asp:LinkButton>
                                            <asp:LinkButton ID="btnDel" runat="server" CommandName="DeletePolicy"
                                                CommandArgument='<%# Eval("POLICY_ID") %>'
                                                CssClass="btn btn-sm btn-outline-danger action-btn"
                                                OnClientClick="return confirmDelete(this, 'Pricing Policy');">Delete
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
            </div>
        </div>
    </asp:Content>