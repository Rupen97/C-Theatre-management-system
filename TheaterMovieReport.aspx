<%@ Page Title="Theater Performance Report" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="TheaterMovieReport.aspx.cs" Inherits="Data_and_Web_Coursework.TheaterMovieReport" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1"><i class="fas fa-map-marked-alt me-2 text-dark"></i>Theater Performance — Movie
                    Schedule</h2>
                <p class="text-muted mb-4">Drill-down into a specific theater to see all current and upcoming shows.</p>

                <%-- ── Help Section ── --%>
                    <div class="alert alert-secondary border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;background:var(--g100);">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:var(--g200);cursor:pointer;" onclick="toggleGuide()">
                            <i class="fas fa-question-circle text-dark me-2"></i> Report Tips
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ul class="mb-0 ps-3">
                                <li class="mb-1"><strong>Cinema Select</strong>: Filter the grid by picking a theater
                                    location.</li>
                                <li class="mb-1"><strong>Pricing Policy</strong>: shows the active multiplier applied to
                                    that specific showtime.</li>
                                <li class="mb-0"><strong>Start/End Time</strong>: Useful for identifying gaps in the
                                    schedule for new shows.</li>
                            </ul>
                        </div>
                    </div>

                    <div class="card mb-4 shadow-sm border-0" style="border-radius:14px;">
                        <div class="card-header text-white fw-bold"
                            style="background:var(--g800);border-radius:14px 14px 0 0;">
                            <i class="fas fa-building me-2"></i>Select Cinema Location
                        </div>
                        <div class="card-body">
                            <div class="row g-3 align-items-end">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Select Cinema</label>
                                    <asp:DropDownList ID="ddlCinema" runat="server" CssClass="form-select">
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <asp:LinkButton ID="btnView" runat="server"
                                        CssClass="btn btn-primary fw-semibold w-100" OnClick="btnView_Click">
                                        <i class="fas fa-film me-2"></i>View Schedule
                                    </asp:LinkButton>
                                </div>
                                <div class="col-md-3">
                                    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <asp:Panel ID="pnlDetails" runat="server" Visible="false">
                        <div class="card shadow-sm border-0" style="border-radius:14px;">
                            <div class="card-header bg-dark text-white fw-bold" style="border-radius:14px 14px 0 0;">
                                <i class="fas fa-calendar-alt me-2 text-success"></i>Current &amp; Upcoming Shows at
                                Selected Cinema
                            </div>
                            <div class="card-body p-0">
                                <asp:GridView ID="gvDetails" runat="server" CssClass="table table-hover mb-0"
                                    AutoGenerateColumns="False">
                                    <HeaderStyle CssClass="table-dark" />
                                    <Columns>
                                        <asp:BoundField DataField="HALL_NAME" HeaderText="Hall" />
                                        <asp:BoundField DataField="TITLE" HeaderText="Movie" />
                                        <asp:BoundField DataField="GENRE" HeaderText="Genre" />
                                        <asp:BoundField DataField="SHOW_TYPE" HeaderText="Type" />
                                        <asp:BoundField DataField="START_TIME" HeaderText="Start Time"
                                            DataFormatString="{0:dd-MMM-yyyy HH:mm}" />
                                        <asp:BoundField DataField="END_TIME" HeaderText="End Time"
                                            DataFormatString="{0:HH:mm}" />
                                        <asp:BoundField DataField="BASE_PRICE" HeaderText="Base Price (NRS)"
                                            DataFormatString="{0:N2}" />
                                        <asp:BoundField DataField="POLICY_NAME" HeaderText="Pricing Policy" />
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="alert alert-warning m-3">
                                            <i class="fas fa-exclamation-triangle me-2"></i>No shows scheduled for this
                                            cinema.
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>
                    </asp:Panel>
            </div>
        </div>
    </asp:Content>