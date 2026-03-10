<%@ Page Title="Movie Management" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Movies.aspx.cs" Inherits="Data_and_Web_Coursework.Movies" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1">Movie Management</h2>
                <p class="text-muted mb-4">Manage the list of available movies for screening.</p>

                <%-- ── Help Section ── --%>
                    <div class="alert alert-secondary border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;background:var(--g100);">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:var(--g200);cursor:pointer;" onclick="toggleGuide()">
                            <i class="fas fa-question-circle text-dark me-2"></i> Managing Movies
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ul class="mb-0 ps-3">
                                <li class="mb-1"><strong>Duration</strong>: Enter movie runtime in minutes (e.g., 120).
                                </li>
                                <li class="mb-1"><strong>Genre/Language</strong>: Useful for filtering and reporting.
                                </li>
                                <li class="mb-0"><strong>Planning</strong>: Ensure movies are entered before creating
                                    showtimes.</li>
                            </ul>
                        </div>
                    </div>

                    <%-- Add / Edit Form --%>
                        <div class="card mb-4 shadow-sm border-0" style="border-radius:14px;">
                            <div class="card-header text-white fw-bold"
                                style="background:var(--g800);border-radius:14px 14px 0 0;">Add / Update Movie</div>
                            <div class="card-body">
                                <asp:HiddenField ID="hfMovieID" runat="server" />
                                <div class="row g-3">
                                    <div class="col-md-2">
                                        <label class="form-label">Movie ID <span class="text-danger">*</span></label>
                                        <asp:TextBox ID="txtMovieID" runat="server" CssClass="form-control"
                                            placeholder="Numeric ID e.g. 1"></asp:TextBox>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Title <span class="text-danger">*</span></label>
                                        <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control"
                                            placeholder="Movie Title (max 60 chars)"></asp:TextBox>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label">Genre <span class="text-danger">*</span></label>
                                        <asp:DropDownList ID="ddlGenre" runat="server" CssClass="form-select">
                                            <asp:ListItem Value="Action">Action</asp:ListItem>
                                            <asp:ListItem Value="Comedy">Comedy</asp:ListItem>
                                            <asp:ListItem Value="Drama">Drama</asp:ListItem>
                                            <asp:ListItem Value="Horror">Horror</asp:ListItem>
                                            <asp:ListItem Value="Sci-Fi">Sci-Fi</asp:ListItem>
                                            <asp:ListItem Value="Romance">Romance</asp:ListItem>
                                            <asp:ListItem Value="Thriller">Thriller</asp:ListItem>
                                            <asp:ListItem Value="Animation">Animation</asp:ListItem>
                                            <asp:ListItem Value="Documentary">Documentary</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label">Duration (min) <span
                                                class="text-danger">*</span></label>
                                        <asp:TextBox ID="txtDuration" runat="server" CssClass="form-control"
                                            placeholder="e.g. 120"></asp:TextBox>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label">Language <span class="text-danger">*</span></label>
                                        <asp:TextBox ID="txtLanguage" runat="server" CssClass="form-control"
                                            placeholder="e.g. English"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="mt-3">
                                    <asp:Button ID="btnSave" runat="server" Text="Save Movie" CssClass="btn btn-success"
                                        OnClick="btnSave_Click" CausesValidation="false" />
                                    <asp:Button ID="btnClear" runat="server" Text="Clear Fields"
                                        CssClass="btn btn-outline-secondary ms-2" OnClick="btnClear_Click" />
                                </div>
                            </div>
                        </div>

                        <%-- Search Bar --%>
                            <div class="card mb-3 shadow-sm">
                                <div class="card-body py-2">
                                    <div class="input-group">
                                        <span class="input-group-text bg-white border-end-0">
                                            <i class="fas fa-search text-muted"></i>
                                        </span>
                                        <asp:TextBox ID="txtSearch" runat="server"
                                            CssClass="form-control border-start-0"
                                            placeholder="Search by title or genre..."></asp:TextBox>
                                        <asp:Button ID="btnSearch" runat="server" Text="Search"
                                            CssClass="btn btn-outline-success" OnClick="btnSearch_Click"
                                            CausesValidation="false" />
                                        <asp:Button ID="btnResetSearch" runat="server" Text="Reset"
                                            CssClass="btn btn-outline-secondary" OnClick="btnResetSearch_Click"
                                            CausesValidation="false" />
                                    </div>
                                </div>
                            </div>

                            <%-- Movies Grid --%>
                                <div class="card shadow-sm">
                                    <div class="card-body p-0">
                                        <asp:GridView ID="gvMovies" runat="server"
                                            CssClass="table table-striped table-hover mb-0" AutoGenerateColumns="False"
                                            DataKeyNames="MOVIE_ID" OnRowCommand="gvMovies_RowCommand">
                                            <EmptyDataTemplate>
                                                <div class="p-4 text-center text-muted">No movies found. Add one above!
                                                </div>
                                            </EmptyDataTemplate>
                                            <Columns>
                                                <asp:BoundField DataField="MOVIE_ID" HeaderText="ID" />
                                                <asp:BoundField DataField="TITLE" HeaderText="Title" />
                                                <asp:BoundField DataField="GENRE" HeaderText="Genre" />
                                                <asp:BoundField DataField="DURATION" HeaderText="Duration (min)" />
                                                <asp:BoundField DataField="LANGUAGE" HeaderText="Language" />
                                                <asp:TemplateField HeaderText="Actions">
                                                    <ItemTemplate>
                                                        <asp:LinkButton ID="btnSchedule" runat="server"
                                                            CommandName="ScheduleMovie"
                                                            CommandArgument='<%# Eval("MOVIE_ID") %>'
                                                            CssClass="btn btn-sm btn-success me-1">
                                                            <i class="fas fa-calendar-plus"></i> Schedule
                                                        </asp:LinkButton>
                                                        <asp:LinkButton ID="btnOccupancy" runat="server"
                                                            CommandName="ViewOccupancy"
                                                            CommandArgument='<%# Eval("MOVIE_ID") %>'
                                                            CssClass="btn btn-sm btn-outline-info me-1">
                                                            <i class="fas fa-chart-pie"></i> Occupancy
                                                        </asp:LinkButton>
                                                        <asp:LinkButton ID="btnEdit" runat="server"
                                                            CommandName="EditMovie"
                                                            CommandArgument='<%# Eval("MOVIE_ID") %>'
                                                            CssClass="btn btn-sm btn-warning me-1">
                                                            <i class="fas fa-edit"></i> Edit
                                                        </asp:LinkButton>
                                                        <asp:LinkButton ID="btnDel" runat="server"
                                                            CommandName="DeleteMovie"
                                                            CommandArgument='<%# Eval("MOVIE_ID") %>'
                                                            CssClass="btn btn-outline-danger btn-sm action-btn mx-1"
                                                            OnClientClick="return confirmDelete(this, 'Movie');">
                                                            <i class="fas fa-trash-alt"></i> Delete
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