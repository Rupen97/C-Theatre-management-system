<%@ Page Title="User Details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Users.aspx.cs" Inherits="Data_and_Web_Coursework.Users" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    </asp:Content>
    <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1">User Details Management</h2>
                <p class="text-muted mb-4">Create, update, and manage system users and customers.</p>

                <%-- ── Help Section ── --%>
                    <div class="alert alert-secondary border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;background:var(--g100);">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:var(--g200);cursor:pointer;" onclick="toggleGuide()">
                            <i class="fas fa-question-circle text-dark me-2"></i> Managing Users
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ul class="mb-0 ps-3">
                                <li class="mb-1"><strong>User ID</strong>: Must be unique. Use the ID field when
                                    creating a new user.</li>
                                <li class="mb-1"><strong>Contact Info</strong>: Ensure phone numbers are entered without
                                    special characters.</li>
                                <li class="mb-0"><strong>Deletion</strong>: Deleting a user will also delete all their
                                    bookings and tickets due to database constraints.</li>
                            </ul>
                        </div>
                    </div>
                    <div class="card mb-4 shadow-sm border-0" style="border-radius:14px;">
                        <div class="card-header text-white fw-bold"
                            style="background:var(--g800);border-radius:14px 14px 0 0;">Add / Update User</div>
                        <div class="card-body">
                            <div class="row g-3">
                                <asp:HiddenField ID="hfUserID" runat="server" />
                                <div class="col-md-3">
                                    <label class="form-label">User ID</label>
                                    <asp:TextBox ID="txtUserID" runat="server" CssClass="form-control"
                                        placeholder="ID (Manual for now)"></asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Name</label>
                                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control"
                                        placeholder="Full Name"></asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Email</label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control"
                                        placeholder="email@example.com"></asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Phone</label>
                                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control"
                                        placeholder="Phone Number"></asp:TextBox>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label">Address</label>
                                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control"
                                        TextMode="MultiLine" Rows="2"></asp:TextBox>
                                </div>
                                <div class="col-12 mt-3">
                                    <asp:Button ID="btnSave" runat="server" Text="Save User" CssClass="btn btn-primary"
                                        OnClick="btnSave_Click" />
                                    <asp:Button ID="btnClear" runat="server" Text="Clear Fields"
                                        CssClass="btn btn-secondary ms-2" OnClick="btnClear_Click" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-header bg-dark text-white">User List</div>
                        <div class="card-body">
                            <asp:GridView ID="gvUsers" runat="server" CssClass="table table-striped table-hover"
                                AutoGenerateColumns="False" DataKeyNames="USER_ID" OnRowCommand="gvUsers_RowCommand">
                                <Columns>
                                    <asp:BoundField DataField="USER_ID" HeaderText="ID" />
                                    <asp:BoundField DataField="USER_NAME" HeaderText="Name" />
                                    <asp:BoundField DataField="USER_EMAIL" HeaderText="Email" />
                                    <asp:BoundField DataField="USER_PHONE" HeaderText="Phone" />
                                    <asp:BoundField DataField="ADDRESS" HeaderText="Address" />
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditUser"
                                                CommandArgument='<%# Eval("USER_ID") %>'
                                                CssClass="btn btn-sm btn-warning">
                                                <i class="fas fa-edit"></i> Edit
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteUser"
                                                CommandArgument='<%# Eval("USER_ID") %>'
                                                CssClass="btn btn-sm btn-danger action-btn"
                                                OnClientClick="return confirmDelete(this, 'User');"><i
                                                    class="fas fa-trash"></i> Delete</asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
            </div>
        </div>
    </asp:Content>