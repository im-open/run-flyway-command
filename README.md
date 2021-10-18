# run-flyway-command

A GitHub Action that will run (Flyway)[https://flywaydb.org/] against a specified database. Flyway must be installed in order for this Action to work. The [setup-flyway](https://github.com/im-open/setup-flyway) Action can be used for that purpose.  
    

## Inputs
| Parameter                 | Is Required | Default | Description                                                                                                                                         |
| ------------------------- | ----------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `db-server-name`          | true        | N/A     | The database server name.                                                                                                                           |
| `db-server-port`          | false       | 1433    | The port the database server listens on.                                                                                                            |
| `db-name`                 | true        | N/A     | The name of the database to run flyway against.                                                                                                     |
| `migration-files-path`    | true        | N/A     | The path to the base directory containing the migration files to have flyway process.                                                               |
| `flyway-command`          | true        | N/A     | The flyway command to run; e.g `migrate`, `validate`, etc.                                                                                          |
| `migration-history-table` | true        | N/A     | The table where the migration history lives. This is most likely dbo.MigrationHistory or Flyway.MigrationHistory.                                   |
| `baseline-version`        | true        | 0       | The baseline version to send to the flyway command.                                                                                                 |
| `managed-schemas`         | true        | N/A     | A comma separated list of schemas that are to be managed by Flyway.MigrationHistory.                                                                |
| `enable-out-of-order`     | true        | false   | A switch that allows new migrations that are a lower version number than a current migration to be run.                                             |
| `use-integrated-security` | true        | true    | A switch defining whether or not to use integrated security. If not provided, a password should be.                                                 |
| `username`                | true        | N/A     | The username of the user making the changes, which is put into the MigrationHistory table, and also to login with if not using integrated security. |
| `password`                | false       | N/A     | The password for the user making changes if not using integrated security.                                                                          |
| `extra-parameters`        | false       | N/A     | A string containing anything extra that should be added to the flyway command.                                                                      |

## Example

```yml
jobs:
  migrate-database:
    runs-on: [self-hosted, windows-2019]
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Setup Flyway
        uses: actions/setup-flyway@v1
        with:
          version: 5.1.4

      - name: Run Flyway Migrations
        uses: im-open/run-flyway-command@v1.2.0
        with:
          db-server-name: 'localhost'
          db-server-port: '1433'
          db-name: 'LocalDb'
          migration-files-path: './src/Database/Migrations'
          flyway-command: 'migrate'
          migration-history-table: 'dbo.MigrationHistory'
          baseline-version: '0'
          managed-schemas: 'dbo,MyCustomSchema'
          enable-out-of-order: 'true'
          use-integrated-security: 'false'
          username: 'database-user'
          password: '${{ secrets.DbUserPassword }}'
```


## Code of Conduct

This project has adopted the [im-open's Code of Conduct](https://github.com/im-open/.github/blob/master/CODE_OF_CONDUCT.md).

## License

Copyright &copy; 2021, Extend Health, LLC. Code released under the [MIT license](LICENSE).
