<%@ Page Title="Cinema & Hall Details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Cinemas.aspx.cs" Inherits="Data_and_Web_Coursework.Cinemas" %>

    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1">Cinema & Hall Management</h2>
                <p class="text-muted mb-4">Manage theater locations and their respective screening halls.</p>

                <%-- ── Help Section ── --%>
                    <div class="alert alert-info border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:rgba(13,202,240,.15);cursor:pointer;" onclick="toggleGuide()">
                            <i class="fas fa-question-circle text-info me-2"></i> Cinema & Hall Tips
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ul class="mb-0 ps-3">
                                <li class="mb-1"><strong>Theater Groups</strong>: All halls must be assigned to an
                                    existing theater.</li>
                                <li class="mb-1"><strong>Hall Capacity</strong>: This is a reference value; seat
                                    availability is managed on the <a href="Seats.aspx">Seats</a> page.</li>
                                <li class="mb-0"><strong>Cinema Details</strong>: Update contact info and email for
                                    theater locations to ensure accurate reporting.</li>
                            </ul>
                        </div>
                    </div>

                    <!-- Cinema Section -->
                    <div class="card mb-4 shadow-sm">
                        <div class="card-header bg-primary text-white">Add / Update Cinema</div>
                        <div class="card-body">
                            <div class="row g-3">
                                <asp:HiddenField ID="hfCinemaID" runat="server" />
                                <div class="col-md-2">
                                    <label class="form-label">ID</label>
                                    <asp:TextBox ID="txtCinemaID" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Name</label>
                                    <asp:TextBox ID="txtCinemaName" runat="server" CssClass="form-control">
                                    </asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Location</label>
                                    <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Phone</label>
                                    <asp:TextBox ID="txtCinemaPhone" runat="server" CssClass="form-control">
                                    </asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Email</label>
                                    <asp:TextBox ID="txtCinemaEmail" runat="server" CssClass="form-control"
                                        TextMode="Email"></asp:TextBox>
                                </div>
                                <div class="col-md-2 align-items-end d-flex">
                                    <asp:Button ID="btnSaveCinema" runat="server" Text="Save Cinema"
                                        CssClass="btn btn-primary w-100" OnClick="btnSaveCinema_Click" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Hall Section -->
                    <div class="card mb-4 shadow-sm border-info">
                        <div class="card-header bg-info text-dark">Add / Update Hall</div>
                        <div class="card-body">
                            <div class="row g-3">
                                <asp:HiddenField ID="hfHallID" runat="server" />
                                <div class="col-md-2">
                                    <label class="form-label">Hall ID</label>
                                    <asp:TextBox ID="txtHallID" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Hall Name</label>
                                    <asp:TextBox ID="txtHallName" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Capacity</label>
                                    <asp:TextBox ID="txtCapacity" runat="server" CssClass="form-control"
                                        TextMode="Number">
                                    </asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Cinema</label>
                                    <asp:DropDownList ID="ddlCinema" runat="server" CssClass="form-select">
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Status</label>
                                    <asp:DropDownList ID="ddlHallStatus" runat="server" CssClass="form-select">
                                        <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
                                        <asp:ListItem Text="Maintenance" Value="Maintenance"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Type</label>
                                    <asp:DropDownList ID="ddlHallType" runat="server" CssClass="form-select">
                                        <asp:ListItem Text="2D" Value="2D"></asp:ListItem>
                                        <asp:ListItem Text="3D" Value="3D"></asp:ListItem>
                                        <asp:ListItem Text="IMAX" Value="IMAX"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2 align-items-end d-flex">
                                    <asp:Button ID="btnSaveHall" runat="server" Text="Save Hall"
                                        CssClass="btn btn-info w-100" OnClick="btnSaveHall_Click" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="card">
                                <div class="card-header">Cinemas</div>
                                <div class="card-body">
                                    <asp:GridView ID="gvCinemas" runat="server" CssClass="table table-sm"
                                        AutoGenerateColumns="False" OnRowCommand="gvCinemas_RowCommand">
                                        <Columns>
                                            <asp:BoundField DataField="THEATRE_ID" HeaderText="ID" />
                                            <asp:BoundField DataField="CINEMA_NAME" HeaderText="Name" />
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditCinema"
                                                        CommandArgument='<%# Eval("THEATRE_ID") %>'
                                                        CssClass="text-warning">
                                                        <i class="fas fa-edit"></i>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="btnDel" runat="server"
                                                        CommandName="DeleteCinema"
                                                        CommandArgument='<%# Eval("THEATRE_ID") %>'
                                                        CssClass="text-danger ms-2 action-btn"
                                                        OnClientClick="return confirmDelete(this, 'Cinema');"><i
                                                            class="fas fa-trash"></i>
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card">
                                <div class="card-header">Halls</div>
                                <div class="card-body">
                                    <asp:GridView ID="gvHalls" runat="server" CssClass="table table-sm"
                                        AutoGenerateColumns="False" OnRowCommand="gvHalls_RowCommand">
                                        <Columns>
                                            <asp:BoundField DataField="HALL_ID" HeaderText="ID" />
                                            <asp:BoundField DataField="HALL_NAME" HeaderText="Name" />
                                            <asp:BoundField DataField="CINEMA_NAME" HeaderText="Cinema" />
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditHall"
                                                        CommandArgument='<%# Eval("HALL_ID") %>'
                                                        CssClass="text-warning"><i class="fas fa-edit"></i>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="btnDel" runat="server" CommandName="DeleteHall"
                                                        CommandArgument='<%# Eval("HALL_ID") %>'
                                                        CssClass="text-danger ms-2 action-btn"
                                                        OnClientClick="return confirmDelete(this, 'Hall');"><i
                                                            class="fas fa-trash"></i>
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </div>
                        </div>
                    </div>
            </div>
        </div>
    </asp:Content>