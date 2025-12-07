from flask import (
    Flask,
    render_template_string,
    request,
    redirect,
    session
)
from db import run_query

app = Flask(__name__)
app.secret_key = "realestate-secret-key"  # any random string is fine

# ===========================================================
# BASE LAYOUT WITH BOOTSTRAP + "WeRent Homes" HEADER
# ===========================================================
BASE_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>WeRent Homes - Real Estate App</title>
    <!-- Bootstrap CSS -->
    <link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
      rel="stylesheet"
      integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
      crossorigin="anonymous"
    >
    <style>
        body {
            background: linear-gradient(135deg, #0f172a, #1e293b);
            min-height: 100vh;
            margin: 0;
            padding: 0;
            color: #0f172a;
        }
        .app-container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 15px;
        }
        .card-main {
            background: #f8fafc;
            border-radius: 18px;
            box-shadow: 0 15px 35px rgba(15,23,42,0.5);
            padding: 24px 30px 30px 30px;
        }
        .brand-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 18px;
        }
        .brand-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .brand-logo {
            width: 36px;
            height: 36px;
            border-radius: 999px;
            background: #1d4ed8;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
            box-shadow: 0 0 0 3px rgba(37,99,235,0.2);
        }
        .brand-title {
            font-weight: 700;
            font-size: 1.25rem;
            color: #0f172a;
        }
        .brand-sub {
            font-size: .8rem;
            color: #64748b;
        }
        .nav-links a {
            margin-left: 10px;
        }
        h1, h2, h3 {
            color: #0f172a;
        }
        a {
            color: #2563eb;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .btn-primary {
            background-color: #2563eb !important;
            border-color: #2563eb !important;
        }
        .btn-primary:hover {
            background-color: #1d4ed8 !important;
        }
        table {
            background: white;
        }
        th {
            background: #e2e8f0;
        }
        input, select {
            border-radius: 0.5rem !important;
        }
        .badge-role {
            font-size: 0.75rem;
            background: #e0f2fe;
            color: #0f172a;
            border-radius: 999px;
            padding: 3px 10px;
        }
    </style>
</head>
<body>
    <div class="app-container">
      <div class="card-main">
        <div class="brand-bar">
          <div class="brand-left">
            <div class="brand-logo">🏠</div>
            <div>
                <div class="brand-title">WeRent Homes</div>
                <div class="brand-sub">Real Estate Management Portal</div>
            </div>
          </div>
          <div class="nav-links">
            <a href="/" class="btn btn-sm btn-outline-secondary">Home</a>
            {% if session.get('role') == 'renter' %}
              <span class="badge-role">Renter: {{ session.get('renter_name', 'User') }}</span>
              <a href="/renter_dashboard" class="btn btn-sm btn-outline-primary">Dashboard</a>
            {% elif session.get('role') == 'agent' %}
              <span class="badge-role">Agent: {{ session.get('agent_name', 'User') }}</span>
              <a href="/agent_dashboard" class="btn btn-sm btn-outline-primary">Dashboard</a>
            {% endif %}
            {% if session.get('role') %}
              <a href="/logout" class="btn btn-sm btn-danger">Logout</a>
            {% endif %}
          </div>
        </div>

        <div class="mt-2">
          {{ content|safe }}
        </div>
      </div>
    </div>
    <!-- Bootstrap JS (optional, for dropdowns etc.) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
            integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
            crossorigin="anonymous"></script>
</body>
</html>
"""

def render_page(content: str):
    """Wrap page content in the base layout."""
    return render_template_string(BASE_HTML, content=content)

# ===========================================================
# HOME PAGE
# ===========================================================
@app.route("/")
def home():
    return render_page("""
        <h1 class="mb-3">Welcome to WeRent Homes</h1>
        <p class="text-muted">Choose how you want to continue:</p>
        <div class="row g-3">
          <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100">
              <div class="card-body">
                <h5 class="card-title">Renter</h5>
                <p class="card-text">Search properties, manage cards, and book rentals.</p>
                <a href="/login_renter" class="btn btn-primary btn-sm">Login as Renter</a>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100">
              <div class="card-body">
                <h5 class="card-title">Agent</h5>
                <p class="card-text">Manage your listings and view incoming bookings.</p>
                <a href="/login_agent" class="btn btn-primary btn-sm">Login as Agent</a>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100">
              <div class="card-body">
                <h5 class="card-title">New User</h5>
                <p class="card-text">Create an account as a renter or agent.</p>
                <a href="/register" class="btn btn-outline-primary btn-sm">Register</a>
              </div>
            </div>
          </div>
        </div>
    """)

# ===========================================================
# REGISTRATION
# ===========================================================
@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        role = request.form.get("role")
        email = request.form.get("email").strip()
        phone = request.form.get("phone").strip()
        first = request.form.get("first_name").strip()
        middle = request.form.get("middle_name").strip() or None
        last = request.form.get("last_name").strip()

        existing = run_query(
            'SELECT user_id FROM "USER" WHERE email = %s;',
            (email,), fetch=True
        )
        if existing:
            return render_page("""
                <h2>Register</h2>
                <div class="alert alert-danger">That email is already registered.</div>
                <a href="/login_renter" class="btn btn-primary btn-sm">Login as Renter</a>
                <a href="/login_agent" class="btn btn-outline-primary btn-sm ms-2">Login as Agent</a>
            """)

        run_query(
            '''
            INSERT INTO "USER" (email, phone_number, first_name, middle_name, last_name)
            VALUES (%s, %s, %s, %s, %s);
            ''',
            (email, phone, first, middle, last),
            fetch=False
        )

        user_row = run_query(
            'SELECT user_id FROM "USER" WHERE email = %s;',
            (email,), fetch=True
        )
        user_id = user_row[0][0]

        line_1 = request.form.get("line_1").strip()
        city = request.form.get("city").strip()
        state_ = request.form.get("state_").strip()
        zip_code = request.form.get("zip_code").strip() or None

        addr_id = None
        if line_1:
            run_query(
                '''
                INSERT INTO ADDRESS (line_1, city, state_, zip_code)
                VALUES (%s, %s, %s, %s);
                ''',
                (line_1, city, state_, zip_code),
                fetch=False
            )
            addr_row = run_query(
                '''
                SELECT address_id FROM ADDRESS
                WHERE line_1 = %s AND city = %s AND state_ = %s
                ORDER BY address_id DESC LIMIT 1;
                ''',
                (line_1, city, state_),
                fetch=True
            )
            addr_id = addr_row[0][0]

        if role == "renter":
            move_in = request.form.get("move_in_date") or None
            budget = request.form.get("budget") or None
            pref_loc = request.form.get("pref_location") or None
            ref_code = request.form.get("referral_code") or None

            run_query(
                '''
                INSERT INTO RENTER (user_id, address_id, Move_in_date, Budget, Pref_location, Referral_code)
                VALUES (%s, %s, %s, %s, %s, %s);
                ''',
                (user_id, addr_id, move_in, budget, pref_loc, ref_code),
                fetch=False
            )
            return redirect("/login_renter")

        elif role == "agent":
            job = request.form.get("job_title") or None
            agency = request.form.get("agency") or None
            langs = request.form.get("lang_spoken") or None

            run_query(
                '''
                INSERT INTO AGENT (user_id, Job_title, Agency, address_id, Lang_spoken)
                VALUES (%s, %s, %s, %s, %s);
                ''',
                (user_id, job, agency, addr_id, langs),
                fetch=False
            )
            return redirect("/login_agent")

        else:
            return "Invalid role selected", 400

    return render_page("""
        <h2>Register</h2>
        <form method="post" class="row g-3">
            <div class="col-md-4">
                <label class="form-label">Role</label>
                <select name="role" class="form-select" required>
                    <option value="renter">Renter</option>
                    <option value="agent">Agent</option>
                </select>
            </div>

            <div class="col-12"><h5 class="mt-2">Basic Info</h5></div>
            <div class="col-md-6">
                <label class="form-label">Email</label>
                <input type="email" name="email" class="form-control" required>
            </div>
            <div class="col-md-6">
                <label class="form-label">Phone</label>
                <input type="text" name="phone" class="form-control" required>
            </div>
            <div class="col-md-4">
                <label class="form-label">First Name</label>
                <input type="text" name="first_name" class="form-control" required>
            </div>
            <div class="col-md-4">
                <label class="form-label">Middle Name</label>
                <input type="text" name="middle_name" class="form-control">
            </div>
            <div class="col-md-4">
                <label class="form-label">Last Name</label>
                <input type="text" name="last_name" class="form-control" required>
            </div>

            <div class="col-12"><h5 class="mt-2">Address (optional)</h5></div>
            <div class="col-md-6">
                <label class="form-label">Line 1</label>
                <input type="text" name="line_1" class="form-control">
            </div>
            <div class="col-md-3">
                <label class="form-label">City</label>
                <input type="text" name="city" class="form-control">
            </div>
            <div class="col-md-3">
                <label class="form-label">State</label>
                <input type="text" name="state_" class="form-control">
            </div>
            <div class="col-md-3">
                <label class="form-label">Zip</label>
                <input type="text" name="zip_code" class="form-control">
            </div>

            <div class="col-12"><h5 class="mt-2">If Renter</h5></div>
            <div class="col-md-4">
                <label class="form-label">Move-in date (YYYY-MM-DD)</label>
                <input type="text" name="move_in_date" class="form-control">
            </div>
            <div class="col-md-4">
                <label class="form-label">Budget</label>
                <input type="number" step="0.01" name="budget" class="form-control">
            </div>
            <div class="col-md-4">
                <label class="form-label">Preferred location</label>
                <input type="text" name="pref_location" class="form-control">
            </div>
            <div class="col-md-4">
                <label class="form-label">Referral code</label>
                <input type="text" name="referral_code" class="form-control">
            </div>

            <div class="col-12"><h5 class="mt-2">If Agent</h5></div>
            <div class="col-md-4">
                <label class="form-label">Job title</label>
                <input type="text" name="job_title" class="form-control">
            </div>
            <div class="col-md-4">
                <label class="form-label">Agency</label>
                <input type="text" name="agency" class="form-control">
            </div>
            <div class="col-md-4">
                <label class="form-label">Languages spoken</label>
                <input type="text" name="lang_spoken" class="form-control">
            </div>

            <div class="col-12">
                <button type="submit" class="btn btn-primary mt-2">Register</button>
                <a href="/" class="btn btn-outline-secondary mt-2 ms-2">Cancel</a>
            </div>
        </form>
    """)

# ===========================================================
# RENTER LOGIN
# ===========================================================
@app.route("/login_renter", methods=["GET", "POST"])
def login_renter():
    if request.method == "POST":
        email = request.form["email"].strip()

        rows = run_query("""
            SELECT r.renter_id, u.first_name
            FROM RENTER r
            JOIN "USER" u ON r.user_id = u.user_id
            WHERE u.email = %s;
        """, (email,), fetch=True)

        if rows:
            renter_id = rows[0][0]
            first_name = rows[0][1]
            session.clear()
            session["role"] = "renter"
            session["renter_id"] = renter_id
            session["renter_name"] = first_name
            return redirect("/renter_dashboard")
        else:
            return render_page("""
                <h2>Renter Login</h2>
                <div class="alert alert-danger">Email not found or not registered as renter.</div>
                <form method="post" class="mb-3">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-control" required>
                    <button type="submit" class="btn btn-primary mt-3">Login</button>
                </form>
                <a href="/register" class="btn btn-outline-primary btn-sm">Register</a>
            """)

    return render_page("""
        <h2>Renter Login</h2>
        <form method="post" class="mb-3">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control" required>
            <button type="submit" class="btn btn-primary mt-3">Login</button>
        </form>
        <a href="/register" class="btn btn-outline-primary btn-sm">Register</a>
    """)

# ===========================================================
# AGENT LOGIN
# ===========================================================
@app.route("/login_agent", methods=["GET", "POST"])
def login_agent():
    if request.method == "POST":
        email = request.form["email"].strip()

        rows = run_query("""
            SELECT a.agent_id, u.first_name
            FROM AGENT a
            JOIN "USER" u ON a.user_id = u.user_id
            WHERE u.email = %s;
        """, (email,), fetch=True)

        if rows:
            agent_id = rows[0][0]
            first_name = rows[0][1]
            session.clear()
            session["role"] = "agent"
            session["agent_id"] = agent_id
            session["agent_name"] = first_name
            return redirect("/agent_dashboard")
        else:
            return render_page("""
                <h2>Agent Login</h2>
                <div class="alert alert-danger">Email not found or not registered as agent.</div>
                <form method="post" class="mb-3">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-control" required>
                    <button type="submit" class="btn btn-primary mt-3">Login</button>
                </form>
                <a href="/register" class="btn btn-outline-primary btn-sm">Register</a>
            """)

    return render_page("""
        <h2>Agent Login</h2>
        <form method="post" class="mb-3">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control" required>
            <button type="submit" class="btn btn-primary mt-3">Login</button>
        </form>
        <a href="/register" class="btn btn-outline-primary btn-sm">Register</a>
    """)

# ===========================================================
# LOGOUT
# ===========================================================
@app.route("/logout")
def logout():
    session.clear()
    return redirect("/")

# ===========================================================
# RENTER DASHBOARD
# ===========================================================
@app.route("/renter_dashboard")
def renter_dashboard():
    if session.get("role") != "renter":
        return redirect("/login_renter")

    name = session.get("renter_name", "Renter")
    return render_page(f"""
        <h2 class="mb-3">Hi, {name} 👋</h2>
        <p class="text-muted">Welcome to your renter dashboard.</p>
        <div class="list-group">
            <a href="/search" class="list-group-item list-group-item-action">
                🔍 Search Properties
            </a>
            <a href="/my_cards" class="list-group-item list-group-item-action">
                💳 Manage Payment Cards
            </a>
            <a href="/my_bookings" class="list-group-item list-group-item-action">
                📅 View My Bookings & Rewards
            </a>
        </div>
    """)

# ===========================================================
# AGENT DASHBOARD
# ===========================================================
@app.route("/agent_dashboard")
def agent_dashboard():
    if session.get("role") != "agent":
        return redirect("/login_agent")

    name = session.get("agent_name", "Agent")

    props = run_query("""
        SELECT p.prop_id, a.line_1, a.city, a.state_,
               p.price, pc.category_name, pd.rooms
        FROM PROPERTY p
        JOIN ADDRESS a ON p.address_id = a.address_id
        JOIN PROPERTY_DETAILS pd ON p.prop_id = pd.prop_id
        JOIN PROPERTY_CATEGORY pc ON pd.property_category_id = pc.property_category_id
        WHERE p.agent_id = %s
        ORDER BY p.prop_id;
    """, (session["agent_id"],), fetch=True)

    rows_html = ""
    for row in props:
        prop_id, addr, city, state_, price, cat, rooms = row
        rows_html += f"""
        <tr>
            <td>{prop_id}</td>
            <td>{addr}, {city}, {state_}</td>
            <td>{cat}</td>
            <td>{rooms if rooms is not None else '-'}</td>
            <td>${price}</td>
            <td>
                <form method="post" action="/agent/property/{prop_id}/delete" style="display:inline;">
                    <button type="submit" class="btn btn-sm btn-outline-danger">Delete</button>
                </form>
            </td>
        </tr>
        """

    return render_page(f"""
        <h2 class="mb-3">Welcome, {name} (Agent)</h2>
        <a href="/agent/property/new" class="btn btn-primary btn-sm mb-3">+ Add New Property</a>
        <h5>Your Properties</h5>
        <table class="table table-striped table-bordered align-middle">
            <thead>
                <tr>
                    <th>ID</th><th>Address</th><th>Type</th><th>Rooms</th><th>Price</th><th>Actions</th>
                </tr>
            </thead>
            <tbody>
                {rows_html if rows_html else '<tr><td colspan="6" class="text-muted">No properties yet.</td></tr>'}
            </tbody>
        </table>
        <a href="/agent_bookings" class="btn btn-outline-primary btn-sm mt-2">View Bookings on My Properties</a>
    """)

# ===========================================================
# AGENT: ADD PROPERTY
# ===========================================================
@app.route("/agent/property/new", methods=["GET", "POST"])
def agent_new_property():
    if session.get("role") != "agent":
        return redirect("/login_agent")

    if request.method == "POST":
        line_1 = request.form.get("line_1").strip()
        city = request.form.get("city").strip()
        state_ = request.form.get("state_").strip()
        zip_code = request.form.get("zip_code").strip() or None

        run_query(
            '''
            INSERT INTO ADDRESS (line_1, city, state_, zip_code)
            VALUES (%s, %s, %s, %s);
            ''',
            (line_1, city, state_, zip_code),
            fetch=False
        )

        addr_row = run_query(
            '''
            SELECT address_id FROM ADDRESS
            WHERE line_1 = %s AND city = %s AND state_ = %s
            ORDER BY address_id DESC LIMIT 1;
            ''',
            (line_1, city, state_),
            fetch=True
        )
        address_id = addr_row[0][0]

        sq_ft = request.form.get("sq_ft") or None
        price = request.form.get("price") or None
        date_avail = request.form.get("date_avail") or None
        utilities = bool(request.form.get("utilities"))
        parking = bool(request.form.get("parking"))

        run_query(
            '''
            INSERT INTO PROPERTY (agent_id, address_id, Sq_ft, Price, Date_of_availability, Utilities, Parking)
            VALUES (%s, %s, %s, %s, %s, %s, %s);
            ''',
            (session["agent_id"], address_id, sq_ft, price, date_avail, utilities, parking),
            fetch=False
        )

        prop_row = run_query(
            '''
            SELECT prop_id FROM PROPERTY
            WHERE agent_id = %s AND address_id = %s
            ORDER BY prop_id DESC LIMIT 1;
            ''',
            (session["agent_id"], address_id),
            fetch=True
        )
        prop_id = prop_row[0][0]

        category_name = request.form.get("category")
        desc = request.form.get("description") or None
        rooms = request.form.get("rooms") or None
        crime = request.form.get("crime_rate") or None
        btype = request.form.get("business_type") or None

        cat_row = run_query(
            "SELECT property_category_id FROM PROPERTY_CATEGORY WHERE category_name = %s;",
            (category_name,), fetch=True
        )
        if not cat_row:
            return "Invalid category", 400
        category_id = cat_row[0][0]

        run_query(
            '''
            INSERT INTO PROPERTY_DETAILS (prop_id, property_category_id, Description_, Rooms, Crime_rate, business_type)
            VALUES (%s, %s, %s, %s, %s, %s);
            ''',
            (prop_id, category_id, desc, rooms, crime, btype),
            fetch=False
        )

        return redirect("/agent_dashboard")

    cats = run_query("SELECT category_name FROM PROPERTY_CATEGORY ORDER BY category_name;", fetch=True)
    options = "".join([f'<option value="{c[0]}">{c[0]}</option>' for c in cats])

    return render_page(f"""
        <h2>Add New Property</h2>
        <form method="post" class="row g-3">
            <div class="col-12"><h5>Address</h5></div>
            <div class="col-md-6">
                <label class="form-label">Line 1</label>
                <input type="text" name="line_1" class="form-control" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">City</label>
                <input type="text" name="city" class="form-control" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">State</label>
                <input type="text" name="state_" class="form-control" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Zip</label>
                <input type="text" name="zip_code" class="form-control">
            </div>

            <div class="col-12"><h5>Basic Info</h5></div>
            <div class="col-md-3">
                <label class="form-label">Sq Ft</label>
                <input type="number" name="sq_ft" class="form-control" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Price</label>
                <input type="number" step="0.01" name="price" class="form-control" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Availability (YYYY-MM-DD)</label>
                <input type="text" name="date_avail" class="form-control">
            </div>
            <div class="col-md-3 d-flex align-items-end gap-2">
                <div class="form-check">
                    <input class="form-check-input" type="checkbox" name="utilities" id="utilCheck">
                    <label class="form-check-label" for="utilCheck">Utilities</label>
                </div>
                <div class="form-check">
                    <input class="form-check-input" type="checkbox" name="parking" id="parkCheck">
                    <label class="form-check-label" for="parkCheck">Parking</label>
                </div>
            </div>

            <div class="col-12"><h5>Details</h5></div>
            <div class="col-md-4">
                <label class="form-label">Category</label>
                <select name="category" class="form-select" required>
                    {options}
                </select>
            </div>
            <div class="col-md-8">
                <label class="form-label">Description</label>
                <input type="text" name="description" class="form-control">
            </div>
            <div class="col-md-3">
                <label class="form-label">Rooms</label>
                <input type="number" name="rooms" class="form-control">
            </div>
            <div class="col-md-3">
                <label class="form-label">Crime rate (text)</label>
                <input type="text" name="crime_rate" class="form-control">
            </div>
            <div class="col-md-6">
                <label class="form-label">Business type (for commercial/land)</label>
                <input type="text" name="business_type" class="form-control">
            </div>

            <div class="col-12">
                <button type="submit" class="btn btn-primary mt-2">Save Property</button>
                <a href="/agent_dashboard" class="btn btn-outline-secondary mt-2 ms-2">Cancel</a>
            </div>
        </form>
    """)

# ===========================================================
# AGENT: DELETE PROPERTY
# ===========================================================
@app.route("/agent/property/<int:prop_id>/delete", methods=["POST"])
def agent_delete_property(prop_id):
    if session.get("role") != "agent":
        return redirect("/login_agent")

    run_query(
        "DELETE FROM PROPERTY WHERE prop_id = %s AND agent_id = %s;",
        (prop_id, session["agent_id"]),
        fetch=False
    )
    return redirect("/agent_dashboard")

# ===========================================================
# AGENT: VIEW BOOKINGS
# ===========================================================
@app.route("/agent_bookings")
def agent_bookings():
    if session.get("role") != "agent":
        return redirect("/login_agent")

    rows = run_query("""
        SELECT b.booking_id, b.booking_date,
               p.prop_id, a.line_1, a.city, p.price,
               u.email AS renter_email
        FROM BOOKING b
        JOIN PROPERTY p ON b.prop_id = p.prop_id
        JOIN ADDRESS a ON p.address_id = a.address_id
        JOIN RENTER r ON b.renter_id = r.renter_id
        JOIN "USER" u ON r.user_id = u.user_id
        WHERE p.agent_id = %s
        ORDER BY b.booking_id DESC;
    """, (session["agent_id"],), fetch=True)

    body = ""
    for row in rows:
        bid, bdate, pid, addr, city, price, remail = row
        body += f"""
        <tr>
            <td>{bid}</td>
            <td>{bdate}</td>
            <td>{pid}</td>
            <td>{addr}, {city}</td>
            <td>${price}</td>
            <td>{remail}</td>
        </tr>
        """

    return render_page(f"""
        <h2>Bookings on Your Properties</h2>
        <table class="table table-striped table-bordered align-middle">
            <thead>
                <tr>
                    <th>Booking ID</th><th>Date</th><th>Property ID</th>
                    <th>Address</th><th>Price</th><th>Renter Email</th>
                </tr>
            </thead>
            <tbody>
                {body if body else '<tr><td colspan="6" class="text-muted">No bookings yet.</td></tr>'}
            </tbody>
        </table>
        <a href="/agent_dashboard" class="btn btn-outline-secondary btn-sm mt-2">Back to Agent Dashboard</a>
    """)

# ===========================================================
# RENTER: SEARCH
# ===========================================================
@app.route("/search", methods=["GET"])
def search():
    if session.get("role") != "renter":
        return redirect("/login_renter")

    city = request.args.get("city") or ""
    min_price = request.args.get("min_price") or ""
    max_price = request.args.get("max_price") or ""
    category = request.args.get("category") or ""
    rooms = request.args.get("rooms") or ""
    sort_by = request.args.get("sort_by") or "price"

    conditions = []
    params = []

    if city:
        conditions.append("LOWER(a.city) = LOWER(%s)")
        params.append(city)
    if min_price:
        conditions.append("p.price >= %s")
        params.append(min_price)
    if max_price:
        conditions.append("p.price <= %s")
        params.append(max_price)
    if category:
        conditions.append("pc.category_name = %s")
        params.append(category)
    if rooms:
        conditions.append("pd.rooms = %s")
        params.append(rooms)

    where_clause = "WHERE 1=1"
    if conditions:
        where_clause += " AND " + " AND ".join(conditions)

    order_clause = "ORDER BY p.price"
    if sort_by == "rooms":
        order_clause = "ORDER BY pd.rooms"
    elif sort_by == "city":
        order_clause = "ORDER BY a.city"

    sql = f"""
        SELECT p.prop_id, a.line_1, a.city, a.state_,
               p.price, pd.rooms, pc.category_name
        FROM PROPERTY p
        JOIN ADDRESS a ON p.address_id = a.address_id
        JOIN PROPERTY_DETAILS pd ON p.prop_id = pd.prop_id
        JOIN PROPERTY_CATEGORY pc ON pd.property_category_id = pc.property_category_id
        {where_clause}
        {order_clause};
    """

    rows = run_query(sql, tuple(params), fetch=True)

    body = ""
    for row in rows:
        pid, line1, ccity, sstate, price, rrooms, cat = row
        body += f"""
        <tr>
            <td>{pid}</td>
            <td>{line1}, {ccity}, {sstate}</td>
            <td>{cat}</td>
            <td>{rrooms if rrooms is not None else '-'}</td>
            <td>${price}</td>
            <td><a href="/book/{pid}" class="btn btn-sm btn-primary">Book</a></td>
        </tr>
        """

    cats = run_query("SELECT category_name FROM PROPERTY_CATEGORY ORDER BY category_name;", fetch=True)
    cat_options = '<option value="">Any</option>' + "".join(
        [f'<option value="{c[0]}" {"selected" if c[0]==category else ""}>{c[0]}</option>' for c in cats]
    )

    return render_page(f"""
        <h2>Search Properties</h2>
        <form method="get" class="row g-3 mb-3">
            <div class="col-md-3">
                <label class="form-label">City</label>
                <input type="text" name="city" value="{city}" class="form-control">
            </div>
            <div class="col-md-3">
                <label class="form-label">Min Price</label>
                <input type="number" step="0.01" name="min_price" value="{min_price}" class="form-control">
            </div>
            <div class="col-md-3">
                <label class="form-label">Max Price</label>
                <input type="number" step="0.01" name="max_price" value="{max_price}" class="form-control">
            </div>
            <div class="col-md-3">
                <label class="form-label">Category</label>
                <select name="category" class="form-select">
                    {cat_options}
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label">Rooms</label>
                <input type="number" name="rooms" value="{rooms}" class="form-control">
            </div>
            <div class="col-md-3">
                <label class="form-label">Sort by</label>
                <select name="sort_by" class="form-select">
                    <option value="price" {"selected" if sort_by=="price" else ""}>Price</option>
                    <option value="rooms" {"selected" if sort_by=="rooms" else ""}>Rooms</option>
                    <option value="city" {"selected" if sort_by=="city" else ""}>City</option>
                </select>
            </div>
            <div class="col-md-3 d-flex align-items-end">
                <button type="submit" class="btn btn-primary">Search</button>
            </div>
        </form>
        <table class="table table-striped table-bordered align-middle">
            <thead>
                <tr>
                    <th>ID</th><th>Address</th><th>Type</th><th>Rooms</th><th>Price</th><th>Action</th>
                </tr>
            </thead>
            <tbody>
                {body if body else '<tr><td colspan="6" class="text-muted">No properties found.</td></tr>'}
            </tbody>
        </table>
        <a href="/renter_dashboard" class="btn btn-outline-secondary btn-sm mt-2">Back to Renter Dashboard</a>
    """)

# ===========================================================
# RENTER: MY CARDS
# ===========================================================
@app.route("/my_cards", methods=["GET", "POST"])
def my_cards():
    if session.get("role") != "renter":
        return redirect("/login_renter")

    renter_id = session["renter_id"]

    if request.method == "POST":
        card_no = request.form.get("card_no").strip()
        name_on_card = request.form.get("name_on_card").strip()
        billing_line1 = request.form.get("billing_line1").strip()
        billing_city = request.form.get("billing_city").strip()
        billing_state = request.form.get("billing_state").strip()
        billing_zip = request.form.get("billing_zip").strip() or None

        run_query(
            '''
            INSERT INTO ADDRESS (line_1, city, state_, zip_code)
            VALUES (%s, %s, %s, %s);
            ''',
            (billing_line1, billing_city, billing_state, billing_zip),
            fetch=False
        )
        addr_row = run_query(
            '''
            SELECT address_id FROM ADDRESS
            WHERE line_1 = %s AND city = %s AND state_ = %s
            ORDER BY address_id DESC LIMIT 1;
            ''',
            (billing_line1, billing_city, billing_state),
            fetch=True
        )
        billing_addr_id = addr_row[0][0]

        run_query(
            '''
            INSERT INTO CARD_DETAILS (renter_id, Card_no, billing_address_id, Name_on_card)
            VALUES (%s, %s, %s, %s);
            ''',
            (renter_id, card_no, billing_addr_id, name_on_card),
            fetch=False
        )

    cards = run_query("""
        SELECT c.card_id, c.card_no, c.name_on_card,
               a.line_1, a.city, a.state_
        FROM CARD_DETAILS c
        JOIN ADDRESS a ON c.billing_address_id = a.address_id
        WHERE c.renter_id = %s
        ORDER BY c.card_id;
    """, (renter_id,), fetch=True)

    rows_html = ""
    for card in cards:
        cid, cno, cname, line1, city, state_ = card
        rows_html += f"""
        <tr>
            <td>{cid}</td>
            <td>{cno}</td>
            <td>{cname}</td>
            <td>{line1}, {city}, {state_}</td>
            <td>
                <form method="post" action="/delete_card/{cid}" style="display:inline;">
                    <button type="submit" class="btn btn-sm btn-outline-danger">Delete</button>
                </form>
            </td>
        </tr>
        """

    return render_page(f"""
        <h2>My Cards</h2>
        <div class="row g-3">
          <div class="col-md-6">
            <h5>Add New Card</h5>
            <form method="post">
                <label class="form-label">Card Number</label>
                <input type="text" name="card_no" class="form-control" required>
                <label class="form-label mt-2">Name on Card</label>
                <input type="text" name="name_on_card" class="form-control" required>
                <label class="form-label mt-2">Billing Address Line 1</label>
                <input type="text" name="billing_line1" class="form-control" required>
                <div class="row mt-2">
                    <div class="col-md-4">
                        <label class="form-label">City</label>
                        <input type="text" name="billing_city" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">State</label>
                        <input type="text" name="billing_state" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Zip</label>
                        <input type="text" name="billing_zip" class="form-control">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary mt-3">Add Card</button>
            </form>
          </div>
          <div class="col-md-6">
            <h5>Saved Cards</h5>
            <table class="table table-striped table-bordered align-middle">
                <thead>
                    <tr>
                        <th>ID</th><th>Card No</th><th>Name</th><th>Billing Address</th><th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    {rows_html if rows_html else '<tr><td colspan="5" class="text-muted">No cards yet.</td></tr>'}
                </tbody>
            </table>
          </div>
        </div>
        <a href="/renter_dashboard" class="btn btn-outline-secondary btn-sm mt-2">Back to Renter Dashboard</a>
    """)

@app.route("/delete_card/<int:card_id>", methods=["POST"])
def delete_card(card_id):
    if session.get("role") != "renter":
        return redirect("/login_renter")

    used = run_query(
        "SELECT 1 FROM BOOKING WHERE card_id = %s LIMIT 1;",
        (card_id,), fetch=True
    )
    if used:
        return render_page("""
            <h2>Delete Card</h2>
            <div class="alert alert-danger">
                Cannot delete a card that has bookings associated with it.
            </div>
            <a href="/my_cards" class="btn btn-outline-secondary btn-sm">Back to My Cards</a>
        """)

    run_query(
        "DELETE FROM CARD_DETAILS WHERE card_id = %s AND renter_id = %s;",
        (card_id, session["renter_id"]),
        fetch=False
    )
    return redirect("/my_cards")

# ===========================================================
# RENTER: BOOK PROPERTY
# ===========================================================
@app.route("/book/<int:prop_id>", methods=["GET", "POST"])
def book_property(prop_id):
    if session.get("role") != "renter":
        return redirect("/login_renter")

    renter_id = session["renter_id"]

    prop_rows = run_query("""
        SELECT p.prop_id, a.line_1, a.city, a.state_,
               p.price, pd.rooms, pc.category_name
        FROM PROPERTY p
        JOIN ADDRESS a ON p.address_id = a.address_id
        JOIN PROPERTY_DETAILS pd ON p.prop_id = pd.prop_id
        JOIN PROPERTY_CATEGORY pc ON pd.property_category_id = pc.property_category_id
        WHERE p.prop_id = %s;
    """, (prop_id,), fetch=True)
    if not prop_rows:
        return "Property not found", 404

    pid, line1, city, state_, price, rooms, cat = prop_rows[0]

    cards = run_query("""
        SELECT card_id, card_no, name_on_card
        FROM CARD_DETAILS
        WHERE renter_id = %s
        ORDER BY card_id;
    """, (renter_id,), fetch=True)

    if request.method == "POST":
        card_id = request.form.get("card_id")
        booking_date = request.form.get("booking_date") or None

        run_query(
            '''
            INSERT INTO BOOKING (prop_id, renter_id, card_id, booking_date)
            VALUES (%s, %s, %s, %s);
            ''',
            (prop_id, renter_id, card_id, booking_date),
            fetch=False
        )

        b_row = run_query(
            '''
            SELECT booking_id FROM BOOKING
            WHERE prop_id = %s AND renter_id = %s
            ORDER BY booking_id DESC LIMIT 1;
            ''',
            (prop_id, renter_id),
            fetch=True
        )
        booking_id = b_row[0][0]

        points = int(price) if price is not None else 0
        run_query(
            '''
            INSERT INTO REWARD (booking_id, renter_id, Points)
            VALUES (%s, %s, %s);
            ''',
            (booking_id, renter_id, points),
            fetch=False
        )

        return redirect("/my_bookings")

    if not cards:
        add_card_message = "<div class='alert alert-warning'>You have no saved cards. Add one first under 'My Cards'.</div>"
        card_options = ""
        disabled_attr = "disabled"
    else:
        add_card_message = ""
        card_options = "".join(
            [f'<option value="{c[0]}">{c[1]} ({c[2]})</option>' for c in cards]
        )
        disabled_attr = ""

    return render_page(f"""
        <h2>Book Property #{pid}</h2>
        <div class="mb-3">
            <p>
                <strong>{cat}</strong><br>
                {line1}, {city}, {state_}<br>
                Rooms: {rooms if rooms is not None else '-'}<br>
                Price: ${price}
            </p>
        </div>
        {add_card_message}
        <form method="post">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Booking date (YYYY-MM-DD)</label>
                    <input type="text" name="booking_date" class="form-control">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Payment card</label>
                    <select name="card_id" class="form-select" required {disabled_attr}>
                        {card_options}
                    </select>
                </div>
            </div>
            <button type="submit" class="btn btn-primary mt-3" {disabled_attr}>Confirm Booking</button>
        </form>
        <a href="/search" class="btn btn-outline-secondary btn-sm mt-3">Back to Search</a>
    """)

# ===========================================================
# RENTER: MY BOOKINGS
# ===========================================================
@app.route("/my_bookings")
def my_bookings():
    if session.get("role") != "renter":
        return redirect("/login_renter")

    renter_id = session["renter_id"]

    rows = run_query("""
        SELECT b.booking_id, b.booking_date,
               p.prop_id, a.line_1, a.city, p.price,
               COALESCE(rw.points, 0)
        FROM BOOKING b
        JOIN PROPERTY p ON b.prop_id = p.prop_id
        JOIN ADDRESS a ON p.address_id = a.address_id
        LEFT JOIN REWARD rw ON b.booking_id = rw.booking_id
        WHERE b.renter_id = %s
        ORDER BY b.booking_id DESC;
    """, (renter_id,), fetch=True)

    body = ""
    for row in rows:
        bid, bdate, pid, line1, city, price, points = row
        body += f"""
        <tr>
            <td>{bid}</td>
            <td>{bdate}</td>
            <td>{pid}</td>
            <td>{line1}, {city}</td>
            <td>${price}</td>
            <td>{points}</td>
            <td>
                <form method="post" action="/cancel_booking/{bid}" style="display:inline;">
                    <button type="submit" class="btn btn-sm btn-outline-danger">Cancel</button>
                </form>
            </td>
        </tr>
        """

    return render_page(f"""
        <h2>My Bookings</h2>
        <table class="table table-striped table-bordered align-middle">
            <thead>
                <tr>
                    <th>Booking ID</th><th>Date</th><th>Property ID</th>
                    <th>Address</th><th>Price</th><th>Reward Points</th><th>Action</th>
                </tr>
            </thead>
            <tbody>
                {body if body else '<tr><td colspan="7" class="text-muted">No bookings yet.</td></tr>'}
            </tbody>
        </table>
        <a href="/renter_dashboard" class="btn btn-outline-secondary btn-sm mt-2">Back to Renter Dashboard</a>
    """)

@app.route("/cancel_booking/<int:booking_id>", methods=["POST"])
def cancel_booking(booking_id):
    if session.get("role") != "renter":
        return redirect("/login_renter")

    run_query("DELETE FROM REWARD WHERE booking_id = %s;", (booking_id,), fetch=False)
    run_query(
        "DELETE FROM BOOKING WHERE booking_id = %s AND renter_id = %s;",
        (booking_id, session["renter_id"]),
        fetch=False
    )
    return redirect("/my_bookings")

# ===========================================================
# MAIN
# ===========================================================
if __name__ == "__main__":
    app.run(debug=True)