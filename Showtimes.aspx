<%@ Page Title="Showtime Details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Showtimes.aspx.cs" Inherits="Data_and_Web_Coursework.Showtimes" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
            <div class="col-md-12">
                <h2 class="mb-1">Showtime Management</h2>
                <p class="text-muted mb-4">Schedule movies in halls and set base pricing.</p>

                <%-- ── Help Section ── --%>
                    <div class="alert alert-secondary border-0 shadow-sm mb-4 p-0"
                        style="border-radius:12px;overflow:hidden;background:var(--g100);">
                        <div class="d-flex align-items-center px-4 py-2 fw-bold"
                            style="background:var(--g200);cursor:pointer;" onclick="toggleGuide()">
                            <i class="fas fa-question-circle text-dark me-2"></i> Showtime Planning
                            <i class="fas fa-chevron-down ms-auto" id="guideChevron"></i>
                        </div>
                        <div id="guideBody" style="display:none;" class="px-4 py-3">
                            <ul class="mb-0 ps-3">
                                <li class="mb-1"><strong>Time Format</strong>: Use the 12-hour picker (AM/PM) for easier
                                    scheduling.</li>
                                <li class="mb-1"><strong>Base Price</strong>: The initial cost before any pricing policy
                                    multipliers are applied.</li>
                                <li class="mb-1"><strong>Clash Prevention</strong>: Ensure showtimes in the same hall do
                                    not overlap in time.</li>
                                <li class="mb-0"><strong>Pricing Policy</strong>: Select a policy (e.g., Weekend,
                                    Holiday) to adjust the final ticket price.</li>
                            </ul>
                        </div>
                    </div>
                    <div class="card mb-4 shadow-sm border-0" style="border-radius:14px;">
                        <div class="card-header text-white fw-bold"
                            style="background:var(--g800);border-radius:14px 14px 0 0;">Add / Update Showtime</div>
                        <div class="card-body">
                            <div class="row g-3">
                                <asp:HiddenField ID="hfShowID" runat="server" />

                                <%-- Hidden fields that store the composed datetime strings for the code-behind --%>
                                    <asp:HiddenField ID="txtStart" runat="server" />
                                    <asp:HiddenField ID="txtEnd" runat="server" />

                                    <div class="col-md-2">
                                        <label class="form-label">Show ID</label>
                                        <asp:TextBox ID="txtShowID" runat="server" CssClass="form-control">
                                        </asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Movie</label>
                                        <asp:DropDownList ID="ddlMovie" runat="server" CssClass="form-select">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Hall</label>
                                        <asp:DropDownList ID="ddlHall" runat="server" CssClass="form-select">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label">Base Price</label>
                                        <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control"
                                            TextMode="Number">
                                        </asp:TextBox>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label">Show Type</label>
                                        <asp:DropDownList ID="ddlType" runat="server" CssClass="form-select">
                                            <asp:ListItem>2D</asp:ListItem>
                                            <asp:ListItem>3D</asp:ListItem>
                                            <asp:ListItem>IMAX</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <%-- ── Start Time picker ── --%>
                                        <div class="col-md-5">
                                            <label class="form-label fw-semibold">
                                                <i class="fas fa-play-circle text-success me-1"></i>Start Time
                                            </label>
                                            <div class="time-picker-card border rounded-3 p-3 bg-light">
                                                <div class="d-flex align-items-center gap-2 flex-wrap">
                                                    <%-- Date --%>
                                                        <div class="flex-fill">
                                                            <label class="form-label small text-muted mb-1">Date</label>
                                                            <input type="date" id="stDate" class="form-control"
                                                                onchange="syncDateTime('start')" />
                                                        </div>
                                                        <%-- Hour --%>
                                                            <div style="width:75px">
                                                                <label
                                                                    class="form-label small text-muted mb-1">Hour</label>
                                                                <select id="stHour" class="form-select"
                                                                    onchange="syncDateTime('start')">
                                                                    <% for(int h=1;h<=12;h++){%>
                                                                        <option value="<%=h%>">
                                                                            <%=h.ToString("D2")%>
                                                                        </option>
                                                                        <% } %>
                                                                </select>
                                                            </div>
                                                            <div class="pt-3 text-muted fw-bold">:</div>
                                                            <%-- Minute --%>
                                                                <div style="width:75px">
                                                                    <label
                                                                        class="form-label small text-muted mb-1">Min</label>
                                                                    <select id="stMin" class="form-select"
                                                                        onchange="syncDateTime('start')">
                                                                        <option value="00">00</option>
                                                                        <option value="15">15</option>
                                                                        <option value="30">30</option>
                                                                        <option value="45">45</option>
                                                                    </select>
                                                                </div>
                                                                <%-- AM/PM --%>
                                                                    <div style="width:80px">
                                                                        <label
                                                                            class="form-label small text-muted mb-1">AM/PM</label>
                                                                        <select id="stAmPm" class="form-select"
                                                                            onchange="syncDateTime('start')">
                                                                            <option value="AM">AM</option>
                                                                            <option value="PM">PM</option>
                                                                        </select>
                                                                    </div>
                                                </div>
                                                <%-- Live preview --%>
                                                    <div class="mt-2">
                                                        <span id="stPreview"
                                                            class="badge bg-success fs-6 px-3 py-2 rounded-pill">
                                                            <i class="fas fa-clock me-1"></i>&nbsp;--
                                                        </span>
                                                    </div>
                                            </div>
                                        </div>

                                        <%-- ── End Time picker ── --%>
                                            <div class="col-md-5">
                                                <label class="form-label fw-semibold">
                                                    <i class="fas fa-stop-circle text-danger me-1"></i>End Time
                                                </label>
                                                <div class="time-picker-card border rounded-3 p-3 bg-light">
                                                    <div class="d-flex align-items-center gap-2 flex-wrap">
                                                        <div class="flex-fill">
                                                            <label class="form-label small text-muted mb-1">Date</label>
                                                            <input type="date" id="enDate" class="form-control"
                                                                onchange="syncDateTime('end')" />
                                                        </div>
                                                        <div style="width:75px">
                                                            <label class="form-label small text-muted mb-1">Hour</label>
                                                            <select id="enHour" class="form-select"
                                                                onchange="syncDateTime('end')">
                                                                <% for(int h=1;h<=12;h++){%>
                                                                    <option value="<%=h%>">
                                                                        <%=h.ToString("D2")%>
                                                                    </option>
                                                                    <% } %>
                                                            </select>
                                                        </div>
                                                        <div class="pt-3 text-muted fw-bold">:</div>
                                                        <div style="width:75px">
                                                            <label class="form-label small text-muted mb-1">Min</label>
                                                            <select id="enMin" class="form-select"
                                                                onchange="syncDateTime('end')">
                                                                <option value="00">00</option>
                                                                <option value="15">15</option>
                                                                <option value="30">30</option>
                                                                <option value="45">45</option>
                                                            </select>
                                                        </div>
                                                        <div style="width:80px">
                                                            <label
                                                                class="form-label small text-muted mb-1">AM/PM</label>
                                                            <select id="enAmPm" class="form-select"
                                                                onchange="syncDateTime('end')">
                                                                <option value="AM">AM</option>
                                                                <option value="PM">PM</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="mt-2">
                                                        <span id="enPreview"
                                                            class="badge bg-danger fs-6 px-3 py-2 rounded-pill">
                                                            <i class="fas fa-clock me-1"></i>&nbsp;--
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="col-md-2">
                                                <label class="form-label">Pricing Policy</label>
                                                <asp:DropDownList ID="ddlPricing" runat="server" CssClass="form-select">
                                                </asp:DropDownList>
                                            </div>

                                            <div class="col-12 mt-3 text-end">
                                                <asp:Button ID="btnSave" runat="server" Text="Schedule Showtime"
                                                    CssClass="btn btn-warning" OnClick="btnSave_Click"
                                                    OnClientClick="return composeDateTimes();" />
                                                <asp:Button ID="btnClear" runat="server" Text="Cancel"
                                                    CssClass="btn btn-outline-secondary" OnClick="btnClear_Click"
                                                    OnClientClick="clearPickers();" />
                                            </div>
                            </div>
                        </div>
                    </div>

                    <div class="card shadow">
                        <div class="card-body">
                            <asp:GridView ID="gvShowtimes" runat="server" CssClass="table table-hover"
                                AutoGenerateColumns="False" OnRowCommand="gvShowtimes_RowCommand">
                                <HeaderStyle CssClass="table-dark" />
                                <Columns>
                                    <asp:BoundField DataField="SHOW_ID" HeaderText="ID" />
                                    <asp:BoundField DataField="TITLE" HeaderText="Movie" />
                                    <asp:BoundField DataField="HALL_NAME" HeaderText="Hall" />
                                    <asp:BoundField DataField="SHOW_TYPE" HeaderText="Type" />
                                    <asp:BoundField DataField="START_TIME" HeaderText="Start"
                                        DataFormatString="{0:dd-MMM-yy hh:mm tt}" />
                                    <asp:BoundField DataField="BASE_PRICE" HeaderText="Base Price"
                                        DataFormatString="{0:N2}" />
                                    <asp:BoundField DataField="POLICY_NAME" HeaderText="Pricing Policy" />
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditShow"
                                                CommandArgument='<%# Eval("SHOW_ID") %>'
                                                CssClass="btn btn-sm btn-outline-warning">Edit
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDel" runat="server" CommandName="DeleteShow"
                                                CommandArgument='<%# Eval("SHOW_ID") %>'
                                                CssClass="btn btn-sm btn-outline-danger ms-1 action-btn"
                                                OnClientClick="return confirmDelete(this, 'Showtime');">Remove
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
            </div>
        </div>

        <%-- ── Time-picker styles & logic ── --%>
            <style>
                .time-picker-card {
                    transition: box-shadow .2s;
                }

                .time-picker-card:focus-within {
                    box-shadow: 0 0 0 3px rgba(255, 193, 7, .35);
                }
            </style>

            <script>
                /* ---------- helpers ---------- */
                function pad2(n) { return String(n).padStart(2, '0'); }

                /* Convert 12-hr picker values → "HH:mm" 24-hr string */
                function to24(hour, min, ampm) {
                    var h = parseInt(hour, 10);
                    if (ampm === 'AM') { if (h === 12) h = 0; }
                    else { if (h !== 12) h += 12; }
                    return pad2(h) + ':' + pad2(parseInt(min, 10));
                }

                /* Build yyyy-MM-ddTHH:mm and push into the hidden ASP.NET field
                   Also updates the human-readable preview badge */
                function syncDateTime(which) {
                    var prefix = (which === 'start') ? 'st' : 'en';
                    var dateEl = document.getElementById(prefix + 'Date');
                    var hourEl = document.getElementById(prefix + 'Hour');
                    var minEl = document.getElementById(prefix + 'Min');
                    var ampmEl = document.getElementById(prefix + 'AmPm');
                    var preview = document.getElementById(prefix + 'Preview');

                    /* hidden field client-side ID injected by ASP.NET */
                    var hiddenId = (which === 'start')
                        ? '<%= txtStart.ClientID %>'
                        : '<%= txtEnd.ClientID %>';
                    var hidden = document.getElementById(hiddenId);

                    if (!dateEl.value) return;
                    var time24 = to24(hourEl.value, minEl.value, ampmEl.value);
                    hidden.value = dateEl.value + 'T' + time24;   // yyyy-MM-ddTHH:mm

                    /* Friendly preview text */
                    var parts = dateEl.value.split('-');           // [yyyy, MM, dd]
                    var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                    var friendlyDate = parts[2] + ' ' + months[parseInt(parts[1]) - 1] + ' ' + parts[0];
                    var h = pad2(hourEl.value), m = minEl.value, ap = ampmEl.value;
                    preview.innerHTML = '<i class="fas fa-clock me-1"></i>' + friendlyDate + ' &nbsp; ' + h + ':' + m + ' ' + ap;
                }

                /* Called just before form submit – makes sure both hidden fields are populated */
                function composeDateTimes() {
                    syncDateTime('start');
                    syncDateTime('end');

                    var hidStart = document.getElementById('<%= txtStart.ClientID %>');
                    var hidEnd = document.getElementById('<%= txtEnd.ClientID %>');
                    if (!hidStart.value || !hidEnd.value) {
                        alert('Please fill in both Start Time and End Time.');
                        return false;
                    }
                    return true;
                }

                /* Clear picker UI after Cancel / successful save */
                function clearPickers() {
                    ['st', 'en'].forEach(function (p) {
                        var d = document.getElementById(p + 'Date');
                        var h = document.getElementById(p + 'Hour');
                        var m = document.getElementById(p + 'Min');
                        var a = document.getElementById(p + 'AmPm');
                        var pr = document.getElementById(p + 'Preview');
                        if (d) d.value = '';
                        if (h) h.selectedIndex = 0;
                        if (m) m.selectedIndex = 0;
                        if (a) a.selectedIndex = 0;
                        if (pr) pr.innerHTML = '<i class="fas fa-clock me-1"></i>&nbsp;--';
                    });
                    document.getElementById('<%= txtStart.ClientID %>').value = '';
                    document.getElementById('<%= txtEnd.ClientID %>').value = '';
                }

                /* Populate pickers when the server round-trips an "Edit" click.
                   The server sets the hidden field values (yyyy-MM-ddTHH:mm).
                   We parse them back to fill the UI controls. */
                function populatePickers(which, isoValue) {
                    if (!isoValue) return;
                    var prefix = (which === 'start') ? 'st' : 'en';
                    /* isoValue = "yyyy-MM-ddTHH:mm" */
                    var datePart = isoValue.substring(0, 10);
                    var timePart = isoValue.substring(11);           /* "HH:mm" */
                    var hh = parseInt(timePart.split(':')[0], 10);
                    var mm = timePart.split(':')[1];
                    var ampm = hh < 12 ? 'AM' : 'PM';
                    var h12 = hh % 12; if (h12 === 0) h12 = 12;

                    document.getElementById(prefix + 'Date').value = datePart;
                    document.getElementById(prefix + 'Hour').value = h12;
                    document.getElementById(prefix + 'Min').value = mm;
                    document.getElementById(prefix + 'AmPm').value = ampm;
                    syncDateTime(which);
                }

                /* On page load: if hidden fields already have values (edit mode), restore pickers */
                window.addEventListener('DOMContentLoaded', function () {
                    var sv = document.getElementById('<%= txtStart.ClientID %>').value;
                    var ev = document.getElementById('<%= txtEnd.ClientID %>').value;
                    if (sv) populatePickers('start', sv);
                    if (ev) populatePickers('end', ev);
                });
            </script>
    </asp:Content>