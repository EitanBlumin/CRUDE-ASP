# CRUDE-ASP

CRUDE:

- **C**reate
- **R**ead
- **U**pdate
- **D**elete
- **E**xecute

![](/docs/images/dataview_basic_toastr.png)

This project aims to implement an easy-to-use platform to create CRUD Application websites using the most-available free technologies (classic ASP, bootstrap, fontawesome, angular, etc.), plus "Execute" functionality to expand database capabilities.
Using this project you can easily create "Data Views" which would serve as CRUD interfaces where you can manipulate data from a SQL Server database, and to also execute custom database commands (such as stored procedures).

[Please see the Wiki for more info](https://github.com/EitanBlumin/CRUDE-ASP/wiki)

## Getting Started

These instructions will get you up and running on your local machine.

### Prerequisites

To install **Classic ASP** on your machine, the following features will need to be installed using "Turn Windows features on or off":
- Internet Information Services
  - Web Management Tools
    - IIS Management Console
    - IIS Management Scripts and Tools
    - IIS Management Service
  - World Wide Web Services
    - Application Development Features
      - ASP
 	  - ISAPI Extensions
 	  - ISAPI Filters
 	  - Server-Side Includes
    - Common HTTP Features (everything)

You will need a **Microsoft SQL Server** database to be installed.
If you don't have a license already, [you can download the Developer edition *for free* here](https://www.microsoft.com/en-us/sql-server/sql-server-downloads).

### Installing

This project is still in initial development, so there's nothing to install at the moment :)

But when there would be a first release, then it would be something like this:

1. Deploy the database using a dacpac file.
2. Copy the website folder to a subfolder in c:\inetpub\wwwroot
3. Update the connection string in the configuration file (dist\asp\inc_config.asp)
4. That's it! The site should be immediately operational and you should be able to start using it.

## Built With

* [Visual Studio 2015](https://visualstudio.microsoft.com/vs/older-downloads/) - Used for both web and database development
* [AdminLTE 2.4.5](https://adminlte.io/) - Free starter web template

## Authors

* **Eitan Blumin** - *Initial work* - [GitHub](https://github.com/EitanBlumin)

List of other [contributors](https://github.com/EitanBlumin/CRUDE-ASP/graphs/contributors) who participated in this project.

## License

This project is licensed under the Mozilla Public License 2.0 - see the [LICENSE.md](https://github.com/EitanBlumin/CRUDE-ASP/blob/master/LICENSE) file for details

## Acknowledgments

* Hat tip to anyone whose code was used, especially AdminLTE.
* Do you want to help by participating in the project? [Let me know via LinkedIn](https://www.linkedin.com/in/eitanblumin).
