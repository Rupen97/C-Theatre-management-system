<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="Data_and_Web_Coursework.Default" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            .chart-container {
                position: relative;
                height: 300px;
                width: 100%;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

        <!-- ── Header ── -->
        <div class="d-flex justify-content-between align-items-center mb-4 pb-2 border-bottom">
            <div>
                <h2 class="fw-bold mb-1" style="color:var(--g900); letter-spacing:-0.5px;">Overview</h2>
                <p class="mb-0" style="color:var(--g500); font-size:0.9rem;">Command Center & Performance Metrics</p>
            </div>
            <div>
                <span class="badge bg-dark rounded-pill px-3 py-2 fw-normal" style="font-size:0.8rem;">
                    <i class="fas fa-circle text-success me-1" style="font-size:0.5rem; vertical-align:middle;"></i>
                    System Online
                </span>
            </div>
        </div>

        <%-- ── Help Section ── --%>
            <div class="alert alert-secondary border-0 shadow-sm mb-4 p-0"
                style="border-radius:12px;overflow:hidden;background:var(--g100);">
                <div class="d-flex align-items-center px-4 py-2 fw-bold" style="background:var(--g200);cursor:pointer;"
                    onclick="toggleGuide()">
                    <i class="fas fa-question-circle text-dark me-2"></i> How to use the Dashboard?
                    <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                </div>
                <div id="guideBody" style="display:none;" class="px-4 py-3">
                    <ul class="mb-0 ps-3">
                        <li class="mb-1"><strong>KPI Cards</strong>: View live totals for Customers, Movies, Tickets,
                            and Revenue.</li>
                        <li class="mb-1"><strong>Hall Occupancy Chart</strong>: Identifies the top 5 busiest halls
                            across all cinemas.</li>
                        <li class="mb-1"><strong>Movie Sales Chart</strong>: Shows which films have sold the most
                            tickets globally.</li>
                        <li class="mb-0"><strong>Golden Hour Status</strong>: Displays the current status of the 1-hour
                            cancellation worker.</li>
                    </ul>
                </div>
            </div>

            <!-- ── KPI Cards ── -->
            <div class="row g-4 mb-4">
                <div class="col-sm-6 col-md-3">
                    <div class="stat-card">
                        <div class="stat-info">
                            <div class="value">
                                <asp:Literal ID="litTotalUsers" runat="server" Text="—"></asp:Literal>
                            </div>
                            <div class="label">Total Users</div>
                        </div>
                        <div class="stat-icon ms-auto">
                            <i class="fas fa-users"></i>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-md-3">
                    <div class="stat-card">
                        <div class="stat-info">
                            <div class="value">
                                <asp:Literal ID="litTotalMovies" runat="server" Text="—"></asp:Literal>
                            </div>
                            <div class="label">Active Movies</div>
                        </div>
                        <div class="stat-icon ms-auto">
                            <i class="fas fa-film"></i>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-md-3">
                    <div class="stat-card">
                        <div class="stat-info">
                            <div class="value">
                                <asp:Literal ID="litUpcomingShows" runat="server" Text="—"></asp:Literal>
                            </div>
                            <div class="label">Upcoming Shows</div>
                        </div>
                        <div class="stat-icon ms-auto">
                            <i class="fas fa-calendar-alt"></i>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-md-3">
                    <div class="stat-card">
                        <div class="stat-info">
                            <div class="value">
                                <asp:Literal ID="litTotalTickets" runat="server" Text="—"></asp:Literal>
                            </div>
                            <div class="label">Tickets Sold</div>
                        </div>
                        <div class="stat-icon ms-auto" style="background:var(--g900); color:var(--g50);">
                            <i class="fas fa-ticket-alt"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ── Charts Row ── -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8">
                    <div class="custom-card h-100">
                        <div class="custom-card-header">
                            <i class="fas fa-chart-bar" style="color:var(--g500);"></i> Top Halls by Occupancy
                        </div>
                        <div class="card-body">
                            <div class="chart-container">
                                <canvas id="occupancyChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="custom-card h-100">
                        <div class="custom-card-header">
                            <i class="fas fa-chart-pie" style="color:var(--g500);"></i> Tickets by Movie (Last 30 Days)
                        </div>
                        <div class="card-body">
                            <div class="chart-container">
                                <canvas id="revenueChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ── Golden Hour Automation ── -->
            <div class="row">
                <div class="col-12">
                    <div class="custom-card" style="border-left:4px solid var(--g800);">
                        <div class="card-body p-4 d-flex align-items-center justify-content-between flex-wrap gap-3">
                            <div>
                                <h5 class="fw-bold mb-1" style="color:var(--g900);"><i class="fas fa-robot me-2"></i>
                                    Golden
                                    Hour Policy</h5>
                                <p class="mb-0" style="color:var(--g500); font-size:0.9rem;">
                                    Auto-cancels unpaid (Reserved) bookings 1 hour before showtime.
                                    Currently tracking <strong style="color:var(--g900);">
                                        <asp:Literal ID="litReservedBookings" runat="server" Text="0"></asp:Literal>
                                    </strong> pending reservations.
                                </p>
                            </div>
                            <div>
                                <asp:Button ID="btnRunCancellation" runat="server" Text="Execute Manual Scan"
                                    CssClass="btn btn-dark fw-bold px-4" OnClick="btnRunCancellation_Click" />
                            </div>
                        </div>
                        <asp:Panel ID="pnlCancelMsg" runat="server" Visible="false" CssClass="px-4 pb-3">
                            <asp:Literal ID="litCancelMsg" runat="server"></asp:Literal>
                        </asp:Panel>
                    </div>
                </div>
            </div>

            <!-- Injecting Data from Code-Behind -->
            <asp:Literal ID="litChartData" runat="server"></asp:Literal>

            <script>
                document.addEventListener('DOMContentLoaded', function () {
                    // Chart global styling to match greyscale
                    Chart.defaults.color = '#737373';
                    Chart.defaults.font.family = "'Inter', sans-serif";

                    // Render Occupancy Bar Chart
                    if (typeof occupancyLabels !== 'undefined') {
                        const ctxOcc = document.getElementById('occupancyChart').getContext('2d');
                        new Chart(ctxOcc, {
                            type: 'bar',
                            data: {
                                labels: occupancyLabels,
                                datasets: [{
                                    label: 'Avg. Occupancy %',
                                    data: occupancyData,
                                    backgroundColor: '#262626',
                                    borderRadius: 4,
                                    barPercentage: 0.6
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: { legend: { display: false } },
                                scales: {
                                    y: {
                                        beginAtZero: true,
                                        max: 100,
                                        grid: { color: '#e5e5e5' }
                                    },
                                    x: { grid: { display: false } }
                                }
                            }
                        });
                    }

                    // Render Tickets by Movie Doughnut Chart
                    if (typeof movieLabels !== 'undefined') {
                        const ctxRev = document.getElementById('revenueChart').getContext('2d');
                        new Chart(ctxRev, {
                            type: 'doughnut',
                            data: {
                                labels: movieLabels,
                                datasets: [{
                                    data: movieData,
                                    backgroundColor: ['#171717', '#737373', '#d4d4d4', '#e5e5e5', '#a1a1a1'],
                                    borderWidth: 0,
                                    hoverOffset: 4
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                cutout: '70%',
                                plugins: {
                                    legend: { position: 'right', labels: { boxWidth: 12, padding: 15 } }
                                }
                            }
                        });
                    }
                });
            </script>
    </asp:Content>