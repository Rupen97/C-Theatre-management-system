<%@ Page Title="Customer Loyalty Report" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="UserTicketReport.aspx.cs" Inherits="Data_and_Web_Coursework.UserTicketReport" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1"><i class="fas fa-user-clock me-2 text-primary"></i>Customer Loyalty View</h2>
                <p class="text-muted mb-4">View ticket purchase history and loyalty stats for the last 6 months.</p>

                <%-- ── Help Section ── --%>
                    <div class="alert alert-info border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:rgba(13,202,240,.15);cursor:pointer;" onclick="toggleGuide()">
                            <i class="fas fa-question-circle text-info me-2"></i> Loyalty Radar Tips
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ul class="mb-0 ps-3">
                                <li class="mb-1"><strong>Selection</strong>: Choose a user to see all tickets issued
                                    under their account.</li>
                                <li class="mb-1"><strong>Status Badge</strong>: Shows if the ticket's booking is Paid or
                                    Reserved.</li>
                                <li class="mb-1"><strong>Total Spend</strong>: Summarizes the total monetary value of
                                    all tickets in the list.</li>
                                <li class="mb-0"><strong>History</strong>: Only shows data from the last 180 days.</li>
                            </ul>
                        </div>
                    </div>

                    <div class="card mb-4 shadow-sm border-0" style="border-radius:14px;">
                        <div class="card-header text-white fw-bold"
                            style="background:linear-gradient(135deg,#3a86ff,#2667d1);border-radius:14px 14px 0 0;">
                            <i class="fas fa-search me-2"></i>Search Customer
                        </div>
                        <div class="card-body">
                            <div class="row g-3 align-items-end">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Select User</label>
                                    <asp:DropDownList ID="ddlUser" runat="server" CssClass="form-select">
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <asp:Button ID="btnSearch" runat="server" Text="📊 Generate Report"
                                        CssClass="btn btn-primary fw-semibold w-100" OnClick="btnSearch_Click" />
                                </div>
                                <div class="col-md-3">
                                    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <asp:Panel ID="pnlReport" runat="server" Visible="false">
                        <div class="card shadow-sm border-0" style="border-radius:14px;">
                            <div class="card-header d-flex justify-content-between align-items-center bg-dark text-white"
                                style="border-radius:14px 14px 0 0;">
                                <span><i class="fas fa-history me-2"></i>Ticket History</span>
                                <asp:Label ID="lblUserInfo" runat="server" CssClass="text-warning fw-semibold">
                                </asp:Label>
                            </div>
                            <div class="card-body p-0">
                                <asp:GridView ID="gvUserTickets" runat="server" CssClass="table table-hover mb-0"
                                    AutoGenerateColumns="False">
                                    <HeaderStyle CssClass="table-secondary" />
                                    <Columns>
                                        <asp:BoundField DataField="TICKET_ID" HeaderText="Ticket #" />
                                        <asp:BoundField DataField="TITLE" HeaderText="Movie" />
                                        <asp:BoundField DataField="GENRE" HeaderText="Genre" />
                                        <asp:BoundField DataField="HALL_NAME" HeaderText="Hall" />
                                        <asp:BoundField DataField="SHOW_TIME" HeaderText="Show Date &amp; Time" />
                                        <asp:BoundField DataField="FINAL_PRICE" HeaderText="Price (NRS)"
                                            DataFormatString="{0:N2}" />
                                        <asp:BoundField DataField="ISSUED_DATE" HeaderText="Issued" />
                                        <asp:TemplateField HeaderText="Status">
                                            <ItemTemplate>
                                                <span
                                                    class='badge <%# Eval("BOOKING_STATUS").ToString() == "Paid" ? "bg-success" : Eval("BOOKING_STATUS").ToString() == "Reserved" ? "bg-warning text-dark" : "bg-secondary" %>'>
                                                    <%# Eval("BOOKING_STATUS") %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="alert alert-info m-3">
                                            <i class="fas fa-info-circle me-2"></i>No tickets found for this user in the
                                            last 6 months.
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                            <div class="card-footer d-flex justify-content-end bg-light">
                                <span class="text-muted small">
                                    <asp:Literal ID="litTotalSpend" runat="server"></asp:Literal>
                                </span>
                            </div>
                        </div>
                    </asp:Panel>
            </div>
        </div>
    </asp:Content>