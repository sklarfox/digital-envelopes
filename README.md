## Digital envelopes

Digital Envelopes is a small app for budgeting, mimicking the 'envelope' method of personal finance management.

#### Development Specs

Ruby version 3.2.2

Tested using Safari Version 16.5.1

RDBMS: postgreSQL Version 14.8

#### Installation

1. Unzip budget.zip to the directory of your choosing
2. Run the command `$ bundle install` from the project directory to ensure all required gems are installed and updated to a compatible version
3. Ensure a compatible version of postgreSQL is installed (recommended 14.8 or higher)
4. Run the command `$ createdb budget` from the terminal to create the required postgres database.
5. Import **one** of two files into the database:
   1. `schema_empty.sql` will create the minimum required schema, but otherwise leave the budget empty. Execute `$ psql -d budget < schema_empty.sql`
   2.  `schema_populated.sql` will create the schema and populate the budget with some test data. Execute `$ psql -d budget < schema_populated.sql`

6. Run `ruby budget.rb` to start the web server.
7. Navigate to `localhost:4567` (or whatever port your application is listening on) from a web browser to access the app.

#### A bit on the 'Envelope' system of personal finance

This app is meant to create a digital version of the envelope system. In the physical world, a budgeter would use real envelopes, and label each envelope with an expense category. This could be rent, groceries, insurance, fun money, or anything else. Then, anytime they are paid income, they would allocate their cash into those envelopes. Then, when a purchase or expense happens, it would be paid from the appropriate envelope.

The key focus of this method is to prevent overspending for any given category; if the cash hasn't been allocated for a purchase, then the envelope is empty. To complete the purchase, then money would need to either be pulled from another category, or not completed after all. This allows the budgeter to be mindful and have greater awareness around spending.

#### Usage

The app requires the user to be logged in to access any part of the app. Once logged in, the user will remain logged in until the `Sign Out` button is pressed.

- **Credentials**: *username*: `password` 

  ​        			  *password*: `password`

1. The **budget** page
   - The main budget page is where you have an overview of your entire budget. 
   - At the top of the page, the amount of money awaiting **'To Be Assigned'** to a category is shown. This is the difference between all inflow transactions and the total amount assigned to each category. This assignment can be thought of as placing cash into an envelope.
   - **<u>The main goal of this app</u>** is to keep the **'To Be Assigned'** amount at 0. If this number is positive, that means there is money unassigned and needs to be placed into a category. If this number is negative, that means that the user has assigned more money than they really have. While this is allowed by the app, it is intended only to allow the user to temporarily over-assign money while moving money between categories. Ultimately categories need to be reassigned until **'To Be Assigned'** is zero.
   - To assign money to a category, enter an amount into the appropriate box and press the **Reassign** button.
   - In the main part of the page, you can see all of your categories, how much money you have assigned to each category, and how much you have remaining to spend from that category. **Assigned** is how much cash you originally placed into the 'envelope'. **Remaining** is how much money is still in the 'envelope', ready to be spent.
   - Below categories is a view of all **accounts**. The current balance of each is also shown.
2. Adding a new account, category, or transaction
   - Click the link at the bottom of the **budget** page
3. Viewing all transactions for an account or category
   - Click on the name of the category or account to be taken to a page which shows the transactions for that category/account
4. Editing an account or category
   - An account or category can both be edited by clicking on the name at the top of the individual account or category page
5. Deleting an account or category
   - An account of category can be deleted by pressing the 'Delete' button at the bottom of the individual account or category page
6. Editing a transaction
   - Press the edit button next to the transaction from either the account or category page
7. Deleting a transaction
   - Press the delete transaction button from the 'Edit Transaction' page

### Additional notes

One major feature that this budget technique would need for real-world use is supporting calendar months. With the current implementation, a category's **'Assigned'** value actually represents the *total sum* of all money assigned to that category for the entirety of the budget. This means that over time, this numbers would keep growing and not necessarily represent the user's current budgetary needs. (For example, with the test data, 'rent' was assigned $1000 and $1000 was spent on the first of the month. The following month, the Assigned amount would need to be 2000, as it technically needs to account for both month's rent payment.)

Ideally, each budget category and its assigned/remaining values would reset each month, so that the numbers a user is working with are relevant to the current month.

However, this is a feature that was assumed to be beyond the scope of this project, and is not implemented for the sake of simplicity. The app in its current state should meet all listed project requirements.