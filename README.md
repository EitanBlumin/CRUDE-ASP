# CRUDE-ASP

CRUDE:

- **C**reate
- **R**ead
- **U**pdate
- **D**elete
- **E**xecute

This project aims to implement an easy-to-use platform to create CRUDE websites using the most-available free technologies (bootstrap, fontawesome, angular, classic ASP...).
Using this project you can easily create "Data Views" which would serve as CRUD interfaces where you can manipulate data from a SQL Server database, and to also execute custom database commands (such as stored procedures).

Please see the Wiki for more info:
https://github.com/EitanBlumin/CRUDE-ASP/wiki

## Getting Started

These instructions will get you up and running on your local machine.

### Prerequisites

The following features will need to be installed using "Turn Windows features on or off":
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

You will need a Microsoft SQL Server database be installed.
If you don't have a license already, you can download the Developer edition for free here:
https://www.microsoft.com/en-us/sql-server/sql-server-downloads

### Installing

Copy the contents of the "build" folder to C:\inetpub\wwwroot\
If the "build" folder doesn't exist (and you only see the "src" folder), that means this project is still in initial development :)

Run this file to deploy the database dacpac: TBD

After that, you'll need to change the connection string in the configuration file (dist\asp\inc_config.asp)
And you're good to go!

## Built With

* [Visual Studio 2015](https://visualstudio.microsoft.com/vs/older-downloads/) - Used for both web and database development
* [AdminLTE 2.4.5](https://adminlte.io/) - Used free starter web template

## Authors

* **Eitan Blumin** - *Initial work* - [GitHub](https://github.com/EitanBlumin)

See also the list of [contributors](https://github.com/EitanBlumin/CRUDE-ASP/graphs/contributors) who participated in this project.

## License

This project is licensed under the Mozilla Public License 2.0 - see the [LICENSE.md](https://github.com/EitanBlumin/CRUDE-ASP/blob/master/LICENSE) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
