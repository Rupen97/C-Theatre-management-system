<%@ Page Title="Occupancy Report" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="OccupancyReport.aspx.cs" Inherits="Data_and_Web_Coursework.OccupancyReport" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1"><i class="fas fa-trophy me-2 text-dark"></i>Movie Hall Occupancy — Top 3 Performers
                </h2>
                <p class="text-muted mb-4">View the top 3 most popular halls for any movie based on ticket sales.</p>

                <%-- ── Help Section ── --%>
                    <div class="alert alert-secondary border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;background:var(--g100);">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:var(--g200);cursor:pointer;" onclick="toggleGuide()">
                            <i class="fas fa-question-circle text-dark me-2"></i> How to read this report?
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ul class="mb-0 ps-3">
                                <li class="mb-1"><strong>Select Movie</strong>: Choose a film to see its performance
                                    across different cinema halls.</li>
                                <li class="mb-1"><strong>Occupancy %</strong>: Calculated as
                                    <code>(Tickets Sold / Total Capacity) * 100</code>.
                                </li>
                                <li class="mb-0"><strong>Top Performers</strong>: Automatically filters and sorts the
                                    top 3 halls by occupancy percentage.</li>
                            </ul>
                        </div>
                    </div>
                    <div class="card mb-4 shadow-sm border-0" style="border-radius:14px;">
                        <div class="card-header text-white fw-bold"
                            style="background:var(--g800);border-radius:14px 14px 0 0;">
                            <i class="fas fa-chart-bar me-2"></i>Select Movie to Analyze
                        </div>
                        <div class="card-body">
                            <div class="row g-3 align-items-end">
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Select Movie</label>
                                    <asp:DropDownList ID="ddlMovie" runat="server" CssClass="form-select">
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <asp:LinkButton ID="btnAnalyze" runat="server"
                                        CssClass="btn btn-primary fw-bold w-100" OnClick="btnAnalyze_Click">
                                        <i class="fas fa-trophy me-2"></i>Get Top 3 Halls
                                    </asp:LinkButton>
                                </div>
                                <div class="col-md-2">
                                    <asp:Label ID="lblMsg" runat="server" CssClass="fw-bold"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <asp:Panel ID="pnlTop3" runat="server" Visible="false">
                        <div class="card shadow border-0" style="border-radius:14px;">
                            <div class="card-header bg-dark text-white" style="border-radius:14px 14px 0 0;">
                                <i class="fas fa-medal me-2 text-warning"></i>
                                <strong>Top 3 Halls by Occupancy %</strong>
                                <small class="ms-2 text-muted">Formula: (Paid Tickets / Hall Capacity) × 100</small>
                            </div>
                            <div class="card-body p-0">
                                <asp:GridView ID="gvTop3" runat="server" CssClass="table table-striped table-hover mb-0"
                                    AutoGenerateColumns="False">
                                    <HeaderStyle CssClass="table-dark" />
                                    <Columns>
                                        <asp:TemplateField HeaderText="Rank">
                                            <HeaderTemplate>
                                                <i class="fas fa-medal me-1"></i> Rank
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <span
                                                    class='badge <%# Convert.ToInt32(Eval("RANK")) == 1 ? "bg-dark text-white fs-6" : Convert.ToInt32(Eval("RANK")) == 2 ? "bg-secondary fs-6" : "bg-light text-dark fs-6" %>'>
                                                    #<%# Eval("RANK") %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="CINEMA_NAME" HeaderText="Cinema" />
                                        <asp:BoundField DataField="HALL_NAME" HeaderText="Hall" />
                                        <asp:BoundField DataField="TOTAL_CAPACITY" HeaderText="Capacity" />
                                        <asp:BoundField DataField="TICKETSSOLD" HeaderText="Tickets Issued" />
                                        <asp:TemplateField HeaderText="Occupancy %">
                                            <ItemTemplate>
                                                <div class="d-flex align-items-center gap-2">
                                                    <div class="progress flex-grow-1" style="height:20px;">
                                                        <div class="progress-bar bg-success" role="progressbar"
                                                            style='<%# string.Format("width:{0}%;", Eval("OCCUPANCYPCT")) %>'
                                                            aria-valuenow='<%# Eval("OCCUPANCYPCT") %>'
                                                            aria-valuemin="0" aria-valuemax="100">
                                                        </div>
                                                    </div>
                                                    <strong>
                                                        <%# string.Format("{0:F1}", Eval("OCCUPANCYPCT")) %>%
                                                    </strong>
                                                </div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <EmptyDataTemplate>
                                        <div class="alert alert-warning m-3">No occupancy data available for this movie.
                                        </div>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </div>
                        </div>
                    </asp:Panel>
            </div>
        </div>
    </asp:Content>