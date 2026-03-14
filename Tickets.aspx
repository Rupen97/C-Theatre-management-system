<%@ Page Title="Tickets" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Tickets.aspx.cs" Inherits="Data_and_Web_Coursework.Tickets" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1"><i class="fas fa-ticket-alt me-2 text-dark"></i>Ticket Issuance</h2>
                <p class="text-muted mb-4">Issue one or more tickets for a booking by selecting available seats below.
                </p>

                <%-- ── How-To Guide ── --%>
                    <div class="alert alert-secondary border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;background:var(--g100);">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:var(--g200);cursor:pointer;" onclick="toggleGuide()" id="guideHeader">
                            <i class="fas fa-question-circle text-dark me-2"></i>
                            How does Ticket Issuance work?
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ol class="mb-0 ps-3">
                                <li class="mb-1"><strong>A Booking must exist first.</strong> Bookings are created on
                                    the <a runat="server" href="~/Bookings.aspx">Bookings</a> page and represent a
                                    customer reserving
                                    seats for a showtime.</li>
                                <li class="mb-1"><strong>Select the Booking</strong> from the dropdown — the system will
                                    automatically load all available (unbooked) seats for that showtime and calculate
                                    the ticket price using the pricing policy.</li>
                                <li class="mb-1"><strong>Tick one or more seats</strong> from the seat list. You can
                                    select multiple seats at once.</li>
                                <li class="mb-1"><strong>Click "Issue Tickets"</strong> — one ticket row is inserted per
                                    selected seat, all linked to the same booking.</li>
                                <li class="mb-0"><strong>Cancel a ticket</strong> by clicking the Cancel button in the
                                    grid — this removes the ticket and frees the seat.</li>
                            </ol>
                        </div>
                    </div>

                    <%-- ── Form Card ── --%>
                        <div class="card mb-4 shadow-sm border-0" style="border-radius:14px;">
                            <div class="card-header text-white fw-bold"
                                style="background:var(--g800);border-radius:14px 14px 0 0;">
                                <i class="fas fa-plus-circle me-2"></i>Issue New Ticket(s)
                            </div>
                            <div class="card-body">
                                <div class="row g-3">

                                    <%-- Mode Selector --%>
                                        <div class="col-md-12 mb-2">
                                            <div class="btn-group w-100" role="group">
                                                <asp:RadioButtonList ID="rblSaleType" runat="server"
                                                    RepeatDirection="Horizontal" AutoPostBack="true"
                                                    OnSelectedIndexChanged="rblSaleType_SelectedIndexChanged"
                                                    CssClass="d-flex gap-3 radio-toggle">
                                                    <asp:ListItem
                                                        Text="<i class='fas fa-receipt me-2'></i>Existing Booking"
                                                        Value="Existing" Selected="True"></asp:ListItem>
                                                    <asp:ListItem
                                                        Text="<i class='fas fa-bolt me-2'></i>Quick Sale (Direct)"
                                                        Value="Quick"></asp:ListItem>
                                                </asp:RadioButtonList>
                                            </div>
                                        </div>

                                        <%-- Existing Booking Section --%>
                                            <asp:PlaceHolder ID="phExistingBooking" runat="server">
                                                <div class="col-md-6">
                                                    <label class="form-label fw-semibold">
                                                        <i class="fas fa-receipt me-1 text-danger"></i>Booking
                                                        <span class="text-danger">*</span>
                                                    </label>
                                                    <asp:DropDownList ID="ddlBooking" runat="server"
                                                        CssClass="form-select" AutoPostBack="true"
                                                        OnSelectedIndexChanged="ddlBooking_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                    <div class="form-text">Select the booking you want to issue tickets
                                                        for.
                                                    </div>
                                                </div>
                                            </asp:PlaceHolder>

                                            <%-- Quick Sale Section --%>
                                                <asp:PlaceHolder ID="phQuickSale" runat="server" Visible="false">
                                                    <div class="col-md-4">
                                                        <label class="form-label fw-semibold">
                                                            <i class="fas fa-user me-1 text-primary"></i>Customer
                                                            <span class="text-danger">*</span>
                                                        </label>
                                                        <asp:DropDownList ID="ddlUser" runat="server"
                                                            CssClass="form-select">
                                                        </asp:DropDownList>
                                                        <div class="form-text">Select the customer for this sale.</div>
                                                    </div>
                                                    <div class="col-md-8">
                                                        <label class="form-label fw-semibold">
                                                            <i
                                                                class="fas fa-calendar-alt me-1 text-warning"></i>Showtime
                                                            <span class="text-danger">*</span>
                                                        </label>
                                                        <asp:DropDownList ID="ddlShowtime" runat="server"
                                                            CssClass="form-select" AutoPostBack="true"
                                                            OnSelectedIndexChanged="ddlShowtime_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                        <div class="form-text">Select the showtime.</div>
                                                    </div>
                                                </asp:PlaceHolder>

                                                <%-- Final Price (auto-calculated, read-only) --%>
                                                    <div class="col-md-3">
                                                        <label class="form-label fw-semibold">
                                                            <i class="fas fa-tag me-1 text-success"></i>Price per Seat
                                                            (NRS)
                                                        </label>
                                                        <div class="input-group">
                                                            <span
                                                                class="input-group-text bg-success text-white">NRS</span>
                                                            <asp:TextBox ID="txtFinalPrice" runat="server"
                                                                CssClass="form-control" TextMode="Number" step="0.01"
                                                                ReadOnly="true"
                                                                style="background:#f8f9fa;font-weight:600;">
                                                            </asp:TextBox>
                                                        </div>
                                                        <div class="form-text">Auto-filled based on showtime pricing
                                                            policy.
                                                        </div>
                                                    </div>

                                                    <%-- Pricing breakdown badge --%>
                                                        <div class="col-md-3 d-flex align-items-end">
                                                            <asp:Label ID="lblPricingInfo" runat="server"
                                                                CssClass="alert alert-info py-2 px-3 mb-0 w-100 small"
                                                                Visible="false">
                                                            </asp:Label>
                                                        </div>

                                                        <%-- Seat multi-select --%>
                                                            <div class="col-md-12">
                                                                <label class="form-label fw-semibold">
                                                                    <i class="fas fa-chair me-1 text-primary"></i>Select
                                                                    Seat(s)
                                                                    <span class="text-danger">*</span>
                                                                </label>
                                                                <div id="seatPanel"
                                                                    class="border rounded-3 p-3 bg-light"
                                                                    style="min-height:60px;max-height:220px;overflow-y:auto;">
                                                                    <asp:Panel ID="pnlNoSelection" runat="server">
                                                                        <span class="text-muted fst-italic">
                                                                            <i class="fas fa-arrow-up me-1"></i>
                                                                            Please select a <asp:Literal
                                                                                ID="litSelectionType" runat="server"
                                                                                Text="booking"></asp:Literal> first to
                                                                            see available seats.
                                                                        </span>
                                                                    </asp:Panel>
                                                                    <asp:CheckBoxList ID="cblSeats" runat="server"
                                                                        RepeatLayout="Flow" RepeatDirection="Horizontal"
                                                                        CssClass="seat-checkbox-list" Visible="false">
                                                                    </asp:CheckBoxList>
                                                                    <asp:Label ID="lblNoSeats" runat="server"
                                                                        Visible="false"
                                                                        CssClass="text-warning fst-italic">
                                                                        <i class="fas fa-exclamation-triangle me-1"></i>
                                                                        All seats for this showtime are already booked
                                                                        or ticketed.
                                                                    </asp:Label>
                                                                </div>
                                                                <div class="form-text">Tick one or more available seats.
                                                                    Each ticked seat gets its own ticket.</div>
                                                            </div>

                                                            <div class="col-12 mt-2">
                                                                <asp:LinkButton ID="btnSave" runat="server"
                                                                    CssClass="btn btn-primary fw-semibold"
                                                                    OnClick="btnSave_Click" CausesValidation="false">
                                                                    <i class="fas fa-ticket-alt me-2"></i>Issue
                                                                    Ticket(s)
                                                                </asp:LinkButton>
                                                                <asp:Button ID="btnClear" runat="server" Text="Clear"
                                                                    CssClass="btn btn-outline-secondary ms-2"
                                                                    OnClick="btnClear_Click" CausesValidation="false" />
                                                            </div>
                                </div>
                            </div>
                        </div>

                        <%-- ── Tickets Grid ── --%>
                            <div class="card shadow-sm border-0" style="border-radius:14px;">
                                <div class="card-header fw-bold" style="border-radius:14px 14px 0 0;">
                                    <i class="fas fa-list me-2"></i>All Issued Tickets
                                </div>
                                <div class="card-body p-0">
                                    <asp:GridView ID="gvTickets" runat="server" CssClass="table table-hover mb-0"
                                        AutoGenerateColumns="False" OnRowCommand="gvTickets_RowCommand"
                                        DataKeyNames="TICKET_ID">
                                        <HeaderStyle CssClass="table-dark" />
                                        <Columns>
                                            <asp:BoundField DataField="TICKET_ID" HeaderText="Ticket #" />
                                            <asp:BoundField DataField="BOOKING_ID" HeaderText="Booking #" />
                                            <asp:BoundField DataField="SEAT_INFO" HeaderText="Seat" />
                                            <asp:BoundField DataField="TITLE" HeaderText="Movie" />
                                            <asp:BoundField DataField="HALL_NAME" HeaderText="Hall" />
                                            <asp:BoundField DataField="START_TIME" HeaderText="Show Time"
                                                DataFormatString="{0:dd-MMM-yy hh:mm tt}" />
                                            <asp:BoundField DataField="FINAL_PRICE" HeaderText="Price (NRS)"
                                                DataFormatString="{0:N2}" />
                                            <asp:BoundField DataField="ISSUED_DATE" HeaderText="Booking Date"
                                                DataFormatString="{0:dd-MMM-yy}" />
                                            <asp:TemplateField HeaderText="Action">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="btnDel" runat="server"
                                                        CommandName="DeleteTicket"
                                                        CommandArgument='<%# Eval("TICKET_ID") %>'
                                                        CssClass="btn btn-sm btn-outline-danger action-btn"
                                                        OnClientClick="return confirmDelete(this, 'Ticket');">
                                                        <i class="fas fa-times"></i> Cancel
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div class="alert alert-secondary m-3">
                                                <i class="fas fa-info-circle me-2"></i>No tickets issued yet.
                                            </div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </div>
            </div>
        </div>

        <style>
            .radio-toggle label {
                padding: 10px 20px;
                border: 2px solid var(--g200);
                border-radius: 8px;
                cursor: pointer;
                font-weight: 600;
                transition: all 0.2s;
                background: white;
                color: var(--g500);
            }

            .radio-toggle input[type="radio"] {
                display: none;
            }

            .radio-toggle input[type="radio"]:checked+label {
                background: var(--g900);
                color: white;
                border-color: var(--g900);
            }

            .radio-toggle label:hover:not(.radio-toggle input[type="radio"]:checked + label) {
                background: var(--g50);
                border-color: var(--g300);
            }

            .seat-checkbox-list label {
                display: inline-flex;
                align-items: center;
                gap: 5px;
                margin: 4px 8px 4px 0;
                padding: 5px 12px;
                border: 1px solid #dee2e6;
                border-radius: 20px;
                background: white;
                cursor: pointer;
                font-size: .875rem;
                transition: background .15s, border-color .15s;
            }

            .seat-checkbox-list label:hover {
                background: #e9f5ff;
                border-color: #86b7fe;
            }

            .seat-checkbox-list input[type=checkbox]:checked+span,
            .seat-checkbox-list input[type=checkbox]:checked~span {
                color: #0d6efd;
            }
        </style>

    </asp:Content>