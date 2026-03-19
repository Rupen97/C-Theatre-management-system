# Theatre Management System

Welcome to the Theatre Management System repository! This project is a robust, web-based application built using ASP.NET Web Forms (C#) to effectively manage cinema operations, ticketing, movies, and reporting.

## Features

* **Cinemas & Screens Management**: Add and manage different cinema locations.
* **Movies & Showtimes**: Schedule movie screenings and manage showtimes dynamically.
* **Booking & Ticketing System**: Handle ticket reservations and bookings for customers. Includes automated workers (`BookingCancellationWorker`) for handling booking expirations.
* **Seat Management**: Track and manage seat occupancy for specific showtimes.
* **Pricing Policies**: Manage global or specific pricing rules (e.g., Golden Hour Automations, discounts).
* **User Accounts**: Keep track of user data.
* **Reporting & Analytics**:
  * Occupancy Reports: Track how full the theaters are.
  * Theater Movie Reports: View analytics per movie and theater.
  * User Ticket Reports: View metrics for users.

## Technology Stack

* **Frontend**: ASP.NET Web Forms (`.aspx`), HTML, CSS (`index.css`)
* **Backend**: C# (`.aspx.cs`, `Global.asax.cs`)
* **Database**: SQL Server (managed via `DatabaseHelper.cs`)

## Setup Instructions

1. **Clone the repository**: Ensure you have downloaded the latest source code.
2. **Database Setup**: 
    - The repository includes basic schema definition files (`Schema.sql`) and dummy data for testing (`TestData.sql`). Use these scripts to initialize your SQL Server database.
3. **Configuration**: 
    - Verify your connection string and settings inside `Web.config`.
4. **Build & Run**:
    - Open the `Data and Web Coursework.sln` solution via Visual Studio.
    - Build the solution (`Ctrl+Shift+B`).
    - Click **Start Debugging** (`F5`) or **Start Without Debugging** (`Ctrl+F5`) to run the web application on IIS Express.

## Project Structure Highlights

- *`Site.Master`* - The main layout/template file maintaining structural consistency.
- *`DatabaseHelper`* - Central class for interacting with the SQL database securely.
- *`*Report.aspx`* - Set of interactive analytics pages for data extraction.

## Contribution

If you would like to contribute, please branch off `main` and submit a Pull Request upon completion. Ensure you test your changes carefully before pushing.

---

*Thank you for exploring the Theatre Management System!*
