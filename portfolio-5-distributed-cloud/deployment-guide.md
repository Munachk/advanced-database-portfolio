# Deployment Evidence — Cloud MySQL

This gets you a real, running cloud database instance to screenshot —
actual "deployment evidence" rather than just discussion.

## Aiven for MySQL (recommended — genuinely free, no card)

As of 2026, Aiven's free MySQL tier requires no credit card and has no
time limit (1 CPU, 1GB RAM, 1GB disk — plenty for this portfolio).

1. Go to [aiven.io](https://aiven.io) and sign up (no card required for
   the free tier).
2. Create a new service(Free trial) → choose **MySQL**.
3. Select the **free plan** tier when offered.
4. Pick any cloud region (pick one close to Nigeria if available, e.g. an
   EU region).
5. Wait a few minutes for the service to provision (status goes from
   "Rebuilding" to "Running").
6. Click into the service → **Overview** tab → copy the connection
   details (host, port, user, password, database name).

### Connect and deploy your schema

Using the MySQL CLI, or MySQL Workbench, or even phpMyAdmin configured to
point at a remote host:

```bash
mysql --host=<your-aiven-host> --port=<port> --user=avnadmin --password=<your-password> --database=defaultdb < schema_mysql.sql
mysql --host=<your-aiven-host> --port=<port> --user=avnadmin --password=<your-password> --database=defaultdb < seed_mysql_large.sql
```

If you don't want to install the MySQL CLI, Aiven's web console includes
a basic query editor — you can paste `schema_mysql.sql` and
`seed_mysql_large.sql` directly into it instead. 

But for this I'm going to be using my local CMD, I'll create multiple php files to connect, 
import my schema and also import my seed data.

Created an `index.php` file which put all the connection string (host, username, password, database) and also 
a path to the certificate `ca.pem` downloaded from the connection info of my DB. Then run the `index.php` file on my cmd- screenshot in checklist.

Created an `index2.php` with same connecting string and sql queries to import my `schema_mqsql.sql` and `seed_mysql_large.sql`.

Created an `index3.php` with same connecting string and sql queries to select count of employee in the database.

### Screenshot checklist

- [ ] Aiven dashboard showing your MySQL service status as "Running," with
      its region/cloud provider visible - `status-running.png`

- [ ] The service's "Overview" tab showing connection info.  -   `connection.png`

- [ ] The database connected to successfully from my local CMD.  -   `connected.png` 

- [ ] Succesfully imported my schema and seed sql  -   `import.png` 

- [ ] A successful `SELECT COUNT(*) FROM employee;` run against the cloud
      instance, returning 120 - `employee-count.png`


