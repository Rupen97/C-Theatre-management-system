<%@ Page Title="Booking Management" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Bookings.aspx.cs" Inherits="Data_and_Web_Coursework.Bookings" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1">Booking Management</h2>
                <p class="text-muted mb-4">Manage customer reservations and status updates.</p>

                <%-- ── Help Section ── --%>
                    <div class="alert alert-info border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:rgba(13,202,240,.15);cursor:pointer;" onclick="toggleGuide()">
                            <i class="fas fa-question-circle text-info me-2"></i> Booking Life-cycle
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ul class="mb-0 ps-3">
                                <li class="mb-1"><strong>Reserved</strong>: Temporary status. "Golden Hour" will
                                    auto-cancel these if not confirmed 1 hour before the show.</li>
                                <li class="mb-1"><strong>Confirmed/Paid</strong>: Finalized bookings ready for ticket
                                    issuance.</li>
                                <li class="mb-1"><strong>Cancelled</strong>: Changes status to Cancelled and
                                    <strong>automatically deletes all linked tickets</strong> to free up seats.</li>
                                <li class="mb-0"><strong>Manual Override</strong>: Use the ID field to update existing
                                    bookings.</li>
                            </ul>
                        </div>
                    </div>
                    <div class="card mb-4 shadow-sm border-primary">
                        <div class="card-header bg-primary text-white">Manual Booking Override / View</div>
                        <div class="card-body">
                            <div class="row g-3">
                                <asp:HiddenField ID="hfBookingID" runat="server" />
                                <div class="col-md-2">
                                    <label class="form-label">Booking ID</label>
                                    <asp:TextBox ID="txtBookingID" runat="server" CssClass="form-control"
                                        placeholder="ID">
                                    </asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">User</label>
                                    <asp:DropDownList ID="ddlUser" runat="server" CssClass="form-select">
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Showtime</label>
                                    <asp:DropDownList ID="ddlShowtime" runat="server" CssClass="form-select">
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Total Amount</label>
                                    <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control" TextMode="Number"
                                        step="0.01"></asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Status</label>
                                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                        <asp:ListItem Text="Confirmed" Value="Confirmed"></asp:ListItem>
                                        <asp:ListItem Text="Cancelled" Value="Cancelled"></asp:ListItem>
                                        <asp:ListItem Text="Reserved" Value="Reserved"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-12 mt-3">
                                    <asp:Button ID="btnSave" runat="server" Text="Save Booking"
                                        CssClass="btn btn-primary" OnClick="btnSave_Click" />
                                    <asp:Button ID="btnClear" runat="server" Text="Clear Fields"
                                        CssClass="btn btn-secondary ms-2" OnClick="btnClear_Click" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card shadow-sm">
                        <div class="card-body">
                            <asp:GridView ID="gvBookings" runat="server" CssClass="table table-hover"
                                AutoGenerateColumns="False" OnRowCommand="gvBookings_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="BOOKING_ID" HeaderText="ID" />
                                    <asp:BoundField DataField="USER_NAME" HeaderText="User" />
                                    <asp:BoundField DataField="MOVIE_TITLE" HeaderText="Movie" />
                                    <asp:BoundField DataField="SHOW_TIME" HeaderText="Showtime" />
                                    <asp:BoundField DataField="BOOKING_TIMESTAMP" HeaderText="Timestamp"
                                        DataFormatString="{0:g}" />
                                    <asp:BoundField DataField="TOTAL_AMOUNT" HeaderText="Amount"
                                        DataFormatString="{0:C}" />
                                    <asp:BoundField DataField="STATUS" HeaderText="Status" />
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditBooking"
                                                CommandArgument='<%# Eval("BOOKING_ID") %>'
                                                CssClass="btn btn-sm btn-outline-warning">Edit</asp:LinkButton>
                                            <asp:LinkButton ID="btnDel" runat="server" CommandName="DeleteBooking"
                                                CommandArgument='<%# Eval("BOOKING_ID") %>'
                                                CssClass="btn btn-sm btn-outline-danger action-btn"
                                                OnClientClick="return confirmDelete(this, 'Booking');">Delete
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