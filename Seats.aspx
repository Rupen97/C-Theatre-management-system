<%@ Page Title="Seat Management" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Seats.aspx.cs" Inherits="Data_and_Web_Coursework.Seats" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1">Seat Management</h2>
                <p class="text-muted mb-4">Configure hall layouts and seat availability.</p>

                <%-- ── Help Section ── --%>
                    <div class="alert alert-info border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:rgba(13,202,240,.15);cursor:pointer;" onclick="toggleGuide()">
                            <i class="fas fa-question-circle text-info me-2"></i> Seat Configuration Tips
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ul class="mb-0 ps-3">
                                <li class="mb-1"><strong>Seat ID</strong>: Must be a unique numeric ID for the database.
                                </li>
                                <li class="mb-1"><strong>Row/Column/Number</strong>: Used to identify the seat's
                                    physical location (e.g., Row A, Column 5, Seat A5).</li>
                                <li class="mb-1"><strong>Status</strong>: 'Available' seats can be booked; 'Maintenance'
                                    seats are hidden from users.</li>
                                <li class="mb-0"><strong>Hall Link</strong>: Seats are permanent to a hall; ensure you
                                    select the correct Hall before saving.</li>
                            </ul>
                        </div>
                    </div>

                    <div class="card mb-4 shadow-sm border-info">
                        <div class="card-header bg-info text-white fw-bold">
                            <i class="fas fa-chair me-2"></i>Add / Update Seat
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <asp:HiddenField ID="hfSeatID" runat="server" />

                                <%-- Seat ID --%>
                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">Seat ID <span
                                                class="text-danger">*</span></label>
                                        <asp:TextBox ID="txtSeatID" runat="server" CssClass="form-control"
                                            placeholder="e.g. 1"></asp:TextBox>
                                    </div>

                                    <%-- Hall --%>
                                        <div class="col-md-3">
                                            <label class="form-label fw-semibold">Hall <span
                                                    class="text-danger">*</span></label>
                                            <asp:DropDownList ID="ddlHall" runat="server" CssClass="form-select">
                                            </asp:DropDownList>
                                            <div class="form-text">Which hall this seat belongs to.</div>
                                        </div>

                                        <%-- Row --%>
                                            <div class="col-md-2">
                                                <label class="form-label fw-semibold">Row</label>
                                                <asp:TextBox ID="txtRow" runat="server" CssClass="form-control"
                                                    placeholder="e.g. A"></asp:TextBox>
                                            </div>

                                            <%-- Column --%>
                                                <div class="col-md-2">
                                                    <label class="form-label fw-semibold">Column</label>
                                                    <asp:TextBox ID="txtColumn" runat="server" CssClass="form-control"
                                                        placeholder="e.g. 1"></asp:TextBox>
                                                </div>

                                                <%-- Seat Number --%>
                                                    <div class="col-md-2">
                                                        <label class="form-label fw-semibold">Seat Number</label>
                                                        <asp:TextBox ID="txtSeatNumber" runat="server"
                                                            CssClass="form-control" placeholder="e.g. A1"></asp:TextBox>
                                                    </div>

                                                    <%-- Status --%>
                                                        <div class="col-md-2">
                                                            <label class="form-label fw-semibold">Status</label>
                                                            <asp:DropDownList ID="ddlStatus" runat="server"
                                                                CssClass="form-select">
                                                                <asp:ListItem Text="Available" Value="Available">
                                                                </asp:ListItem>
                                                                <asp:ListItem Text="Reserved" Value="Reserved">
                                                                </asp:ListItem>
                                                                <asp:ListItem Text="Broken" Value="Broken">
                                                                </asp:ListItem>
                                                            </asp:DropDownList>
                                                        </div>

                                                        <div class="col-12 mt-2">
                                                            <asp:Button ID="btnSave" runat="server" Text="Save Seat"
                                                                CssClass="btn btn-info text-white"
                                                                OnClick="btnSave_Click" CausesValidation="false" />
                                                            <asp:Button ID="btnClear" runat="server" Text="Clear"
                                                                CssClass="btn btn-outline-secondary ms-2"
                                                                OnClick="btnClear_Click" CausesValidation="false" />
                                                        </div>
                            </div>
                        </div>
                    </div>

                    <div class="card shadow-sm">
                        <div class="card-body p-0">
                            <asp:GridView ID="gvSeats" runat="server" CssClass="table table-hover mb-0"
                                AutoGenerateColumns="False" OnRowCommand="gvSeats_RowCommand" AllowPaging="True"
                                PageSize="15" OnPageIndexChanging="gvSeats_PageIndexChanging">
                                <HeaderStyle CssClass="table-dark" />
                                <Columns>
                                    <asp:BoundField DataField="SEAT_ID" HeaderText="ID" />
                                    <asp:BoundField DataField="HALL_NAME" HeaderText="Hall" />
                                    <asp:BoundField DataField="SEAT_ROW" HeaderText="Row" />
                                    <asp:BoundField DataField="SEAT_COLUMN" HeaderText="Col" />
                                    <asp:BoundField DataField="SEAT_NUMBER" HeaderText="Seat No." />
                                    <asp:BoundField DataField="STATUS" HeaderText="Status" />
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditSeat"
                                                CommandArgument='<%# Eval("SEAT_ID") %>'
                                                CssClass="btn btn-sm btn-outline-warning me-1">
                                                <i class="fas fa-edit"></i> Edit
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDel" runat="server" CommandName="DeleteSeat"
                                                CommandArgument='<%# Eval("SEAT_ID") %>'
                                                CssClass="btn btn-sm btn-outline-danger action-btn"
                                                OnClientClick="return confirmDelete(this, 'Seat');">
                                                <i class="fas fa-trash-alt"></i> Delete
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <div class="p-4 text-center text-muted">No seats found. Add one above!</div>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>

            </div>
        </div>
    </asp:Content>